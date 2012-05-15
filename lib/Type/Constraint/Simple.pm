package Type::Constraint::Simple;
{
  $Type::Constraint::Simple::VERSION = '0.02'; # TRIAL
}

use strict;
use warnings;
use namespace::autoclean;

use Moose;

with 'Type::Constraint::Role::Interface';

__PACKAGE__->meta()->make_immutable();

1;

# ABSTRACT: Class for simple (non-parameterized or specialized) types



=pod

=head1 NAME

Type::Constraint::Simple - Class for simple (non-parameterized or specialized) types

=head1 VERSION

version 0.02

=head1 SYNOPSIS

  my $str = t('Str');

  print $str->name(); # Str

  my $parent = $str->parent();

  if ( $str->value_is_valid($value) ) { ... }

  $str->validate_or_die($value);

  my $code = $str->inline_coercion_and_check('$_[0]');

=head1 DESCRIPTION

This class implements simple type constraints, constraints without special
properties or parameterization.

It does not actually contain any real code of its own. The entire
implementation is provided by the L<Type::Constraint::Role::Interface> role,
but the primary API for type constraints is documented here.

All other type constraint classes in this distribution implement this API,
except where otherwise noted.

=head1 API

This class provides the following methods.

=head2 Type::Constraint::Simple->new(...)

This creates a new constraint. It accepts the following named parameters:

=over 4

=item * name => $name

This is the type's name. The name is optional, but if provided it must be a
string.

=item * parent => $type

The type's parent type. This must be an object which does the
L<Type::Constraint::Role::Interface> role.

This parameter is optional.

=item * constraint => sub { ... }

A subroutine reference implementing the constraint. It will be called as a
method on the object and passed a single argument, the value to check.

It should return true or false to indicate whether the value matches the
constraint.

This parameter is mutually exclusive with C<inline_generator>.

You can also pass this option with the key C<where> in the parameter list.

=item * inline_generator => sub { ... }

This should be a subroutine reference which returns a string containing a
single term. This code should I<not> end in a semicolon. This code should
implement the constraint.

The generator will be called as a method on the constraint with a single
argument. That argument is the name of the variable being coerced, something
like C<'$_[0]'> or C<'$var'>.

This parameter is mutually exclusive with C<constraint>.

You can also pass this option with the key C<inline> in the parameter list.

=item * inline_environment => {}

This should be a hash reference of variable names (with sigils) and values for
that variable. The values should be I<references> to the values of the
variables.

This environment will be used when compiling the constraint as part of a
subroutine. The named variables will be captured as closures in the generated
subroutine, using L<Eval::Closure>.

It should be very rare to need to set this in the constructor. It's more
likely that a special type subclass would need to provide values that it
generates internally.

This parameter defaults to an empty hash reference.

=item * message_generator => sub { ... }

A subroutine to generate an error message when the type check fails. The
default message says something like "Validation failed for type named Int
declared in package Type::Library::Builtins
(.../Type/blib/lib/Type/Library/Builtins.pm) at line 147 in sub named (eval)
with value 1.1".

You can override this to provide something more specific about the way the
type failed.

The subroutine you provide will be called as a method on the type with two
arguments. The first is the description of the type (the bit in the message
above that starts with "type named Int ..." and ends with "... in sub named
(eval)". This description says what the thing is and where it was defined.

The second argument is the value that failed the type check, after any
coercions that might have been applied.

The inline generator is expected to include code to implement both the current
type and all its parents. Typically, the easiest way to do this is to write a
subroutine something like this:

  sub {
      my $self = shift;
      my $var  = shift;

      return $_[0]->parent()->inline_check( $_[1] )
          . ' and more checking code goes here';
  }

You can also pass this option with the key C<message> in the parameter list.

=item * declared_at => $declared_at

This parameter must be a L<Type::DeclaredAt> object.

This parameter is required.

=back

It is possible to create a type without a constraint of its own.

=head2 $type->name(), $type->parent()

Returns the value of these parameters as they were passed to the constructor.

=head2 $type->is_anon()

Returns false for named types, true otherwise.

=head2 $type->coercions()

Returns a list of L<Type::Coercion> objects which belong to this constraint.

=head2 $type->coercion_from_type($name)

Given a type name, this method returns a L<Type::Coercion> object which
coerces from that type, if such a coercion exists.

=head2 $type->validate_or_die($value)

This method does nothing if the value is valid. If it is not, it throws a
L<Type::Exception>.

=head2 $type->value_is_valid($value)

Returns true or false depending on whether the C<$value> passes the type
constraint.

=head2 $type->has_real_constraint()

This returns true if the type was created with a C<constraint> or
C<inline_generator> parameter. This is used internally to skip type checks for
types that don't actually implement a constraint.

=head2 $type->inline_check($var)

Given a variable name, this returns a string of code that implements the
constraint. If the type is not inlinable, this method throws an error.

=head2 $type->id()

This is a unique id for the type as a string. This is useful if you need to
make a hash key based on a type, for example.

=head2 $type->add_coercion($coercion)

This adds a new L<Type::Coercion> to the type. If the type already has a
coercion from the same type as the new coercion, it will throw an error.

=head2 $type->has_coercion_from_type($other_type)

This method returns true if the type can coerce from the other type.

=head2 $type->coerce_value($value)

This attempts to coerce a value into a new value that matches the type. It
checks all of the type's coercions. If it finds one which has a "from" type
that accepts the value, it runs the coercion and returns the new value.

If it cannot find a matching coercion it throws an error.

=head2 $type->inline_coercion_and_check($var)

Given a variable name, this returns a string of code and an environment hash
that implements all of the type's coercions as well as the type check itself.

This will throw an exception unless both the type and all of its coercions are
inlinable.

The generated code will throw a L<Type::Exception> if the type constraint
fails. If the constraint passes, then the generated code returns the (possibly
coerced) value.

The return value is a two-element list. The first element is the code. The
second is a hash reference containing variables which need to be in scope for
the code to work. This is intended to be passed to L<Eval::Closure>'s
C<eval_closure> subroutine.

The returned code is a single C<do { }> block without a terminating
semicolon.

=head1 ROLES

This role does the L<Type::Constraint::Role::Interface>,
L<Type::Role::Inlinable> and L<MooseX::Clone> roles.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut


__END__

