use Test;
BEGIN { plan tests => 47 };

use LibSBML;
use strict;

#########################

my $level   = 2;
my $version = 4;

my $id    = 'delay';
my $value = 6.2;
my $unit  = 'second';
my $name  = 'Forward Michaelis-Menten Constant';

# create w/ arguments
my $p = new LibSBML::Parameter($level,$version);
$p->setId($id);
$p->setValue($value);
$p->setUnits($unit);
ok($p->getTypeCode() == $LibSBML::SBML_PARAMETER);
ok($p->getMetaId(), '');
ok($p->getNotes(), undef);
ok($p->getAnnotation(), undef);
ok($p->isSetId(), 1);
ok($p->getId(), $id);
ok($p->isSetName(), 0);
ok($p->getName(), '');
ok($p->isSetValue(), 1);
ok($p->getValue(), $value);
ok($p->isSetUnits(), 1);
ok($p->getUnits(), $unit);
ok($p->getConstant(), 1);

# create w/o arguments
$p = new LibSBML::Parameter($level,$version);
ok($p->getTypeCode() == $LibSBML::SBML_PARAMETER);
ok($p->getMetaId(), '');
ok($p->getNotes(), undef);
ok($p->getAnnotation(), undef);
ok($p->isSetId(), 0);
ok($p->getId(), '');
ok($p->isSetName(), 0);
ok($p->getName(), '');
ok($p->isSetValue(), 0);
ok($p->getValue(), 0);
ok($p->isSetUnits(), 0);
ok($p->getUnits(), '');
ok($p->getConstant(), 1);

# set/get field Id
ok($p->isSetName(), 0);
$p->setId($id);
ok($p->isSetId(), 1);
ok($p->getId(), $id);
# reflexive case
$p->setId($p->getId());
ok($p->isSetId(), 1);
ok($p->getId(), $id);
$p->setId('');
ok($p->isSetId(), 0);
ok($p->getId(), '');

# set/get field Name
ok($p->isSetName(), 0);
$p->setName($name);
ok($p->isSetName(), 1);
ok($p->getName(), $name);
# reflexive case
$p->setName($p->getName());
ok($p->isSetName(), 1);
ok($p->getName(), $name);
$p->setName('');
ok($p->isSetName(), 0);
ok($p->getName(), '');

# set/get field Unit
ok($p->isSetUnits(), 0);
$p->setUnits($unit);
ok($p->isSetUnits(), 1);
ok($p->getUnits(), $unit);
# reflexive case
$p->setUnits($p->getUnits());
ok($p->isSetUnits(), 1);
ok($p->getUnits(), $unit);
$p->setUnits('');
ok($p->isSetUnits(), 0);
ok($p->getUnits(), '');

__END__
