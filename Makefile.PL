#!/usr/bin/env perl
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;
use inc::Module::Install;

name            ('Parley');
author          ('Chisel Wright<chiselwright@users.berlios.de>');
abstract        ('Message board / forum application');
license         ('perl');
version_from    ('lib/Parley/Version.pm');
version         ('1.0.0');

requires(
    'Catalyst'                                                  => '5.008001',
    'Catalyst::Action::RenderView'                              => 0,
    'Catalyst::Model::DBIC::Schema'                             => 0,
    'Catalyst::Plugin::Authentication'                          => 0,
    'Catalyst::Plugin::Authentication::Credential::Password'    => 0,
    'Catalyst::Plugin::Authentication::Store::DBIC'             => 0,
    'Catalyst::Plugin::Authorization::ACL'                      => 0,
    'Catalyst::Plugin::Authorization::Roles'                    => 0,
    'Catalyst::Plugin::ConfigLoader'                            => 0,
    'Catalyst::Plugin::Dumper'                                  => 0,
    'Catalyst::Plugin::Email'                                   => 0,
    'Catalyst::Plugin::FillInForm'                              => 0,
    'Catalyst::Plugin::FormValidator'                           => 0,
    'Catalyst::Plugin::I18N'                                    => 0,
    'Catalyst::Plugin::Session'                                 => 0,
    'Catalyst::Plugin::Session::State::Cookie'                  => 0,
    'Cache::FastMmap'                                           => 0,
    'Catalyst::Plugin::Session::Store::FastMmap'                => 0,
    'Catalyst::Plugin::StackTrace'                              => 0,
    'Catalyst::Plugin::Static::Simple'                          => 0,
    'Catalyst::View::TT'                                        => 0,
    'Data::FormValidator'                                       => '4.50',
    'Data::SpreadPagination'                                    => 0,
    'DateTime'                                                  => 0,
    'DateTime::Format::Pg'                                      => 0,
    'DateTime::TimeZone'                                        => 0,
    'Email::Valid'                                              => 0,
    'Image::Magick'                                             => 0,
    'HTML::FillInForm'                                          => '1.07',
    'Image::Size'                                               => 0,
    'JSON'                                                      => '2.04',
    'List::MoreUtils'                                           => 0,
    'MIME::Lite'                                                => 0,
    'Net::IP::Match::Regexp'                                    => 0,
    'Perl6::Export::Attrs'                                      => 0,
    'Proc::Daemon'                                              => 0,
    'Proc::PID::File'                                           => 0,
    'Readonly'                                                  => 0,
    'Text::Context::EitherSide'                                 => 0,
    'Time::Piece'                                               => 0,
    'YAML'                                                      => 0,
);

build_requires (
    'Test::More'                                                => 0,
    'Test::WWW::Mechanize::Catalyst'                            => 0,
    'Test::DBIx::Class::Schema'                                 => '0.01004',
);

catalyst;

install_script glob('script/*.pl');
#auto_install;
WriteAll;
