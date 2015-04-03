use Test;
BEGIN { plan tests => 49 };

use LibSBML;

#########################

my $level   = 2;
my $version = 4;

# creation w/o arguments
my $c = new LibSBML::Compartment($level,$version);
ok($c->getTypeCode() == $LibSBML::SBML_COMPARTMENT);
ok($c->getMetaId(), '');
ok($c->getNotes(), undef);
ok($c->getAnnotation(), undef);

ok($c->getSpatialDimensions() == 3);
ok($c->getVolume() == 1);
ok($c->getConstant() == 1);

ok($c->isSetId() == 0);
ok($c->isSetName() == 0);
ok($c->isSetSize() == 0);
ok($c->isSetVolume() == 0);
ok($c->isSetUnits() == 0);
ok($c->isSetOutside() == 0);

# creation w/ arguments not wrapped
# $c = new LibSBML::Compartment('A', 3.6, 'liter', 'B');
# ok($c->getTypeCode() == $LibSBML::SBML_COMPARTMENT);
# ok($c->getMetaId(), '');
# ok($c->getNotes(), '');
# ok($c->getAnnotation(), '');
# ok($c->isSetName() == 0);
# ok($c->getName(), '');
# ok($c->getSpatialDimensions() == 3);

# ok($c->getId() eq 'A');
# ok($c->isSetUnits() == 1);
# ok($c->getUnits() eq 'liter');
# ok($c->isSetOutside() == 1);
# ok($c->getOutside() eq 'B');

# ok($c->getSize == 3.6);
# ok($c->getConstant() == 1);

# ok($c->isSetId() == 1);
# ok($c->isSetName() == 0);
# ok($c->isSetSize() == 1);
# ok($c->isSetVolume() == 1);
# ok($c->isSetUnits() == 1);
# ok($c->isSetOutside() == 1);

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

# outside
my $outside = 'cell';
$c->setOutside($outside);
ok($c->isSetOutside() == 1);
ok($c->getOutside() eq $outside);

$c->setOutside($c->getOutside());
ok($c->isSetOutside() == 1);
ok($c->getOutside() eq $outside);

$c->setOutside('');
ok($c->isSetOutside() == 0);
ok($c->getOutside() ne $outside);

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

