package Type::Role::Inlinable;
{
  $Type::Role::Inlinable::VERSION = '0.01'; # TRIAL
}

use strict;
use warnings;
use namespace::autoclean;

use Eval::Closure qw( eval_closure );

use Moose::Role;
use MooseX::Aliases;

requires '_build_description';

has inline_generator => (
    is        => 'ro',
    isa       => 'CodeRef',
    predicate => '_has_inline_generator',
    alias     => 'inline',
);

has inline_environment => (
    is      => 'ro',
    isa     => 'HashRef[Any]',
    lazy    => 1,
    default => sub { {} },
);

has _generated_inline_sub => (
    is       => 'ro',
    isa      => 'CodeRef',
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_generated_inline_sub',
);

has declared_at => (
    is       => 'ro',
    isa      => 'HashRef[Maybe[Str]]',
    required => 1,
);

has _description => (
    is       => 'ro',
    isa      => 'Str',
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_description',
);

sub can_be_inlined {
    my $self = shift;

    return $self->_has_inline_generator();
}

sub _build_generated_inline_sub {
    my $self = shift;

    my $source
        = 'sub { ' . $self->inline_generator()->( $self, '$_[0]' ) . '}';

    return eval_closure(
        source      => $source,
        environment => $self->inline_environment(),
        description => 'inlined sub for ' . $self->_description(),
    );
}

sub _declaration_description {
    my $self = shift;

    my $decl = $self->declared_at();

    my $desc = "declared in package $decl->{package} ($decl->{filename}) at line $decl->{line}";
    $desc .= " in sub named $decl->{sub}" if defined $decl->{sub};

    return $desc;
}

1;
