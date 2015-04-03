use Test;
BEGIN { plan tests => 234 };

use LibSBML;
use strict;
use vars qw/$formula $f $tu $su $math $m/;

#########################

my $level   = 2;
my $version = 4;

my $id = 'Branch';
my $Rk = 0; # counter for Reactions
my $Rl = 0; # counter for Rules

# create w/ Id
my $m = new LibSBML::Model($level,$version);
$m->setId('repressilator');
ok($m->getTypeCode() == $LibSBML::SBML_MODEL);
ok($m->getMetaId(), '');
ok($m->getNotes(), undef);
ok($m->getAnnotation(), undef);
ok($m->isSetId(), 1);
ok($m->getId(), 'repressilator');
ok($m->isSetName(), 0);
ok($m->getName(), '');
ok($m->getNumUnitDefinitions(), 0);
ok($m->getNumCompartments(), 0);
ok($m->getNumSpecies(), 0);
ok($m->getNumParameters(), 0);
ok($m->getNumReactions(), 0);

# create w/ Name
$m = new LibSBML::Model($level,$version);
$m->setName('The Repressilator Model');
ok($m->getTypeCode() == $LibSBML::SBML_MODEL);
ok($m->getMetaId(), '');
ok($m->getNotes(), undef);
ok($m->getAnnotation(), undef);
ok($m->isSetId(), 0);
ok($m->getId(), '');
ok($m->isSetName(), 1);
ok($m->getName(), 'The Repressilator Model');
ok($m->getNumUnitDefinitions(), 0);
ok($m->getNumCompartments(), 0);
ok($m->getNumSpecies(), 0);
ok($m->getNumParameters(), 0);
ok($m->getNumReactions(), 0);

# create w/o arguments
$m = new LibSBML::Model($level,$version);
ok($m->getTypeCode() == $LibSBML::SBML_MODEL);
ok($m->getMetaId(), '');
ok($m->getNotes(), undef);
ok($m->getAnnotation(), undef);
ok($m->isSetId(), 0);
ok($m->getId(), '');
ok($m->isSetName(), 0);
ok($m->getName(), '');
ok($m->getNumUnitDefinitions(), 0);
ok($m->getNumCompartments(), 0);
ok($m->getNumSpecies(), 0);
ok($m->getNumParameters(), 0);
ok($m->getNumReactions(), 0);

# set/get Id
ok($m->isSetId(), 0);
$m->setId($id);
ok($m->isSetId(), 1);
ok($m->getId(), $id);
# reflexive case
$m->setId($m->getId());
ok($m->isSetId(), 1);
ok($m->getId(), $id);
$m->setId('');
ok($m->isSetId(), 0);
ok($m->getId(), '');

# set/get Name
ok($m->isSetName(), 0);
$m->setName($id);
ok($m->isSetName(), 1);
ok($m->getName(), $id);
# reflexive case
$m->setName($m->getName());
ok($m->isSetName(), 1);
ok($m->getName(), $id);
$m->setName('');
ok($m->isSetName(), 0);
ok($m->getName(), '');

# create FunctionDefinition
my $fd = $m->createFunctionDefinition();
ok($fd->getTypeCode() == $LibSBML::SBML_FUNCTION_DEFINITION);
ok($m->getNumFunctionDefinitions(), 1);

# add/get FunctionDefinition
$fd = new LibSBML::FunctionDefinition($level,$version);
ok($m->addFunctionDefinition($fd),$LibSBML::LIBSBML_INVALID_OBJECT);
$fd->setId('fd');
$fd->setMath(LibSBML::parseFormula('1+1'));
ok($m->addFunctionDefinition($fd),0);
ok($m->getNumFunctionDefinitions(), 2);
ok($m->getFunctionDefinition(0)->getTypeCode()
   == $LibSBML::SBML_FUNCTION_DEFINITION);
ok($m->getFunctionDefinition(1)->getTypeCode()
   == $LibSBML::SBML_FUNCTION_DEFINITION);
ok($m->getFunctionDefinition(2),  undef);

