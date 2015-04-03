use Test;
BEGIN { plan tests => 1 };

use Data::Dumper;
use LibSBML;

#########################
# convert string-formula to AST and back
# check if input-formula and output-formula are equal

my $formula = 'X^n/(1+X^n)';
my $f = LibSBML::formulaToString(LibSBML::parseFormula($formula));

# ret rid of inserted white-space
$f =~ s/\s+//g;
ok($f, $formula);
