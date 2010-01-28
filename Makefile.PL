use inc::Module::Install;
name 'Number-Phone-JP';
all_from 'lib/Number/Phone/JP.pm';

build_requires 'Test::More';
requires 'UNIVERSAL::require' => 0;

WriteAll;
