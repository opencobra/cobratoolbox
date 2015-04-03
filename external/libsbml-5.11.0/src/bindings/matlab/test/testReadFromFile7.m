function y = testReadFromFile7(silent)

filename = fullfile(pwd,'test-data', 'l2v2-newelements.xml');

m = TranslateSBML(filename);

test = 34;
Totalfail = 0;

Totalfail = Totalfail + fail_unless(m.SBML_level == 2);
Totalfail = Totalfail + fail_unless(m.SBML_version == 2);

Totalfail = Totalfail + fail_unless(m.sboTerm == 4);

%     <listOfCompartmentTypes>
%         <compartmentType id="mitochondria"/>
%     </listOfCompartmentTypes>
  
  Totalfail = Totalfail + fail_unless( length(m.compartmentType) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.compartmentType.id, 'mitochondria'));

%     <listOfSpeciesTypes>
%         <speciesType id="Glucose"/> 
%     </listOfSpeciesTypes>        

  Totalfail = Totalfail + fail_unless( length(m.speciesType) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.speciesType.id, 'Glucose'));


%   //
%   // <listOfCompartments>
%     <compartment id="cell" size="0.013" compartmentType="mitochondria" outside="m"/>
%     <compartment id="m" size="0.013" compartmentType="mitochondria"/>
%   // </listOfCompartments>
%   //

  Totalfail = Totalfail + fail_unless( length(m.compartment) == 2);

  Totalfail = Totalfail + fail_unless( strcmp(m.compartment(1).id, 'cell'));
  Totalfail = Totalfail + fail_unless( m.compartment(1).size == 0.013);
  Totalfail = Totalfail + fail_unless( strcmp(m.compartment(1).compartmentType, 'mitochondria'));
  Totalfail = Totalfail + fail_unless( strcmp(m.compartment(1).outside, 'm'));

  Totalfail = Totalfail + fail_unless( strcmp(m.compartment(2).id, 'm'));
  Totalfail = Totalfail + fail_unless( m.compartment(2).size == 0.013);
  Totalfail = Totalfail + fail_unless( strcmp(m.compartment(2).compartmentType, 'mitochondria'));

%   //
%   // <listOfSpecies>
%     <species id="X0" compartment="cell" speciesType="Glucose"/>
%   // </listOfSpecies>
%   //

  Totalfail = Totalfail + fail_unless( length(m.species) == 2);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).id, 'X0'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).compartment, 'cell' ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).speciesType, 'Glucose' ));

% <listOfInitialAssignments>
%     <initialAssignment symbol="X0">
%         <math xmlns="http://www.w3.org/1998/Math/MathML">
%             <apply>
%                 <times/>
%                 <ci> y </ci>
%                 <cn> 2 </cn>
%             </apply>
%         </math>
%     </initialAssignment>
%  </listOfInitialAssignments>    

  Totalfail = Totalfail + fail_unless( length(m.initialAssignment) == 1);

  Totalfail = Totalfail + fail_unless( strcmp( m.initialAssignment(1).symbol, 'X0' ));
  Totalfail = Totalfail + fail_unless( strcmp( m.initialAssignment(1).math, 'y*2' ));

% <listOfConstraints>
%     <constraint>
%         <math xmlns="http://www.w3.org/1998/Math/MathML">
%             <apply>
%                 <lt/>
%                 <cn> 1 </cn>
%                 <ci> cell </ci>
%             </apply>
%         </math>
%         <message>
%             <p xmlns="http://www.w3.org/1999/xhtml">
%             Species S1 is out of range 
%             </p>
%         </message>
%     </constraint>
% </listOfConstraints>        

  Totalfail = Totalfail + fail_unless( length(m.constraint) == 1);

  Totalfail = Totalfail + fail_unless( strcmp( m.constraint(1).math, 'lt(1,cell)' ));
% not yet!!
% Totalfail = Totalfail + fail_unless( strcmp( m.constraint(1).message, 'Species S1 is out of range' ));
        
%   //
%   // <listOfReactions> ... </listOfReactions>
%   //

  Totalfail = Totalfail + fail_unless( length(m.reaction) == 1);

% <listOfReactions>
%     <reaction id="in" sboTerm="0000005">
%         <listOfReactants>
%             <speciesReference species="X0" id="me" name="sarah"/>
%         </listOfReactants>
%     </reaction>
% </listOfReactions>

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).id, 'in'));
  Totalfail = Totalfail + fail_unless( m.reaction(1).sboTerm == 231);
  Totalfail = Totalfail + fail_unless( m.reaction(1).reversible == 1);

  Totalfail = Totalfail + fail_unless( length(m.reaction(1).reactant) == 1);
  Totalfail = Totalfail + fail_unless( length(m.reaction(1).product)  == 0);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).reactant.species, 'X0'));
  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).reactant.id, 'me'));
  Totalfail = Totalfail + fail_unless( strcmp(m.reaction(1).reactant.name, 'sarah'));

  Totalfail = Totalfail + fail_unless( m.reaction(1).kineticLaw.sboTerm == -1);

if (silent == 0)
disp('Testing readFromFile7:');
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
    
