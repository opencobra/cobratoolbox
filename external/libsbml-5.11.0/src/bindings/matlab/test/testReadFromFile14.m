function y = testReadFromFile14(silent)

filename = fullfile(pwd,'test-data', 'convertedFormulas.xml');

m = TranslateSBML(filename);

test = 0;
Totalfail = 0;

Totalfail = Totalfail + fail_unless(m.SBML_level == 3);
Totalfail = Totalfail + fail_unless(m.SBML_version == 1);

test = test + 2;


%    <listOfFunctionDefinitions>
%       <functionDefinition id="fd">
%         <math xmlns="http://www.w3.org/1998/Math/MathML">
%           <lambda>
%             <bvar>
%               <ci> x </ci>
%             </bvar>
%             <apply>
%               <power/>
%               <ci> x </ci>
%               <cn type="integer"> 3 </cn>
%             </apply>
%           </lambda>
%         </math>
%       </functionDefinition>
%     </listOfFunctionDefinitions>
  Totalfail = Totalfail + fail_unless( length(m.functionDefinition) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.functionDefinition.id, 'fd'));
  Totalfail = Totalfail + fail_unless( strcmp(m.functionDefinition.math, 'lambda(x,power(x,3))'));
  Totalfail = Totalfail + fail_unless( strcmp(m.functionDefinition.typecode, 'SBML_FUNCTION_DEFINITION'));

  test = test + 4;

  
%     <listOfInitialAssignments>
%       <initialAssignment symbol="p1">
%         <math xmlns="http://www.w3.org/1998/Math/MathML">
%           <apply>
%             <arccosh/>
%             <ci> x </ci>
%           </apply>
%         </math>
%       </initialAssignment>
%     </listOfInitialAssignments>

  Totalfail = Totalfail + fail_unless( length(m.initialAssignment) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.initialAssignment.symbol, 'p1'));
  Totalfail = Totalfail + fail_unless( strcmp(m.initialAssignment.math, 'acosh(x)'));
  Totalfail = Totalfail + fail_unless( strcmp(m.initialAssignment.typecode, 'SBML_INITIAL_ASSIGNMENT'));

  test = test + 4;

%     <listOfRules>

  Totalfail = Totalfail + fail_unless( length(m.rule) == 5);

  test = test + 1;

%       <algebraicRule>
%         <math xmlns="http://www.w3.org/1998/Math/MathML">
%           <apply>
%             <power/>
%             <ci> x </ci>
%             <cn type="integer"> 3 </cn>
%           </apply>
%         </math>
%       </algebraicRule>

  Totalfail = Totalfail + fail_unless( strcmp(m.rule(1).formula, 'power(x,3)'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(1).typecode, 'SBML_ALGEBRAIC_RULE'));

  test = test + 2;


%       <assignmentRule variable="p2">
%         <math xmlns="http://www.w3.org/1998/Math/MathML">
%           <apply>
%             <times/>
%             <ci> x </ci>
%             <exponentiale/>
%           </apply>
%         </math>
%       </assignmentRule>

  Totalfail = Totalfail + fail_unless( strcmp(m.rule(2).variable, 'p2'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(2).formula, 'x*exp(1)'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(2).typecode, 'SBML_ASSIGNMENT_RULE'));

  test = test + 3;


%       <assignmentRule variable="p">
%         <math xmlns="http://www.w3.org/1998/Math/MathML">
%           <apply>
%             <root/>
%             <degree>
%               <cn type="integer"> 3 </cn>
%             </degree>
%             <ci> x </ci>
%           </apply>
%         </math>
%       </assignmentRule>

  Totalfail = Totalfail + fail_unless( strcmp(m.rule(3).variable, 'p'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(3).formula, 'nthroot(x,3)'));

  Totalfail = Totalfail + fail_unless( strcmp(m.rule(3).typecode, 'SBML_ASSIGNMENT_RULE'));

  test = test + 3;