# add/get FunctionDefinitionById
$fd = new LibSBML::FunctionDefinition($level,$version);
$fd->setId('sin');
$fd->setMath(LibSBML::parseFormula('sin(x)'));
$m->addFunctionDefinition($fd);
$fd = new LibSBML::FunctionDefinition($level,$version);
$fd->setId('cos');
$fd->setMath(LibSBML::parseFormula('cos(x)'));
$m->addFunctionDefinition($fd);

ok($m->getNumFunctionDefinitions(), 4);
ok($m->getFunctionDefinition('sin')->getId(),
   $m->getFunctionDefinition(2)->getId());
ok($m->getFunctionDefinition('cos')->getId(),
   $m->getFunctionDefinition(3)->getId());
ok($m->getFunctionDefinition('tan'), undef);

# create UnitDefinition
my $ud = $m->createUnitDefinition();
ok($ud->getTypeCode() == $LibSBML::SBML_UNIT_DEFINITION);
ok($m->getNumUnitDefinitions(), 1);

# add/get UnitDefinition                          Id       Name
$ud = new LibSBML::UnitDefinition($level,$version);
$ud->setId('volume');
$ud->setName('mmls');
my $u = new LibSBML::Unit($level,$version);
$u->setKind($LibSBML::UNIT_KIND_LITRE);
$ud->addUnit($u);
$m->addUnitDefinition($ud);
$ud = new LibSBML::UnitDefinition($level,$version);
$ud->setId('mmls');
$ud->setName('volume');
$ud->addUnit($u);
$m->addUnitDefinition($ud);
ok($m->getNumUnitDefinitions(), 3);
ok($m->getUnitDefinition(0)->getTypeCode() == $LibSBML::SBML_UNIT_DEFINITION);
ok($m->getUnitDefinition(0)->getName(), '');
ok($m->getUnitDefinition(1)->getTypeCode() == $LibSBML::SBML_UNIT_DEFINITION);
ok($m->getUnitDefinition(1)->getName(), 'mmls');
ok($m->getUnitDefinition(2)->getTypeCode() == $LibSBML::SBML_UNIT_DEFINITION);
ok($m->getUnitDefinition(2)->getName(), 'volume');
ok($m->getUnitDefinition(3),  undef);

# get UnitDefinitionById
ok($m->getUnitDefinition('volume')->getName(),
   $m->getUnitDefinition(2)->getId());
ok($m->getUnitDefinition('mmls')->getName(),
   $m->getUnitDefinition(1)->getId());
ok($m->getUnitDefinition('liter'), undef);

# create Unit
$ud = $m->createUnitDefinition();
$ud = $m->createUnitDefinition();
ok($m->getNumUnitDefinitions(), 5);
$u = $m->createUnit();
ok($u->getTypeCode() == $LibSBML::SBML_UNIT);
$ud = $m->getUnitDefinition(4);
ok($ud->getTypeCode() == $LibSBML::SBML_UNIT_DEFINITION);
ok($ud->getNumUnits(), 1);

# create Unit noUnitDefinition
my $mNO = new LibSBML::Model($level,$version);
ok($mNO->getTypeCode() == $LibSBML::SBML_MODEL);
ok($mNO->getNumUnitDefinitions(), 0);
ok($mNO->createUnit(), undef);

# create Compartment
my $c = $m->createCompartment();
$c->setId('a');
ok($c->getTypeCode() == $LibSBML::SBML_COMPARTMENT);
ok($m->getNumCompartments(), 1);

# add/get Compartment
$c = new LibSBML::Compartment($level,$version);
$c->setId('A');
$m->addCompartment($c);
$m->getCompartment(1)->setId('A');
$m->getCompartment(1)->setName('B');
$c->setId('B');
$m->addCompartment($c);
$m->getCompartment(2)->setId('B');
$m->getCompartment(2)->setName('A');
ok($m->getNumCompartments(), 3);
ok($m->getCompartment(0)->getTypeCode() == $LibSBML::SBML_COMPARTMENT);
ok($m->getName(), '');
ok($m->getId(),   '');
ok($m->getCompartment(1)->getTypeCode() == $LibSBML::SBML_COMPARTMENT);
ok($m->getCompartment(1)->getId(),   'A');
ok($m->getCompartment(1)->getName(), 'B');
ok($m->getCompartment(2)->getTypeCode() == $LibSBML::SBML_COMPARTMENT);
ok($m->getCompartment(2)->getId(),   'B');
ok($m->getCompartment(2)->getName(), 'A');
ok($m->getCompartment(3), undef);

