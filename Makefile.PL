use inc::Module::Install;

name('Parley');
abstract('Catalyst Forum Application');
author('Chisel Wright C<< <pause@herlpacker.co.uk> >>');
version_from('lib/Parley.pm');
license('perl');

include('ExtUtils::AutoInstall');

requires(
    'Catalyst'                                      => '5.66',
    'Catalyst::Model::DBIC'                         => '0.13',
    'Catalyst::Plugin::Authentication'              => '0.07',
    'Catalyst::Plugin::Authentication::Store::DBIC' => '0.05002',
    'Catalyst::Plugin::DefaultEnd'                  => '0.05',
    'Catalyst::Plugin::Dumper'                      => '0.000002',
    'Catalyst::Plugin::Email'                       => '0.05',
    'Catalyst::Plugin::FillInForm'                  => '0.06',
    'Catalyst::Plugin::Prototype'                   => '1.32',
    'Catalyst::Plugin::Session'                     => '0.05',
    'Catalyst::Plugin::Session::State::Cookie'      => '0.02',
    'Catalyst::Plugin::Session::Store::FastMmap'    => '0.02',
    'Catalyst::Plugin::Static::Simple'              => '0.13',
    'Catalyst::Plugin::StackTrace'                  => '0.04',
    'Catalyst::View::TT'                            => '0.22',
    'Data::SpreadPagination'                        => 0,
    'DBD::Pg'                                       => '1.47',
    'DBIx::Class'                                   => '0.06000',
    'DBIx::Class::Loader'                           => '0.21',
    'Data::FormValidator'                           => '4.14',
    'DateTime::Format::Pg'                          => '0.11',
    'Digest::MD5'                                   => '2.36',
    'List::MoreUtils'                               => '0.19',
    'Readonly'                                      => '1.03',
    'Time::Piece'                                   => '1.09',
    'YAML'                                          => '0.58',
);

catalyst_files();

install_script( glob('script/*.pl') );
#auto_install();
&WriteAll;
