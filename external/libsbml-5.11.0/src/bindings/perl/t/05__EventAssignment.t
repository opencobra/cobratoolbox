use Test;
BEGIN { plan tests => 29 };

use LibSBML;
use strict;
use vars qw/$formula $f $var/;

#########################

my $level   = LibSBML::SBMLDocument::getDefaultLevel();
my $version = LibSBML::SBMLDocument::getDefaultVersion();

$formula = 'X^n/(1+X^n)';
$f = '';
$var = 'k2';

# creation w/o arguments
my $ae = new LibSBML::EventAssignment($level,$version);
ok($ae->getTypeCode() == $LibSBML::SBML_EVENT_ASSIGNMENT);
ok($ae->getMetaId(), '');
ok($ae->getNotes(), undef);
ok($ae->getAnnotation(), undef);
ok($ae->isSetVariable(), 0);
ok($ae->getVariable(), '');
ok($ae->isSetMath(), 0);
ok($ae->getMath(), undef);

# creation w/ AST
$ae = new LibSBML::EventAssignment($level,$version);
$ae->setVariable('k');
$ae->setMath(LibSBML::parseFormula($formula));
ok($ae->getTypeCode() == $LibSBML::SBML_EVENT_ASSIGNMENT);
ok($ae->getMetaId(), '');
ok($ae->getNotes(), undef);
ok($ae->getAnnotation(), undef);
ok($ae->isSetVariable(), 1);
ok($ae->getVariable(), 'k');
ok($ae->isSetMath(), 1);
($f = LibSBML::formulaToString($ae->getMath())) =~ s/\s+//g;
ok($f, $formula);

# set/get fields

# field variable
$ae = new LibSBML::EventAssignment($level,$version);
ok($ae->getTypeCode() == $LibSBML::SBML_EVENT_ASSIGNMENT);
$ae->setVariable($var);
ok($ae->isSetVariable(), 1);
ok($ae->getVariable(), $var);
# reflexive case
$ae->setVariable($ae->getVariable());
ok($ae->isSetVariable(), 1);
ok($ae->getVariable(), $var);
$ae->setVariable('');
ok($ae->isSetVariable(), 0);
ok($ae->getVariable(), '');

# field math
ok($ae->isSetMath(), 0);
$ae->setMath(LibSBML::parseFormula($formula));
ok($ae->isSetMath(), 1);
($f = LibSBML::formulaToString($ae->getMath())) =~ s/\s+//g;
ok($f, $formula);
# reflexive case
$ae->setMath($ae->getMath());
ok($ae->isSetMath(), 1);
($f = LibSBML::formulaToString($ae->getMath())) =~ s/\s+//g;
ok($f, $formula);
$ae->setMath(undef);
ok($ae->isSetMath(), 0);
