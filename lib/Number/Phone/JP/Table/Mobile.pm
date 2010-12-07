package Number::Phone::JP::Table::Mobile;

use strict;
use warnings;

our $VERSION = '0.20101201';

# Table last modified: 2010-12-01
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    80 => '(?:(?:8(?:5[0-35-7]|[0-4]\d|6[03569]|7[01])|6(?:[013-79]\d|2[0-26-9]|8[0-5])|(?:(?:4[0-7]|[1-3]\d)|5\d)\d|7(?:3[0-8]|[0-2]\d))\d{5})',
    90 => '(?:[1-9]\d{7})',
);

1;
__END__
