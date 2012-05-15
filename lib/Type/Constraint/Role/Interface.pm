package Type::Constraint::Role::Interface;
{
  $Type::Constraint::Role::Interface::VERSION = '0.02'; # TRIAL
}

use strict;
use warnings;
use namespace::autoclean;

use Devel::PartialDump;
use List::AllUtils qw( all );
use Sub::Name qw( subname );
use Try::Tiny;
use Type::Exception;

use Moose::Role;

with 'MooseX::Clone', 'Type::Role::Inlinable';

has name => (
    is        => 'ro',
    isa       => 'Str',
    predicate => '_has_name',
);

has parent => (
    is        => 'ro',
    does      => 'Type::Constraint::Role::Interface',
    predicate => '_has_parent',
);

has _constraint => (
    is        => 'rw',
    writer    => '_set_constraint',
    isa       => 'CodeRef',
    predicate => '_has_constraint',
    init_arg  => 'constraint',
);

has _optimized_constraint => (
    is       => 'ro',
    isa      => 'CodeRef',
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_optimized_constraint',
);

has _ancestors => (
    is       => 'ro',
    isa      => 'ArrayRef',
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_ancestors',
);

my $_default_message_generator = sub {
    my $type  = shift;
    my $thing = shift;
    my $value = shift;

    return
          q{Validation failed for } 
        . $thing
        . q{ with value }
        . Devel::PartialDump->new()->dump($value);
};

has _message_generator => (
    is       => 'ro',
    isa      => 'CodeRef',
    default  => sub { $_default_message_generator },
    init_arg => 'message_generator',
);

has _coercions => (
    traits  => [ 'Clone', 'Hash' ],
    handles => {
        coercions               => 'values',
        coercion_from_type      => 'get',
        _has_coercion_from_type => 'exists',
        _add_coercion           => 'set',
        has_coercions           => 'count',
    },
    default => sub { {} },
);

my $NullConstraint = sub { 1 };

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    my $p = $class->$orig(@_);

    $p->{constraint}        = delete $p->{where}   if exists $p->{where};
    $p->{message_generator} = delete $p->{message} if exists $p->{message};

    return $p;
};

sub BUILD { }

around BUILD => sub {
    my $orig = shift;
    my $self = shift;

    unless ( $self->_has_constraint() || $self->_has_inline_generator() ) {
        $self->_set_constraint($NullConstraint);
    }

    die
        'A type constraint should have either a constraint or inline_generator parameter, not both'
        if $self->_has_constraint() && $self->_has_inline_generator();

    return;
};

sub validate_or_die {
    my $self  = shift;
    my $value = shift;

    return if $self->value_is_valid($value);

    Type::Exception->throw(
        message => $self->_message_generator()
            ->( $self, $self->_description(), $value ),
        type  => $self,
        value => $value,
    );
}

sub value_is_valid {
    my $self  = shift;
    my $value = shift;

    return $self->_optimized_constraint()->($value);
}

sub _ancestors_and_self {
    my $self = shift;

    return ( ( reverse @{ $self->_ancestors() } ), $self );
}

sub is_anon {
    my $self = shift;

    return !$self->_has_name();
}

sub has_real_constraint {
    my $self = shift;

    return (   $self->_has_constraint
            && $self->_constraint() ne $NullConstraint )
        || $self->_has_inline_generator();
}

sub inline_check {
    my $self = shift;

    die 'Cannot inline' unless $self->_has_inline_generator();

    return $self->_inline_generator()->( $self, @_ );
}

sub _build_optimized_constraint {
    my $self = shift;

    if ( $self->can_be_inlined() ) {
        return $self->_generated_inline_sub();
    }
    else {
        return $self->_constraint_with_parents();
    }
}

