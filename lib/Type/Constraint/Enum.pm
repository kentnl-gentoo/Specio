package Type::Constraint::Enum;
{
  $Type::Constraint::Enum::VERSION = '0.01'; # TRIAL
}

use strict;
use warnings;
use namespace::autoclean;

use B ();
use Type::Library::Builtins;

use Moose;

with 'Type::Constraint::Role::Interface';

my $Str = t('Str');
has '+parent' => (
    init_arg => undef,
    default  => sub { $Str },
);

has values => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
);

my $_inline_generator = sub {
    my $self = shift;
    my $val  = shift;

    return
          'defined(' 
        . $val . ') '
        . '&& !ref('
        . $val . ') '
        . '&& $_enum_values{'
        . $val . '}';
};

has '+inline_generator' => (
    init_arg => undef,
    default  => sub { $_inline_generator },
);

has '+inline_environment' => (
    default => sub { $_[0]->_build_inline_environment() },
);

sub _build_inline_environment {
    my $self = shift;

    my %values = map { $_ => 1 } @{ $self->values() };

    return { '%_enum_values' => \%values };
}

__PACKAGE__->meta()->make_immutable();
