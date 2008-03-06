package Parley::Schema;
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;
use Parley::Version;  our $VERSION = $Parley::VERSION;

use base 'DBIx::Class::Schema';

# explicitly load Parley::Schema classes
__PACKAGE__->load_classes(
    [
        'Authentication',
        'EmailQueue',
        'ForumModerator',
        'Forum',
        'LogAdminAction',
        'PasswordReset',
        'Person',
        'Post',
        'Preference',
        'PreferenceTimeString',
        'RegistrationAuthentication',
        'Role',
        'TermsAgreed',
        'Terms',
        'Thread',
        'ThreadView',
        'UserRole',
    ]
);

1;
