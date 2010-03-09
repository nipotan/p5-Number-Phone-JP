#!/usr/local/bin/perl

use strict;
use warnings;
use Encode;
use FindBin;
use LWP::Simple;
use Regexp::Assemble::Compressed;
use HTML::TableParser::Grid;
use Spreadsheet::ParseExcel;
use File::Basename;
use Getopt::Long;

our $DEBUG;
our $UPDATED;
our $VERSION;
our $STOREDIR;
our $TABLEDIR;
our $TESTDIR ;

GetOptions(
    'date=s' => sub { updated_on(\$UPDATED, @_) },
    verbose  => \$DEBUG,
) or die <DATA>;

$DEBUG    = defined $ENV{DEBUG} ? $ENV{DEBUG} : $DEBUG;
$UPDATED  = defined $UPDATED ? $UPDATED : today();
$VERSION  = "0." . do { (my $ymd = $UPDATED) =~ s/-//g; $ymd };
$STOREDIR = "$FindBin::Bin/share";
$TABLEDIR = "$FindBin::Bin/lib/Number/Phone/JP/Table";
$TESTDIR  = "$FindBin::Bin/t";

main();

sub main {
    my %task_map = (
        Class1  => +{ function => 'class' },
        Class2  => +{ skip => 1 },
        Phs     => +{
            function    => 'fixed_pref',
            prefix      => '070',
            test_suffix => '12345',
        },
        Pager   => +{
            function    => 'fixed_pref',
            prefix      => '020',
            test_suffix => '12345',
        },
        Q2      => +{
            function    => 'fixed_pref',
            filename    => 'jyoho_number.htm',
            prefix      => '0990',
            test_suffix      => '123',
        },
        Fmc     => +{
            function    => 'fixed_pref',
            prefix      => '060',
            test_suffix => '1234',
        },
        Upt     => +{ function    => 'upt' },
        United  => +{
            function    => 'fixed_pref',
            filename    => 'toitu_number.htm',
            prefix      => '0570',
            test_suffix => '123',
        },
        Ipphone => +{
            function    => 'fixed_pref',
            filename    => 'ip_number.htm',
            prefix      => '050',
            test_suffix => '1234',
        },
    );

    opendir my $dh, $TABLEDIR or die "$TABLEDIR: $!";
    for my $file (readdir $dh) {
        next unless $file =~ /^(\w+)\.pm$/;
        my $class = $1;
        no strict 'refs';
        if (my $param = $task_map{$class}) {
            next if $param->{skip};
            my $func = delete $param->{function};
            _warn("calling $func()");
            $func->($class, $param);
        }
        else {
            my $func = lc($class);
            _warn("calling $func()");
            $func->($class);
        }
    }
}

sub fixed_pref {
    my($class, $param) = @_;
    my $lc_class = lc($class);
    my $filename = "$TABLEDIR/$class.pm";
    my $file = $param->{filename} || "$lc_class.htm";
    _warn($file);
    $file = "$STOREDIR/$file";
    my $res = http_get_file($file);
    unless ($res == 200) {
        _warn("fail to get new file: $file ($res)");
        return;
    }
    my $prefix = $param->{prefix};
    my($rows, $cols, $column_values) = table_parse($file, $prefix);

    open my $fh, '>', $filename or die "$filename: $!";
    print $fh table_class_header($class);

    my @ok = ();
    my @ng = ();
    my $test_suffix   = $param->{test_suffix};
    my $regexp_suffix = '\d{' . length($test_suffix) . '}';

    my $re = Regexp::Assemble::Compressed->new;
    for my $row (sort { $a <=> $b } keys %$rows) {
        for my $col (sort { $a <=> $b } keys %$cols) {
            my $number = sprintf '%s%s', $rows->{$row}, $cols->{$col};
            _warn($number . ("x" x (length $test_suffix)));
            my $value = $column_values->{$row}{$col};
            $number =~ s/^$prefix//;
            if (!defined $value || $value =~ /^(\s|-)*$/) {
                push @ng, "$prefix ${number}${test_suffix}";
                next;
            }
            else {
                push @ok, "$prefix ${number}${test_suffix}";
            }
            $re->add($number . $regexp_suffix);
        }
    }

    (my $table_prefix = $param->{prefix}) =~ s/^0//;
    (my $regexp = $re->re) =~ s/^\(\?-xism:/(?:/;
    printf $fh "    $table_prefix => '%s',\n", compress($regexp);
    printf $fh table_class_footer();
    close $fh;

    make_test($lc_class, \@ok, \@ng);
}

sub home {
    my $class = shift;
    my $lc_class = lc($class);
    my $filename = "$TABLEDIR/$class.pm";
    my %table = ();
    my @ok = ();
    my @ng = ();
    my $modified;

    for my $num (1 .. 9) {
        my $file = sprintf 'fixed_%d.xls', $num;
        _warn($file);
        $file = "$STOREDIR/$file";
        my $res = http_get_file($file);
        unless ($res == 200) {
            _warn("fail to get new file: $file ($res)");
            next;
        }
        $modified = 1;
        my $excel = Spreadsheet::ParseExcel::Workbook->Parse($file);
        my $sheet = shift @{$excel->{Worksheet}};
        $sheet->{MaxRow} ||= $sheet->{MinRow};
        for my $row ($sheet->{MinRow} .. $sheet->{MaxRow}) {
            my $pref = $sheet->{Cells}[$row][3]->{Val};
            next unless defined $pref && $pref =~ s/^0//;
            my $local_pref = $sheet->{Cells}[$row][4]->{Val};
            my $status = encode('utf-8', $sheet->{Cells}[$row][6]->Value);
            unless ($status =~ /(?:使用中|使用予定)/) {
                push @ng, sprintf '0%s %s1234', $pref, $local_pref;
                next;
            }
            push @ok, sprintf '0%s %s1234', $pref, $local_pref;
            unless (exists $table{$pref}) {
                $table{$pref} = Regexp::Assemble::Compressed->new;
            }
            $table{$pref}->add("$local_pref\\d{4}");
            _warn(sprintf "%s-%s: %s", $pref, $local_pref, $status);
        }
    }
    return unless $modified;

    open my $fh, '>', $filename or die "$filename: $!";
    print $fh table_class_header($class);
    for my $pref (sort { $a cmp $b } keys %table) {
        (my $re = $table{$pref}->re) =~ s/^\(\?-xism:/(?:/;
        printf $fh "    %-4d => '%s',\n", $pref, compress($re);
    }
    print $fh table_class_footer();
    close $fh;

    make_test($lc_class, \@ok, \@ng);
}

sub class {
    my $file = 'company1.htm';
    _warn($file);
    $file = "$STOREDIR/$file";
    my $res = http_get_file($file);
    unless ($res == 200) {
        _warn("fail to get new file: $file ($res)");
        return;
    }
    my $prefix = qr<00(?:[3-8]|2\d|91\d)?$>;
    my($rows, $cols, $column_values) = table_parse($file, $prefix);

    # formerly, the numbers that's prefixed by "009" are called class2.
    # it's left for backward compatibility.
    my @class1_rows = ();
    my @class2_rows = ();
    no warnings 'uninitialized';
    for my $row (sort { $a <=> $b } %$rows) {
        if ($rows->{$row} =~ /^009/) {
            push @class2_rows, $row;
        }
        else {
            push @class1_rows, $row;
        }
    }

    my @ok = ();
    my @ng = ();
    my $class1_file = "$TABLEDIR/Class1.pm";
    my $class1_test = "$TESTDIR/class1.t";

    no warnings 'uninitialized';
    open my $fh, '>', $class1_file or die "$class1_file: $!";
    print $fh table_class_header('Class1');
    for my $row (@class1_rows) {
        for my $col (sort { $a <=> $b } keys %$cols) {
            next unless $rows->{$row};
            my $prefix = sprintf '%s%s', $rows->{$row}, $cols->{$col};
            _warn("${prefix}xxxxxxxx");
            my $value = $column_values->{$row}{$col};
            if ($value =~ /^(\s|-)*$/) {
                push @ng, "$prefix 12345678";
                next;
            }
            else {
                push @ok, "$prefix 12345678";
            }
            $prefix =~ s/^0//;
            printf $fh
                "    %-7s => '%s', # %s\n", "'" . $prefix . "'", '\d+', $value;
        }
    }
    print $fh table_class_footer();
    close $fh;

    make_test('class1', \@ok, \@ng);

    @ok = ();
    @ng = ();
    my $class2_file = "$TABLEDIR/Class2.pm";
    my $class2_test = "$TESTDIR/class2.t";

    open $fh, '>', $class2_file or die "$class2_file: $!";
    print $fh table_class_header('Class2');
    for my $row (@class2_rows) {
        for my $col (sort { $a <=> $b } keys %$cols) {
            my $prefix = sprintf '%s%s', $rows->{$row}, $cols->{$col};
            _warn("${prefix}xxxxxxxx");
            my $value = $column_values->{$row}{$col};
            if ($value =~ /^(\s|-)*$/) {
                push @ng, "$prefix 12345678";
                next;
            }
            else {
                push @ok, "$prefix 12345678";
            }
            $prefix =~ s/^0//;
            printf $fh
                "    %-8s => '%s', # %s\n", "'" . $prefix . "'", '\d+', $value;
        }
    }
    print $fh table_class_footer();
    close $fh;

    make_test('class2', \@ok, \@ng);
}

sub mobile {
    my $filename = "$TABLEDIR/Mobile.pm";
    my $file = 'mobile80.htm';
    _warn($file);
    $file = "$STOREDIR/$file";
    my $res = http_get_file($file);
    unless ($res == 200) {
        _warn("fail to get new file: $file ($res)");
        return;
    }

    my $rows = {};
    my $cols = {};
    my $column_values = {};

    ($rows, $cols, $column_values) = table_parse($file, '080');

    open my $fh, '>', $filename or die "$filename: $!";
    print $fh table_class_header('Mobile');

    my @ok = ();
    my @ng = ();
    my $re = Regexp::Assemble::Compressed->new;
    for my $row (sort { $a <=> $b } keys %$rows) {
        for my $col (sort { $a <=> $b } keys %$cols) {
            my $number = sprintf '%s%s', $rows->{$row}, $cols->{$col};
            _warn("${number}xxxxx");
            my $value = $column_values->{$row}{$col};
            $number =~ s/^080//;
            if (!defined $value || $value =~ /^(\s|-)*$/) {
                push @ng, "080 ${number}12345";
                next;
            }
            else {
                push @ok, "080 ${number}12345";
            }
            $re->add($number . '\d{5}');
        }
    }
    (my $regexp = $re->re) =~ s/^\(\?-xism:/(?:/;
    printf $fh "    80 => '%s',\n", compress($regexp);

    $file = 'mobile90.htm';
    _warn($file);
    $file = "$STOREDIR/$file";
    $res = http_get_file($file);
    unless ($res == 200) {
        _warn("fail to get new file: $file ($res)");
        return;
    }

    ($rows, $cols, $column_values) = table_parse($file, '090');

    $re = Regexp::Assemble::Compressed->new;
    for my $row (sort { $a <=> $b } keys %$rows) {
        for my $col (sort { $a <=> $b } keys %$cols) {
            my $number = sprintf '%s%s', $rows->{$row}, $cols->{$col};
            _warn("${number}xxxxx");
            my $value = $column_values->{$row}{$col};
            $number =~ s/^090//;
            if ($value =~ /^(\s|-)*$/) {
                push @ng, "090 ${number}12345";
                next;
            }
            else {
                push @ok, "090 ${number}12345";
            }
            $re->add($number . '\d{5}');
        }
    }
    ($regexp = $re->re) =~ s/^\(\?-xism:/(?:/;
    printf $fh "    90 => '%s',\n", compress($regexp);
    printf $fh table_class_footer();
    close $fh;

    make_test('mobile', \@ok, \@ng);
}

sub freedial {
    my $filename = "$TABLEDIR/Freedial.pm";
    my $file = 'mobile0120.htm';
    _warn($file);
    $file = "$STOREDIR/$file";
    my $res = http_get_file($file);
    unless ($res == 200) {
        _warn("fail to get new file: $file ($res)");
        return;
    }

    my $rows = {};
    my $cols = {};
    my $column_values = {};

    open my $in, $file or die "$file: $!";
    my $html = do { local $/; <$in> };
    close $in;

    ($rows, $cols, $column_values) = table_parse($file, '0120');

    open my $fh, '>', $filename or die "$filename: $!";
    print $fh table_class_header('Freedial');

    my @ok = ();
    my @ng = ();
    my $re = Regexp::Assemble::Compressed->new;
    for my $row (sort { $a <=> $b } keys %$rows) {
        for my $col (sort { $a <=> $b } keys %$cols) {
            my $number = sprintf '%s%s', $rows->{$row}, $cols->{$col};
            _warn("${number}xxx");
            my $value = $column_values->{$row}{$col};
            $number =~ s/^0120//;
            if ($value =~ /^(\s|-)*$/) {
                push @ng, "0120 ${number}123";
                next;
            }
            else {
                push @ok, "0120 ${number}123";
            }
            $re->add($number . '\d{3}');
        }
    }
    (my $regexp = $re->re) =~ s/^\(\?-xism:/(?:/;
    printf $fh "    120 => '%s',\n", compress($regexp);

    $file = 'mobile0800.htm';
    _warn($file);
    $file = "$STOREDIR/$file";
    $res = http_get_file($file);
    unless ($res == 200) {
        _warn("fail to get new file: $file ($res)");
        return;
    }
    ($rows, $cols, $column_values) = table_parse($file, '0800');

    $re = Regexp::Assemble::Compressed->new;
    for my $row (sort { $a <=> $b } keys %$rows) {
        for my $col (sort { $a <=> $b } keys %$cols) {
            my $number = sprintf '%s%s', $rows->{$row}, $cols->{$col};
            _warn("${number}xxxx");
            my $value = $column_values->{$row}{$col};
            $number =~ s/^0800//;
            if (!defined $value || $value =~ /^(\s|-)*$/) {
                push @ng, "0800 ${number}1234";
                next;
            }
            else {
                push @ok, "0800 ${number}1234";
            }
            $re->add($number . '\d{4}');
        }
    }
    ($regexp = $re->re) =~ s/^\(\?-xism:/(?:/;
    printf $fh "    800 => '%s',\n", compress($regexp);
    printf $fh table_class_footer();
    close $fh;

    make_test('freedial', \@ok, \@ng);
}

sub upt {
    my $filename = "$TABLEDIR/Upt.pm";
    open my $fh, '>', $filename or die "$filename: $!";
    printf $fh <<'END', $VERSION;
package Number::Phone::JP::Table::Upt;

use strict;
use warnings;
require Number::Phone::JP::Table::Fmc;

our $VERSION = '%s';

our %%TEL_TABLE = %%Number::Phone::JP::Table::Fmc::TEL_TABLE;

1;
__END__
END
    ;
    close $fh;
    make_test('upt', [], []);
}

sub table_parse {
    my($file, $prefix) = @_;
    open my $in, $file or die "$file: $!";
    my $html = do { local $/; <$in> };
    close $in;
    # HTML::TableParser::Grid does not support parsing <th> tag.
    $html =~ s{(</?)th(>)}{$1td$2}gi;

    my $parser = HTML::TableParser::Grid->new($html, 0);
    my %rows = ();
    my %cols = ();
    my %column_values = ();

    no warnings 'uninitialized';
    for my $row (0 .. $parser->num_rows) {
        my $read_header = 0;
        for my $col (0 .. $parser->num_columns) {
            my $value = convert_value($parser->cell($row, $col));
            $column_values{$row}{$col} = $value;
            if ($col == 0) {
                if ($value eq '番号') {
                    # probably, they're wrote on the table header
                    $read_header = 1;
                }
                elsif ($value =~ /^$prefix/) {
                    $rows{$row} = $value;
                }
            }
            elsif ($read_header) {
                if ($value =~ /^\d$/) {
                    $cols{$col} = $value;
                }
            }
        }
    }

    return(\%rows, \%cols, \%column_values);
}

sub http_get_file {
    my $file = shift;
    my $uri = basename($file);
    my $url =
        sprintf 'http://www.soumu.go.jp/johotsusintokei/tel_number/%s', $uri;
    return LWP::Simple::mirror($url, $file);
}

sub convert_value {
    my $value = shift;
    no warnings 'uninitialized';
    return unless length $value;
    $value = decode('shift_jis', $value);
    use utf8;
    $value =~ tr/０-９Ａ-Ｚａ-ｚ　！”＃＄％＆’（）＊＋，−．／：；＜＝＞？＠［¥］＾＿‘｛｜｝〜/0-9A-Za-z !"#$%&'()*+,-.\/:;<=>?@[\\]^_`{|}~/;
    return encode('utf-8', $value);
}

sub compress { # makes regexp more compressed
    my $regexp = shift;
    $regexp =~ s{((?:\\d(?!\{)){2,})}{
        my $len = length($1) / 2;
        sprintf("\\d{%d}", $len);
    }eg;
    $regexp =~ s{((?:\\d)*)((?:\\d\{\d+\})+)((?:\\d(?!\{))*)}{
        my($prefix, $match_times, $postfix) = ($1, $2, $3);
        my $total = 0;
        my @times = $match_times =~ m{\\d\{(\d+)\}}g;
        $total += $_ for @times;
        $total += length($prefix)  / 2 if $prefix;
        $total += length($postfix) / 2 if $postfix;
        sprintf("\\d{%d}", $total);
    }eg;
    return $regexp;
}


sub table_class_header {
    my $name = shift;
    my $desc_pref   = $name eq 'Home' ? 'Area-Pref'        : 'Pref';
    my $desc_regexp = $name eq 'Home' ? 'Local-Pref-Regex' : 'Assoc-Pref-Regex';
    return sprintf <<'END', $name, $VERSION, $UPDATED, $desc_pref, $desc_regexp;
package Number::Phone::JP::Table::%s;

use strict;
use warnings;

our $VERSION = '%s';

# Table last modified: %s
our %%TEL_TABLE = (
    # %s => q<%s>,
END
    ;
}

sub table_class_footer {
    return <<'END';
);

1;
__END__
END
    ;
}

sub make_test {
    my($name, $ok, $ng) = @_;
    my $testfile = "$TESTDIR/$name.t";
    open my $t, '>', $testfile or die "$testfile: $!";
    print $t "use strict;\n";
    printf $t
        "use Test::More tests => %d;\n\n", scalar(@$ok) + scalar(@$ng) + 1;
    print $t "use_ok('Number::Phone::JP', '$name');\n\n";
    print $t "my \$tel = Number::Phone::JP->new;\n";
    for my $test (@$ok) {
        printf $t test_ok($test);
    }
    for my $test (@$ng) {
        printf $t test_ng($test);
    }
    close $t;
}

sub test_ok {
    my $ok = shift;
    return sprintf "ok(\$tel->set_number('%s')->is_valid_number, " .
                   "'checking for %s');\n", $ok, $ok;
}

sub test_ng {
    my $ng = shift;
    return sprintf "ok(!\$tel->set_number('%s')->is_valid_number, " .
                   "'checking for %s');\n", $ng, $ng;
}

sub today {
    my $self = shift;
    my @lt = localtime();
    return sprintf '%d-%02d-%02d', $lt[5] + 1900, $lt[4] + 1, $lt[3];
}

sub _warn {
    return unless $DEBUG;
    warn(map { "$_\n" } @_);
}

sub updated_on {
    my($ref, $name, $value) = @_;
    unless ($value =~ /^\d{4}-\d\d-\d\d$/) {
        die qq{$name option is assumed to have the format "YYYY-MM-DD"\n};
    }
    $$ref = $value;
}

__DATA__
Usage: regexp-table-maker.pl [OPTION]...

options:
  -d, --date=YYYY-MM-DD    specifies the date of updated the tables.
                           it'll be used for $VERSION of each classes.

  -v, --verbose            verbose mode.
                           causes to print debugging messages about its
                           progress.
                           you can also turn on the feature using DEBUG
                           environment variable.

