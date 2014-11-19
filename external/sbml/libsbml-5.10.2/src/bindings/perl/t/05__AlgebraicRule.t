use Test;
BEGIN { plan tests => 24 };

use LibSBML;
use strict;
use vars qw/$formula $f/;

#########################

my $level   = LibSBML::SBMLDocument::getDefaultLevel();
my $version = LibSBML::SBMLDocument::getDefaultVersion();

$formula = 'X^n/(1+X^n)';
$f = '';

# creation w/o formula
my $ar = new LibSBML::AlgebraicRule($level,$version);
ok($ar->getTypeCode() == $LibSBML::SBML_ALGEBRAIC_RULE);
ok($ar->getMetaId(), "");
ok($ar->getNotes(), undef);
ok($ar->getAnnotation(), undef);
ok($ar->isSetFormula(), 0);
ok($ar->getFormula(), '');
ok($ar->isSetMath(), 0);
ok($ar->getMath(), undef);

# creation with formula
$ar = new LibSBML::AlgebraicRule($level,$version);
ok($ar->setFormula($formula),$LibSBML::LIBSBML_OPERATION_SUCCESS);
ok($ar->getTypeCode() == $LibSBML::SBML_ALGEBRAIC_RULE);
ok($ar->getMetaId(), '');
ok($ar->getNotes(), undef);
ok($ar->getAnnotation(), undef);
ok($ar->isSetFormula(), 1);
($f = LibSBML::formulaToString($ar->getMath())) =~ s/\s+//g;
ok($f, $formula);
ok($ar->isSetMath(), 1);

# creation with AST
$ar = new LibSBML::AlgebraicRule($level,$version);
ok($ar->setMath(LibSBML::parseFormula($formula)),$LibSBML::LIBSBML_OPERATION_SUCCESS);
ok($ar->getTypeCode() == $LibSBML::SBML_ALGEBRAIC_RULE);
ok($ar->getMetaId(), '');
ok($ar->getNotesString(), "");
ok($ar->getAnnotationString(), "");
ok($ar->isSetFormula(), 1);
ok($ar->isSetMath(), 1);
($f = LibSBML::formulaToString($ar->getMath())) =~ s/\s+//g;
ok($f, $formula);
