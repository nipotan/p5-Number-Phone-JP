package Number::Phone::JP::Table::Q2;

use strict;
use warnings;

our $VERSION = '0.20110601';

# Table last modified: 2011-06-01
our %TEL_TABLE = (
    # Pref => q<Assoc-Pref-Regex>,
    990 => '(?:(?:6(?:2[013-9]|1[0-35-79]|0[0-35-7]|3[02-48]|4[01478]|8[0159])|5(?:3[0-8]|4[0-79]|8[013-9]|[0-2]\d))\d{3})',
);

1;
__END__
