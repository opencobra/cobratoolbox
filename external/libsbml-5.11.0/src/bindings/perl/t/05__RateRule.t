use Test;
BEGIN { plan tests => 37 };

use LibSBML;
use strict;
use vars qw/$formula1 $formula2 $f/;

#########################

my $level   = LibSBML::SBMLDocument::getDefaultLevel();
my $version = LibSBML::SBMLDocument::getDefaultVersion();

$formula1 = 'X^n/(1+X^n)';
$formula2 = 'Y^n/(1+Y^n)';
$f = '';

# creation with formula
my $rr = new LibSBML::RateRule($level,$version);
$rr->setVariable('Y');
$rr->setFormula($formula1);
ok($rr->getTypeCode() == $LibSBML::SBML_RATE_RULE);
ok($rr->getMetaId(), '');
ok($rr->getNotes(), undef);
ok($rr->getAnnotation(), undef);
ok($rr->isSetVariable(), 1);
ok($rr->getVariable(), 'Y');
ok($rr->isSetFormula(), 1);
ok($rr->getFormula(), $formula1);
ok($rr->isSetMath(), 1);
($f = LibSBML::formulaToString($rr->getMath())) =~ s/\s+//g;
ok($f, $formula1);

# creation with AST
$rr = new LibSBML::RateRule($level,$version);
$rr->setVariable('Z');
$rr->setFormula($formula2);
ok($rr->getTypeCode() == $LibSBML::SBML_RATE_RULE);
ok($rr->getMetaId(), '');
ok($rr->getNotes(), undef);
ok($rr->getAnnotation(), undef);
ok($rr->isSetVariable(), 1);
ok($rr->getVariable(), 'Z');
ok($rr->isSetFormula(), 1);
($f = $rr->getFormula()) =~ s/\s+//g;
ok($f, $formula2);
ok($rr->isSetMath(), 1);
($f = LibSBML::formulaToString($rr->getMath())) =~ s/\s+//g;
ok($f, $formula2);

# creation w/o variable and formula
$rr = new LibSBML::RateRule($level,$version);
ok($rr->getTypeCode() == $LibSBML::SBML_RATE_RULE);
ok($rr->getMetaId(), '');
ok($rr->getNotes(), undef);
ok($rr->getAnnotation(), undef);
ok($rr->isSetVariable(), 0);
ok($rr->getVariable(), '');
ok($rr->isSetFormula(), 0);
ok($rr->getFormula(), '');
ok($rr->isSetMath(), 0);
ok($rr->getMath(), undef);

# set/get field variable
ok($rr->isSetVariable(), 0);
$rr->setVariable('XYZ');
ok($rr->isSetVariable(), 1);
ok($rr->getVariable(), 'XYZ');
$rr->setVariable($rr->getVariable());
ok($rr->isSetVariable(), 1);
ok($rr->getVariable(), 'XYZ');
$rr->setVariable('');
ok($rr->isSetVariable(), 0);
ok($rr->getVariable(), '');

__END__
