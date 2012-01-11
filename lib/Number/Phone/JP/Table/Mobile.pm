package Number::Phone::JP::Table::Mobile;

use strict;
use warnings;

our $VERSION = '0.20120105';

# Table last modified: 2012-01-05
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    80 => '(?:(?:7(?:5[0-6]|[0-4]\d)|9(?:[0-2]\d|3[01]|40)|[1-68]\d{2})\d{5})',
    90 => '(?:[1-9]\d{7})',
);

1;
__END__
