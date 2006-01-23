use inc::Module::Install;

name('Parley');
abstract('Catalyst Forum Application');
author('Chisel Wright C<< <pause@herlpacker.co.uk> >>');
version_from('lib/Parley.pm');
license('perl');

include('ExtUtils::AutoInstall');

requires(
    'Catalyst'                                      => '5.63',
    'Catalyst::Model::DBIC'                         => '0.13',
    'Catalyst::Plugin::Authentication'              => '0.05',
    'Catalyst::Plugin::Authentication::Store::DBIC' => '0.04',
    'Catalyst::Plugin::DefaultEnd'                  => '0.03',
    'Catalyst::Plugin::Dumper'                      => '0.000002',
    'Catalyst::Plugin::Email'                       => '0.05',
    'Catalyst::Plugin::FillInForm'                  => '0.05',
    'Catalyst::Plugin::Prototype'                   => '1.32',
    'Catalyst::Plugin::Session'                     => '0.01',
    'Catalyst::Plugin::Session::State::Cookie'      => '0.01',
    'Catalyst::Plugin::Session::Store::FastMmap'    => '0.01',
    'Catalyst::Plugin::Static::Simple'              => '0.12',
    'Catalyst::Plugin::StackTrace'                  => '0.02',
    'Catalyst::View::TT'                            => '0.20',
    'DBD::Pg'                                       => '1.43',
    'DBIx::Class'                                   => '0.04001',
    'DBIx::Class::Loader'                           => '0.14',
    'Data::FormValidator'                           => '4.02',
    'DateTime::Format::Pg'                          => '0.09',
    'Digest::MD5'                                   => '2.33',
    'List::MoreUtils'                               => '0.17',
    'Readonly'                                      => '1.03',
    'Time::Piece'                                   => '1.08',
    'YAML'                                          => '0.53',
);

catalyst_files();

install_script( glob('script/*.pl') );
#auto_install();
&WriteAll;
