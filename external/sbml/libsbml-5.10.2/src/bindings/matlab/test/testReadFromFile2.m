function y = testReadFromFile2(silent)

filename = fullfile(pwd,'test-data', 'l1v1-units.xml');

m = TranslateSBML(filename);

test = 81;
Totalfail = 0;

Totalfail = Totalfail + fail_unless(m.SBML_level == 1);
Totalfail = Totalfail + fail_unless(m.SBML_version == 1);

%   /**
%    * <listOfUnitDefinitions>
%    *   <unitDefinition name="substance"> ... </unitDefinition>
%    *   <unitDefinition name="mls">       ... </unitDefinition>
%    * </listOfUnitDefinitions>
%    */
  Totalfail = Totalfail + fail_unless( length(m.unitDefinition) == 2);

  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition(1).name, 'substance'));
  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition(2).name, 'mls'));

%   /**
%    * <unitDefinition name="substance">
%    *   <listOfUnits>
%    *     <unit kind="mole" scale="-3"/>
%    *   </listOfUnits>
%    * </unitDefinition>
%    */
  Totalfail = Totalfail + fail_unless( length(m.unitDefinition(1).unit) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition(1).unit.kind, 'mole'));
  Totalfail = Totalfail + fail_unless( m.unitDefinition(1).unit.exponent == 1);
  Totalfail = Totalfail + fail_unless( m.unitDefinition(1).unit.scale == -3);

%   /**
%    * <unitDefinition name="mls">
%    *   <listOfUnits>
%    *     <unit kind="mole"   scale="-3"/>
%    *     <unit kind="liter"  exponent="-1"/>
%    *     <unit kind="second" exponent="-1"/>
%    *   </listOfUnits>
%    * </unitDefinition>
%    */
  Totalfail = Totalfail + fail_unless( length(m.unitDefinition(2).unit) == 3);

  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition(2).unit(1).kind, 'mole'));
  Totalfail = Totalfail + fail_unless( m.unitDefinition(2).unit(1).exponent == 1);
  Totalfail = Totalfail + fail_unless( m.unitDefinition(2).unit(1).scale == -3);

  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition(2).unit(2).kind, 'liter'));
  Totalfail = Totalfail + fail_unless( m.unitDefinition(2).unit(2).exponent == -1);
  Totalfail = Totalfail + fail_unless( m.unitDefinition(2).unit(2).scale == 0);

  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition(2).unit(3).kind, 'second'));
  Totalfail = Totalfail + fail_unless( m.unitDefinition(2).unit(3).exponent == -1);
  Totalfail = Totalfail + fail_unless( m.unitDefinition(2).unit(3).scale == 0);

%   /**
%    * <listOfCompartments>
%    *   <compartment name="cell"/>
%    * </listOfCompartments>
%    */
  Totalfail = Totalfail + fail_unless( length(m.compartment) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.compartment.name, 'cell'));

%  /**
%    * <listOfSpecies>
%    *   <specie name="x0" compartment="cell" initialAmount="1"/>
%    *   <specie name="x1" compartment="cell" initialAmount="1"/>
%    *   <specie name="s1" compartment="cell" initialAmount="1"/>
%    *   <specie name="s2" compartment="cell" initialAmount="1"/>
%    * </listOfSpecies>
%    */
  Totalfail = Totalfail + fail_unless( length(m.species) == 4);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).name, 'x0'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).compartment, 'cell' ));
  Totalfail = Totalfail + fail_unless( m.species(1).initialAmount == 1);
  Totalfail = Totalfail + fail_unless( m.species(1).boundaryCondition == 0);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(2).name, 'x1'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(2).compartment, 'cell' ));
  Totalfail = Totalfail + fail_unless( m.species(2).initialAmount == 1);
  Totalfail = Totalfail + fail_unless( m.species(2).boundaryCondition == 0);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(3).name, 's1'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(3).compartment, 'cell' ));
  Totalfail = Totalfail + fail_unless( m.species(3).initialAmount == 1);
  Totalfail = Totalfail + fail_unless( m.species(3).boundaryCondition == 0);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(4).name, 's2'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(4).compartment, 'cell' ));
  Totalfail = Totalfail + fail_unless( m.species(4).initialAmount == 1);
  Totalfail = Totalfail + fail_unless( m.species(4).boundaryCondition == 0);

