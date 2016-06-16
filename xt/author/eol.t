use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::EOL 0.18

use Test::More 0.88;
use Test::EOL;

my @files = (
    'lib/Specio.pm',
    'lib/Specio/Coercion.pm',
    'lib/Specio/Constraint/AnyCan.pm',
    'lib/Specio/Constraint/AnyDoes.pm',
    'lib/Specio/Constraint/AnyIsa.pm',
    'lib/Specio/Constraint/Enum.pm',
    'lib/Specio/Constraint/ObjectCan.pm',
    'lib/Specio/Constraint/ObjectDoes.pm',
    'lib/Specio/Constraint/ObjectIsa.pm',
    'lib/Specio/Constraint/Parameterizable.pm',
    'lib/Specio/Constraint/Parameterized.pm',
    'lib/Specio/Constraint/Role/CanType.pm',
    'lib/Specio/Constraint/Role/DoesType.pm',
    'lib/Specio/Constraint/Role/Interface.pm',
    'lib/Specio/Constraint/Role/IsaType.pm',
    'lib/Specio/Constraint/Simple.pm',
    'lib/Specio/Constraint/Union.pm',
    'lib/Specio/Declare.pm',
    'lib/Specio/DeclaredAt.pm',
    'lib/Specio/Exception.pm',
    'lib/Specio/Exporter.pm',
    'lib/Specio/Helpers.pm',
    'lib/Specio/Library/Builtins.pm',
    'lib/Specio/Library/Numeric.pm',
    'lib/Specio/Library/Perl.pm',
    'lib/Specio/Library/String.pm',
    'lib/Specio/OO.pm',
    'lib/Specio/Registry.pm',
    'lib/Specio/Role/Inlinable.pm',
    'lib/Specio/TypeChecks.pm',
    't/00-report-prereqs.dd',
    't/00-report-prereqs.t',
    't/anon.t',
    't/builtins-sanity.t',
    't/builtins.t',
    't/coercion.t',
    't/combines.t',
    't/conflicts.t',
    't/declare-helpers.t',
    't/does-type.t',
    't/exception.t',
    't/inline-environment.t',
    't/inline.t',
    't/lib/Specio/Library/Combines.pm',
    't/lib/Specio/Library/Conflict.pm',
    't/lib/Specio/Library/Union.pm',
    't/lib/Specio/Library/XY.pm',
    't/lib/Test/Types.pm',
    't/multiple-libraries.t',
    't/numeric-sanity.t',
    't/parameterized.t',
    't/perl-sanity.t',
    't/string-sanity.t',
    't/t-clean.t',
    't/union-library.t',
    't/union.t',
    't/with-moo.t',
    't/with-moose.t'
);

eol_unix_ok($_, { trailing_whitespace => 1 }) foreach @files;
done_testing;