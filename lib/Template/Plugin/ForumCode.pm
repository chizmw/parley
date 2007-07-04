package Template::Plugin::ForumCode;
use strict;
use warnings;

use base qw{ Template::Plugin };
use base qw{ Template::Plugin::HTML };

our $VERSION = '0.01_01';

sub new {
    my ($class, $context, @args) = @_;

    my $new_obj = bless {}, $class;

    # simple [x][/x] --> <x></x> tags
    $new_obj->{simple_tags} = [qw{
        b
        u
        i
    }];
    # replacements; e.g. __x__ --> <u>x</u>
    $new_obj->{replacements} = [
        {   from => '__',       to => 'u'   },
        {   from => '\*\*',     to => 'b'   },
        #{   from => '\/\/',     to => 'i'   },
    ];

    return $new_obj;
}

sub forumcode {
    my ($self, $text) = @_;

    # first of all ESCAPE EVERYTHING!
    $text = Template::Plugin::HTML->escape($text);

    # turn newlines into <br /> tags
    $self->_preserve_newlines(\$text );

    $self->_simple_tags     ( \$text );
    $self->_replacements    ( \$text );
    $self->_colouring       ( \$text );
    $self->_lists           ( \$text );
    $self->_url_links       ( \$text );
    $self->_images          ( \$text );
    
    return $text;
}

sub _preserve_newlines {
    my ($self, $textref) = @_;

    $$textref =~ s{\n}{<br />}xmsg;
}

sub _simple_tags {
    my ($self, $textref) = @_;

    # deal with acceptable [x]...[/x] markup
    foreach my $tag (@{ $self->{simple_tags} }) {
        # we should be able to combine these two into one
        $$textref =~ s{\[$tag\]}{<$tag>}g;
        $$textref =~ s{\[/$tag\]}{</$tag>}g;
    }
}

sub _replacements {
    my ($self, $textref) = @_;

    # now deal with replacements
    foreach my $tag (@{ $self->{replacements} }) {
        $$textref =~ s{
            $tag->{from}
            (.+?)
            $tag->{from}
        }
        {<$tag->{to}>$1</$tag->{to}>}gx;
    }
}

sub _url_links {
    my ($self, $textref) = @_;

    # deal with links with no text-label
    $$textref =~ s{\[url\](.+?)\[/url\]}
        {<a href="$1">$1</a>}xmsg;
    # deal with links with a text-label
    $$textref =~ s{
        \[url           # start of url tag
        \s+             # need some whitespace
        name=&quot;     # name="
        (.+?)           # the name
        &quot;          # closing "
        \s*             # optional whitespace
        \]              # close the opening tag
        (.+?)           # the url
        \[/url\]        # close the URL tag
    }
    {<a href="$2">$1</a>}xmsg;
}

sub _images {
    my ($self, $textref) = @_;

    # deal with image tags
    $$textref =~ s{
        \[img
        (.*?)
        \]
        (.+?)
        \[/img\]
    }
    {<img src="$2"$1 />}xmsg;
}

sub _colouring {
    my ($self, $textref) = @_;

    # deal with colouring
    $$textref =~ s{
        \[color
        =
        (
              red | orange | yellow | green | blue
            | black | white
            | \#[0-9a-fA-F]{3}
            | \#[0-9a-fA-F]{6}
        )
        \]
        (.+?)
        \[/color\]
    }
    {<span style="color: $1">$2</span>}ixmsg;
}

sub _lists {
    my ($self, $textref) = @_;

    $$textref =~ s{
        \[list\]
        (?:
            \s*
            (?:
                <br\s*?/>
            )?
            \s*
        )
        (.+?)
        \[/list\]
        [\s]*
        (?:
            <br\s*?/>
        )?
    }
    {_list_elements($1)}xmsge;
}

sub _list_elements {
    my ($text) = @_;

    # ordered lists
    if (
        $text =~ s{
            \[\*\]
            \s*
            (.+?)
            <br\s*?/>
            \s*
        }
        {<li>$1</li>}xmsg
    ) {
        return qq{<ul>$text</ul>};
    }

    # ordered lists
    if (
        $text =~ s{
            \[1\]
            \s*
            (.+?)
            <br\s*?/>
            \s*
        }
        {<li>$1</li>}xmsg
    ) {
        return qq{<ol>$text</ol>};
    }


    # otherwise, just return what we were given
    return $text;
}

1;
__END__
vim: ts=8 sts=4 et sw=4 sr sta

=pod

=head1 NAME

Template::Plugin::ForumCode - class for "ForumCode" filter

=head1 SYNOPSIS

  # load the TT module
  [% USE ForumCode %]

  # ForumCodify some text
  [% ForumCode.forumcode('[b]bold[/u] [u]underlined[/u] [i]italic[/i]') %]
  [% ForumCode.forumcode('**bold** __underlined__') %]

=head1 DESCRIPTION

This module implements ForumCode, a simple markup language inspired by the
likes of BBCode.

ForumCode allows end-users (of a web-site) limited access to a set of HTML
markup through a HTML-esque syntax.

This module works by using L<Template::Plugin::HTML> to escape all HTML
entities and markup. It then performs a series of transformations to convert
ForumCode markup into the appropriate HTML markup.

=head1 MARKUP

The ForumCode plugin will perform the following transformations:

=over 4

=item B<[b]>...B<[/b]> or B<**>...B<**>

Make the text between the markers I<bold>.

=item B<[u]>...B<[/u]> or B<__>...B<___>

Make the text between the markers I<underlined>.
  
=item B<[i]>...B<[/i]>

Make the text between the markers I<italicised>.

=item B<[url]>...B<[/url]>

Make the text between the markers into a HTML link. If you
would like to give the link a name, use the following format:

S<[url B<name="...">]...[/url]>

=back

=head1 METHODS

=head2 new

Create a new instance of the plugin for TT usage

=head2 forumcode

The transformation function

=head1 AUTHOR

Chisel Wright C<< <pause@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
