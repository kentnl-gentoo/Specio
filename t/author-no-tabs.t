
BEGIN {
  unless ($ENV{AUTHOR_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for testing by the author');
  }
}

use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.15

use Test::More 0.88;
use Test::NoTabs;

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
    'lib/Specio/Declare.pm',
    'lib/Specio/DeclaredAt.pm',
    'lib/Specio/Exception.pm',
    'lib/Specio/Exporter.pm',
    'lib/Specio/Helpers.pm',
    'lib/Specio/Library/Builtins.pm',
    'lib/Specio/OO.pm',
    'lib/Specio/Registry.pm',
    'lib/Specio/Role/Inlinable.pm',
    'lib/Specio/TypeChecks.pm',
    't/00-report-prereqs.dd',
    't/00-report-prereqs.t',
    't/anon.t',
    't/author-00-compile.t',
    't/author-eol.t',
    't/author-mojibake.t',
    't/author-no-tabs.t',
    't/author-pod-spell.t',
    't/author-pod-syntax.t',
    't/author-test-version.t',
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
    't/lib/Specio/Library/XY.pm',
    't/multiple-libraries.t',
    't/parameterized.t',
    't/release-cpan-changes.t',
    't/release-pod-coverage.t',
    't/release-pod-linkcheck.t',
    't/release-portability.t',
    't/release-tidyall.t',
    't/t-clean.t',
    't/with-moo.t',
    't/with-moose.t'
);

notabs_ok($_) foreach @files;
done_testing;
