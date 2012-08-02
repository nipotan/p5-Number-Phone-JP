package Number::Phone::JP::Table::Mobile;

use strict;
use warnings;

our $VERSION = '0.20120801';

# Table last modified: 2012-08-01
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    80 => '(?:(?:9(?:[0-7]\d|9[0-6]|8[0-5])|7(?:6[0-8]|[0-5]\d|9[7-9])|[1-68]\d{2})\d{5})',
    90 => '(?:[1-9]\d{7})',
);

1;
__END__
