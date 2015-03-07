use Test;
BEGIN { plan tests => 432 };

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
@files = qw/l1v1-branch.xml l1v2-branch.xml l2v1-branch.xml/;

foreach (@files) {
  $level = $1, $version = $2 if m/\Al(\d)v(\d)-/;
  my $file = File::Spec->catfile($testDataDir, $_);
  
  # per file we have:
  # 72 tests for read from file
  # 72 tests for read from string
  # which gives in total for all files 432 tests
  foreach my $d ($rd->readSBML($file),
		 $rd->readSBMLFromString(slurp_file($file))) {

#
    # Ignore unit issues.
    $d->setConsistencyChecks(9, 0);

    ok($d->getLevel(), $level);
    ok($d->getVersion(), $version);
    ok($d->getNumErrors(), 0);
    ok($d->checkConsistency(), 0);

#
    my $m = $d->getModel();
    ok(defined($m));
    ok($m->getName(), 'Branch') if $level == 1;
    ok($m->getId(),   'Branch') if $level == 2;
    ok($m->getNumCompartments(), 1);
    ok($m->getNumSpecies(), 4);
    ok($m->getNumReactions(), 3);

#
    my $c = $m->getCompartment(0);
    ok($c->getName(), 'compartmentOne') if $level == 1;
    ok($c->getId(),   'compartmentOne') if $level == 2;  
    ok($c->getVolume(), 1.0);

#
    my $s = $m->getSpecies(0);
    ok($s->getName(), 'S1') if $level == 1;
    ok($s->getId(),   'S1') if $level == 2;  
    ok($s->getCompartment(), 'compartmentOne');
    ok($s->getInitialAmount(), 0.0);
    ok($s->getBoundaryCondition(), 0);

    $s = $m->getSpecies(1);
    ok($s->getName(), 'X0') if $level == 1;
    ok($s->getId(),   'X0') if $level == 2; 
    ok($s->getCompartment(), 'compartmentOne');
    ok($s->getInitialAmount(), 0.0);
    ok($s->getBoundaryCondition(), 1);

    $s = $m->getSpecies(2);
    ok($s->getName(), 'X1') if $level == 1;
    ok($s->getId(),   'X1') if $level == 2;  
    ok($s->getCompartment(), 'compartmentOne');
    ok($s->getInitialAmount(), 0.0);
    ok($s->getBoundaryCondition(), 1);

    $s = $m->getSpecies(3);
    ok($s->getName(), 'X2') if $level == 1;
    ok($s->getId(),   'X2') if $level == 2;  
    ok($s->getCompartment(), 'compartmentOne');
    ok($s->getInitialAmount(), 0.0);
    ok($s->getBoundaryCondition(), 1);

#
    my $r = $m->getReaction(0);
    ok($r->getName(), 'reaction_1') if $level == 1;
    ok($r->getId(),   'reaction_1') if $level == 2;  
    ok($r->getReversible(), 0);
    ok($r->getFast(), 0);
    ok($r->getNumReactants(), 1);
    ok($r->getNumProducts(), 1);
    my $sr = $r->getReactant(0);
    ok($sr->getSpecies(), 'X0');
    ok($sr->getStoichiometry(), 1);
    ok($sr->getDenominator(), 1);
    $sr = $r->getProduct(0);
    ok($sr->getSpecies(), 'S1');
    ok($sr->getStoichiometry(), 1);
    ok($sr->getDenominator(), 1);
    my $kl = $r->getKineticLaw();
    ok($kl->getFormula(), 'k1 * X0');
    ok($kl->getNumParameters(), 1);
    my $p = $kl->getParameter(0);
    ok($p->getName(), 'k1') if $level == 1;
    ok($p->getId(),   'k1') if $level == 2;  
    ok($p->getValue(), 0);

    $r = $m->getReaction(1);
    ok($r->getName(), 'reaction_2') if $level == 1;
    ok($r->getId(),   'reaction_2') if $level == 2;  
    ok($r->getReversible(), 0);
    ok($r->getFast(), 0);
    ok($r->getNumReactants(), 1);
    ok($r->getNumProducts(), 1);
    $sr = $r->getReactant(0);
    ok($sr->getSpecies(), 'S1');
    ok($sr->getStoichiometry(), 1);
    ok($sr->getDenominator(), 1);
    $sr = $r->getProduct(0);
    ok($sr->getSpecies(), 'X1');
    ok($sr->getStoichiometry(), 1);
    ok($sr->getDenominator(), 1);
    $kl = $r->getKineticLaw();
    ok($kl->getFormula(), 'k2 * S1');
    ok($kl->getNumParameters(), 1);
    $p = $kl->getParameter(0);
    ok($p->getName(), 'k2') if $level == 1;
    ok($p->getId(),   'k2') if $level == 2;
    ok($p->getValue(), 0);

    $r = $m->getReaction(2);
    ok($r->getName(), 'reaction_3') if $level == 1;
    ok($r->getId(),   'reaction_3') if $level == 2;
    ok($r->getReversible(), 0);
    ok($r->getFast(), 0);
    ok($r->getNumReactants(), 1);
    ok($r->getNumProducts(), 1);
    $sr = $r->getReactant(0);
    ok($sr->getSpecies(), 'S1');
    ok($sr->getStoichiometry(), 1);
    ok($sr->getDenominator(), 1);
    $sr = $r->getProduct(0);
    ok($sr->getSpecies(), 'X2');
    ok($sr->getStoichiometry(), 1);
    ok($sr->getDenominator(), 1);
    $kl = $r->getKineticLaw();
    ok($kl->getFormula(), 'k3 * S1');
    ok($kl->getNumParameters(), 1);
    $p = $kl->getParameter(0);
    ok($p->getName(), 'k3') if $level == 1;
    ok($p->getId(),   'k3') if $level == 2;
    ok($p->getValue(), 0);
  }
}

#---
sub slurp_file {
    # file is automatically close at block exit
    return do { local $/; <FH> } if open(FH, "< @{[shift()]}");
    return undef;
}
