package Specio::Constraint::Role::DoesType;

use strict;
use warnings;

our $VERSION = '0.12';

use Role::Tiny;
use Storable qw( dclone );

use Specio::Constraint::Role::Interface;
with 'Specio::Constraint::Role::Interface';

{
    ## no critic (Subroutines::ProtectPrivateSubs)
    my $attrs = dclone( Specio::Constraint::Role::Interface::_attrs() );
    ## use critic

    for my $name (qw( parent _inline_generator )) {
        $attrs->{$name}{init_arg} = undef;
        $attrs->{$name}{builder}
            = $name =~ /^_/ ? '_build' . $name : '_build_' . $name;
    }

    $attrs->{role} = {
        isa      => 'Str',
        required => 1,
    };

    ## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
    sub _attrs {
        return $attrs;
    }
}

## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _wrap_message_generator {
    my $self      = shift;
    my $generator = shift;

    my $role = $self->role();

    $generator //= sub {
        my $description = shift;
        my $value       = shift;

        return
              "Validation failed for $description with value "
            . Devel::PartialDump->new()->dump($value)
            . '(does not do '
            . $role . ')';
    };

    my $d = $self->_description();

    return sub { $generator->( $d, @_ ) };
}
## use critic

1;

# ABSTRACT: Provides a common implementation for Specio::Constraint::AnyDoes and Specio::Constraint::ObjectDoes

__END__

=pod

=head1 NAME

Specio::Constraint::Role::DoesType - Provides a common implementation for Specio::Constraint::AnyDoes and Specio::Constraint::ObjectDoes

=head1 VERSION

version 0.12

=head1 DESCRIPTION

See L<Specio::Constraint::AnyDoes> and L<Specio::Constraint::ObjectDoes> for
details.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2015 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
