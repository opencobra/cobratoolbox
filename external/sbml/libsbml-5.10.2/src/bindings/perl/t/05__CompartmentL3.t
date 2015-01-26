use Test;
BEGIN { plan tests => 39 };

use LibSBML;

#########################

my $level   = LibSBML::SBMLDocument::getDefaultLevel();
my $version = LibSBML::SBMLDocument::getDefaultVersion();

# creation w/o arguments
my $c = new LibSBML::Compartment($level,$version);
ok($c->getTypeCode() == $LibSBML::SBML_COMPARTMENT);
ok($c->getMetaId(), '');
ok($c->getNotes(), undef);
ok($c->getAnnotation(), undef);

ok($c->isSetId() == 0);
ok($c->isSetName() == 0);
ok($c->isSetSize() == 0);
ok($c->isSetVolume() == 0);
ok($c->isSetUnits() == 0);

# set/get fields
my $id = 'mitochondria';
$c = new LibSBML::Compartment($level,$version);
ok($c->setId($id), $LibSBML::LIBSBML_OPERATION_SUCCESS);
ok($c->getTypeCode() == $LibSBML::SBML_COMPARTMENT);

# id
ok($c->getId() eq $id);
ok($c->isSetId() == 1);

$c->setId($c->getId());
ok($c->isSetId() == 1);
ok($c->getId() eq $id);

$c->setId('');
ok($c->isSetId() == 0);
ok($c->getId() ne $id);

# name
my $name = 'My Favorite Factory';
$c->setName($name);
ok($c->isSetName() == 1);
ok($c->getName() eq $name);

$c->setName($c->getName());
ok($c->isSetName() == 1);
ok($c->getName() eq $name);

$c->setName('');
ok($c->isSetName() == 0);
ok($c->getName() ne $name);

# units
my $units = 'volume';
$c->setUnits($units);
ok($c->isSetUnits() == 1);
ok($c->getUnits() eq $units);

$c->setUnits($c->getUnits());
ok($c->isSetUnits() == 1);
ok($c->getUnits() eq $units);

$c->setUnits('');
ok($c->isSetUnits() == 0);
ok($c->getUnits() ne $units);

# unset fields
$c->setSize(0.2);
ok($c->isSetSize() == 1);
ok($c->getSize() == 0.2);

$c->unsetSize();
ok($c->isSetSize() == 0);

$c->setVolume(25.0);
ok($c->isSetVolume() == 1);
ok($c->getVolume() == 25.0);

$c->unsetVolume();
ok($c->isSetVolume() == 0);

# move fields
my $before = 'I am an Id';
my $after  = 'I am a Name';
$c = new LibSBML::Compartment($level,$version);
ok($c->setId($before),$LibSBML::LIBSBML_INVALID_ATTRIBUTE_VALUE);
$c->initDefaults();
ok($c->getTypeCode() == $LibSBML::SBML_COMPARTMENT);
ok($c->isSetId() == 0);
ok($c->isSetName() == 0);

