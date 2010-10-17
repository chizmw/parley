#!/usr/bin/env perl
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;
use inc::Module::Install;

name            ('Parley');
author          ('Chisel Wright<chiselwright@users.berlios.de>');
abstract        ('Message board / forum application');
license         ('perl');
version         ('1.2.1');

requires(
    'Catalyst'                                                  => '5.80029',
    'Catalyst::Runtime'                                         => '5.80029',
    'Catalyst::Action::RenderView'                              => '0.14',
    'Catalyst::Authentication::Store::DBIx::Class'              => '0.1400',
    'Catalyst::Controller::reCAPTCHA'                           => '0.7',
    'Catalyst::Controller::Validation::DFV'                     => '0.0.6',
    'Catalyst::Model::DBIC::Schema'                             => '0.43',
    'Catalyst::Plugin::Authorization::ACL'                      => '0.15',
    'Catalyst::Plugin::Authorization::Roles'                    => '0.08',
    'Catalyst::Plugin::ConfigLoader'                            => '0.30',
    'Catalyst::Plugin::Email'                                   => '0.08',
    'Catalyst::Plugin::FillInForm'                              => '0.12',
    'Catalyst::Plugin::FormValidator'                           => '0.094',
    'Catalyst::Plugin::I18N'                                    => '0.10',
    'Catalyst::Plugin::Session'                                 => '0.31',
    'Catalyst::Plugin::Session::State::Cookie'                  => '0.17',
    'Cache::FastMmap'                                           => '1.36',
    'Catalyst::Plugin::Session::Store::DBIC'                    => '0.11',
    'Catalyst::Plugin::StackTrace'                              => '0.11',
    'Catalyst::Plugin::Static::Simple'                          => '0.29',
    'Catalyst::View::TT'                                        => '0.35',
    'Catalyst::View::JSON'                                      => '0.31',
    'Config::General'                                           => '2.49',
    'Data::FormValidator'                                       => '4.66',
    'Data::SpreadPagination'                                    => '0.1.2',
    'Date::Manip'                                               => '6.13',
    'DateTime'                                                  => '0.63',
    'DateTime::Format::Pg'                                      => '0.16005',
    'DateTime::TimeZone'                                        => '1.22',
    'DBD::Pg'                                                   => '2.17.1',
    'Email::Valid'                                              => '0.184',
    'HTML::FillInForm'                                          => '2.00',
    'Image::Size'                                               => '3.23',
    'JSON'                                                      => '2.26',
    'List::MoreUtils'                                           => '0.22',
    'MIME::Lite'                                                => '3.027',
    'Net::IP::Match::Regexp'                                    => '1.01',
    'Perl6::Export::Attrs'                                      => '0.0.3',
    'Proc::Daemon'                                              => '0.03',
    'Proc::PID::File'                                           => '1.27',
    'Readonly'                                                  => '1.03',
    'SQL::Translator'                                           => '0.11006',
    'Template::Plugin::ForumCode'                               => '0.0.5',
    'Text::Context::EitherSide'                                 => '1.4',
    'Time::Piece'                                               => '1.15_01',
);

build_requires (
    'Test::Aggregate'                                           => '0.363',
    'Test::More'                                                => '0.94',
    'Test::WWW::Mechanize::Catalyst'                            => '0.52',
    'Test::DBIx::Class::Schema'                                 => '0.01007',
);

tests_recursive;

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
