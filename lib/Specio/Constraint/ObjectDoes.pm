package Specio::Constraint::ObjectDoes;
{
  $Specio::Constraint::ObjectDoes::VERSION = '0.06';
}

use strict;
use warnings;
use namespace::autoclean;

use B                  ();
use Devel::PartialDump ();
use Scalar::Util       ();
use Specio::Library::Builtins;

use Moose;

with 'Specio::Constraint::Role::DoesType';

my $Object = t('Object');
has '+parent' => (
    init_arg => undef,
    default  => sub { $Object },
);

my $_inline_generator = sub {
    my $self = shift;
    my $val  = shift;

    return
          'Scalar::Util::blessed('
        . $val . ')' . ' && '
        . $val
        . q{->can('does')} . '&&'
        . $val
        . '->does('
        . B::perlstring( $self->role ) . ')';
};

has '+_inline_generator' => (
    init_arg => undef,
    default  => sub { $_inline_generator },
);

__PACKAGE__->meta()->make_immutable();

1;

# ABSTRACT: A class for constraints which require an object that does a specific role

__END__

=pod

=head1 NAME

Specio::Constraint::ObjectDoes - A class for constraints which require an object that does a specific role

=head1 VERSION

version 0.06

=head1 SYNOPSIS

  my $type = Specio::Constraint::ObjectDoes->new(...);
  print $type->role();

=head1 DESCRIPTION

This is a specialized type constraint class for types which require an object
that does a specific role.

=head1 API

This class provides all of the same methods as L<Specio::Constraint::Simple>,
with a few differences:

=head2 Specio::Constraint::ObjectDoes->new( ... )

The C<parent> parameter is ignored if it passed, as it is always set to the
C<Defined> type.

The C<inline_generator> and C<constraint> parameters are also ignored. This
class provides its own default inline generator subroutine reference.

This class overrides the C<message_generator> default if none is provided.

Finally, this class requires an additional parameter, C<role>. This must be a
single role name.

=head2 $object_isa->role()

Returns the role name passed to the constructor.

=head1 ROLES

This class does the L<Specio::Constraint::Role::DoesType>,
L<Specio::Constraint::Role::Interface>, L<Specio::Role::Inlinable>, and
L<MooseX::Clone> roles.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
