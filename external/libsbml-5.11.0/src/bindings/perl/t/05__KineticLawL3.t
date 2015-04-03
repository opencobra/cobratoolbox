use Test;
BEGIN { plan tests => 59 };

use LibSBML;
use strict;
use vars qw/$formula $f $tu $su $math $m/;

#########################

my $level   = LibSBML::SBMLDocument::getDefaultLevel();
my $version = LibSBML::SBMLDocument::getDefaultVersion();

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
my $k0 = new LibSBML::LocalParameter($level,$version);
my $k1 = new LibSBML::LocalParameter($level,$version);
$k1->setId('k1');
$k1->setValue(3.14);
my $k2 = new LibSBML::LocalParameter($level,$version);
$k2->setId('k2');
$k2->setValue(2.72);
ok($kl->addLocalParameter($k0), $LibSBML::LIBSBML_INVALID_OBJECT);
$k0->setId('k0');
$kl->addLocalParameter($k0);
ok($kl->getNumLocalParameters(), 1);
$k0 = $kl->getLocalParameter($kl->getNumLocalParameters()-1);
ok($k0->getId(), 'k0');
ok($k0->getName(), '');
$kl->addLocalParameter($k1);
ok($kl->getNumLocalParameters(), 2);
$k1 = $kl->getLocalParameter($kl->getNumLocalParameters()-1);
ok($k1->getName(), '');
ok($k1->getId(), 'k1');
ok($k1->getValue() == 3.14);
$kl->addLocalParameter($k2);
ok($kl->getNumLocalParameters(), 3);
$k2 = $kl->getLocalParameter($kl->getNumLocalParameters()-1);
ok($k2->getName(), '');
ok($k2->getId(), 'k2');
ok($k2->getValue() == 2.72);
