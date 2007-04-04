package Parley::App::Communication::Email;
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;

use Perl6::Export::Attrs;

sub queue_email :Export( :email ) {
    my ($c, $options) = @_;
    my $queued_mail = $c->model('ParleyDB')->resultset('EmailQueue')->create(
        {
            sender          => $options->{headers}{from}        || q{Missing From <chisel@somewhere.com>},

            recipient       => $options->{recipient}->id()      || 0,
            subject         => $options->{headers}{subject}     || q{Subject Line Missing},
            text_content    => $options->{text_content}         || q{Email Body Text Missing},
            html_content    => $options->{html_content}         || undef,
        }
    );
    return 1; # success
}

sub send_email :Export( :email ) {
    my ($c, $options) = @_;
    my ($text_content, $html_content, $email_status);

    # preparing for future expansion, where we intend to build multipart emails
    # and we'll be using ->{template}{text} and ->{template}{html}
    if (            exists $options->{template}
            and ref($options->{template}) ne 'HASH'
    ) {
        $c->log->warn(
              q{DEPRECATED use of ->{template} = 'file.eml'}
            . q{: plain-text template name should be stored in }
            . q{->{template}{text} instead of ->{template}}
        );

        # put the data in the right place
        my $tpl_name = $options->{template};
        $options->{template} = {};
        $options->{template}{text} = $tpl_name;
    }

    # we don't send anything immediately ... push it into the queue of outgoing
    # messages

    # prepare the text content portion of the message - we read this from a
    # [template] file which we render
    $text_content = $c->view('Plain')->render(
        $c,
        $options->{template}{text},
        {
            additional_template_paths => [ $c->config->{root} . q{/email_templates}],

            # automatically make the person data available
            person => $options->{person},

            # pass through extra TT data
            %{ $options->{template_data} || {} },
        }
    );

    # if we have html_content, prepare that for queueing
    if (defined $options->{template}{html}) {
        $html_content = $c->view('Plain')->render(
            $c,
            $options->{template}{html},
            {
                additional_template_paths => [ $c->config->{root} . q{/email_templates}],

                # automatically make the person data available
                person => $options->{person},

                # pass through extra TT data
                %{ $options->{template_data} || {} },
            }
        );
    }

    # queue the message
    $email_status = $c->queue_email(
        {
            headers => {
                from        =>     $options->{headers}{from}
                                || q{Missing From <missing.from@localhost>},
                subject     =>     $options->{headers}{subject}
                                || q{Subject Line Missing},
            },

            recipient       => $options->{person},
            text_content    => $text_content,
            html_content    => $html_content,
        },
    );

    # did we queue the email OK?
    if ($email_status) {
        $c->log->info(
              q{send_email(}
            . $options->{person}->email()
            . q{): }
            . $email_status
        );

        return 1;
    }
    else {
        $c->log->error( $email_status );
        $c->stash->{error}{message} = q{There was a problem sending an email from the system};
        return 0;
    }
}

sub old_send_email :Export( :email ) {
    my ($c, $options) = @_;

    # preparing for future expansion, where we intend to build multipart emails
    # and we'll be using ->{template}{text} and ->{template}{html}
    if (            exists $options->{template}
            and ref($options->{template}) ne 'HASH'
    ) {
        $c->log->warn(
              q{DEPRECATED use of ->{template} = 'file.eml'}
            . q{: plain-text template name should be stored in }
            . q{->{template}{text} instead of ->{template}}
        );

        # put the data in the right place
        my $tpl_name = $options->{template};
        $options->{template} = {};
        $options->{template}{text} = $tpl_name;
    }

    # send an email off to the new user
    my $email_status = $c->email(
        header => [
            To      => $options->{person}->email(),
            From    => $options->{headers}{from}      || q{Missing From <chisel@somewhere.com>},
            Subject => $options->{headers}{subject}   || q{Subject Line Missing},
        ],

        body => $c->view('Plain')->render(
            $c,
            $options->{template}{text},
            {
                additional_template_paths => [ $c->config->{root} . q{/email_templates}],

                # automatically make the person data available
                person => $options->{person},

                # pass through extra TT data
                %{ $options->{template_data} || {} },
            }
        ),
    );

    # did we get "Message sent" from the email send?
    if ($email_status eq q{Message sent}) {
        $c->log->info(
              q{send_email(}
            . $options->{person}->email()
            . q{): }
            . $email_status
        );

        return 1;
    }
    else {
        $c->log->error( $email_status );
        $c->stash->{error}{message} = q{Sorry, we are currently unable to store your information. Please try again later.};
        return 0;
    }
}

1;

__END__

=head1 NAME

Parley::App::Communication::Email - email helper functions

=head1 SYNOPSIS

  use Parley::App::Communication::Email;

  $self->send_email($c, $options);

=head1 SEE ALSO

L<Parley::Controller::Root>, L<Catalyst::Plugin::Email>, L<Catalyst>

=head1 AUTHOR

Chisel Wright C<< <chisel@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
