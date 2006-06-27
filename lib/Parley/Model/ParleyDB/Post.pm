package Parley::Model::ParleyDB::Post;

use strict;
use warnings;
use base 'DBIx::Class::Core';
use DateTime::Format::Pg;

my @date_cols = qw[ created edited ];

foreach my $datecol (@date_cols) {
    __PACKAGE__->inflate_column($datecol, {
        inflate => sub { DateTime::Format::Pg->parse_datetime(shift); },
        deflate => sub { DateTime::Format::Pg->format_datetime(shift); },
    });
}

sub thread_post_count {
    my ($self, $thread) = @_;

    return $self->count(
        {
            thread  => $thread->id(),
        },
        {
        }
    );
}

sub thread_position {
    my ($self, $post) = @_;

    warn "thread_position()";

    if (not defined $post) {
        warn('$post id undefined in call to Parley::Model::ParleyDB::Post->thread_position()');
        return;
    }

    # explicitly 'deflate' the creation time, as DBIx::Class (<=v0.06003) doesn't deflate on search()
    my $position = $self->count(
        {
            thread  => $post->thread()->id(),
            created => {
                '<='   => DateTime::Format::Pg->format_datetime($post->created())
            },
        }
    );

    return $position;
}

sub page_containing_post {
    my ($self, $post, $posts_per_page) = @_;

    warn "page_containing_post()";

    my $position_in_thread = $self->thread_position($post);

    # work out what page the Nth post is on
    my $page_number = int(($position_in_thread - 1) / $posts_per_page) + 1;

    return $page_number;
}

1;
__END__

=pod

=head1 NAME

Parley::Model::ParleyDB::Post - Catalyst DBIC Table Model

=head1 SYNOPSIS

See L<Parley>

=head1 DESCRIPTION

Catalyst DBIC Table Model.

=head1 EXTRA METHODS

The following extra methods are available:

=head2 thread_position($post)

Given a Parley::Model::ParleyDB::Post object, $post, return the position of the
post in the thread. For example, the initial post in a thread will always be
position #1.

  # get the position of the current_post
  my $post_position = $c->model('ParleyDB')->table('post')->thread_position(
    $c->stash->{current_post},
  );
  # show the information into the catalyst log
  $c->log->info(
      'post '
    . $c->stash->{current_post}->id()
    . ' is at position '
    . $post_position
  );

=head2 page_containing_post($post, $posts_per_page)

Given a Parley::Model::ParleyDB::Post object, $post, and the number of posts to
show per page in a thread, $posts_per_page, return the number of the page that
the post would appear on.

  # get the page that the current post belongs on, using parley.yml for the
  # value of the number of posts per page
  my $page_number =  $c->model('ParleyDB')->table('post')->page_containing_post(
    $c->stash->{current_post},
    $c->config->{posts_per_page},
  );
  # show the information into the catalyst log
  $c->log->info( $c->stash->{current_post}->id() . ' is on page #' . $page_number);

=head1 AUTHOR

Chisel Wright C<< <pause@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

vim: ts=8 sts=4 et sw=4 sr sta
