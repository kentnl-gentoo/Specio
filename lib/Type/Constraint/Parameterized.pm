package Type::Constraint::Parameterized;
{
  $Type::Constraint::Parameterized::VERSION = '0.03'; # TRIAL
}

use strict;
use warnings;
use namespace::autoclean;

use Type::Constraint::Parameterized;

use Moose;

with 'Type::Constraint::Role::Interface';

has '+parent' => (
    isa      => 'Type::Constraint::Parameterizable',
    required => 1,
);

has parameter => (
    is       => 'ro',
    does     => 'Type::Constraint::Role::Interface',
    required => 1,
);

sub can_be_inlined {
    my $self = shift;

    return $self->_has_inline_generator()
        && $self->parameter()->can_be_inlined();
}

# Moose compatibility methods - these exist as a temporary hack to make Type
# work with Moose.

sub type_parameter {
    shift->parameter();
}

__PACKAGE__->meta()->make_immutable();

1;

# ABSTRACT: A class which represents parameterized constraints



=pod

=head1 NAME

Type::Constraint::Parameterized - A class which represents parameterized constraints

=head1 VERSION

version 0.03

=head1 SYNOPSIS

  my $arrayref = t('ArrayRef');

  my $arrayref_of_int = $arrayref->parameterize( of => t('Int') );

  my $parent = $arrayref_of_int->parent(); # returns ArrayRef
  my $parameter = $arrayref_of_int->parameter(); # returns Int

=head1 DESCRIPTION

This class implements the API for parameterized types.

=head1 API

This class implements the same API as L<Type::Constraint::Simple>, with a few
additions.

=head2 Type::Constraint::Parameterized->new(...)

This class's constructor accepts two additional parameters:

=over 4

=item * parent

This should be the L<Type::Constraint::Parameterizable> object from which this
object was created.

This parameter is required.

=item * parameter

This is the type parameter for the parameterized type. This must be an object
which does the L<Type::Constraint::Role::Interface> role.

This parameter is required.

=back

=head2 $type->parameter()

Returns the type that was passed to the constructor.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut


__END__

