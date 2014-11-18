use Test;
BEGIN { plan tests => 66 };

use LibSBML;
use strict;
use vars qw/$id $name $t_formula $trigger $t $d_formula $delay $d $units/;

#########################

my $level   = 2;
my $version = 4;

$id = 'e1';
$t_formula = 'leq(P1,t)';
$trigger = '';
$t = '';
$d_formula = 't+1';
$delay = '';
$d = '';
$units = 'second';
$name = 'Set k2 to zero when P1 <= t';

# create w/ AST
my $e = new LibSBML::Event($level,$version);
$e->setId($id);
$trigger = new LibSBML::Trigger($level,$version);
$trigger->setMath(LibSBML::parseFormula($t_formula));
$e->setTrigger($trigger);
ok($e->getTypeCode() == $LibSBML::SBML_EVENT);
ok($e->getMetaId(), '');
ok($e->getNotes(), undef);
ok($e->getAnnotation(), undef);
ok($e->isSetId(), 1);
ok($e->getId(), 'e1');
ok($e->isSetName(), 0);
ok($e->getName(), '');
ok($e->isSetTrigger(), 1);
($t = LibSBML::formulaToString($e->getTrigger()->getMath())) =~ s/\s+//g;
ok($t, $t_formula);

# creation w/o arguments
$e = new LibSBML::Event($level,$version);
ok($e->getTypeCode() == $LibSBML::SBML_EVENT);
ok($e->getMetaId(), '');
ok($e->getNotes(), undef);
ok($e->getAnnotation(), undef);
ok($e->isSetId(), 0);
ok($e->getId(), '');
ok($e->isSetName(), 0);
ok($e->getName(), '');
ok($e->isSetTrigger(), 0);
ok($e->getTrigger(), undef);
ok($e->isSetDelay(), 0);
ok($e->getDelay(), undef);
ok($e->isSetTimeUnits(), 0);
ok($e->getTimeUnits(), '');

# set/get id
$e->setId($id);
ok($e->isSetId(), 1);
ok($e->getId(), $id);
# reflexive case
$e->setId($e->getId());
ok($e->isSetId(), 1);
ok($e->getId(), $id);
$e->setId('');
ok($e->isSetId(), 0);
ok($e->getId(), '');

# set/get name
$e->setName($name);
ok($e->isSetName(), 1);
ok($e->getName(), $name);
# reflexive case
$e->setName($e->getName());
ok($e->isSetName(), 1);
ok($e->getName(), $name);
$e->setName('');
ok($e->isSetName(), 0);
ok($e->getName(), '');

# set/get trigger
$trigger = new LibSBML::Trigger($level,$version);
$trigger->setMath(LibSBML::parseFormula($t_formula));
$e->setTrigger($trigger);
ok($e->isSetTrigger(), 1);
($t = LibSBML::formulaToString($e->getTrigger()->getMath())) =~ s/\s+//g;
ok($t, $t_formula);
# reflexive case
$e->setTrigger($e->getTrigger());
ok($e->isSetTrigger(), 1);
($t = LibSBML::formulaToString($e->getTrigger()->getMath())) =~ s/\s+//g;
ok($t, $t_formula);
$e->setTrigger(undef);
ok($e->isSetTrigger(), 0);
ok($e->getTrigger(), undef);

# set/get delay
$delay = new LibSBML::Delay($level,$version);
$delay->setMath(LibSBML::parseFormula($d_formula));
$e->setDelay($delay);
ok($e->isSetDelay(), 1);
($d = LibSBML::formulaToString($e->getDelay()->getMath())) =~ s/\s+//g;
ok($d, $d_formula);
# reflexive case
$e->setDelay($e->getDelay());
ok($e->isSetDelay(), 1);
($d = LibSBML::formulaToString($e->getDelay()->getMath())) =~ s/\s+//g;
ok($d, $d_formula);
$e->setDelay(undef);
ok($e->isSetDelay(), 0);
ok($e->getDelay(), undef);

# set/get timeunits
ok($e->setTimeUnits($units),$LibSBML::LIBSBML_UNEXPECTED_ATTRIBUTE);
ok($e->isSetTimeUnits(), 0);
ok($e->getTimeUnits(), "");
# reflexive case
$e->setTimeUnits($e->getTimeUnits());
ok($e->isSetTimeUnits(), 0);
ok($e->getTimeUnits(), "");

# add/get EventAssignments
$e = new LibSBML::Event($level,$version);
$e->setId($id);
ok($e->getTypeCode(), $LibSBML::SBML_EVENT);
my $ea = new LibSBML::EventAssignment($level,$version);
$ea->setVariable('k');
$ea->setMath(LibSBML::parseFormula('0'));
ok($ea->getTypeCode(), $LibSBML::SBML_EVENT_ASSIGNMENT);

ok($e->isSetId(), 1);
ok($e->getId(), $id);
$e->setName($name);
ok($e->isSetName(), 1);
ok($e->getName(), $name);
ok($e->addEventAssignment($ea),$LibSBML::LIBSBML_OPERATION_SUCCESS);
ok($e->getNumEventAssignments(), 1);
$ea = $e->getEventAssignment($e->getNumEventAssignments()-1);
ok($ea->getTypeCode(), $LibSBML::SBML_EVENT_ASSIGNMENT);
ok($ea->isSetVariable(), 1);
ok($ea->getVariable(), 'k');
ok($ea->isSetMath(), 1);
(my $f = LibSBML::formulaToString($ea->getMath())) =~ s/\s+//g;
ok($f, '0');
