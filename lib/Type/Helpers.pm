package Type::Helpers;
{
  $Type::Helpers::VERSION = '0.02'; # TRIAL
}

use strict;
use warnings;

use Carp qw( croak );
use Exporter 'import';
use overload ();
use Params::Util qw( _STRING );
use Scalar::Util qw( blessed );
use Type::DeclaredAt;

our @EXPORT_OK = qw( install_t_sub _INSTANCEDOES _STRINGLIKE );

sub install_t_sub {
    my $caller = shift;
    my $types  = shift;

    # XXX - check to see if their t() is something else entirely?
    return if  $caller->can('t');

    my $t = sub {
        my $name = shift;

        croak 'The t() subroutine requires a single non-empty string argument'
            unless _STRINGLIKE( $name );

        croak "There is no type named $name available for the $caller package"
            unless exists $types->{ $name };

        my $found = $types->{ $name };

        return $found unless @_;

        my %p = @_;

        croak "Cannot parameterize a non-parameterizable type"
            unless $found->can('parameterize');

        return $found->parameterize(
            declared_at => Type::DeclaredAt->new_from_caller(1),
            %p,
        );
    };

    {
        no strict 'refs';
        no warnings 'redefine';
        *{ $caller . '::t' } = $t;
    }

    return;
}

# XXX - this should be added to Params::Util
sub _STRINGLIKE ($) {
    return $_[0] if _STRING( $_[0] );

    return $_[0]
        if blessed $_[0]
            && overload::Method( $_[0], q{""} )
            && length "$_[0]";

    return undef;
}

sub _INSTANCEDOES ($$) {
    return $_[0]
        if blessed $_[0] && $_[0]->can('does') && $_[0]->does( $_[1] );
    return undef;
}

1;

# ABSTRACT: Helper subs for the Type distro



=pod

=head1 NAME

Type::Helpers - Helper subs for the Type distro

=head1 VERSION

version 0.02

=head1 DESCRIPTION

There's nothing public here.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut


__END__

