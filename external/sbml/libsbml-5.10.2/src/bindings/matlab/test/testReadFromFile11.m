function y = testReadFromFile11(silent)

filename = fullfile(pwd,'test-data', 'l2v3-newMath.xml');

m = TranslateSBML(filename);

test = 20;
Totalfail = 0;

Totalfail = Totalfail + fail_unless(m.SBML_level == 2);
Totalfail = Totalfail + fail_unless(m.SBML_version == 3);

%         <listOfSpecies>
%             <species id="X0" name="s1" compartment="cell" initialConcentration="1"/>
%         </listOfSpecies>

  Totalfail = Totalfail + fail_unless( length(m.species) == 1);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).name, 's1'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).id, 'X0'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).compartment, 'cell' ));
  Totalfail = Totalfail + fail_unless( m.species(1).initialConcentration == 1);
  Totalfail = Totalfail + fail_unless( m.species(1).boundaryCondition == 0);


% 		<listOfEvents>
% 			<event id="e" timeUnits="second">
% 				<trigger>
% 					<math xmlns="http://www.w3.org/1998/Math/MathML">
% 						<apply>
% 							<neq/>
% 							<cn> 0 </cn>
% 							<cn> 1 </cn>
% 						</apply>
% 					</math>
% 				</trigger>
% 				<delay>
% 					<math xmlns="http://www.w3.org/1998/Math/MathML">
% 						<ci> p </ci>
% 					</math>
% 				</delay>
% 				<listOfEventAssignments>
% 					<eventAssignment variable="p2">
% 						<math xmlns="http://www.w3.org/1998/Math/MathML">
% 							<cn> 0 </cn>
% 						</math>
% 					</eventAssignment>
% 				</listOfEventAssignments>
% 			</event>
% 		</listOfEvents>
  Totalfail = Totalfail + fail_unless( length(m.event) == 1);
  
  Totalfail = Totalfail + fail_unless( strcmp( m.event(1).id, 'e'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.event(1).trigger.math, 'ne(0,1)'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.event(1).delay.math, 'p'             ));

  Totalfail = Totalfail + fail_unless( length(m.event.eventAssignment) == 1);

  Totalfail = Totalfail + fail_unless( strcmp( m.event(1).eventAssignment.variable, 'p2'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.event(1).eventAssignment.math, '0'             ));

%         <listOfReactions>
%             <reaction id="in">
%                 <listOfReactants>
%                     <speciesReference species="X0">
%                       <stoichiometryMath>
%                         <math xmlns="http://www.w3.org/1998/Math/MathML">
%                           <ci> cell </ci>
%                         </math>
%                       </stoichiometryMath>
%                     </speciesReference>
%                 </listOfReactants>
%             </reaction>
%         </listOfReactions>
  Totalfail = Totalfail + fail_unless( length(m.reaction) == 1);
  
  Totalfail = Totalfail + fail_unless( strcmp( m.reaction(1).id, 'in'             ));
  
  Totalfail = Totalfail + fail_unless( length(m.reaction(1).reactant) == 1);
  
  Totalfail = Totalfail + fail_unless( strcmp( m.reaction(1).reactant(1).species, 'X0'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.reaction(1).reactant(1).stoichiometryMath.math, 'cell'             ));
if (silent == 0)

disp('Testing readFromFile11:');
disp(sprintf('Number tests: %d', test));
disp(sprintf('Number fails: %d', Totalfail));
disp(sprintf('Pass rate: %d%%\n', ((test-Totalfail)/test)*100));
end;;
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
    
