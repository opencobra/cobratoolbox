function y = testReadFromFile10(silent)

filename = fullfile(pwd,'test-data', 'l2v1-allelements.xml');

m = TranslateSBML(filename);

test = 25;
Totalfail = 0;

Totalfail = Totalfail + fail_unless(m.SBML_level == 2);
Totalfail = Totalfail + fail_unless(m.SBML_version == 1);
Totalfail = Totalfail + fail_unless( strcmp(m.metaid, '_001'));

%        <listOfFunctionDefinitions>
%          <functionDefinition id="f" name="fred">
%          <math xmlns="http://www.w3.org/1998/Math/MathML">
%           <lambda>
%             <bvar> <ci> x </ci> </bvar>
%             <bvar> <ci> y </ci></bvar>
%             <apply>
%               <plus/> <ci> x </ci> <ci> y </ci>
%             </apply>
%           </lambda>
%         </math>
%         </functionDefinition>
%        </listOfFunctionDefinitions>
  Totalfail = Totalfail + fail_unless( length(m.functionDefinition) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.functionDefinition.name, 'fred'));
  Totalfail = Totalfail + fail_unless( strcmp(m.functionDefinition.id, 'f'));
  Totalfail = Totalfail + fail_unless( strcmp(m.functionDefinition.metaid, '_002'));
  Totalfail = Totalfail + fail_unless( strcmp(m.functionDefinition.math, 'lambda(x,y,x+y)'));

%         <listOfSpecies>
%             <species id="X0" name="s1" compartment="cell" initialConcentration="1"/>
%         </listOfSpecies>

  Totalfail = Totalfail + fail_unless( length(m.species) == 3);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).name, 'x0'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).id, 'X0'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).compartment, 'cell' ));
  Totalfail = Totalfail + fail_unless( m.species(1).initialConcentration == 1);
  Totalfail = Totalfail + fail_unless( m.species(1).boundaryCondition == 0);
  Totalfail = Totalfail + fail_unless( strcmp(m.species(1).metaid, '_004'));


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
  Totalfail = Totalfail + fail_unless( strcmp( m.event(1).timeUnits, 'second'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.event(1).trigger, 'ne(0,1)'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.event(1).delay, 'p'             ));
  Totalfail = Totalfail + fail_unless( strcmp(m.event(1).metaid, '_007'));

  Totalfail = Totalfail + fail_unless( length(m.event.eventAssignment) == 1);

  Totalfail = Totalfail + fail_unless( strcmp( m.event(1).eventAssignment.variable, 'T'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.event(1).eventAssignment.math, '0'             ));
  Totalfail = Totalfail + fail_unless( strcmp(m.event(1).eventAssignment.metaid, '_008'));

if (silent == 0)

disp('Testing readFromFile10:');
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
    
