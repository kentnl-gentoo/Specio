package Type::Constraint::Role::CanType;
{
  $Type::Constraint::Role::CanType::VERSION = '0.02'; # TRIAL
}

use strict;
use warnings;

use Lingua::EN::Inflect qw( PL_N WORDLIST );
use Scalar::Util qw( blessed );

use Moose::Role;

with 'Type::Constraint::Role::Interface';

has methods => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
);

my $_default_message_generator = sub {
    my $self  = shift;
    my $thing = shift;
    my $value = shift;

    my @methods = grep { !$value->can($_) } @{ $self->methods() };
    my $class = blessed $value;
    $class ||= $value;

    my $noun = PL_N( 'method', scalar @methods );

    return
          $class
        . ' is missing the '
        . WORDLIST( map { "'$_'" } @methods ) . q{ }
        . $noun;
};

sub _default_message_generator { return $_default_message_generator }

override BUILDARGS => sub {
    my $self = shift;

    my $p = super();

    if ( defined $p->{can} && !ref $p->{can} ) {
        $p->{can} = [ $p->{can} ];
    }

    return $p;
};

1;

# ABSTRACT: Provides a common implementation for Type::Constraint::AnyCan and Type::Constraint::ObjectCan



=pod

=head1 NAME

Type::Constraint::Role::CanType - Provides a common implementation for Type::Constraint::AnyCan and Type::Constraint::ObjectCan

=head1 VERSION

version 0.02

=head1 DESCRIPTION

See L<Type::Constraint::AnyCan> and L<Type::Constraint::ObjectCan> for details.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut


__END__

