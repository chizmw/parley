use inc::Module::Install;

name 'Parley';
all_from 'lib/Parley.pm';

requires 'Catalyst' => '5.7001';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::FormValidator';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Model::DBIC::Schema';
requires 'Data::FormValidator' => '4.50';
requires 'Email::Valid';
requiees 'Perl6::Export::Attrs';
requires 'YAML'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
