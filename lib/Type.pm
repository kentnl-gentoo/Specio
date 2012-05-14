package Type;
{
  $Type::VERSION = '0.01'; # TRIAL
}

use strict;
use warnings;

1;

# ABSTRACT: Type constraints and coercions for Perl



=pod

=head1 NAME

Type - Type constraints and coercions for Perl

=head1 VERSION

version 0.01

=head1 SYNOPSIS

  package MyApp::Type::Library;

  use Type::Declare;
  use Type::Library::Builtins;

  declare(
      'PositiveInt',
      parent => t('Int'),
      inline => sub {
          $_[0]->parent()->inline_check( $_[1] ) . ' && ( ' . $_[1] . ' > 0';
      },
  );

  # or ...

  declare(
      'PositiveInt',
      parent => t('Int'),
      where  => sub { $_[0] > 0 },
  );

  declare(
      'ArrayRefOfPositiveInt',
      parent => t(
          'ArrayRef',
          of => t('PositiveInt'),
      ),
  );

  coerce(
      'ArrayRefOfPositiveInt',
      from  => t('PositiveInt'),
      using => sub { [ $_[0] ] },
  );

  any_can_type(
      'Duck',
      methods => [ 'duck_walk', 'quack' ],
  );

  object_isa_type('MyApp::Person');

=head1 DESCRIPTION

B<WARNING: This thing is very alpha.>

The C<Type> distribution provides classes for representing type constraints
and coercion, along with syntax sugar for declaring them.

Note that this is not a proper type system for Perl. Nothing in this
distribution will magically make the Perl interpreter start checking a value's
type on assignment to a variable. In fact, there's no built-in way to apply a
type to a variable at all.

Instead, you can explicitly check a value against a type, and optionally
coerce values to that type.

My long-term goal is to replace Moose's built-in types and L<MooseX::Types>
with this module.

=head1 WHAT IS A TYPE?

At it's core, a type is simply a constraint. A constraint is code that checks
a value and returns true or false. Most constraints are represented by
L<Type::Constraint::Simple> objects, though there are some other type
constraint classes for specialized constraint types.

Types can be named or anonymous, and they can have a parent type. A type has
an optional constraint. The constraint is optional because sometimes you want
to make a named subtype of some existing parent without adding additional
constraints.

Constraints can be expressed either in terms of a simple subroutine reference
or in terms of an inline generator subroutine reference. The former is easier
to write, but the latter is preferred, since it allow for much more extensive
optimizations.

A type can also have an optional message generator subroutine reference. You
can use this to provide a more intelligent error message when a value does not
pass the constraint, though the default message should suffice for more cases.

Finally, you can associate a set of coercions with a type. A coercion is a
subroutine reference (or inline generator, like constraints), that takes a
value of one type and turns it into a value that matches the type the coercion
belongs to.

=head1 BUILTIN TYPES

This distribution ships with a set of builtin types representing the types
provided by the Perl interpreter itself. They are arranged in a hierarchy as
follows:

  Item
      Bool
      Maybe (of `a)
      Undef
      Defined
          Value
              Str
                  Num
                      Int
                  ClassName
          Ref
              ScalarRef (of `a)
              ArrayRef (of `a)
              HashRef (of `a)
              CodeRef
              RegexpRef
              GlobRef
              FileHandle
              Object

The C<Item> type accepts anything and everything.

The C<Bool> type only accepts C<undef>, C<0>, or C<1>.

The C<Undef> type only accepts C<undef>.

The C<Defined> type accepts anything I<except> C<undef>.

The C<Num> and C<Int> types are stricter about numbers than Perl
is. Specifically, they do not allow any sort of space in the number, nor do
they accept "Nan", "Inf", or "Infinity".

The C<ClassName> type constraint checks that the name is valid I<and> that the
class is loaded.

The C<FileHandle> type accepts either a glob, a scalar filehandle, or anything
that isa L<IO::Handle>.

All types accept overloaded objects that support the required operation. See
below for details.

=head2 Overloading

Perl's overloading is horribly broken and doesn't make much sense at all.

However, unlike Moose, all type constraints allow overloaded objects where
they make sense.

For types where overloading makes sense, we explicitly check that the object
provides the type overloading we expect. We I<do not> simply try to use the
object as the type and question and hope it works. This means that these
checks effective ignore the C<fallback> setting for the overloaded object. In
other words, an object that overloads stringification will not pass the
C<Bool> type check unless it I<also> overloads boolification.

Most types do not check that the overloaded method actually returns something
that matches the constraint. This may change in the future.

The C<Bool> type accepts an object that provides C<bool> overloading.

The C<Str> type accepts an object that provides string (C<q{""}>) overloading.

The C<Num> type accepts an object that provides numeric C<'0+'}>
overloading. The C<Int> type does as well, but it will check that the
overloading returns an actual integer.

The C<ClassName> type will accept an object with string overloading that
returns a class name.

To make this all more confusing, the C<Value> type will I<never> accept an
object, even though some it's subtypes will.

The various reference types all accept objects which provide the appropriate
overloading. The C<FileHandle> type accepts an object which overloads
globification as long as the returned glob is an open filehandle.

=head1 PARAMETERIZABLE TYPES

