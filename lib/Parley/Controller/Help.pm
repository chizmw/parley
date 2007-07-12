package Parley::Controller::Help;
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;
use base 'Catalyst::Controller';

sub index : Private {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'help/contents';
}

sub default :Private {
    my ($self, $c) = @_;
    my $help_template;

    # the section / page to show is derived from the URI
    $help_template = $c->request->arguments->[1];

    # set the template to use based on the URI
    $c->stash->{template} = qq[help/${help_template}];
    # send to the view
    $c->forward('Parley::View::TT');

    # deal with errors (i.e. missing templates)
    if ($c->error) {
        # only show the "unknown help section" page if we couldn't find the
        # page to show
        if ($c->error->[0] =~ m{file error - help/$help_template: not found}ms) {
            $c->clear_errors;
            $c->forward( 'unknown' );
        }
    }
}

sub unknown :Local {
    my ($self, $c) = @_;
    $c->stash->{template} = 'help/unknown';
}

=head1 NAME

Parley::Controller::Help - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index 

=head1 AUTHOR

Chisel Wright C<< <chiselwright@users.berlios.de> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
