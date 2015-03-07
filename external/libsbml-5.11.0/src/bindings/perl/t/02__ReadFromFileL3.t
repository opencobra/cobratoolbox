use Test;
BEGIN { plan tests => 68 };

use File::Spec;
use LibSBML;
use strict;
use vars qw/$testDataDir @files $rd $level $version/;

#########################

my @dataPathFrags = (File::Spec->updir(),
                     File::Spec->updir(),
                     qw/sbml test test-data/);
$testDataDir = File::Spec->catdir(@dataPathFrags);
$level = 1;
$version = 1;
$rd = new LibSBML::SBMLReader;
@files = qw/l3v1-new-invalid.xml/;

foreach (@files) {
  $level = 3;
  $version = 1;
  my $file = File::Spec->catfile($testDataDir, $_);
  
  foreach my $d ($rd->readSBML($file),
		 $rd->readSBMLFromString(slurp_file($file))) {

#
    # Ignore unit issues.
    $d->setConsistencyChecks(9, 0);

    ok($d->getLevel(), $level);
    ok($d->getVersion(), $version);

#
    my $m = $d->getModel();
    ok(defined($m));
    ok($m->getTimeUnits(),   'second');
    ok($m->getSubstanceUnits(),   'mole');
    ok($m->getExtentUnits(),   'mole');
    ok($m->getLengthUnits(),   'metre');
    ok($m->getAreaUnits(),   'metre');
    ok($m->getVolumeUnits(),   'litre');
    ok($m->getConversionFactor(),   'p');
    ok($m->getNumUnitDefinitions(), 2);
    ok($m->getNumCompartments(), 3);
    ok($m->getNumSpecies(), 2);
    ok($m->getNumParameters(), 3);
    ok($m->getNumReactions(), 3);
#
    my $c = $m->getCompartment(0);
    ok(defined($c));
    ok($c->getSpatialDimensions(), 3);
    
#
    my $c1 = $m->getCompartment(2);
    ok(defined($c1));
    ok($c1->getSpatialDimensionsAsDouble(), 4.6);
#
    my $s = $m->getSpecies(0);
    ok(defined($s));
    ok($s->getConversionFactor(), 'p');
    
#
    my $r = $m->getReaction(0);
    ok(defined($r));
    ok($s->getCompartment(), 'comp');
    
#
    my $kl = $r->getKineticLaw();
    ok(defined($kl));
    ok($kl->getNumLocalParameters(), 2);
    ok($kl->getNumParameters(), 2);
    
#
    my $lp = $kl->getLocalParameter(0);
    ok(defined($lp));
    ok($lp->getId(), 'k1');
    ok($lp->getValue(), 0.1);
    ok($lp->getUnits(), 'per_second');
    
#
    my $lp1 = $kl->getParameter(1);
    ok(defined($lp1));
    ok($lp1->getId(), 'k2');
#
    my $sr = $r->getReactant(0);
    ok(defined($sr));
    ok($sr->getConstant(), 1);
   
    
  }
}

#---
sub slurp_file {
    # file is automatically close at block exit
    return do { local $/; <FH> } if open(FH, "< @{[shift()]}");
    return undef;
}
