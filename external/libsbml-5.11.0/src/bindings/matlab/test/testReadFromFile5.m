function y = testReadFromFile5(silent)

filename = fullfile(pwd,'test-data', 'l2v1-assignment.xml');

m = TranslateSBML(filename);

test = 64;
Totalfail = 0;

Totalfail = Totalfail + fail_unless(m.SBML_level == 2);
Totalfail = Totalfail + fail_unless(m.SBML_version == 1);

%   //
%   // <listOfCompartments>
%   //   <compartment id="cell"/>
%   // </listOfCompartments>
%   //
  Totalfail = Totalfail + fail_unless( length(m.compartment) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.compartment.id, 'cell'));

%   //
%   // <listOfSpecies>
%   //   <species id="X0" compartment="cell" initialConcentration="1"/>
%   //   <species id="X1" compartment="cell" initialConcentration="0"/>
%   //   <species id="T"  compartment="cell" initialConcentration="0"/>
%   //   <species id="S1" compartment="cell" initialConcentration="0"/>
%   //   <species id="S2" compartment="cell" initialConcentration="0"/>
%   // </listOfSpecies>
%   //

  Totalfail = Totalfail + fail_unless( length(m.species) == 5);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).id, 'X0'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).compartment, 'cell' ));
  Totalfail = Totalfail + fail_unless( m.species(1).initialConcentration == 1);
  Totalfail = Totalfail + fail_unless( m.species(1).boundaryCondition == 0);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(2).id, 'X1'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(2).compartment, 'cell' ));
  Totalfail = Totalfail + fail_unless( m.species(2).initialConcentration == 0);
  Totalfail = Totalfail + fail_unless( m.species(2).boundaryCondition == 0);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(3).id, 'T'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(3).compartment, 'cell' ));
  Totalfail = Totalfail + fail_unless( m.species(3).initialConcentration == 0);
  Totalfail = Totalfail + fail_unless( m.species(3).boundaryCondition == 0);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(4).id, 'S1'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(4).compartment, 'cell' ));
  Totalfail = Totalfail + fail_unless( m.species(4).initialConcentration == 0);
  Totalfail = Totalfail + fail_unless( m.species(4).boundaryCondition == 0);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(5).id, 'S2'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(5).compartment, 'cell' ));
  Totalfail = Totalfail + fail_unless( m.species(5).initialConcentration == 0);
  Totalfail = Totalfail + fail_unless( m.species(5).boundaryCondition == 0);

%   //
%   // <listOfParameters>
%   //   <parameter id="Keq" value="2.5"/>
%   // </listOfParameters>
%   //
  Totalfail = Totalfail + fail_unless( length(m.parameter) == 1);

  Totalfail = Totalfail + fail_unless( strcmp( m.parameter(1).id, 'Keq'             ));
  Totalfail = Totalfail + fail_unless( m.parameter(1).value == 2.5);

%   //
%   // <listOfRules> ... </listOfRules>
%   //

  Totalfail = Totalfail + fail_unless( length(m.rule) == 2);

%     //
%   // <assignmentRule variable="S1">
%   //   <math xmlns="http://www.w3.org/1998/Math/MathML">
%   //     <apply>
%   //       <divide/>
%   //       <ci> T </ci>
%   //       <apply>
%   //         <plus/>
%   //         <cn> 1 </cn>
%   //         <ci> Keq </ci>
%   //       </apply>
%   //     </apply>
%   //   </math>
%   // </assignmentRule>
%   //

  Totalfail = Totalfail + fail_unless( strcmp( m.rule(1).typecode, 'SBML_ASSIGNMENT_RULE'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.rule(1).variable, 'S1'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.rule(1).formula, 'T/(1+Keq)'             ));

%   //
%   // <assignmentRule variable="S2">
%   //   <math xmlns="http://www.w3.org/1998/Math/MathML">
%   //     <apply>
%   //       <times/>
%   //       <ci> Keq </ci>
%   //       <ci> S1 </ci>
%   //     </apply>
%   //   </math>
%   // </assignmentRule>
%   //
  Totalfail = Totalfail + fail_unless( strcmp( m.rule(2).typecode, 'SBML_ASSIGNMENT_RULE'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.rule(2).variable, 'S2'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.rule(2).formula, 'Keq*S1'             ));

%   //
%   // <listOfReactions> ... </listOfReactions>
%   //

  Totalfail = Totalfail + fail_unless( length(m.reaction) == 2);

%   //
%   // <reaction id="in">
%   //   <listOfReactants>
%   //     <speciesReference species="X0"/>
%   //   </listOfReactants>
%   //   <listOfProducts>
%   //     <speciesReference species="T"/>
%   //   </listOfProducts>
%   //   <kineticLaw>
%   //     <math xmlns="http://www.w3.org/1998/Math/MathML">
%   //       <apply>
%   //         <times/>
%   //         <ci> k1 </ci>
%   //         <ci> X0 </ci>
%   //       </apply>
%   //     </math>
%   //     <listOfParameters>
%   //       <parameter id="k1" value="0.1"/>
%   //     </listOfParameters>
%   //   </kineticLaw>
%   // </reaction>
%   // 
  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).id, 'in'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).reversible ~= 0);

  Totalfail = Totalfail + fail_unless( length(m.reaction(1).reactant) == 1);
  Totalfail = Totalfail + fail_unless( length(m.reaction(1).product)  == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).reactant.species, 'X0'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).reactant.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(1).reactant.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).product.species, 'T'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).product.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(1).product.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).kineticLaw.formula, 'k1*X0'));
  Totalfail = Totalfail + fail_unless(length(m.reaction(1).kineticLaw.parameter) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).kineticLaw.parameter.id, 'k1'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).kineticLaw.parameter.value == 0.1);

%  //
%   // <reaction id="out">
%   //   <listOfReactants>
%   //     <speciesReference species="T"/>
%   //   </listOfReactants>
%   //   <listOfProducts>
%   //     <speciesReference species="X1"/>
%   //   </listOfProducts>
%   //   <kineticLaw>
%   //     <math xmlns="http://www.w3.org/1998/Math/MathML">
%   //       <apply>
%   //         <times/>
%   //         <ci> k2 </ci>
%   //         <ci> S2 </ci>
%   //       </apply>
%   //     </math>
%   //     <listOfParameters>
%   //       <parameter id="k2" value="0.15"/>
%   //     </listOfParameters>
%   //   </kineticLaw>
%   // </reaction>
%   //
  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(2).id, 'out'));
  Totalfail = Totalfail + fail_unless( m.reaction(2).reversible ~= 0);
 
  Totalfail = Totalfail + fail_unless( length(m.reaction(2).reactant) == 1);
  Totalfail = Totalfail + fail_unless( length(m.reaction(2).product)  == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(2).reactant.species, 'T'));
  Totalfail = Totalfail + fail_unless( m.reaction(2).reactant.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(2).reactant.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(2).product.species, 'X1'));
  Totalfail = Totalfail + fail_unless( m.reaction(2).product.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(2).product.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(2).kineticLaw.formula, 'k2*X1'));
  Totalfail = Totalfail + fail_unless(length(m.reaction(2).kineticLaw.parameter) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(2).kineticLaw.parameter.id, 'k2'));
  Totalfail = Totalfail + fail_unless( m.reaction(2).kineticLaw.parameter.value == 0.15);


if (silent == 0)
disp('Testing readFromFile5:');
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
    
