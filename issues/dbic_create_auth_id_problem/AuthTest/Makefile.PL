use inc::Module::Install;

name 'AuthTest';
all_from 'lib/AuthTest.pm';

requires Catalyst => '5.64';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
