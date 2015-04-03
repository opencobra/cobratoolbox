use Test;
BEGIN { plan tests => 18 };

use LibSBML;

#########################

my $level   = LibSBML::SBMLDocument::getDefaultLevel();
my $version = LibSBML::SBMLDocument::getDefaultVersion();

my $formula = 'X^n/(1+X^n)';

# creation with AST
$fd = new LibSBML::FunctionDefinition($level,$version);
$fd->setId('Y');
$fd->setMath(LibSBML::parseFormula($formula));
ok($fd->isSetId(), 1);
ok($fd->getId(), 'Y');
ok($fd->isSetName(), 0);
ok($fd->isSetMath(), 1);
($f = LibSBML::formulaToString($fd->getMath())) =~ s/\s+//g;
ok($f, $formula);
$fd->setName('hill function');
ok($fd->isSetName(), 1);
ok($fd->getName(), 'hill function');
$fd->unsetName();
ok($fd->isSetName(), 0);

# creation w/o AST
$fd = new LibSBML::FunctionDefinition($level,$version);
ok($fd->isSetName(), 0);
ok($fd->isSetId(), 0);
ok($fd->isSetMath(), 0);

# field name
$fd->setName('function_name');
ok($fd->isSetName(), 1);
ok($fd->getName(), 'function_name');
$fd->unsetName();
ok($fd->isSetName(), 0);

# field id
$fd->setId('function_id_A');
ok($fd->isSetId(), 1);
ok($fd->getId(), 'function_id_A');

# field math
$fd->setMath(LibSBML::parseFormula($formula));
ok($fd->isSetMath(), 1);
($f = LibSBML::formulaToString($fd->getMath())) =~ s/\s+//g;
ok($f, $formula);

# FunctionDefinitionIdCmp not wrapped
# my $fd1 = new LibSBML::FunctionDefinition;
# $fd->setId('function_id_B');
# my $fd2 = new LibSBML::FunctionDefinition;
# $fd->setId('function_id_C');
# ok($fd->FunctionDefinitionIdCmp($fd1) < 0);
# ok($fd->FunctionDefinitionIdCmp($fd), 0);
# ok($fd->FunctionDefinitionIdCmp($fd2) > 0);
