package Number::Phone::JP::Table::Mobile;

use strict;
use warnings;

our $VERSION = '0.20130201';

# Table last modified: 2013-02-01
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    80 => '(?:(?:9(?:[0-79]\d|8[0-5])|[1-8]\d{2})\d{5})',
    90 => '(?:[1-9]\d{7})',
);

1;
__END__
