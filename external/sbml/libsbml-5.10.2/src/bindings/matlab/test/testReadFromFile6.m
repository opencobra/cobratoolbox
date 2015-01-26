function y = testReadFromFile6(silent)

filename = fullfile(pwd,'test-data', 'csymbolTime-reaction-l2.xml');

m = TranslateSBML(filename);

test = 25;
Totalfail = 0;

Totalfail = Totalfail + fail_unless(m.SBML_level == 2);
Totalfail = Totalfail + fail_unless(m.SBML_version == 1);

%   //
%   // <listOfCompartments>
%   //   <compartment id="c" size="1"/>
%   // </listOfCompartments>
%   //

  Totalfail = Totalfail + fail_unless( length(m.compartment) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.compartment.id, 'c'));

  Totalfail = Totalfail + fail_unless( m.compartment.size == 1);

%   //
%   // <listOfSpecies>
%   //   <species id="S1" compartment="c" initialAmount="1"/>
%   //   <species id="S2" compartment="c" initialAmount="0"/>
%   // </listOfSpecies>
%   //

  Totalfail = Totalfail + fail_unless( length(m.species) == 2);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).id, 'S1'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).compartment, 'c' ));
  Totalfail = Totalfail + fail_unless( m.species(1).initialAmount == 1);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(2).id, 'S2'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(2).compartment, 'c' ));
  Totalfail = Totalfail + fail_unless( m.species(2).initialAmount == 0);

%   //
%   // <listOfReactions> ... </listOfReactions>
%   //

  Totalfail = Totalfail + fail_unless( length(m.reaction) == 1);

%   //
%   // <reaction id="r" reversible="false">
%   //   <listOfReactants>
%   //     <speciesReference species="S1"/>
%   //   </listOfReactants>
%   //   <listOfProducts>
%   //     <speciesReference species="S2"/>
%   //   </listOfProducts>
%   //   <kineticLaw>
%   //     <math xmlns="http://www.w3.org/1998/Math/MathML">
%   //       <apply>
%   //         <times/>
%   //           <csymbol encoding="text" definitionURL="http://www.sbml.org/sbml/symbols/time">
%   //             my_time
%   //           </csymbol>
%   //           <ci> X0 </ci>
%   //       </apply>
%   //     </math>
%   //   </kineticLaw>
%   // </reaction>
%   // 
  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).id, 'r'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).reversible == 0);

  Totalfail = Totalfail + fail_unless( length(m.reaction(1).reactant) == 1);
  Totalfail = Totalfail + fail_unless( length(m.reaction(1).product)  == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).reactant.species, 'S1'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).reactant.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(1).reactant.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).product.species, 'S2'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).product.stoichiometry == 1);
  Totalfail = Totalfail + fail_unless( m.reaction(1).product.denominator == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).kineticLaw.formula, 'S1*c/my_time'));

% model contains the csymbol time

  Totalfail = Totalfail + fail_unless( strcmp(m.time_symbol, 'my_time'));
  

if (silent == 0)
disp('Testing readFromFile6:');
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
    
