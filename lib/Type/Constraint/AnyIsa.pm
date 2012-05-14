package Type::Constraint::AnyIsa;
{
  $Type::Constraint::AnyIsa::VERSION = '0.01'; # TRIAL
}

use strict;
use warnings;
use namespace::autoclean;

use B                  ();
use Devel::PartialDump ();
use Scalar::Util       ();
use Type::Library::Builtins;

use Moose;

with 'Type::Constraint::Role::IsaType';

my $Defined = t('Defined');
has '+parent' => (
    init_arg => undef,
    default  => sub { $Defined },
);

my $_inline_generator = sub {
    my $self = shift;
    my $val  = shift;

    return
          '( Scalar::Util::blessed(' 
        . $val
        . ') || ( '
        . " defined $val && ! ref $val ) ) && "
        . $val 
        . '->isa('
        . B::perlstring( $self->class ) . ')';
};

has '+inline_generator' => (
    init_arg => undef,
    default  => sub { $_inline_generator },
);

has '+message_generator' => (
    default => sub { $_[0]->_default_message_generator() },
);

__PACKAGE__->meta()->make_immutable();

1;
