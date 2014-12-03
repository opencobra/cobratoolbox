function y = testReadFromFile3(silent)

filename = fullfile(pwd,'test-data', 'l1v1-rules.xml');

m = TranslateSBML(filename);

test = 77;
Totalfail = 0;

Totalfail = Totalfail + fail_unless(m.SBML_level == 1);
Totalfail = Totalfail + fail_unless(m.SBML_version == 1);

%   /**
%    * <listOfCompartments>
%    *  <compartment name="cell" volume="1"/>
%    * </listOfCompartments>
%    */
  Totalfail = Totalfail + fail_unless( length(m.compartment) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.compartment.name, 'cell'));
  Totalfail = Totalfail + fail_unless( m.compartment.volume == 1);

%   /**
%    * <listOfSpecies>
%    *   <specie name="s1" compartment="cell" initialAmount="4"/>
%    *   <specie name="s2" compartment="cell" initialAmount="2"/>
%    *   <specie name="x0" compartment="cell" initialAmount="1"/>
%    *   <specie name="x1" compartment="cell" initialAmount="0"/>
%    * </listOfSpecies>
%    */  

  Totalfail = Totalfail + fail_unless( length(m.species) == 4);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).name, 's1'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).compartment, 'cell' ));
  Totalfail = Totalfail + fail_unless( m.species(1).initialAmount == 4);
  Totalfail = Totalfail + fail_unless( m.species(1).boundaryCondition == 0);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(2).name, 's2'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(2).compartment, 'cell' ));
  Totalfail = Totalfail + fail_unless( m.species(2).initialAmount == 2);
  Totalfail = Totalfail + fail_unless( m.species(2).boundaryCondition == 0);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(3).name, 'x0'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(3).compartment, 'cell' ));
  Totalfail = Totalfail + fail_unless( m.species(3).initialAmount == 1);
  Totalfail = Totalfail + fail_unless( m.species(3).boundaryCondition == 0);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(4).name, 'x1'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(4).compartment, 'cell' ));
  Totalfail = Totalfail + fail_unless( m.species(4).initialAmount == 0);
  Totalfail = Totalfail + fail_unless( m.species(4).boundaryCondition == 0);

%   /**
%    * <listOfParameters>
%    *   <parameter name="k1" value="1.2"/>
%    *   <parameter name="k2" value="1000"/>
%    *   <parameter name="k3" value="3000"/>
%    *   <parameter name="k4" value="4.5"/>
%    * </listOfParameters>
%    */
  Totalfail = Totalfail + fail_unless( length(m.parameter) == 6);

  Totalfail = Totalfail + fail_unless( strcmp( m.parameter(1).name, 'k1'             ));
  Totalfail = Totalfail + fail_unless( m.parameter(1).value == 1.2);

  Totalfail = Totalfail + fail_unless( strcmp( m.parameter(2).name, 'k2'             ));
  Totalfail = Totalfail + fail_unless( m.parameter(2).value == 1000);

  Totalfail = Totalfail + fail_unless( strcmp( m.parameter(3).name, 'k3'             ));
  Totalfail = Totalfail + fail_unless( m.parameter(3).value == 3000);

  Totalfail = Totalfail + fail_unless( strcmp( m.parameter(4).name, 'k4'             ));
  Totalfail = Totalfail + fail_unless( m.parameter(4).value == 4.5);

  Totalfail = Totalfail + fail_unless( strcmp( m.parameter(5).name, 'k'             ));
  Totalfail = Totalfail + fail_unless( m.parameter(5).value == 1);

  Totalfail = Totalfail + fail_unless( strcmp( m.parameter(6).name, 't'             ));
  Totalfail = Totalfail + fail_unless( m.parameter(6).value == 1);

%  /**
%    * <listOfRules>
%    *   <parameterRule name="t" formula="s1 + s2"/>
%    *   <parameterRule name="k" formula="k3/k2"/>
%    *   <specieConcentrationRule specie="s2" formula="k * t/(1 + k)"/>
%    *   <specieConcentrationRule specie="s1" formula="t - s2"/>
%    * </listOfRules>
%    */
  Totalfail = Totalfail + fail_unless( length(m.rule) == 4);
  
  Totalfail = Totalfail + fail_unless( strcmp( m.rule(1).typecode, 'SBML_PARAMETER_RULE'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.rule(1).type, 'scalar'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.rule(1).name, 't'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.rule(1).formula, 's1+s2'             ));

  Totalfail = Totalfail + fail_unless( strcmp( m.rule(2).typecode, 'SBML_PARAMETER_RULE'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.rule(2).type, 'scalar'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.rule(2).name, 'k'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.rule(2).formula, 'k3/k2'             ));

  Totalfail = Totalfail + fail_unless( strcmp( m.rule(3).typecode, 'SBML_SPECIES_CONCENTRATION_RULE'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.rule(3).type, 'scalar'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.rule(3).species, 's2'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.rule(3).formula, 'k*t/(1+k)'             ));

  Totalfail = Totalfail + fail_unless( strcmp( m.rule(4).typecode, 'SBML_SPECIES_CONCENTRATION_RULE'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.rule(4).type, 'scalar'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.rule(4).species, 's1'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.rule(4).formula, 't-s2'             ));

%   /**
%    * <listOfReactions>
%    *   <reaction name="j1" > ... </reaction>
%    *   <reaction name="j3" > ... </reaction>
%    * </listOfReactions>
%    */

  Totalfail = Totalfail + fail_unless( length(m.reaction) == 2);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).name, 'j1'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).reversible ~= 0);
  Totalfail = Totalfail + fail_unless( m.reaction(1).fast == 0);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(2).name, 'j3'));
  Totalfail = Totalfail + fail_unless( m.reaction(2).reversible ~= 0);
  Totalfail = Totalfail + fail_unless( m.reaction(2).fast == 0);

%   /**
%    * <reaction name="j1">
%    *   <listOfReactants>
%    *     <specieReference specie="x0"/>
%    *   </listOfReactants>
%    *   <listOfProducts>
%    *     <specieReference specie="s1"/>
%    *   </listOfProducts>
%    *   <kineticLaw formula="k1 * x0"/>
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

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).kineticLaw.formula, 'k1*x0'));

%   /**
%    * <reaction name="j3">
%    *   <listOfReactants>
%    *     <specieReference specie="s2"/>
%    *   </listOfReactants>
%    *   <listOfProducts>
%    *     <specieReference specie="x1"/>
%    *   </listOfProducts>
%    *   <kineticLaw formula="k4 * s2"/>
%    * </reaction>
%    */

  Totalfail = Totalfail + fail_unless( length(m.reaction(2).reactant) == 1);
  Totalfail = Totalfail + fail_unless( length(m.reaction(2).product)  == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(2).reactant.species, 's2'));
  Totalfail = Totalfail + fail_unless( m.reaction(2).reactant.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(2).reactant.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(2).product.species, 'x1'));
  Totalfail = Totalfail + fail_unless( m.reaction(2).product.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(2).product.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(2).kineticLaw.formula, 'k4*s2'));


if (silent == 0)
disp('Testing readFromFile3:');
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
    
