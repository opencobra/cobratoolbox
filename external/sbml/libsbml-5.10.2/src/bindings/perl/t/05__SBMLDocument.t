use Test;
BEGIN { plan tests => 36 };

use File::Spec;
use LibSBML;
use strict;
use vars qw/$testDataDir $perlTestDir $file $rd $d $errors $str $pm/;
    
#########################

my $os = 'cygwin';
my @dataPathFrags = (File::Spec->updir(),
                     File::Spec->updir(),
                     qw/sbml test test-data/);
my @testPathFrags = (File::Spec->curdir(), 't');
$testDataDir = File::Spec->catdir(@dataPathFrags);
$perlTestDir = File::Spec->catdir(@testPathFrags);
$rd = new LibSBML::SBMLReader;

# nonexisting file
$file = File::Spec->catfile($testDataDir, 'nonexistent.xml');
$d = $rd->readSBML($file);
$errors = $d->getNumErrors();
ok($errors > 0);
$pm = $d->getError($errors);
ok(!defined($pm));
$pm = $d->getError($errors-1);
ok(defined($pm));
ok($pm->getErrorId(), 2);

# non-sbml file: xsd file
$file = File::Spec->catfile($testDataDir, 'sbml-l1v1.xsd');
$d = $rd->readSBML($file);
$errors = $d->getNumErrors();
ok($errors > 0);
$pm = $d->getError($errors-1);
ok(defined($pm));
ok($pm->getErrorId(),20201);

# non-sbml file
$file = File::Spec->catfile($testDataDir, 'not-sbml.xml');
$d = $rd->readSBML($file);
$errors = $d->getNumErrors();
ok($errors > 0);
$pm = $d->getError($errors-1);
ok(defined($pm));
ok($pm->getErrorId(), 20201);
ok($pm->getLine(), 3);

# proper sbml file l1v1 from file
$file = File::Spec->catfile($testDataDir,'l1v1-branch.xml');
$d = $rd->readSBML($file);
ok($d->getNumErrors(), 0, $d->printErrors());
ok($d->getNumErrors(), 0);
ok($d->checkConsistency(), 6);
ok($d->getLevel(), 1);
ok($d->getVersion(), 1);
# proper sbm file l1v1 from string
$str  = slurp_file($file);
$d = $rd->readSBMLFromString($str) if defined($str);
skip(!defined($str), $d->getNumErrors(), 0);
skip(!defined($str), $d->checkConsistency(), 6);
skip(!defined($str), $d->getLevel(), 1);
skip(!defined($str), $d->getVersion(), 1);

# proper sbm file l1v2 from file
$file = File::Spec->catfile($testDataDir,'l1v2-branch.xml');
$d = $rd->readSBML($file);
ok($d->getNumErrors(), 0);
ok($d->checkConsistency(), 6);
ok($d->getLevel(), 1);
ok($d->getVersion(), 2);
# proper sbm file l1v2 from string
$str  = slurp_file($file);
$d = $rd->readSBMLFromString($str) if defined($str);
skip(!defined($str), $d->getNumErrors(), 0);
skip(!defined($str), $d->checkConsistency(), 6);
skip(!defined($str), $d->getLevel(), 1);
skip(!defined($str), $d->getVersion(), 2);

# proper sbm file l2v1 from file
$file = File::Spec->catfile($testDataDir,'l2v1-branch.xml');
$d = $rd->readSBML($file);
ok($d->getNumErrors(), 0);
ok($d->checkConsistency(), 6);
ok($d->getLevel(), 2);
ok($d->getVersion(), 1);
# proper sbm file l2v1 from string
$str  = slurp_file($file);
$d = $rd->readSBMLFromString($str) if defined($str);
skip(!defined($str), $d->getNumErrors(), 0);
skip(!defined($str), $d->checkConsistency(), 6);
skip(!defined($str), $d->getLevel(), 2);
skip(!defined($str), $d->getVersion(), 1);

#---
sub slurp_file {
    # file is automatically close at block exit
    return do { local $/; <FH> } if open(FH, '<', "@{[shift()]}");
    return undef;
}
