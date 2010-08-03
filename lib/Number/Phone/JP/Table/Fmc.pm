package Number::Phone::JP::Table::Fmc;

use strict;
use warnings;

our $VERSION = '0.20100701';

# Table last modified: 2010-07-01
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    60 => '(?:3(?:5[0-6]|[34]\d)\d{5})',
);

1;
__END__
