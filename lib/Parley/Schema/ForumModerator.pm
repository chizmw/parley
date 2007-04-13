package Parley::Schema::ForumModerator;
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components('PK::Auto', 'Core');
__PACKAGE__->table('forum_moderator');
__PACKAGE__->add_columns(
    person => {
        data_type       => "integer",
        default_value   => undef,
        is_nullable     => 0,
        size            => 4
    },

    forum => {
        data_type       => "integer",
        default_value   => undef,
        is_nullable     => 0,
        size            => 4
    },

    can_moderate => {
        data_type => "boolean",
        default_value => "false",
        is_nullable => 0,
        size => 1,
    },
);

__PACKAGE__->add_unique_constraint('forum_moderator_person_key', ['person', 'forum']);
__PACKAGE__->belongs_to('person', 'Person', { person_id => 'person' });
__PACKAGE__->belongs_to('forum',  'Forum',  {  forum_id => 'forum'  });

1;
