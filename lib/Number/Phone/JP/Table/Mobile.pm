package Number::Phone::JP::Table::Mobile;

use strict;
use warnings;

our $VERSION = '0.20110106';

# Table last modified: 2011-01-06
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    80 => '(?:(?:8(?:5[0-35-7]|[0-4]\d|6[03569]|7[01])|6(?:[013-79]\d|2[0-26-9]|8[0-6])|7(?:3[0-8]|[0-2]\d)|4(?:[0-7]\d|8[01])|[1-35]\d{2})\d{5})',
    90 => '(?:[1-9]\d{7})',
);

1;
__END__
