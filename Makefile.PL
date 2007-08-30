use inc::Module::Install;

name 'Parley';
all_from 'lib/Parley.pm';

requires 'Catalyst' => '5.7001';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Model::DBIC::Schema';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authentication::Credential::Password';
requires 'Catalyst::Plugin::Authentication::Store::DBIC';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Dumper';
requires 'Catalyst::Plugin::Email';
requires 'Catalyst::Plugin::FillInForm';
requires 'Catalyst::Plugin::FormValidator';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Cache::FastMmap';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::StackTrace';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::View::TT';
requires 'Data::FormValidator' => '4.50';
requires 'Data::SpreadPagination';
requires 'DateTime';
requires 'DateTime::Format::Pg';
requires 'DateTime::TimeZone';
requires 'Email::Valid';
requires 'Graphics::Magick';
requires 'Image::Size';
requires 'List::MoreUtils';
requires 'MIME::Lite';
requires 'Perl6::Export::Attrs';
requires 'Proc::Daemon';
requires 'Proc::PID::File';
requires 'Readonly';
requires 'Text::Context::EitherSide';
requires 'YAML'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
