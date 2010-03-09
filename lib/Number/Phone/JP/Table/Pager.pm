package Number::Phone::JP::Table::Pager;

use strict;
use warnings;

our $VERSION = '0.20100104';

# Table last modified: 2010-01-04
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    20 => '(?:4(?:9[29]|6\d)\d{5})',
);

1;
__END__
