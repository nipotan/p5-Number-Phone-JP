package Number::Phone::JP::Table::Mobile;

use strict;
use warnings;

our $VERSION = '0.20140203';

# Table last modified: 2014-02-03
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    80 => '(?:[1-9]\d{7})',
    90 => '(?:[1-9]\d{7})',
);

1;
__END__
