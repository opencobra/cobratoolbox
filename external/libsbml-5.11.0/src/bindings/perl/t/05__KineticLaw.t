use Test;
BEGIN { plan tests => 72 };

use LibSBML;
use strict;
use vars qw/$formula $f $tu $su $math $m/;

#########################

my $level   = 2;
my $version = 4;

$tu = 'seconds';
$su = 'ug';
$formula = 'k1*X0';
$f = '';
$math = 'k3/k2';
$m = '';

# create w/ formula
my $kl = new LibSBML::KineticLaw($level,$version);
$kl->setFormula($formula);
ok($kl->setTimeUnits($tu), $LibSBML::LIBSBML_UNEXPECTED_ATTRIBUTE);
ok($kl->setSubstanceUnits($su), $LibSBML::LIBSBML_UNEXPECTED_ATTRIBUTE);
ok($kl->getTypeCode() == $LibSBML::SBML_KINETIC_LAW);
ok($kl->getMetaId(), '');
ok($kl->getNotes(), undef);
ok($kl->getAnnotation(), undef);
ok($kl->isSetFormula(), 1);
ok($kl->getFormula(), $formula);
ok($kl->isSetTimeUnits(), 0);
ok($kl->getTimeUnits(), "");
ok($kl->isSetSubstanceUnits(), 0);
ok($kl->getSubstanceUnits(), "");
ok($kl->isSetMath(), 1);
($f = LibSBML::formulaToString($kl->getMath())) =~ s/\s+//g;
ok($f, $formula);
ok($kl->getNumParameters(), 0);

# create w/o arguments
$kl = new LibSBML::KineticLaw($level,$version);
ok($kl->getTypeCode() == $LibSBML::SBML_KINETIC_LAW);
ok($kl->getMetaId(), '');
ok($kl->getNotes(), undef);
ok($kl->getAnnotation(), undef);
ok($kl->isSetFormula(), 0);
ok($kl->getFormula(), '');
ok($kl->isSetTimeUnits(), 0);
ok($kl->getTimeUnits(), '');
ok($kl->isSetSubstanceUnits(), 0);
ok($kl->getSubstanceUnits(), '');
ok($kl->isSetMath(), 0);
ok($kl->getMath(), undef);
ok($kl->getNumParameters(), 0);    

# set/get formula
$kl->setFormula($formula);
ok($kl->isSetFormula(), 1);
ok($kl->getFormula(), $formula);
# reflexive case
$kl->setFormula($kl->getFormula());
ok($kl->isSetFormula(), 1);
ok($kl->getFormula(), $formula);
$kl->setFormula('');
ok($kl->isSetFormula(), 0);
ok($kl->getFormula(), '');

# set/get formula from AST
$kl->setMath(LibSBML::parseFormula($formula));
ok($kl->isSetMath(), 1);
ok($kl->isSetFormula(), 1);
($f = LibSBML::formulaToString($kl->getMath())) =~ s/\s+//g;
ok($f, $formula);

# set/get math
$kl->setMath(LibSBML::parseFormula($math));
ok($kl->isSetMath(), 1);
($m = LibSBML::formulaToString($kl->getMath())) =~ s/\s+//g;
ok($m, $math);
# reflexive case
$kl->setMath($kl->getMath());
ok($kl->isSetMath(), 1);
($m = LibSBML::formulaToString($kl->getMath())) =~ s/\s+//g;
ok($m, $math);
$kl->setMath(undef);
ok($kl->isSetMath(), 0);
ok($kl->getMath(), undef);

# set/get math from formula
$kl->setFormula($math);
ok($kl->isSetMath(), 1);
ok($kl->isSetFormula(), 1);
($m = LibSBML::formulaToString($kl->getMath())) =~ s/\s+//g;
ok($m, $math);
ok($kl->getFormula(), $math);

# add/get parameter
my $k0 = new LibSBML::Parameter($level,$version);
my $k1 = new LibSBML::Parameter($level,$version);
$k1->setId('k1');
$k1->setValue(3.14);
my $k2 = new LibSBML::Parameter($level,$version);
$k2->setId('k2');
$k2->setValue(2.72);
ok($kl->addParameter($k0), $LibSBML::LIBSBML_INVALID_OBJECT);
$k0->setId('k0');
$kl->addParameter($k0);
ok($kl->getNumParameters(), 1);
$k0 = $kl->getParameter($kl->getNumParameters()-1);
ok($k0->getId(), 'k0');
ok($k0->getName(), '');
ok($k0->getValue(), 0);
$kl->addParameter($k1);
ok($kl->getNumParameters(), 2);
$k1 = $kl->getParameter($kl->getNumParameters()-1);
ok($k1->getName(), '');
ok($k1->getId(), 'k1');
ok($k1->getValue() == 3.14);
$kl->addParameter($k2);
ok($kl->getNumParameters(), 3);
$k2 = $kl->getParameter($kl->getNumParameters()-1);
ok($k2->getName(), '');
ok($k2->getId(), 'k2');
ok($k2->getValue() == 2.72);

$kl = new LibSBML::KineticLaw(2,1);
# set/get timeunits
$kl->setTimeUnits($tu);
ok($kl->isSetTimeUnits(), 1);
ok($kl->getTimeUnits(), $tu);
# reflexive case
$kl->setTimeUnits($kl->getTimeUnits());
ok($kl->isSetTimeUnits(), 1);
ok($kl->getTimeUnits(), $tu);
$kl->setTimeUnits('');
ok($kl->isSetTimeUnits(), 0);
ok($kl->getTimeUnits(), '');

# set/get substanceunits
$kl->setSubstanceUnits($su);
ok($kl->isSetSubstanceUnits(), 1);
ok($kl->getSubstanceUnits(), $su);
# reflexive case
$kl->setSubstanceUnits($kl->getSubstanceUnits());
ok($kl->isSetSubstanceUnits(), 1);
ok($kl->getSubstanceUnits(), $su);
$kl->setSubstanceUnits('');
ok($kl->isSetSubstanceUnits(), 0);
ok($kl->getSubstanceUnits(), '');
