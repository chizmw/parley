package Parley::Controller::Post;

use strict;
use warnings;
use base 'Catalyst::Controller';
use DateTime;
use List::MoreUtils qw{ uniq };

=head1 NAME

Parley::Controller::Post - Catalyst Controller

=head1 SYNOPSIS

See L<Parley>

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head1 AUTHOR

Chisel Wright C<< <pause@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use Data::FormValidator 4.02;
our $DFV;

BEGIN {
    $DFV = Data::FormValidator->new(
        {
            edit_post => {
                required        => [qw/post_message/],
                field_filters   => {
                    post_message    => 'trim',
                },
                msgs => {
                    missing => q{One or more required fields are missing},
                    format  => '%s',
                },
            },
        }
    )
}

sub view : Local {
    my ($self, $c) = @_;

    # if we don't have a post param, then return with an error
    unless (defined $c->stash->{current_post}) {
        $c->stash->{error}{message} = q{Incomplete URL};
        return;
    }

    # work out what page in which thread the post lives
    my $thread = $c->stash->{current_post}->thread->id();
    my $page_number =  $c->model('ParleyDB')->table('post')->page_containing_post(
        $c->stash->{current_post},
        $c->config->{posts_per_page},
    );

    # build the URL to redirect to
    my $redirect_url = $c->uri_for(
        '/thread',
          "view?thread=$thread"
        . "&page=$page_number"
        . "#" . $c->stash->{current_post}->id()
    );
    $c->response->redirect( $redirect_url );
}

sub edit : Local {
    my ($self, $c) = @_;
    my (@messages);

    # need to be logged in to edit post
    Parley::App::Helper->login_if_required($c, q{You must be logged in to edit your posts});

    # you can only edit posts you've created
    if ($c->authed_user->id() != $c->stash->{current_post}->creator()->id()) {
        push @messages, q{You can only edit your own posts};
    }

    # you can't edit a locked post (not that you can see the link unless you're hacking)
    elsif ($c->stash->{current_post}->thread()->locked()) {
        push @messages, q{You can't edit locked posts};
    }

    # deal with any actual form submits
    elsif ($c->request->param('post_update')) {
        @messages = $self->_edit_post( $c );
    }

    if (scalar @messages) {
        @messages = uniq(sort(@messages));
        $c->stash->{messages} = \@messages;
    }
}

sub _edit_post {
    my ($self, $c) = @_;
    my ($results, @messages);

    if ($DFV) {
        $results = $DFV->check($c->req->parameters, 'edit_post');
    };

    if ($results || !$DFV) {
        # update the post with the new information
        $c->stash->{current_post}->message( $results->valid->{post_message} );

        # set the edited time
        $c->stash->{current_post}->edited( DateTime->now() );

        # store the updates in the db
        $c->stash->{current_post}->update();

        # view the thread - but only if no errors
        if (not scalar(@messages)) {
            $c->response->redirect(
                $c->uri_for(
                      '/thread/view?thread='
                    . $c->stash->{current_post}->thread()->id()
                )
            );
        }
    }
    else {
        $c->log->error('DFV failed');
        push @messages, map {$_} values %{$results->msgs};
    }

    return (uniq(sort @messages));
}

1;
