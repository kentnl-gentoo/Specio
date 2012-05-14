package Type::Constraint::Parameterized;
{
  $Type::Constraint::Parameterized::VERSION = '0.01'; # TRIAL
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

__PACKAGE__->meta()->make_immutable();

1;
