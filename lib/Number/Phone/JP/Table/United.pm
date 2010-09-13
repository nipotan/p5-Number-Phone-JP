package Number::Phone::JP::Table::United;

use strict;
use warnings;

our $VERSION = '0.20100906';

# Table last modified: 2010-09-06
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    570 => '(?:(?:5(?:7[0-2]|00|55)|1(?:0[0-2]|11)|3(?:00|33)|7(?:00|77)|88[128]|9[19]9|0\d{2}|222|600)\d{3})',
);

1;
__END__
