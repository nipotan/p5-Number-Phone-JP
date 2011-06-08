package Number::Phone::JP::Table::Mobile;

use strict;
use warnings;

our $VERSION = '0.20110502';

# Table last modified: 2011-05-02
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    80 => '(?:(?:8(?:5[0-35-7]|[0-47]\d|6[035-79]|8[01])|6(?:[013-9]\d|2[0-25-9])|4(?:[0-7]\d|8[0-4])|7(?:4[0-8]|[0-3]\d)|[1-35]\d{2})\d{5})',
    90 => '(?:[1-9]\d{7})',
);

1;
__END__
