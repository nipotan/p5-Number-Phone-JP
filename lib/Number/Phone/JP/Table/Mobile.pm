package Number::Phone::JP::Table::Mobile;

use strict;
use warnings;

our $VERSION = '0.20140804';

# Table last modified: 2014-08-04
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    70 => '(?:(?:3(?:0[0-8]|[1-3]\d|4[01])|2(?:[0-36-9]\d|4[01]|50)|1\d{2})\d{5})',
    80 => '(?:[1-9]\d{7})',
    90 => '(?:[1-9]\d{7})',
);

1;
__END__
