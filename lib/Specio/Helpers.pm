package Specio::Helpers;

use strict;
use warnings;

use Carp qw( croak );
use Exporter 'import';
use overload ();

our $VERSION = '0.24';

use Scalar::Util qw( blessed );

our @EXPORT_OK = qw( install_t_sub is_class_loaded _STRINGLIKE );

sub install_t_sub {

    # Specio::DeclaredAt use Specio::OO, which in turn uses
    # Specio::Helpers. If we load this with "use" we get a cirular require and
    # a big mess.
    require Specio::DeclaredAt;

    my $caller = shift;
    my $types  = shift;

    # XXX - check to see if their t() is something else entirely?
    return if $caller->can('t');

    my $t = sub {
        my $name = shift;

        croak 'The t subroutine requires a single non-empty string argument'
            unless _STRINGLIKE($name);

        croak "There is no type named $name available for the $caller package"
            unless exists $types->{$name};

        my $found = $types->{$name};

        return $found unless @_;

        my %p = @_;

        croak 'Cannot parameterize a non-parameterizable type'
            unless $found->can('parameterize');

        return $found->parameterize(
            declared_at => Specio::DeclaredAt->new_from_caller(1),
            %p,
        );
    };

    {
        ## no critic (TestingAndDebugging::ProhibitNoStrict)
        no strict 'refs';
        no warnings 'redefine';
        *{ $caller . '::t' } = $t;
    }

    return;
}

## no critic (Subroutines::ProhibitSubroutinePrototypes, Subroutines::ProhibitExplicitReturnUndef)
sub _STRINGLIKE ($) {
    return $_[0] if _STRING( $_[0] );

    return $_[0]
        if blessed $_[0]
        && overload::Method( $_[0], q{""} )
        && length "$_[0]";

    return undef;
}

# Borrowed from Params::Util
sub _STRING ($) {
    return defined $_[0] && !ref $_[0] && length( $_[0] ) ? $_[0] : undef;
}

# Borrowed from Types::Standard
sub is_class_loaded {
    my $stash = do {
        ## no critic (TestingAndDebugging::ProhibitNoStrict)
        no strict 'refs';
        \%{ $_[0] . '::' };
    };

    return 1 if exists $stash->{ISA};
    return 1 if exists $stash->{VERSION};

    foreach my $globref ( values %{$stash} ) {
        return 1 if *{$globref}{CODE};
    }

    return 0;
}

1;

# ABSTRACT: Helper subs for the Specio distro

__END__

=pod

=encoding UTF-8

=head1 NAME

Specio::Helpers - Helper subs for the Specio distro

=head1 VERSION

version 0.24

=head1 DESCRIPTION

There's nothing public here.

=for Pod::Coverage .*

=head1 SUPPORT

Bugs may be submitted through L<the RT bug tracker|http://rt.cpan.org/Public/Dist/Display.html?Name=Specio>
(or L<bug-specio@rt.cpan.org|mailto:bug-specio@rt.cpan.org>).

I am also usually active on IRC as 'drolsky' on C<irc://irc.perl.org>.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENCE

This software is Copyright (c) 2016 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
