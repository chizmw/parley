package Parley::Controller::My;
use strict;
use warnings;
use base 'Catalyst::Controller';

use Parley::App::Error qw( :methods );

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Global class data
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

my %dfv_profile_for = (
    # DFV validation profile for preferences
    time_format => {
        # make sure we get *something* for checkboxes
        # (which don't submit anything at all when unchecked)
        defaults => {
            use_utc     => 0,
            show_tz     => 0,
        },

        require_some => {
            tz_data => [ 1, qw(use_utc selectZone) ],
        },
        optional => [
            qw( show_tz time_format ),
        ],

        filters     => [qw( trim )],
        msgs => {
            format  => q{%s},
            missing => q{One or more required fields are missing},

            constraints => {
                tz_data => 'you must do stuff',
            },
        },
    },

    notifications => {
        # make sure we get *something* for checkboxes
        # (which don't submit anything at all when unchecked)
        defaults => {
            watch_on_post       => 0,
            notify_thread_watch => 0,
        },

        required => [
            qw(
                watch_on_post
                notify_thread_watch
            )
        ],
    },
);

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Controller Actions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub auto : Private {
    my ($self, $c) = @_;
    # need to be logged in to perform any 'my' actions
    my $status = $c->login_if_required(
        q{You must be logged in before you can access this area}
    );
    if (not defined $status) {
        return 0;
    }

    # undecided if you need to be authed to perform 'my' actions
    #if (not Parley::App::Helper->is_authenticted($c)) {
    #    $c->stash->{error}{message} = q{You need to authenticate your registration before you can start a new topic.};
    #}


    # data we always want in the stash for /my

    # what's the current time? then we can show it in the TZ area
    $c->stash->{current_time} = DateTime->now();

    # fetch timezone categories
    my $tz_categories = DateTime::TimeZone->all_names();
    $c->stash->{tz_categories} = $tz_categories;

    # fetch time formats
    $c->stash->{time_formats} =
        $c->model('ParleyDB')->resultset('PreferenceTimeString')->search(
            {},     # fetch everything
            {
                order_by    => 'sample',    # order by the "preview/sample" string
            }
        );


    return 1;
}


sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Parley::Controller::My in My.');
}


sub preferences : Local {
    my ($self, $c) = @_;
    my ($tz_categories);

    # where did we come from? it would be nice to return there when we're done
    if (
        defined $c->request->referer()
            and 
        $c->request->referer() !~ m{/my/preferences}xms
    ) {
        $c->session->{my_pref_came_from} = $c->request->referer();
    }

    # show a specific tab?
    if (defined $c->request->param('tab')) {
        $c->flash->{show_pref_tab} ||= 'tab_' . $c->request->param('tab');
    }

    # formfill/stash data
    if ('UTC' eq $c->_authed_user()->preference()->timezone()) {
        $c->stash->{formdata}{use_utc} = 1;
    }
    else {
        $c->stash->{formdata}{selectZone}
            = $c->_authed_user()->preference()->timezone();
    }
    # time format
    if (defined $c->_authed_user()->preference()->time_format()) {
        $c->stash->{formdata}{time_format} =
            $c->_authed_user()->preference()->time_format()->id();
    }
    # show tz?
    $c->stash->{formdata}{show_tz}
        = $c->_authed_user()->preference()->show_tz();

    # watched threads
    my $watches = $c->model('ParleyDB')->resultset('ThreadView')->search(
        {
            person      => $c->_authed_user()->id(),
            watched     => 1,
        },
        {
            order_by    => 'last_post.created DESC',
            join        => {
                'thread' => 'last_post',
            },
        }
    );
    $c->stash->{thread_watches} = $watches;

    return;
}