# get CompartmentById
ok($m->getCompartment('A')->getName(), $m->getCompartment(2)->getId());
ok($m->getCompartment('B')->getName(), $m->getCompartment(1)->getId());
ok($m->getCompartment('C'), undef);

# create Species
my $s = $m->createSpecies();
$s->setId('S1');
$s->setCompartment('A');
ok($s->getTypeCode() == $LibSBML::SBML_SPECIES);
ok($m->getNumSpecies(), 1);

# add/get Species
$s = new LibSBML::Species($level,$version);
$s->setId('Glucose');
$s->setCompartment('A');
$m->addSpecies($s);
$m->getSpecies(1)->setId('Glucose');
$m->getSpecies(1)->setName('Glucose_6_P');
$s->setId('Glucose_6_P');
$m->addSpecies($s);
$m->getSpecies(2)->setId('Glucose_6_P');
$m->getSpecies(2)->setName('Glucose');
ok($m->getNumSpecies(), 3);
ok($m->getSpecies(0)->getTypeCode() == $LibSBML::SBML_SPECIES);
ok($m->getSpecies(0)->getId(),   'S1');
ok($m->getSpecies(0)->getName(), '');
ok($m->getSpecies(1)->getTypeCode() == $LibSBML::SBML_SPECIES);
ok($m->getSpecies(1)->getId(), 'Glucose');
ok($m->getSpecies(1)->getName(), 'Glucose_6_P');
ok($m->getSpecies(2)->getTypeCode() == $LibSBML::SBML_SPECIES);
ok($m->getSpecies(2)->getId(), 'Glucose_6_P');
ok($m->getSpecies(2)->getName(), 'Glucose');
ok($m->getSpecies(3),  undef);

# get SpeciesById
ok($m->getSpecies('Glucose')->getName(), $m->getSpecies(2)->getId());
ok($m->getSpecies('Glucose_6_P')->getName(), $m->getSpecies(1)->getId());
ok($m->getSpecies('Glucose_5_P'), undef);

# overloaded constructor for C-API Species_createWith is missing
# therefore this workaround
my $s1 = new LibSBML::Species($level,$version);
$s1->setId('species1'); $s1->setCompartment('c');
$s1->setInitialAmount(1); $s1->setSubstanceUnits('amount');
$s1->setBoundaryCondition(1); $s1->setCharge(0);
my $s2 = new LibSBML::Species($level,$version);
$s2->setId('species2'); $s2->setCompartment('c');
$s2->setInitialAmount(2); $s2->setSubstanceUnits('amount');
$s2->setBoundaryCondition(0); $s2->setCharge(0);
my $s3 = new LibSBML::Species($level,$version);
$s3->setId('species3'); $s3->setCompartment('c');
$s3->setInitialAmount(3); $s3->setSubstanceUnits('amount');
$s3->setBoundaryCondition(1); $s3->setCharge(0);
ok($m->getNumSpecies(), 3);
$m->addSpecies($s1);
ok($m->getNumSpecies(), 4);
ok($m->getNumSpeciesWithBoundaryCondition(), 1);
$m->addSpecies($s2);
ok($m->getNumSpecies(), 5);
ok($m->getNumSpeciesWithBoundaryCondition(), 1);
$m->addSpecies($s3);
ok($m->getNumSpecies(), 6);
ok($m->getNumSpeciesWithBoundaryCondition(), 2);

# create Parameter
my $p = $m->createParameter();
$p->setId('P1');
ok($p->getTypeCode() == $LibSBML::SBML_PARAMETER);
ok($m->getNumParameters(), 1);

