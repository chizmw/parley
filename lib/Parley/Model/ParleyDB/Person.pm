package Parley::Model::ParleyDB::Person;

use strict;
use warnings;
use base 'DBIx::Class::Core';
use DateTime::Format::Pg;

#__PACKAGE__->add_columns(qw/person_id first_name last_name email forum_name authentication/);
#__PACKAGE__->set_primary_key('person_id');

__PACKAGE__->belongs_to(
    authentication => 'Parley::Model::ParleyDB::Authentication'
);

__PACKAGE__->belongs_to(
    preference => 'Parley::Model::ParleyDB::Preference'
);


sub last_post_viewed_in_thread {
    my ($self, $person, $thread) = @_;
    my ($last_viewed, $last_post);

    # we need to be careful that we haven't deleted/hidden the post that
    # matches the exact timestamp of last_viewed for a thread - this is why we
    # use <= and not ==, since we can just return the latest undeleted post

    # get the "last_viewed" value from thread_view
    $last_viewed = Parley::Model::ParleyDB::ThreadView->search(
        {
            person  => $person->id(),
            thread  => $thread->id(),
        },
    )->first();

    # if last_viewed isn't defined, it should mean the user has never viewed
    # this thread
    if (not defined $last_viewed) {
        warn "thread has never been viewed - returning first post in thread";

        $last_post = Parley::Model::ParleyDB::Post->search(
            {
                thread  => $thread->id(),
            },
            {
                rows        => 1,
                order_by    => 'created ASC',
            }
        );

        return $last_post->first();
    }
        
    if (not $last_viewed->count()) {
        warn "no matches for 'last viewed' in last_post_viewed_in_thread()";
        return;
    }

    # now get the last post pade on or before our timestamp for when we last
    # viewed the thread
    $last_post = Parley::Model::ParleyDB::Post->search(
        {
            created => {
                '<=', 
                DateTime::Format::Pg->format_datetime($last_viewed->timestamp())
            },
            thread  => $thread->id(),
        },
        {
            rows        => 1,
            order_by    => 'created DESC',
        }
    );

    # return the first result (if we have any)
    if ($last_post->count()) {
        return $last_post->first();
    }

    # oh well, we didn't get anything
    # XXX this might cause problems in the future, but we'll see
    return;
}


=head1 NAME

Parley::Model::ParleyDB::Person - Catalyst DBIC Table Model

=head1 SYNOPSIS

See L<Parley>

=head1 DESCRIPTION

Catalyst DBIC Table Model.

=head1 AUTHOR

Chisel Wright C<< <pause@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
