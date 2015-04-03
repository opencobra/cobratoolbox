function y = testReadFromFile4(silent)

filename = fullfile(pwd,'test-data', 'l1v1-minimal.xml');

m = TranslateSBML(filename);

test = 21;
Totalfail = 0;

Totalfail = Totalfail + fail_unless(m.SBML_level == 1);
Totalfail = Totalfail + fail_unless(m.SBML_version == 1);

%   /**
%    * <listOfCompartments>
%    *  <compartment name="x"/>
%    * </listOfCompartments>
%    */

  Totalfail = Totalfail + fail_unless( length(m.compartment) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.compartment.name, 'x'));

%   /**
%    * <listOfSpecies>
%    *   <specie name="y" compartment="x" initialAmount="1"/>
%    * </listOfSpecies>
%    */

  Totalfail = Totalfail + fail_unless( length(m.species) == 1);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).name, 'y'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).compartment, 'x' ));
  Totalfail = Totalfail + fail_unless( m.species(1).initialAmount == 1);
  Totalfail = Totalfail + fail_unless( m.species(1).boundaryCondition == 0);

%   /**
%    * <listOfReactions>
%    *   <reaction name="x">
%    *     <listOfReactants>
%    *       <specieReference specie="y"/>
%    *     </listOfReactants>
%    *     <listOfProducts>
%    *       <specieReference specie="y"/>
%    *     </listOfProducts>
%    *   </reaction>
%    * </listOfReactions>
%    */

  Totalfail = Totalfail + fail_unless( length(m.reaction) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).name, 'x1'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).reversible ~= 0);
  Totalfail = Totalfail + fail_unless( m.reaction(1).fast == 0);

  Totalfail = Totalfail + fail_unless( length(m.reaction(1).reactant) == 1);
  Totalfail = Totalfail + fail_unless( length(m.reaction(1).product)  == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).reactant.species, 'y'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).reactant.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(1).reactant.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).product.species, 'y'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).product.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(1).product.denominator == 1);


if (silent == 0)
disp('Testing readFromFile4:');
disp(sprintf('Number tests: %d', test));
disp(sprintf('Number fails: %d', Totalfail));
disp(sprintf('Pass rate: %d%%\n', ((test-Totalfail)/test)*100));
end;

if (Totalfail == 0)
    y = 0;
else
    y = 1;
end;

function y = fail_unless(arg)

if (~arg)
    y = 1;
else
    y = 0;
end;
    
