use Test::More;
BEGIN { plan tests => 21 };

use LibSBML;
use strict;

#########################

SKIP : {
skip("CompartmentVolumeRule is obsolete",21);

# creation w/o arguments
my $cvr = new LibSBML::CompartmentVolumeRule();
ok($cvr->getTypeCode() == $LibSBML::SBML_COMPARTMENT_VOLUME_RULE);
ok($cvr->getType() == $LibSBML::RULE_TYPE_SCALAR);
ok($cvr->getMetaId(), '');
ok($cvr->getNotes(), '');
ok($cvr->getAnnotation(), '');
ok($cvr->isSetFormula(), 0);
ok($cvr->getFormula(), '');
ok($cvr->isSetCompartment(), 0);
ok($cvr->getCompartment(), '');

# creation w/ arguments
# note: the order of arguments differs between the c++ and c interface !!!
$cvr = new LibSBML::CompartmentVolumeRule('nucleus',
					  'v + 1',
					  $LibSBML::RULE_TYPE_RATE);
ok($cvr->getTypeCode() == $LibSBML::SBML_COMPARTMENT_VOLUME_RULE);
ok($cvr->getType() == $LibSBML::RULE_TYPE_RATE);
ok($cvr->getMetaId(), '');
ok($cvr->getNotes(), '');
ok($cvr->getAnnotation(), '');
ok($cvr->isSetFormula(), 1);
ok($cvr->getFormula(), 'v + 1');
ok($cvr->isSetCompartment(), 1);
ok($cvr->getCompartment(), 'nucleus');

# set/get field compartment
$cvr->setCompartment('cell');
ok($cvr->isSetCompartment(), 1);
ok($cvr->getCompartment(), 'cell');
$cvr->setCompartment($cvr->getCompartment());
ok($cvr->getCompartment(), 'cell');

}
