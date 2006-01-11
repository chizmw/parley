package Parley::App::DFV_hack;
use strict;
use warnings;
use Data::FormValidator 4.00;

BEGIN {
    eval 'use Data::FormValidator 4.00';
    if (!$@) {
        #############################################################
        # This is here until the patch makes it to release
        #############################################################
        no warnings 'redefine';
        sub Data::FormValidator::Results::msgs {
            my $self = shift;
            my $controls = shift || {};
            if (defined $controls and ref $controls ne 'HASH') {
                die "$0: parameter passed to msgs must be a hash ref";
            }


            # Allow msgs to be called more than one to accumulate error messages
            $self->{msgs} ||= {};
            $self->{profile}{msgs} ||= {};
            $self->{msgs} = { %{ $self->{msgs} }, %$controls };

            # Legacy typo support.
            for my $href ($self->{msgs}, $self->{profile}{msgs}) {
                if (
                     (not defined $href->{invalid_separator})
                     &&  (defined $href->{invalid_seperator})
                 ) {
                    $href->{invalid_separator} = $href->{invalid_seperator};
                }
            }

            my %profile = (
                prefix  => '',
                missing => 'Missing',
                invalid => 'Invalid',
                invalid_separator => ' ',

                format  => '<span style="color:red;font-weight:bold"><span class="dfv_errors">* %s</span></span>',
                %{ $self->{msgs} },
                %{ $self->{profile}{msgs} },
            );


            my %msgs = ();

            # Add invalid messages to hash
                #  look at all the constraints, look up their messages (or provide a default)
                #  add field + formatted constraint message to hash
            if ($self->has_invalid) {
                my $invalid = $self->invalid;
                for my $i ( keys %$invalid ) {
                    $msgs{$i} = join $profile{invalid_separator}, map {
                        Data::FormValidator::Results::_error_msg_fmt($profile{format},($profile{constraints}{$_} || $profile{invalid}))
                        } @{ $invalid->{$i} };
                }
            }

            # Add missing messages, if any
            if ($self->has_missing) {
                my $missing = $self->missing;
                for my $m (@$missing) {
                    $msgs{$m} = Data::FormValidator::Results::_error_msg_fmt($profile{format},
                      (ref $profile{missing} eq 'HASH' ?
                          ($profile{missing}->{$m} || $profile{missing}->{default} || 'Missing') : $profile{missing}));
                }
            }

            my $msgs_ref = Data::FormValidator::Results::prefix_hash($profile{prefix},\%msgs);

            $msgs_ref->{ $profile{any_errors} } = 1 if defined $profile{any_errors};

            return $msgs_ref;
        }
        #############################################################
    }
}

1;
__END__
vim: ts=8 sts=4 et sw=4 sr sta