%       <rateRule variable="p3">
%         <math xmlns="http://www.w3.org/1998/Math/MathML">
%           <apply>
%             <log/>
%             <logbase>
%               <cn type="integer"> 2 </cn>
%             </logbase>
%             <ci> p1 </ci>
%           </apply>
%         </math>
%       </rateRule>
%     </listOfRules>

  Totalfail = Totalfail + fail_unless( strcmp(m.rule(4).variable, 'p3'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(4).formula, 'log2(p1)'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(4).typecode, 'SBML_RATE_RULE'));

  test = test + 3;

%       <rateRule variable="x">
%         <math xmlns="http://www.w3.org/1998/Math/MathML">
%           <apply>
%             <ln/>
%             <ci> p1 </ci>
%           </apply>
%         </math>
%       </rateRule>

  Totalfail = Totalfail + fail_unless( strcmp(m.rule(5).variable, 'x'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(5).formula, 'log(p1)'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(5).typecode, 'SBML_RATE_RULE'));

  test = test + 3;


%       <listOfConstraints>
%       <constraint>
%         <math xmlns="http://www.w3.org/1998/Math/MathML">
%           <apply>
%             <and/>
%             <false/>
%             <true/>
%             <false/>
%           </apply>
%         </math>
%       </constraint>
%     </listOfConstraints>

  Totalfail = Totalfail + fail_unless( length(m.constraint) == 1);
 
  Totalfail = Totalfail + fail_unless( strcmp(m.constraint.math, 'and(and(false,true),false)'));
  Totalfail = Totalfail + fail_unless( strcmp(m.constraint.typecode, 'SBML_CONSTRAINT'));

  test = test + 3;

%     <listOfReactions>
%       <reaction id="r">
%         <listOfReactants>
%           <speciesReference species="s" constant="true"/>
%         </listOfReactants>
%         <kineticLaw>
%           <math xmlns="http://www.w3.org/1998/Math/MathML">
%             <apply>
%               <log/>
%               <logbase>
%                 <cn type="integer"> 10 </cn>
%               </logbase>
%               <ci> s </ci>
%             </apply>
%           </math>
%           <listOfParameters>
%             <parameter id="k" value="9" units="litre"/>
%           </listOfParameters>
%         </kineticLaw>
%       </reaction>
%     </listOfReactions>

  Totalfail = Totalfail + fail_unless( length(m.reaction) == 1);
 
  Totalfail = Totalfail + fail_unless( strcmp(m.reaction.kineticLaw.math, 'log10(s)'));
  Totalfail = Totalfail + fail_unless( strcmp(m.reaction.typecode, 'SBML_REACTION'));

  test = test + 3;

%     <listOfEvents>
%       <event useValuesFromTriggerTime="false">
%         <trigger>
%           <math xmlns="http://www.w3.org/1998/Math/MathML">
%             <apply>
%               <leq/>
%               <ci> x </ci>
%               <cn type="integer"> 3 </cn>
%             </apply>
%           </math>
%         </trigger>
%         <delay>
%           <math xmlns="http://www.w3.org/1998/Math/MathML">
%             <apply>
%               <times/>
%               <ci> x </ci>
%               <cn type="integer"> 3 </cn>
%             </apply>
%           </math>
%         </delay>
%         <listOfEventAssignments>
%           <eventAssignment variable="a">
%             <math xmlns="http://www.w3.org/1998/Math/MathML">
%               <apply>
%                 <log/>
%                 <logbase>
%                   <cn type="integer"> 3 </cn>
%                 </logbase>
%                 <ci> x </ci>
%               </apply>
%             </math>
%           </eventAssignment>
%         </listOfEventAssignments>
%       </event>
%     </listOfEvents>

  Totalfail = Totalfail + fail_unless( length(m.event) == 1);
 
  Totalfail = Totalfail + fail_unless( strcmp(m.event.trigger.math, 'le(x,3)'));
  Totalfail = Totalfail + fail_unless( strcmp(m.event.eventAssignment.math, '(log(x)/log(3))'));

  test = test + 3;


if (silent == 0)
disp('Testing readFromFile14:');
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
    