sub _constraint_with_parents {
    my $self = shift;

    my @constraints;
    for my $type ( $self->_ancestors_and_self() ) {
        next unless $type->has_real_constraint();

        # If a type can be inlined, we can use that and discard all of the
        # ancestors we've seen so far, since we can assume that the inlined
        # constraint does all of the ancestor checks in addition to its own.
        if ( $type->can_be_inlined() ) {
            @constraints = $type->_generated_inline_sub();
        }
        else {
            push @constraints, $type->_constraint();
        }
    }

    return $NullConstraint unless @constraints;

    return subname(
        'optimized constraint for ' . $self->_description() => sub {
            all { $_->( $_[0] ) } @constraints;
        }
    );
}

# This is only used for identifying from types as part of coercions, but I
# want to leave open the possibility of using something other than
# _description in the future.
sub id {
    my $self = shift;

    return $self->_description();
}

sub add_coercion {
    my $self     = shift;
    my $coercion = shift;

    my $from_id = $coercion->from()->id();

    confess "Cannot add two coercions fom the same type: $from_id"
        if $self->_has_coercion_from_type($from_id);

    $self->_add_coercion( $from_id => $coercion );

    return;
}

sub has_coercion_from_type {
    my $self = shift;
    my $type = shift;

    return $self->_has_coercion_from_type( $type->id() );
}

sub coerce_value {
    my $self  = shift;
    my $value = shift;

    for my $coercion ( $self->coercions() ) {
        next unless $coercion->from()->value_is_valid($value);

        return $coercion->coerce($value);
    }

    die 'Could not find a coercion for '
        . Devel::PartialDump->new()->dump($value);
}

sub can_inline_coercion_and_check {
    my $self = shift;

    return all { $_->can_be_inlined() } $self, $self->coercions();
}

sub inline_coercion_and_check {
    my $self = shift;

    die 'Cannot inline coercion and check'
        unless $self->can_inline_coercion_and_check();

    my %env = (
        '$_Type_Constraint_Interface_type' => \$self,
        '$_Type_Constraint_Interface_message_generator' =>
            \( $self->_message_generator() ),
        '$_Type_Constraint_Interface_description' =>
            \( $self->_description() ),
        %{ $self->_inline_environment() },
    );

    my $source = 'do {' . 'my $value = ' . $_[0] . ';';
    for my $coercion ( $self->coercions() ) {
        $source
            .= '$value = '
            . $coercion->inline_coercion( $_[0] ) . ' if '
            . $coercion->from()->inline_check( $_[0] ) . ';';

        %env = ( %env, %{ $coercion->_inline_environment() } );
    }

    #<<<
    $source
        .= $self->inline_check('$value')
        . ' or Type::Exception->throw( '
            . ' message => $_Type_Constraint_Interface_message_generator->('
                . '   $_Type_Constraint_Interface_type, $_Type_Constraint_Interface_description, $value ), '
            . ' type    => $_Type_Constraint_Interface_type,'
            . ' value   => $value );';
    #>>>
    $source .= '$value };';

    return ( $source, \%env );
}

sub _build_ancestors {
    my $self = shift;

    my @parents;

    my $type = $self;
    while ( $type = $type->parent() ) {
        push @parents, $type;
    }

    return \@parents;

}

sub _build_description {
    my $self = shift;

    my $desc
        = $self->is_anon() ? 'anonymous type' : 'type named ' . $self->name();

    $desc .= q{ } . $self->declared_at()->description();

    return $desc;
}

1;

# ABSTRACT: The interface all type constraints should provide



=pod

=head1 NAME

Type::Constraint::Role::Interface - The interface all type constraints should provide

=head1 VERSION

version 0.02

=head1 DESCRIPTION

This role defines the interface that all type constraints must provide, and
provides most (or all) of the implementation. The L<Type::Constraint::Simple>
class simply consumes this role and provides no additional code. Other
constraint classes add features or override some of this role's functionality.

=head1 API

See the L<Type::Constraint::Simple> documentation for details. See the
internals of various constraint classes to see how this role can be overridden
or expanded upon.

=head1 ROLES

This role does the L<Type::Role::Inlinable> and L<MooseX::Clone> roles.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut


__END__

