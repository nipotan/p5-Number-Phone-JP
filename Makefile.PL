use inc::Module::Install;
name 'Number-Phone-JP';
all_from 'lib/Number/Phone/JP.pm';

build_requires 'Test::More';
build_requires 'Test::Requires';
requires 'UNIVERSAL::require' => 0;
author_tests 'xt';
WriteAll;
