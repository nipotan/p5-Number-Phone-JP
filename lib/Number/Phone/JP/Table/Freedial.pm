package Number::Phone::JP::Table::Freedial;

use strict;
use warnings;

our $VERSION = '0.20170801';

# Table last modified: 2017-08-01
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    120 => '(?:(?:9(?:[1-35-9]\d|4[014-9]|0[0157])|[0-8]\d{2})\d{3})',
    800 => '(?:(?:8(?:3[0-8]|0[05-9]|[12]\d|88)|6(?:4[1-9]|[5-9]\d|0[0-3])|9(?:[3-9]\d|2[4-9]|00|19)|3(?:3[3-9]|[4-9]\d|00)|5(?:5[5-9]|[6-9]\d|00)|1(?:2[03]|[07]0|11)|(?:0[08]|40)0|2(?:00|22)|7(?:00|77))\d{4})',
);

1;
__END__
