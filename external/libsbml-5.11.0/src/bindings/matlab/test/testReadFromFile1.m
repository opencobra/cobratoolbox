function y = testReadFromFile1(silent)

filename = fullfile(pwd,'test-data', 'l1v1-branch.xml');
notes1 = sprintf('%s\n  %s\n    %s\n    %s\n    %s\n    %s\n    %s\n  %s\n%s', ... 
    '<notes>', ...
    '<body xmlns="http://www.w3.org/1999/xhtml">', ...
    '<p>Simple branch system.</p>', ...
    '<p>The reaction looks like this:</p>', ...
    '<p>reaction-1:   X0 -&gt; S1; k1*X0;</p>', ...
    '<p>reaction-2:   S1 -&gt; X1; k2*S1;</p>', ...
    '<p>reaction-3:   S1 -&gt; X2; k3*S1;</p>', ...
    '</body>', ...
    '</notes>');
    


m = TranslateSBML(filename);

test = 70;
Totalfail = 0;

Totalfail = Totalfail + fail_unless(m.SBML_level == 1);
Totalfail = Totalfail + fail_unless(m.SBML_version == 1);
Totalfail = Totalfail + fail_unless(strcmp(m.name,'Branch'));
Totalfail = Totalfail + fail_unless(strcmp(m.notes, notes1));

%  /**
%    * <listOfCompartments>
%    *  <compartment name="compartmentOne" volume="1"/>
%    * </listOfCompartments>
%    */
  Totalfail = Totalfail + fail_unless( length(m.compartment) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.compartment.name, 'compartmentOne'));
  Totalfail = Totalfail + fail_unless( m.compartment.volume == 1);


%   /**
%    * <listOfSpecies>
%    *   <specie name="S1" initialAmount="0" compartment="compartmentOne"
%    *           boundaryCondition="false"/>
%    *   <specie name="X0" initialAmount="0" compartment="compartmentOne"
%    *           boundaryCondition="true"/>
%    *   <specie name="X1" initialAmount="0" compartment="compartmentOne"
%    *           boundaryCondition="true"/>
%    *   <specie name="X2" initialAmount="0" compartment="compartmentOne"
%    *           boundaryCondition="true"/>
%    * </listOfSpecies>
%    */
  Totalfail = Totalfail + fail_unless( length(m.species) == 4);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).name, 'S1'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).compartment, 'compartmentOne' ));
  Totalfail = Totalfail + fail_unless( m.species(1).initialAmount == 0);
  Totalfail = Totalfail + fail_unless( m.species(1).boundaryCondition == 0);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(2).name, 'X0'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(2).compartment, 'compartmentOne' ));
  Totalfail = Totalfail + fail_unless( m.species(2).initialAmount == 0);
  Totalfail = Totalfail + fail_unless( m.species(2).boundaryCondition == 1);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(3).name, 'X1'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(3).compartment, 'compartmentOne' ));
  Totalfail = Totalfail + fail_unless( m.species(3).initialAmount == 0);
  Totalfail = Totalfail + fail_unless( m.species(3).boundaryCondition == 1);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(4).name, 'X2'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(4).compartment, 'compartmentOne' ));
  Totalfail = Totalfail + fail_unless( m.species(4).initialAmount == 0);
  Totalfail = Totalfail + fail_unless( m.species(4).boundaryCondition == 1);

% 
%   /**
%    * <listOfReactions>
%    *   <reaction name="reaction_1" reversible="false"> ... </reaction>
%    *   <reaction name="reaction_2" reversible="false"> ... </reaction>
%    *   <reaction name="reaction_3" reversible="false"> ... </reaction>
%    * </listOfReactions>
%    */
  Totalfail = Totalfail + fail_unless( length(m.reaction) == 3);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).name, 'reaction_1'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).reversible == 0);
  Totalfail = Totalfail + fail_unless( m.reaction(1).fast == 0);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(2).name, 'reaction_2'));
  Totalfail = Totalfail + fail_unless( m.reaction(2).reversible == 0);
  Totalfail = Totalfail + fail_unless( m.reaction(2).fast == 0);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(3).name, 'reaction_3'));
  Totalfail = Totalfail + fail_unless( m.reaction(3).reversible == 0);
  Totalfail = Totalfail + fail_unless( m.reaction(3).fast == 0);
