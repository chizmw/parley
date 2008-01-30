package Parley::Controller::Post;

use strict;
use warnings;
use base 'Catalyst::Controller';
use DateTime;
use JSON;
use Template::Plugin::ForumCode;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Global class data
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

my %dfv_profile_for = (
    # DFV validation profile for adding a new topic
    edit_post => {
        required    => [qw( post_message )],
        filters     => [qw( trim )],
        msgs => {
            format  => q{%s},
            missing => q{One or more required fields are missing},
        },
    },
);

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Controller Actions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub edit : Local {
    my ($self, $c) = @_;

    # if we don't have a post param, then return with an error
    unless (defined $c->_current_post) {
        $c->stash->{error}{message} = $c->localize(q{Incomplete URL});
        return;
    }

    # you need to be logged in to edit a post
    # (although non-logged users shouldn't see an edit link, you never know
    # what people will make-up or bookmark)
    $c->login_if_required($c->localize(q{EDIT LOGIN REQUIRED}));

    # you can only edit you own posts
    # (unless you're a moderator, but we don't do that yet)
    if ($c->_authed_user()->id() != $c->_current_post()->creator()->id()) {
        $c->stash->{error}{message} = $c->localize(q{EDIT OWN POSTS ONLY});
        return;
    }

    # you can't edit a locked post
    elsif ($c->_current_post->thread->locked) {
        $c->stash->{error}{message} = $c->localize(q{EDIT LOCKED POST});
        return;
    }

    # process the form submission
    elsif (defined $c->request->method() and $c->request->method() eq 'POST') {
        # validate the form data
        $c->form(
            $dfv_profile_for{edit_post}
        );
        # deal with missing/invalid fields
        if ($c->form->has_missing()) {
            $c->stash->{view}{error}{message} = $c->localize(q{DFV FILL REQUIRED});
            foreach my $f ( $c->form->missing ) {
                push @{ $c->stash->{view}{error}{messages} }, $f;
            }
        }
        elsif ($c->form->has_invalid()) {
            $c->stash->{view}{error}{message} = $c->localize(q{DFV FIELDS INVALID});
            foreach my $f ( $c->form->invalid ) {
                push @{ $c->stash->{view}{error}{messages} }, $f;
            }
        }
        # otherwise; everything seems fine - edit the post
        else {
            # update the post with the new information
            $c->_current_post->message( $c->form->valid->{post_message} );

            # set the edited time
            $c->_current_post->edited( DateTime->now() );

            # store the updates in the db
            $c->_current_post->update();

            # view the (updated) post
            $c->detach('/post/view');
        }
    }
}

sub view : Local {
    my ($self, $c) = @_;

    # if we don't have a post param, then return with an error
    unless (defined $c->_current_post) {
        $c->stash->{error}{message} = $c->localize(q{Incomplete URL});
        return;
    }

    # work out what page in which thread the post lives
    my $thread = $c->_current_post->thread->id();
    my $page_number =  $c->model('ParleyDB')->resultset('Post')->page_containing_post(
        $c->stash->{current_post},
        $c->config->{posts_per_page},
    );

    # build the URL to redirect to
    my $redirect_url =
        $c->uri_for(
            '/thread/view',
            {
                thread  => $thread,
                page    => $page_number,
            }
        )
        . "#" . $c->_current_post->id()
    ;

    # redirect to the relevant place in the appropriate thread
    $c->log->debug( "post/view: redirecting to $redirect_url" );
    $c->response->redirect( $redirect_url );
    return;
}

sub preview : Local {
    my ($self, $c) = @_;
    my $tt_forum = Template::Plugin::ForumCode->new();
    my $msg_source = $c->request->param('msg_source');

    my $json = objToJson(
        {
            'formatted' =>
                $tt_forum->forumcode(
                    $msg_source
                )
        }
    );

    $c->response->body( $json );
    return;
}


1;
__END__

=pod

=head1 NAME

Parley::Controller::Post - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 ACTIONS

=head2 view 

View a specific post, specified by the post in $c->_current_post

=head1 AUTHOR

Chisel Wright C<< <chiselwright@users.berlios.de> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

vim: ts=8 sts=4 et sw=4 sr sta
