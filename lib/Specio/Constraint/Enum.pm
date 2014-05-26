package Specio::Constraint::Enum;
$Specio::Constraint::Enum::VERSION = '0.09'; # TRIAL
use strict;
use warnings;

use B ();
use Role::Tiny::With;
use Specio::Library::Builtins;
use Specio::OO qw( new _accessorize );
use Storable qw( dclone );

use Specio::Constraint::Role::Interface;
with 'Specio::Constraint::Role::Interface';

{
    my $attrs = dclone( Specio::Constraint::Role::Interface::_attrs() );

    for my $name (qw( parent _inline_generator )) {
        $attrs->{$name}{init_arg} = undef;
        $attrs->{$name}{builder} = '_build_' . ( $name =~ s/^_//r );
    }

    $attrs->{values} = {
        isa      => 'ArrayRef',
        required => 1,
    };

    sub _attrs {
        return $attrs;
    }
}

{
    my $Str = t('Str');
    sub _build_parent { $Str }
}

{
    my $_inline_generator = sub {
        my $self = shift;
        my $val  = shift;

        return
              'defined('
            . $val . ') '
            . '&& !ref('
            . $val . ') '
            . '&& $_Specio_Constraint_Enum_enum_values{'
            . $val . '}';
    };

    sub _build_inline_generator { $_inline_generator }
}

sub _build_inline_environment {
    my $self = shift;

    my %values = map { $_ => 1 } @{ $self->values() };

    return { '%_Specio_Constraint_Enum_enum_values' => \%values };
}

__PACKAGE__->_accessorize();

1;

# ABSTRACT: A class for constraints which require a string matching one of a set of values

__END__

=pod

=head1 NAME

Specio::Constraint::Enum - A class for constraints which require a string matching one of a set of values

=head1 VERSION

version 0.09

=head1 SYNOPSIS

  my $type = Specio::Constraint::Enum->new(...);
  print $_, "\n" for @{ $type->values() };

=head1 DESCRIPTION

This is a specialized type constraint class for types which require a string
that matches one of a list of values.

=head1 API

This class provides all of the same methods as L<Specio::Constraint::Simple>,
with a few differences:

=head2 Specio::Constraint::Enum->new( ... )

The C<parent> parameter is ignored if it passed, as it is always set to the
C<Str> type.

The C<inline_generator> and C<constraint> parameters are also ignored. This
class provides its own default inline generator subroutine reference.

Finally, this class requires an additional parameter, C<values>. This must be a
a list of valid strings for the type.

=head2 $enum->values()

Returns an array reference of valid values for the type.

=head1 ROLES

This class does the L<Specio::Constraint::Role::Interface>,
L<Specio::Role::Inlinable>, and L<MooseX::Clone> roles.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
