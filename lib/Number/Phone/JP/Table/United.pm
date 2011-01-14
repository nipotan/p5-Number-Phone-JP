package Number::Phone::JP::Table::United;

use strict;
use warnings;

our $VERSION = '0.20110106';

# Table last modified: 2011-01-06
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    570 => '(?:(?:1(?:0[0-2]|11)|5(?:7[0-2]|55)|3(?:00|33)|88[128]|9[19]9|0\d{2}|222|777)\d{3})',
);

1;
__END__