# add/get Parameter
$p = new LibSBML::Parameter($level,$version);
$p->setId('Km1');
$m->addParameter($p);
$m->getParameter(1)->setId('Km1');
$m->getParameter(1)->setName('Km2');
$p->setId('Km2');
$m->addParameter($p);
$m->getParameter(2)->setId('Km2');
$m->getParameter(2)->setName('Km1');
ok($m->getNumParameters(), 3);
ok($m->getParameter(0)->getTypeCode() == $LibSBML::SBML_PARAMETER);
ok($m->getParameter(0)->getId(), 'P1');
ok($m->getParameter(0)->getName(), '');
ok($m->getParameter(1)->getTypeCode() == $LibSBML::SBML_PARAMETER);
ok($m->getParameter(1)->getId(), 'Km1');
ok($m->getParameter(1)->getName(), 'Km2');
ok($m->getParameter(2)->getTypeCode() == $LibSBML::SBML_PARAMETER);
ok($m->getParameter(2)->getId(), 'Km2');
ok($m->getParameter(2)->getName(), 'Km1');
ok($m->getParameter(3),  undef);

# get ParameterById
ok($m->getParameter('Km1')->getName(), $m->getParameter(2)->getId());
ok($m->getParameter('Km2')->getName(), $m->getParameter(1)->getId());
ok($m->getParameter('Km3'), undef);

# create AssignmentRule
my $ar = $m->createAssignmentRule(); $Rl++;
$ar->setVariable('a1');
$ar->setFormula('x + 1');
ok($ar->getTypeCode() == $LibSBML::SBML_ASSIGNMENT_RULE);
ok($m->getNumRules(), $Rl);
ok($m->getRule($Rl-1)->getTypeCode() == $LibSBML::SBML_ASSIGNMENT_RULE);
ok($m->getRule($Rl-1)->getFormula(), 'x + 1');

# add/get AssignmentRule
$ar = new LibSBML::AssignmentRule($level,$version);
$ar->setVariable('a2');
$ar->setFormula('y + 1');
ok($m->addRule($ar), $LibSBML::LIBSBML_OPERATION_SUCCESS);
$Rl++;
ok($m->getNumRules(), $Rl);
ok($m->getRule($Rl-1)->getTypeCode()
   == $LibSBML::SBML_ASSIGNMENT_RULE);
ok($m->getRule($Rl-2)->getTypeCode()
   == $LibSBML::SBML_ASSIGNMENT_RULE);
ok($m->getRule($Rl),  undef);

# create RateRule
my $rr = $m->createRateRule(); $Rl++;
$rr->setVariable('r1');
ok($rr->getTypeCode() == $LibSBML::SBML_RATE_RULE);
ok($m->getNumRules(), $Rl);
ok($m->getRule($Rl-1)->getTypeCode() == $LibSBML::SBML_RATE_RULE);

# add/get RateRule
$rr = new LibSBML::RateRule($level,$version);
$rr->setVariable('r2');
$rr->setFormula('w + 1');
ok($m->addRule($rr), $LibSBML::LIBSBML_OPERATION_SUCCESS); $Rl++;
ok($m->getNumRules(), $Rl);
ok($m->getRule($Rl-1)->getTypeCode()
   == $LibSBML::SBML_RATE_RULE);
ok($m->getRule($Rl-2)->getTypeCode()
   == $LibSBML::SBML_RATE_RULE);
ok($m->getRule($Rl),  undef);

# create AlgebraicRule
#$ar = new LibSBML::AlgebraicRule($level,$version);
#$ar->setFormula('x + 1');
#$ar = $m->createAlgebraicRule(); $Rl++;
#ok($ar->getTypeCode() == $LibSBML::SBML_ALGEBRAIC_RULE);
#ok($m->getNumRules(), $Rl);
#ok($m->getRule($Rl-1)->getTypeCode() == $LibSBML::SBML_ALGEBRAIC_RULE);

# add/get AlgebraicRule
#$ar = new LibSBML::AlgebraicRule($level,$version);
#$ar->setFormula('y + 1');
#ok($m->addRule($ar),$LibSBML::LIBSBML_OPERATION_SUCCESS); $Rl++;
#ok($m->getNumRules(), $Rl);
#ok($m->getRule($Rl-1)->getTypeCode()
#   == $LibSBML::SBML_ALGEBRAIC_RULE);
#ok($m->getRule($Rl-2)->getTypeCode()
#   == $LibSBML::SBML_ALGEBRAIC_RULE);
#ok($m->getRule($Rl),  undef);