sub update :Path('/my/preferences/update') {
    my ($self, $c) = @_;
    my $form_name = $c->request->param('form_name');

    # use the my/preferences template
    $c->stash->{template} = 'my/preferences';

    # make sure the form name matches something we have a DFV profile for
    if (not exists $dfv_profile_for{ $form_name }) {
        $c->stash->{error}{message} = "no such form: $form_name";
        return;
    }

    # validate the specified form
    $c->form(
        $dfv_profile_for{ $form_name }
    );

    # are we updating TZ preferences?
    if ('time_format' eq $form_name) {
        # return to the right tab
        # use session flash, or we lose the info with the redirect
        $c->flash->{show_pref_tab} = 'tab_time';

        $self->_process_form_time_format( $c );
        $c->response->redirect( $c->uri_for('/my/preferences') );
    }
    # are we updating notification preferences?
    elsif ('notifications' eq $form_name) {
        # return to the right tab
        # use session flash, or we lose the info with the redirect
        $c->flash->{show_pref_tab} = 'tab_notify';

        $self->_process_form_notifications( $c );
        $c->response->redirect( $c->uri_for('/my/preferences') );
    }

    # otherwise we haven't decided how to handle the specified form ...
    else {
        $c->stash->{error}{message} = "don't know how to handle: $form_name";
        return;
    }

    return;
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Private Methods
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub _form_data_valid {
    my ($self, $c) = @_;

    # deal with missing/invalid fields
    if ($c->form->has_missing()) {
        $c->stash->{view}{error}{message} = q{You must fill in all the required fields};
        foreach my $f ( $c->form->missing ) {
            push @{ $c->stash->{view}{error}{messages} }, $f;
        }

        return; # invalid form data
    }
    elsif ($c->form->has_invalid()) {
        $c->stash->{view}{error}{message} = q{One or more fields are invalid};
        foreach my $f ( $c->form->invalid ) {
            push @{ $c->stash->{view}{error}{messages} }, $f;
        }

        return; # invalid form data
    }

    # otherwise, the form data is ok ...
    return 1;
}

sub _process_form_notifications {
    my ($self, $c) = @_;

    if (not $self->_form_data_valid($c)) {
        return;
    }

    # Automatically add watches for new posts?
    $c->_authed_user()->preference()->watch_on_post(
        $c->form->valid('watch_on_post')
    );

    # Receive email notification for watched threads
    $c->_authed_user()->preference()->notify_thread_watch(
        $c->form->valid('notify_thread_watch')
    );

    # store changes
    $c->_authed_user()->preference()->update;

    return;
}


sub _process_form_time_format {
    my ($self, $c) = @_;

    if (not $self->_form_data_valid($c)) {
        return;
    }

    $c->log->debug(
        ref($c->_authed_user()->preference())
    );

    # tz preference value
    if ($c->form->valid('use_utc')) {
        $c->_authed_user()->preference()->timezone('UTC');
    }
    else {
        $c->_authed_user()->preference()->timezone(
            $c->form->valid('selectZone')
        );
    }
    # time_format preference
    if (defined $c->form->valid('time_format')) {
        $c->_authed_user()->preference()->time_format(
            $c->form->valid('time_format')
        )
    }
    else {
        $c->_authed_user()->preference()->time_format( undef );
    }
    # show_tz
    $c->_authed_user()->preference()->show_tz(
        ($c->form->valid('show_tz') || 0)
    );
    # store changes
    $c->_authed_user()->preference()->update();

    return;
}

sub saveHandler : Local {
    my ($self, $c) = @_;
    my $fieldname = $c->request->param('fieldname');

    my %field_map = (
        'First Name' => {
            'resultset'     => 'Person',
            'db_column'     => 'first_name',
        },
        'Last Name' => {
            'resultset'     => 'Person',
            'db_column'     => 'last_name',
        },
        'Forum Name' => {
            'resultset'     => 'Person',
            'db_column'     => 'forum_name',
            'is_unique'     => 1,
        },
    );

    if (exists $field_map{$fieldname}) {
        my $resultset = $field_map{$fieldname}->{resultset};
        my $db_column = $field_map{$fieldname}->{db_column};
        my $is_unique = $field_map{$fieldname}->{is_unique} || 0;

        # get the user we're authed as
        my $person = $c->model('ParleyDB')->resultset($resultset)->find(
            $c->_authed_user()->id()
        );
        # it would be nice to deduce this from the schema, but hey ..
        # .. this'll do for now
        if ($is_unique) {
            # make sure the value isn't already in use
            my $count = $c->model('ParleyDB')->resultset($resultset)->count(
                {
                    $db_column => $c->request->param('value'),
                }
            );
            if ($count) {
                $c->response->body(
                      q{<p>'}
                    . $c->request->param('value')
                    . q{' has already been used by another user.</p>}
                );
                return;
            };
        }

        # perform the update
        eval {
            # update the relevant field
            $person->update(
                {
                    $db_column => $c->request->param('value'),
                }
            );
        };
        # check for errors
        if ($@) {
            parley_warn($c, $@);
            $c->response->body(qq{<p>ERROR: $@</p>});
        }
        else {
            $c->response->body(
                  q{<p>Updated }
                . $fieldname
                . q{ from '}
                . $c->request->param('ovalue')
                . q{' to '}
                . $c->request->param('value')
                . q{'</p>}
            );
        }
    }
    else {
        $c->response->body(q{<p>Unknown field name</p>});
    }
}

=head1 NAME

Parley::Controller::My - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index 

=head1 AUTHOR

Chisel Wright C<< chiselwright@users.berlios.de> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
