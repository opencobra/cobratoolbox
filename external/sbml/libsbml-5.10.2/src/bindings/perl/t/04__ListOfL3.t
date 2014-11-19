use Test;
BEGIN { plan tests => 34 };

use LibSBML;
use strict;

#########################

my $level   = LibSBML::SBMLDocument::getDefaultLevel();
my $version = LibSBML::SBMLDocument::getDefaultVersion();

# create a listof
my $lo = new LibSBML::ListOf();
ok($lo->getTypeCode() == $LibSBML::SBML_LIST_OF);
ok($lo->getMetaId(), '');
ok($lo->getNotes(), undef);
ok($lo->getAnnotation(), undef);
ok($lo->size(), 0);

# create 6 items
my $c1 = new LibSBML::Compartment($level,$version);
ok($c1->getTypeCode() == $LibSBML::SBML_COMPARTMENT);
my $c2 = new LibSBML::Compartment($level,$version);
ok($c2->getTypeCode() == $LibSBML::SBML_COMPARTMENT);
my $s1 = new LibSBML::Compartment($level,$version);
ok($s1->getTypeCode() == $LibSBML::SBML_COMPARTMENT);
my $s2 = new LibSBML::Compartment($level,$version);
ok($s2->getTypeCode() == $LibSBML::SBML_COMPARTMENT);
my $s3 = new LibSBML::Compartment($level,$version);
my $p1 = new LibSBML::Compartment($level,$version);
ok($p1->getTypeCode() == $LibSBML::SBML_COMPARTMENT);


my @list = ($s1, $c1, $s2, $p1, $s3, $c2);
my @roll = @list[5,0,1,2,3,4]; 

# add items to listof
my $num = 0;
$lo->append($_), ok($lo->size(), ++$num) for @list; 

# check typecodes of items
ok($lo->get($_)->getTypeCode(), $list[$_]->getTypeCode()) for 0..$num-1;

# roll listof (1,2,3,4,5,6) -> (6,1,2,3,4,5)
$lo->append($lo->remove(0)), ok($lo->size(), $num) for 0..$num-2;
# check items typecodes
ok($lo->get($_)->getTypeCode(), $roll[$_]->getTypeCode()) for 0..$num-1;

# remove all items from listof
$lo->remove(0) for 0..$num-1;
ok($lo->size(), 0);
