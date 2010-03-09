package Number::Phone::JP::Table::Mobile;

use strict;
use warnings;

our $VERSION = '0.20100104';

# Table last modified: 2010-01-04
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    80 => '(?:(?:6(?:4[0-689]|[0135-79]\d|2[0-26-9]|8[0-3])|8(?:3[0-8]|1[0-7]|2[01568]|0\d)|4(?:4[0-7]|[0-3]\d)|(?:[1-35]\d|7[0-2])\d)\d{5})',
    90 => '(?:[1-9]\d{7})',
);

1;
__END__
