use Test::More;
BEGIN { plan tests => 37 };

use LibSBML;
use strict;

#########################

my $formula = 'X^n/(1+X^n)';
my $name    = 'cell';
my $unit    = 'cells';

SKIP : {
skip("ParameterRule is obsolete",37);

# creation with formula
my $pr = new LibSBML::ParameterRule('Y',
				    $formula,
				    $LibSBML::RULE_TYPE_SCALAR);
ok($pr->getTypeCode() == $LibSBML::SBML_PARAMETER_RULE);
ok($pr->getNotes(), '');
ok($pr->getAnnotation(), '');
ok($pr->isSetUnits(), 0);
ok($pr->getUnits(), '');
ok($pr->isSetFormula(), 1);
ok($pr->getFormula(), $formula);
ok($pr->isSetName(), 1);
ok($pr->getName(), 'Y');
ok($pr->getType(), $LibSBML::RULE_TYPE_SCALAR);

# creation w/o arguments
$pr = new LibSBML::ParameterRule();
ok($pr->getTypeCode() == $LibSBML::SBML_PARAMETER_RULE);
ok($pr->getNotes(), '');
ok($pr->getAnnotation(), '');
ok($pr->isSetUnits(), 0);
ok($pr->getUnits(), '');
ok($pr->isSetFormula(), 0);
ok($pr->getFormula(), '');
ok($pr->isSetName(), 0);
ok($pr->getName(), '');
ok($pr->getType(), $LibSBML::RULE_TYPE_SCALAR);

# set/get field name
ok($pr->isSetName(), 0);
$pr->setName($name);
ok($pr->isSetName(), 1);
ok($pr->getName(), $name);
# reflexive case
$pr->setName($pr->getName());
ok($pr->isSetName(), 1);
ok($pr->getName(), $name);
$pr->setName('');
ok($pr->isSetName(), 0);
ok($pr->getName(), '');

# set/get field units
ok($pr->isSetUnits(), 0);
$pr->setUnits($unit);
ok($pr->isSetUnits(), 1);
ok($pr->getUnits(), $unit);
# reflexive case
$pr->setUnits($pr->getUnits());
ok($pr->isSetUnits(), 1);
ok($pr->getUnits(), $unit);
$pr->setUnits('');
ok($pr->isSetUnits(), 0);
ok($pr->getUnits(), '');
$pr->setUnits($name);
ok($pr->getUnits(), $name);
$pr->unsetUnits();
ok($pr->isSetUnits(), 0);
ok($pr->getUnits(), '');
}

__END__