# create Reaction
my $r = $m->createReaction(); $Rk++;
$r->setId("reaction_0");
ok($r->getTypeCode() == $LibSBML::SBML_REACTION);
ok($m->getNumReactions(),$Rk);
ok($m->getReaction(0)->getTypeCode() == $LibSBML::SBML_REACTION);

# add/get Reaction
$r = new LibSBML::Reaction($level,$version);
$r->setId("reaction_1");
$m->addReaction($r); $Rk++;
$m->getReaction($Rk-1)->setId('reaction_1');
$m->getReaction($Rk-1)->setName('reaction_2');
$r->setId("reaction_2");
$m->addReaction($r); $Rk++;
$m->getReaction($Rk-1)->setId('reaction_2');
$m->getReaction($Rk-1)->setName('reaction_1');
ok($m->getNumReactions(), $Rk);
ok($m->getReaction($Rk-1)->getTypeCode()
   == $LibSBML::SBML_REACTION);
ok($m->getReaction($Rk-1)->getId(), 'reaction_2');
ok($m->getReaction($Rk-1)->getName(), 'reaction_1');
ok($m->getReaction($Rk-2)->getTypeCode()
   == $LibSBML::SBML_REACTION);
ok($m->getReaction($Rk-2)->getId(), 'reaction_1');
ok($m->getReaction($Rk-2)->getName(), 'reaction_2');
ok($m->getReaction($Rk),  undef);

# get ReactionById
ok($m->getReaction('reaction_1')->getName(), $m->getReaction(2)->getId());
ok($m->getReaction('reaction_2')->getName(), $m->getReaction(1)->getId());
ok($m->getReaction('reaction_3'), undef);


# create Reactant
$r = $m->createReaction();
$r = $m->createReaction(); $Rk += 2;
my $sr = $m->createReactant();
ok(defined $sr); # note Reactant has no SBMLTypeCode
ok($m->getNumReactions(), $Rk);
$r = $m->getReaction($Rk-1);
ok($r->getTypeCode() == $LibSBML::SBML_REACTION);
ok($r->getNumReactants(), 1);
ok(defined $r->getReactant(0)); # note Reactant has no SBMLTypeCode

# create Reactant noReaction
$mNO = new LibSBML::Model($level,$version);
ok($mNO->getTypeCode() == $LibSBML::SBML_MODEL);
ok($mNO->getNumReactions(), 0);
ok($mNO->createReactant(), undef);

# create Product
$r = $m->createReaction();
$r = $m->createReaction(); $Rk += 2;
$sr = $m->createProduct();
ok(defined $sr); # note Product has no SBMLTypeCode
ok($m->getNumReactions(), $Rk);
$r = $m->getReaction($Rk-1);
ok($r->getNumProducts(), 1);
ok(defined $r->getProduct(0)); # note Product has no SBMLTypeCode

# create Product noReaction
$mNO = new LibSBML::Model($level,$version);
ok($mNO->getTypeCode() == $LibSBML::SBML_MODEL);
ok($mNO->getNumReactions(), 0);
ok($mNO->createProduct(), undef);

# create Modifier
$r = $m->createReaction();
$r = $m->createReaction(); $Rk += 2;
my $msr = $m->createModifier();
ok(defined $msr); # note Modifier has no SBMLTypeCode
ok($m->getNumReactions(), $Rk);
$r = $m->getReaction($Rk-1);
ok($r->getNumModifiers(), 1);
ok(defined $r->getModifier(0)); # note Modifier has no SBMLTypeCode

# create Modifier noReaction
$mNO = new LibSBML::Model($level,$version);
ok($mNO->getTypeCode() == $LibSBML::SBML_MODEL);
ok($mNO->getNumReactions(), 0);
ok($mNO->createModifier(), undef);

# create KineticLaw
$r = $m->createReaction();
$r = $m->createReaction(); $Rk += 2;
my $kl = $m->createKineticLaw();
ok($kl->getTypeCode() == $LibSBML::SBML_KINETIC_LAW);
ok($m->getNumReactions(), $Rk);
$r = $m->getReaction($Rk-2);
ok($r->getKineticLaw(), undef);
$r = $m->getReaction($Rk-1);
ok($r->getKineticLaw()->getTypeCode() == $LibSBML::SBML_KINETIC_LAW);

