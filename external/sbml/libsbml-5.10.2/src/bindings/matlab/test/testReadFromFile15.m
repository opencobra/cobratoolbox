function y = testReadFromFile15(silent)

filename = fullfile(pwd,'test-data', 'csymbolAvogadro.xml');

m = TranslateSBML(filename);

test = 23;
Totalfail = 0;

Totalfail = Totalfail + fail_unless(m.SBML_level == 3);
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
%   //           <csymbol encoding="text" definitionURL="http://www.sbml.org/sbml/symbols/avogadro">
%   //             NA
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

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).product.species, 'S2'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).product.stoichiometry == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).kineticLaw.math, 'S1*c/NA'));

% model contains the csymbol time

  Totalfail = Totalfail + fail_unless( strcmp(m.avogadro_symbol, 'NA'));
  

if (silent == 0)
disp('Testing readFromFile15:');
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
    
