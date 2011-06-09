package Number::Phone::JP::Table::Mobile;

use strict;
use warnings;

our $VERSION = '0.20110601';

# Table last modified: 2011-06-01
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    80 => '(?:(?:7(?:4[0-8]|[0-3]\d)|9(?:0[0-6]|1[0-4])|[1-68]\d{2})\d{5})',
    90 => '(?:[1-9]\d{7})',
);

1;
__END__
