use 5.006;
use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::Compile 2.054

use Test::More;

plan tests => 27;

my @module_files = (
    'Specio.pm',
    'Specio/Coercion.pm',
    'Specio/Constraint/AnyCan.pm',
    'Specio/Constraint/AnyDoes.pm',
    'Specio/Constraint/AnyIsa.pm',
    'Specio/Constraint/Enum.pm',
    'Specio/Constraint/ObjectCan.pm',
    'Specio/Constraint/ObjectDoes.pm',
    'Specio/Constraint/ObjectIsa.pm',
    'Specio/Constraint/Parameterizable.pm',
    'Specio/Constraint/Parameterized.pm',
    'Specio/Constraint/Role/CanType.pm',
    'Specio/Constraint/Role/DoesType.pm',
    'Specio/Constraint/Role/Interface.pm',
    'Specio/Constraint/Role/IsaType.pm',
    'Specio/Constraint/Simple.pm',
    'Specio/Declare.pm',
    'Specio/DeclaredAt.pm',
    'Specio/Exception.pm',
    'Specio/Exporter.pm',
    'Specio/Helpers.pm',
    'Specio/Library/Builtins.pm',
    'Specio/OO.pm',
    'Specio/Registry.pm',
    'Specio/Role/Inlinable.pm',
    'Specio/TypeChecks.pm'
);



# no fake home requested

my $inc_switch = -d 'blib' ? '-Mblib' : '-Ilib';

use File::Spec;
use IPC::Open3;
use IO::Handle;

open my $stdin, '<', File::Spec->devnull or die "can't open devnull: $!";

my @warnings;
for my $lib (@module_files)
{
    # see L<perlfaq8/How can I capture STDERR from an external command?>
    my $stderr = IO::Handle->new;

    my $pid = open3($stdin, '>&STDERR', $stderr, $^X, $inc_switch, '-e', "require q[$lib]");
    binmode $stderr, ':crlf' if $^O eq 'MSWin32';
    my @_warnings = <$stderr>;
    waitpid($pid, 0);
    is($?, 0, "$lib loaded ok");

    shift @_warnings if @_warnings and $_warnings[0] =~ /^Using .*\bblib/
        and not eval { require blib; blib->VERSION('1.01') };

    if (@_warnings)
    {
        warn @_warnings;
        push @warnings, @_warnings;
    }
}



is(scalar(@warnings), 0, 'no warnings found')
    or diag 'got warnings: ', ( Test::More->can('explain') ? Test::More::explain(\@warnings) : join("\n", '', @warnings) );


