package Number::Phone::JP::Table::Mobile;

use strict;
use warnings;

our $VERSION = '0.20110704';

# Table last modified: 2011-07-04
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    80 => '(?:(?:9(?:[01][0-6]|2[0-5])|7(?:4[0-8]|[0-3]\d)|[1-68]\d{2})\d{5})',
    90 => '(?:[1-9]\d{7})',
);

1;
__END__
