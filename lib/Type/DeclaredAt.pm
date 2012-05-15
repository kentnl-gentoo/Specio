package Type::DeclaredAt;
{
  $Type::DeclaredAt::VERSION = '0.02'; # TRIAL
}

use strict;
use warnings;

use Moose;

has package => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has filename => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has line => (
    is       => 'ro',
    isa      => 'Int',
    required => 1,
);

has subroutine => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_subroutine',
);

sub new_from_caller {
    my $class = shift;
    my $depth = shift;

    my %p;
    @p{qw( package filename line )} = ( caller($depth) )[ 0, 1, 2 ];

    my $sub = ( caller( $depth + 1 ) )[3];
    $p{subroutine} = $sub if defined $sub;

    return $class->new(%p);
}

sub description {
    my $self = shift;

    my $package  = $self->package();
    my $filename = $self->filename();
    my $line     = $self->line();

    my $desc = "declared in package $package ($filename) at line $line";
    if ( $self->has_subroutine() ) {
        $desc .= ' in sub named ' . $self->subroutine();
    }

    return $desc;
}

__PACKAGE__->meta()->make_immutable();

1;

# ABSTRACT: A class to represent where a type or coercion was declared



=pod

=head1 NAME

Type::DeclaredAt - A class to represent where a type or coercion was declared

=head1 VERSION

version 0.02

=head1 SYNOPSIS

  my $declared = Type::DeclaredAt->new_from_caller(1);

  print $declared->description();

=head1 DESCRIPTION

This class provides a thin wrapper around some of the return values from
Perl's C<caller()> built-in. It's used internally to identify where types and
coercions are being declared, which is useful when generating error messages.

=head1 API

This class provides the following methods.

=head2 Type::DeclaredAt->new_from_caller($depth)

Given a call stack depth, this method returns a new C<Type::DeclaredAt>
object.

=head2 $declared_at->package(), $declared_at->filename(), $declared_at->line()

Returns the call stack information recorded when the object was created. These
values are always populated.

=head2 $declared_at->subroutine()

Returns the subroutine from the call stack. This may be an C<udnef>

=head2 $declared_at->has_subroutine()

Returns true if there is a subroutine name associated with this object.

=head2 $declared_at->description()

Puts all the information together into a single string like "declared in
package Foo::Bar (.../Foo/Bar.pm) at line 42 in sub named blah".

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut


__END__

