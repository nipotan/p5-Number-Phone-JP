package Number::Phone::JP::Table::Mobile;

use strict;
use warnings;

our $VERSION = '0.20160601';

# Table last modified: 2016-06-01
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    70 => '(?:(?:6(?:3[0-6]|[124-69]\d|8[0-5])|5(?:0[1-9]|[1-6]\d|81)|7(?:[0-245]\d|3[0-3]|60)|3(?:[0-35-9]\d|4[01])|2(?:[0-46-9]\d|50)|[14]\d{2})\d{5})',
    80 => '(?:[1-9]\d{7})',
    90 => '(?:[1-9]\d{7})',
);

1;
__END__
