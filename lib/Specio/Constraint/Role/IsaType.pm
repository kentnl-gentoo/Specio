package Specio::Constraint::Role::IsaType;
$Specio::Constraint::Role::IsaType::VERSION = '0.09'; # TRIAL
use strict;
use warnings;

use Storable qw( dclone );

use Role::Tiny;

use Specio::Constraint::Role::Interface;
with 'Specio::Constraint::Role::Interface';

{
    my $attrs = dclone( Specio::Constraint::Role::Interface::_attrs() );

    for my $name (qw( parent _inline_generator )) {
        $attrs->{$name}{init_arg} = undef;
        $attrs->{$name}{builder} = '_build_' . ( $name =~ s/^_//r );
    }

    $attrs->{class} = {
        isa      => 'ClassName',
        required => 1,
    };

    sub _attrs {
        return $attrs;
    }
}

sub _wrap_message_generator {
    my $self      = shift;
    my $generator = shift;

    my $class = $self->class();

    $generator //= sub {
        my $description = shift;
        my $value       = shift;

        return
              "Validation failed for $description with value "
            . Devel::PartialDump->new()->dump($value)
            . '(not isa '
            . $class . ')';
    };

    my $d = $self->_description();

    return sub { $generator->( $d, @_ ) };
}

1;

# ABSTRACT: Provides a common implementation for Specio::Constraint::AnyIsa and Specio::Constraint::ObjectIsa

__END__

=pod

=head1 NAME

Specio::Constraint::Role::IsaType - Provides a common implementation for Specio::Constraint::AnyIsa and Specio::Constraint::ObjectIsa

=head1 VERSION

version 0.09

=head1 DESCRIPTION

See L<Specio::Constraint::AnyIsa> and L<Specio::Constraint::ObjectIsa> for details.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
