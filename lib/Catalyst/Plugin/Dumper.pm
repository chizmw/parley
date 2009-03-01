package Catalyst::Plugin::Dumper;
# vim: ts=8 sts=4 et sw=4 sr sta
use Moose; # gives us strict and warnings

#extends 'Catalyst::Log';

has 'headers'  => (
      is      => 'rw',
      isa     => 'Header',
      default => sub { HTTP::Headers->new } 
);

1;
__END__