%    /**
%    * <listOfParameters>
%    *   <parameter name="vm" value="2" units="mls"/>
%    *   <parameter name="km" value="2"/>
%    * </listOfParameters>
%    */
  Totalfail = Totalfail + fail_unless( length(m.parameter) == 2);

  Totalfail = Totalfail + fail_unless( strcmp( m.parameter(1).name, 'vm'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.parameter(1).units, 'mls' ));
  Totalfail = Totalfail + fail_unless( m.parameter(1).value == 2);

  Totalfail = Totalfail + fail_unless( strcmp( m.parameter(2).name, 'km'             ));
  Totalfail = Totalfail + fail_unless( m.parameter(2).value == 2);

%  /**
%    * <listOfReactions>
%    *   <reaction name="v1"> ... </reaction>
%    *   <reaction name="v2"> ... </reaction>
%    *   <reaction name="v3"> ... </reaction>
%    * </listOfReactions>
%    */

  Totalfail = Totalfail + fail_unless( length(m.reaction) == 3);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).name, 'v1'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).reversible ~= 0);
  Totalfail = Totalfail + fail_unless( m.reaction(1).fast == 0);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(2).name, 'v2'));
  Totalfail = Totalfail + fail_unless( m.reaction(2).reversible ~= 0);
  Totalfail = Totalfail + fail_unless( m.reaction(2).fast == 0);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(3).name, 'v3'));
  Totalfail = Totalfail + fail_unless( m.reaction(3).reversible ~= 0);
  Totalfail = Totalfail + fail_unless( m.reaction(3).fast == 0);

%  /**
%    * <reaction name="v1">
%    *   <listOfReactants>
%    *     <specieReference specie="x0"/>
%    *   </listOfReactants>
%    *   <listOfProducts>
%    *     <specieReference specie="s1"/>
%    *   </listOfProducts>
%    *   <kineticLaw formula="(vm * s1)/(km + s1)"/>
%    * </reaction>
%    */
 
  Totalfail = Totalfail + fail_unless( length(m.reaction(1).reactant) == 1);
  Totalfail = Totalfail + fail_unless( length(m.reaction(1).product)  == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).reactant.species, 'x0'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).reactant.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(1).reactant.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).product.species, 's1'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).product.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(1).product.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).kineticLaw.formula, '(vm*s1)/(km+s1)'));

%   /**
%    * <reaction name="v2">
%    *   <listOfReactants>
%    *     <specieReference specie="s1"/>
%    *   </listOfReactants>
%    *   <listOfProducts>
%    *     <specieReference specie="s2"/>
%    *   </listOfProducts>
%    *   <kineticLaw formula="(vm * s2)/(km + s2)"/>
%    * </reaction>
%    */

  Totalfail = Totalfail + fail_unless( length(m.reaction(2).reactant) == 1);
  Totalfail = Totalfail + fail_unless( length(m.reaction(2).product)  == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(2).reactant.species, 's1'));
  Totalfail = Totalfail + fail_unless( m.reaction(2).reactant.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(2).reactant.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(2).product.species, 's2'));
  Totalfail = Totalfail + fail_unless( m.reaction(2).product.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(2).product.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(2).kineticLaw.formula, '(vm*s2)/(km+s2)'));

%   /**
%    * <reaction name="v3">
%    *   <listOfReactants>
%    *     <specieReference specie="s2"/>
%    *   </listOfReactants>
%    *   <listOfProducts>
%    *     <specieReference specie="x1"/>
%    *   </listOfProducts>
%    *   <kineticLaw formula="(vm * s1)/(km + s1)"/>
%    * </reaction>
%    */
  Totalfail = Totalfail + fail_unless( length(m.reaction(3).reactant) == 1);
  Totalfail = Totalfail + fail_unless( length(m.reaction(3).product)  == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(3).reactant.species, 's2'));
  Totalfail = Totalfail + fail_unless( m.reaction(3).reactant.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(3).reactant.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(3).product.species, 'x1'));
  Totalfail = Totalfail + fail_unless( m.reaction(3).product.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(3).product.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(3).kineticLaw.formula, '(vm*s1)/(km+s1)'));

if (silent == 0)
disp('Testing readFromFile2:');
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
    
