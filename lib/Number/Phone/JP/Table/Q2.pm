package Number::Phone::JP::Table::Q2;

use strict;
use warnings;

our $VERSION = '0.20141201';

# Table last modified: 2014-12-01
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    990 => '(?:(?:6(?:2[013-9]|1[0-35-79])|5(?:[12]\d|04))\d{3})',
);

1;
__END__
