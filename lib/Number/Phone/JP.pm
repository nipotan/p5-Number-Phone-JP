package Number::Phone::JP;

use strict;
use warnings;
use 5.008_001;
use Carp;
use UNIVERSAL::require;

our $VERSION = '0.20110901';
our %TEL_TABLE = ();

sub import {
    my $self = shift;
    %TEL_TABLE = ();
    if (@_) {
        for my $subclass (@_) {
            my $package =
                sprintf('%s::Table::%s', __PACKAGE__, ucfirst(lc($subclass)));
            $package->require or croak $@;
            {
                no strict 'refs';
                while (my($k, $v) = each %{"$package\::TEL_TABLE"}) {
                    $TEL_TABLE{$k} = $v;
                }
            }
        }
    }
    else {
        require Number::Phone::JP::Table;
        import  Number::Phone::JP::Table;
    }
    return $self;
}

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->set_number(@_) if @_;
    return $self;
}

sub set_number {
    my $self   = shift;
    my $number = shift;
    if (ref($number) eq 'ARRAY') {
        $self->_prefix = shift @$number;
        (my $num = join('', @$number)) =~ s/\D+//g;
        $self->_number = $num;
    }
    elsif (defined $_[0]) {
        $self->_prefix = $number;
        (my $num = join('', @_)) =~ s/\D+//g;
        $self->_number = $num;
    }
    elsif ($number =~ /^\D*(0\d+)\D(.+)$/) {
        my $pref = $1;
        my $num  =  $2;
        $pref =~ s/\D+//g;
        $num  =~ s/\D+//g;
        $self->_prefix = $pref;
        $self->_number = $num;
    }
    else {
        carp "The number is invalid telephone number.";
        $self->_prefix = ();
        $self->_number = ();
    }
    return $self;
}

sub is_valid_number {
    my $self = shift;
    unless ($self->_prefix || $self->_number) {
        carp "Any number was not set";
        return;
    }
    my $pref = $self->_prefix;
    return unless $pref =~ s/^0//;
    my $re = $TEL_TABLE{$pref};
    return unless defined $re;
    return $self->_number =~ /^$re$/;
}

sub _prefix : lvalue { shift->{_prefix} }
sub _number : lvalue { shift->{_number} }

1;
__END__

=head1 NAME

Number::Phone::JP - Validate Japanese phone numbers

=head1 SYNOPSIS

 use Number::Phone::JP;
 
 my $tel = Number::Phone::JP->new('012', '34567890');
 print "This is valid!!\n" if $tel->is_valid_number;
 
 $tel->set_number('098 7654 3210');
 print "This is valid!!\n" if $tel->is_valid_number;
 
 $tel->import(qw(mobile PHS));
 $tel->set_number('090-0123-4567');
 print "This is valid!!\n" if $tel->is_valid_number;

=head1 DESCRIPTION

Number::Phone::JP is a simple module to validate Japanese phone
number formats. The Japanese phone numbers are regulated by
Ministry of Internal Afairs and Communications of Japan.
You can validate what a target number is valid from this
regulation point of view.

There are many categories for type of telephones in Japan. This module
is able to be used narrowed down to the type of phones.

This module only validates what a phone number agrees on the
regulation. Therefore, it does B<NOT> validate what a phone number
actually exists.

This validation needs only an area (or category) prefix and behind it.
The separator of number behind the prefix is ignored.

=head1 METHODS

=head2 new

This method constructs the Number::Phone::JP instance. you can put
some argument of a phone number to it.
It needs a two stuff for validation, area prefix (or carrier's prefix)
and following (means local-area prefix, subscriber's number, and something).

If you put only one argument, this module will separate it by
the first non-number character. And it will be ignored any non-number
characters.

=head2 import

It exists to select what categories is used for validation. You should
pass some specified categories to this method.

Categories list is as follows:

 Class1   ... Class1 undertaking associations
 Class2   ... Class2 undertaking associations
 Freedial ... Freedials
 Home     ... Household phones
 IPPhone  ... IP phones
 Mobile   ... Mobile phones
 Pager    ... Pager (called "pocketbell")
 PHS      ... Personal Handy-phone Systems
 Q2       ... Dial Q2 services
 United   ... United phone number
 FMC      ... Fixed Mobile Convergence
              (was started in 2007 in Japan)
 UPT      ... Universal Personal Telecommunication
              (was merged to FMC category in 2007 in Japan.
               this class works same as FMC.
               it's left for backward compatibility.)

The category's names are B<ignored case>. Actually, the import method
calls others C<Number::Phone::JP::Table::>I<Category> module and
import this. The default importing table, C<Number::Phone::JP::Table>
module is including all the categories table.

For importing, you can import by calling this method, and you can
import by B<calling this module> with some arguments.

 Example:
  # by calling import method
  use Number::Phone::JP; # import all the categories (default)
  my $tel = Number::Phone::JP->new->import(qw(mobile PHS));
 
  # by calling this module
  use Number::Phone::JP qw(Mobile Phs);
  my $tel = Number::Phone::JP->new; # same as above

=head2 set_number

Set/change the target phone number. The syntax of arguments for this
method is same as C<new()> method (see above).

=head2 is_valid_number

This method validates what the already set number is valid on your
specified categories. It returns true if the number is valid, and
returns false if the number is invalid.

=head1 EXAMPLE

 use Number::Phone::JP qw(mobile phs);
 
 my $tel = Number::Phone::JP->new;
 open FH, 'customer.list' or die "$!";
 while (<FH>) {
     chomp;
     unless ($tel->set_number($_)->is_valid_number) {
         print "$_ is invalid number\n"
     }
 }
 close FH;

=head1 AUTHOR

Koichi Taniguchi (a.k.a. nipotan) E<lt>taniguchi@livedoor.jpE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Number::Phone::JP::Table>

=cut