# create KineticLaw noReaction
$mNO = new LibSBML::Model($level,$version);
ok($mNO->getTypeCode() == $LibSBML::SBML_MODEL);
ok($mNO->getNumReactions(), 0);
ok($mNO->createKineticLaw(), undef);

# create KineticLawParameter
$r = $m->createReaction();
$r = $m->createReaction(); $Rk += 2;
$kl = $m->createKineticLaw();
$p = $m->createKineticLawParameter();
ok($m->getNumReactions(), $Rk);
ok($m->getReaction($Rk-2)->getKineticLaw(), undef);
ok($m->getReaction($Rk-1)->getKineticLaw()->getTypeCode()
   == $LibSBML::SBML_KINETIC_LAW);
ok($m->getReaction($Rk-1)->getKineticLaw()->getNumParameters(), 1);
ok($m->getReaction($Rk-1)->getKineticLaw()
   ->getParameter(0)->getTypeCode() == $LibSBML::SBML_PARAMETER);

# create KineticLawParameter noReaction
$mNO = new LibSBML::Model($level,$version);
ok($mNO->getTypeCode() == $LibSBML::SBML_MODEL);
ok($mNO->getNumReactions(), 0);
ok($mNO->createKineticLawParameter(), undef);

# create KineticLawParameter noKineticLaw
ok($m->createReaction()->getKineticLaw(), undef); $Rk++;
ok($m->createKineticLawParameter(), undef);

# create Event
my $e = $m->createEvent();
$e->setId('event_0');
my $t = new LibSBML::Trigger($level,$version);
$t->setMath(LibSBML::parseFormula("lambda(x,x^3)"));
$e->setTrigger($t);
$e->createEventAssignment();
ok($e->getTypeCode() == $LibSBML::SBML_EVENT);
ok($m->getNumEvents(), 1);
ok($m->getEvent(0)->getTypeCode() == $LibSBML::SBML_EVENT);

# add/get Event
$e = new LibSBML::Event($level,$version);
$e->setId('event_1');
$e->setTrigger($t);
$e->createEventAssignment();
$m->addEvent($e);
$m->getEvent(1)->setId('event_1');
$m->getEvent(1)->setName('event_2');
$e = new LibSBML::Event($level,$version);
$e->setId('event_2');
$e->setTrigger($t);
$e->createEventAssignment();
$m->addEvent($e);
$m->getEvent(2)->setId('event_2');
$m->getEvent(2)->setName('event_1');
ok($m->getNumEvents(), 3);
ok($m->getEvent(0)->getTypeCode() == $LibSBML::SBML_EVENT);
ok($m->getEvent(0)->getId(), 'event_0');
ok($m->getEvent(0)->getName(), '');
ok($m->getEvent(1)->getTypeCode() == $LibSBML::SBML_EVENT);
ok($m->getEvent(1)->getId(), 'event_1');
ok($m->getEvent(1)->getName(), 'event_2');
ok($m->getEvent(2)->getTypeCode() == $LibSBML::SBML_EVENT);
ok($m->getEvent(2)->getId(), 'event_2');
ok($m->getEvent(2)->getName(), 'event_1');
ok($m->getEvent(3),  undef);

# get EventById
ok($m->getEvent('event_1')->getName(), $m->getEvent(2)->getId());
ok($m->getEvent('event_2')->getName(), $m->getEvent(1)->getId());
ok($m->getEvent('event_3'), undef);

# create EventAssignment
$m->createEvent();
$m->getEvent(3)->setId('event_3');
$m->getEvent(3)->setTrigger($t);
my $ea = $m->createEventAssignment();
ok($ea->getTypeCode() == $LibSBML::SBML_EVENT_ASSIGNMENT);
ok($m->getNumEvents(), 4);
ok($m->getEvent(3)->getNumEventAssignments(), 1);
ok($m->getEvent(3)->getEventAssignment(0)->getTypeCode()
   == $LibSBML::SBML_EVENT_ASSIGNMENT);
    
# create EventAssignment noEvent
$mNO = new LibSBML::Model($level,$version);
ok($mNO->getTypeCode() == $LibSBML::SBML_MODEL);
ok($mNO->getNumEvents(), 0);
ok($mNO->createEventAssignment(), undef);

__END__
