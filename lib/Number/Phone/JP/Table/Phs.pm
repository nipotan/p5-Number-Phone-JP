package Number::Phone::JP::Table::Phs;

use strict;
use warnings;

our $VERSION = '0.20100104';

# Table last modified: 2010-01-04
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    70 => '(?:(?:5(?:0[1-9]|[1-6]\d|7[7-9]|9[34]|81)|6(?:3[0-6]|[124-69]\d|8[0-5]|75))\d{5})',
);

1;
__END__