Any type followed by a type parameter C<of `a> in the hierarchy above can be
parameterized. The parameter is itself a type, so you can say you want an
"ArrayRef of Int", or even an "ArrayRef of HashRef of ScalarRef of ClassName".

When they are parameterized, the C<ScalarRef> and C<ArrayRef> types check that
the value(s) they refer to match the type parameter. For the C<HashRef> type,
the parameter applies to the values (keys are never checked).

=head2 Maybe

The C<Maybe> type is a special parameterized type. It allows for either
C<undef> or a value. All by itself, it is meaningless, since it is equivalent
to "Maybe of Item", which is equivalent to Item. When parameterized, it
accepts either an C<undef> or the its parameter.

This is useful for optional attributes or parameters. However, whenever
possible, you're often better off making the parameter not required at
all. This usually makes for a simpler API.

=head1 REGISTRIES AND IMPORTING

Types are local to each package where they are used. When you "import" types
from some other library, you are actually making a copy of that type.

This means that a type named "Foo" in one package may not be the same as "Foo"
in another package. This has potential for confusion, but it also avoids the
magic action at a distance pollution that comes with a global type naming
system.

The registry is managed internally by the Type distribution's modules, and is
not exposed to your code. To access a type, you always call C<t('TypeName')>.

This returns the named type, or dies if no such type exists.

Because types are always copied on import, it's safe to create coercions on
any type. Your coercion from C<Str> to C<Int> will not be seen by any other
package, unless that package explicitly imports your C<Int> type.

When you import types, you import every type defined in the package you import
from. However, you I<can> overwrite an imported type with your own type
definition. You I<cannot> define the same type twice internally.

=head1 CREATING A TYPE LIBRARY

By default, all types created inside a package are invisible to other
packages. If you want to create a type library, you need to inherit from
L<Type::Exporter> package:

  package MyApp::Type::Library;

  use parent 'Type::Exporter';

  use Type::Declare;
  use Type::Library::Builtins;

  declare(
      'Foo',
      parent => t('Str'),
      where  => sub { $_[0] =~ /foo/i },
  );

Now the L<MyApp::Type::Library> package will export a single type named
C<Foo>. It I<does not> (yet) re-export the types provided by
L<Type::Library::Builtins>.

If you want to make your library re-export some other libraries types, you can
ask for this explicitly:

  package MyApp::Type::Library;

  use parent 'Type::Exporter';

  use Type::Declare;
  use Type::Library::Builtins -reexport;

  declare( 'Foo, ... );

Now L<MyApp::Types::Library> exports any types it defines, as well as all the
types defined in L<Type::Library::Builtins>.

=head1 DECLARING TYPES

Use the L<Type::Declare> module to declare types. It exports a set of helpers
for declaring types. See that module's documentation for more details on these
helpers.

=head1 Moose, MooseX::Types, and Type

This module aims to supplant both L<Moose>'s built-in type system (see
L<Moose::Util::TypeConstraints> aka MUTC) and L<MooseX::Types>, which attempts
to patch some of the holes in the Moose built-in type design.

Here are some of the salient differences:

=over 4

=item * Type names are strings, but they're not global

Unlike Moose and MooseX::Types, type names are always local to the current
package. There is no possibility of name collision between different modules,
so you can safely use short types names for code.

Unlike MooseX::Types, types are strings, so there is no possibility of
colliding with existing class or subroutine names.

=item * No type auto-creation

Types are always retrieved using the C<t()> subroutine. If you pass an unknown
name to this subroutine it dies. This is different from Moose and
MooseX::Types, which assume that unknown names are class names.

=item * Exceptions are objects

The C<< $type->validate_or_die() >> method throws a L<Type::Exception> object
on failure, not a string.

=item * Anon types are explicit

With L<Moose> and L<MooseX::Types>, you use the same subroutine, C<subtype()>,
to declare both named and anonymous types. With Type, you use C<declare()> for
named types and C<anon()> for anonymous types.

=item * Class and object types are separate

Moose and MooseX::Types have C<class_type> and C<duck_type>. The former type
requires an object, while the latter accepts a class name or object.

In Type, the distinction between accepting an object versus object or class is
explicit. There are four declaration helpers, C<object_can_type>,
C<object_isa_type>, C<any_can_type>, and C<any_isa_type>.

=item * Types can either have a constraint or inline generator, not both

Moose and MooseX::Types types can be defined with a subroutine reference as
the constraint, an inline generator subroutine, or both. This is purely for
backwards compatibility, and it makes the internals more complicated than they
need to be.

With Type, a constraint can have I<either> a subroutine reference or an inline
generator, not both.

=item * Coercions can be inlined

I simply never got around to implementing this in Moose.

=item * No crazy coercion features

Moose has some bizarre (and mostly) undocumented features relating to
coercions and parameterizable types. This is a misfeature.

=back

=head1 BUGS

Please report any bugs or feature requests to C<bug-type@rt.cpan.org>, or
through the web interface at L<http://rt.cpan.org>.  I will be notified, and
then you'll automatically be notified of progress on your bug as I make
changes.

=head1 DONATIONS

If you'd like to thank me for the work I've done on this module, please
consider making a "donation" to me via PayPal. I spend a lot of free time
creating free software, and would appreciate any support you'd care to offer.

Please note that B<I am not suggesting that you must do this> in order for me
to continue working on this particular software. I will continue to do so,
inasmuch as I have in the past, for as long as it interests me.

Similarly, a donation made in this way will probably not make me work on this
software much more, unless I get so many donations that I can consider working
on free software full time, which seems unlikely at best.

To donate, log into PayPal and send money to autarch@urth.org or use the
button on this page: L<http://www.urth.org/~autarch/fs-donation.html>

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut


__END__


