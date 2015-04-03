use Test;
BEGIN { plan tests => 22 };

use LibSBML;
use strict;
use vars qw/$formula $f/;

#########################

my $level   = LibSBML::SBMLDocument::getDefaultLevel();
my $version = LibSBML::SBMLDocument::getDefaultVersion();

$formula = 'X^n/(1+X^n)';
$f = '';

# creation with formula
my $r = new LibSBML::AssignmentRule($level,$version);
ok($r->setVariable('Y'), $LibSBML::LIBSBML_OPERATION_SUCCESS);
ok($r->setFormula($formula), $LibSBML::LIBSBML_OPERATION_SUCCESS);
ok($r->getTypeCode() == $LibSBML::SBML_ASSIGNMENT_RULE);
ok($r->isSetVariable(), 1);
ok($r->isSetMath(), 1);
ok($r->getType(), $LibSBML::RULE_TYPE_SCALAR);
($f = LibSBML::formulaToString($r->getMath())) =~ s/\s+//g;
ok($f, $formula);

# creation with AST
$r = new LibSBML::AssignmentRule($level,$version);
ok($r->setVariable('Y'), $LibSBML::LIBSBML_OPERATION_SUCCESS);
ok($r->setMath(LibSBML::parseFormula($formula)), $LibSBML::LIBSBML_OPERATION_SUCCESS);
ok($r->getTypeCode() == $LibSBML::SBML_ASSIGNMENT_RULE);
ok($r->isSetVariable(), 1);
ok($r->isSetMath(), 1);
ok($r->getType(), $LibSBML::RULE_TYPE_SCALAR);
($f = LibSBML::formulaToString($r->getMath())) =~ s/\s+//g;
ok($f, $formula);

# creation w/o formula
$r = new LibSBML::AssignmentRule($level,$version);
ok($r->getTypeCode() == $LibSBML::SBML_ASSIGNMENT_RULE);
ok($r->isSetVariable(), 0);
ok($r->isSetMath(), 0);
ok($r->getType(), $LibSBML::RULE_TYPE_SCALAR);

# set/get variable
$r->setVariable('Y');
ok($r->isSetVariable(), 1);
ok($r->getVariable(), 'Y');

# set/get math
$r->setMath(LibSBML::parseFormula($formula));
($f = LibSBML::formulaToString($r->getMath())) =~ s/\s+//g;
ok($f, $formula);

# creat a document and a model
my $d = new LibSBML::SBMLDocument($level,$version);
my $m = $d->createModel();
$m->setId('assignment_rule');

# create and add two species and a parameter and the rule to the model
my $s1 = $m->createSpecies();
$s1->setId('X');
$s1->setConstant(0);
$s1->setBoundaryCondition(0);
$s1->setHasOnlySubstanceUnits(0);
my $s2 = $m->createSpecies();
$s2->setId('Y');
$s2->setConstant(0);
$s2->setBoundaryCondition(0);
$s2->setHasOnlySubstanceUnits(0);
my $p = $m->createParameter();
$p->setId('n');
$p->setConstant(1);
$m->addRule($r);

# check the model
my $ref = join '', <DATA>;
my $doc = $d->writeSBMLToString();
ok($doc, $ref);

# functions not wrapped

__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<sbml xmlns="http://www.sbml.org/sbml/level3/version1/core" level="3" version="1">
  <model id="assignment_rule">
    <listOfSpecies>
      <species id="X" hasOnlySubstanceUnits="false" boundaryCondition="false" constant="false"/>
      <species id="Y" hasOnlySubstanceUnits="false" boundaryCondition="false" constant="false"/>
    </listOfSpecies>
    <listOfParameters>
      <parameter id="n" constant="true"/>
    </listOfParameters>
    <listOfRules>
      <assignmentRule variable="Y">
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <apply>
            <divide/>
            <apply>
              <power/>
              <ci> X </ci>
              <ci> n </ci>
            </apply>
            <apply>
              <plus/>
              <cn type="integer"> 1 </cn>
              <apply>
                <power/>
                <ci> X </ci>
                <ci> n </ci>
              </apply>
            </apply>
          </apply>
        </math>
      </assignmentRule>
    </listOfRules>
  </model>
</sbml>