% 
%   /**
%    * <reaction name="reaction_1" reversible="false">
%    *   <listOfReactants>
%    *     <specieReference specie="X0" stoichiometry="1"/>
%    *   </listOfReactants>
%    *   <listOfProducts>
%    *     <specieReference specie="S1" stoichiometry="1"/>
%    *   </listOfProducts>
%    *   <kineticLaw formula="k1 * X0">
%    *     <listOfParameters>
%    *       <parameter name="k1" value="0"/>
%    *     </listOfParameters>
%    *   </kineticLaw>
%    * </reaction>
%    */
% 
  Totalfail = Totalfail + fail_unless( length(m.reaction(1).reactant) == 1);
  Totalfail = Totalfail + fail_unless( length(m.reaction(1).product)  == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).reactant.species, 'X0'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).reactant.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(1).reactant.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).product.species, 'S1'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).product.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(1).product.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).kineticLaw.formula, 'k1*X0'));
  Totalfail = Totalfail + fail_unless(length(m.reaction(1).kineticLaw.parameter) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).kineticLaw.parameter.name, 'k1'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).kineticLaw.parameter.value == 0);
% 
% 
%   /**
%    * <reaction name="reaction_2" reversible="false">
%    *   <listOfReactants>
%    *     <specieReference specie="S1" stoichiometry="1"/>
%    *   </listOfReactants>
%    *   <listOfProducts>
%    *     <specieReference specie="X1" stoichiometry="1"/>
%    *   </listOfProducts>
%    *   <kineticLaw formula="k2 * S1">
%    *     <listOfParameters>
%    *       <parameter name="k2" value="0"/>
%    *     </listOfParameters>
%    *   </kineticLaw>
%    * </reaction>
%    */
  Totalfail = Totalfail + fail_unless( length(m.reaction(2).reactant) == 1);
  Totalfail = Totalfail + fail_unless( length(m.reaction(2).product)  == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(2).reactant.species, 'S1'));
  Totalfail = Totalfail + fail_unless( m.reaction(2).reactant.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(2).reactant.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(2).product.species, 'X1'));
  Totalfail = Totalfail + fail_unless( m.reaction(2).product.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(2).product.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(2).kineticLaw.formula, 'k2*S1'));
  Totalfail = Totalfail + fail_unless(length(m.reaction(2).kineticLaw.parameter) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(2).kineticLaw.parameter.name, 'k2'));
  Totalfail = Totalfail + fail_unless( m.reaction(2).kineticLaw.parameter.value == 0);

% 
%   /**
%    * <reaction name="reaction_3" reversible="false">
%    *   <listOfReactants>
%    *     <specieReference specie="S1" stoichiometry="1"/>
%    *   </listOfReactants>
%    *   <listOfProducts>
%    *     <specieReference specie="X2" stoichiometry="1"/>
%    *   </listOfProducts>
%    *   <kineticLaw formula="k3 * S1">
%    *     <listOfParameters>
%    *       <parameter name="k3" value="0"/>
%    *     </listOfParameters>
%    *   </kineticLaw>
%    * </reaction>
%    */
  Totalfail = Totalfail + fail_unless( length(m.reaction(3).reactant) == 1);
  Totalfail = Totalfail + fail_unless( length(m.reaction(3).product)  == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(3).reactant.species, 'S1'));
  Totalfail = Totalfail + fail_unless( m.reaction(3).reactant.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(3).reactant.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(3).product.species, 'X2'));
  Totalfail = Totalfail + fail_unless( m.reaction(3).product.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(3).product.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(3).kineticLaw.formula, 'k3*S1'));
  Totalfail = Totalfail + fail_unless(length(m.reaction(3).kineticLaw.parameter) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(3).kineticLaw.parameter.name, 'k3'));
  Totalfail = Totalfail + fail_unless( m.reaction(3).kineticLaw.parameter.value == 0);

if (silent == 0)
disp('Testing readFromFile1:');
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
    
