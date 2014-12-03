function y = testReadFromFile12(silent)

filename = fullfile(pwd,'test-data', 'l2v4-all.xml');

m = TranslateSBML(filename);

test = 75;
Totalfail = 0;

Totalfail = Totalfail + fail_unless(m.SBML_level == 2);
Totalfail = Totalfail + fail_unless(m.SBML_version == 4);

%     <listOfFunctionDefinitions>
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

%     <listOfUnitDefinitions>
%       <unitDefinition id="ud1">
%         <listOfUnits>
%           <unit kind="mole"/>
%         </listOfUnits>
%       </unitDefinition>
%     </listOfUnitDefinitions>
  Totalfail = Totalfail + fail_unless( length(m.unitDefinition) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition.id, 'ud1'));
  
  Totalfail = Totalfail + fail_unless( length(m.unitDefinition.unit) == 1);
  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition.unit.kind, 'mole'));
  
%     <listOfCompartmentTypes>
%       <compartmentType id="hh"/>
%     </listOfCompartmentTypes>
  Totalfail = Totalfail + fail_unless( length(m.compartmentType) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.compartmentType.id, 'hh'));
 
%     <listOfSpeciesTypes>
%       <speciesType id="gg"/>
%     </listOfSpeciesTypes>
  Totalfail = Totalfail + fail_unless( length(m.speciesType) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.speciesType.id, 'gg'));

%     <listOfCompartments>
%       <compartment id="a" size="1" constant="false"/>
%     </listOfCompartments>
  Totalfail = Totalfail + fail_unless( length(m.compartment) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.compartment.id, 'a'));
  Totalfail = Totalfail + fail_unless( m.compartment.constant == 0);
  Totalfail = Totalfail + fail_unless( m.compartment.size == 1);

%     <listOfSpecies>
%       <species id="s" compartment="a" initialAmount="0"/>
%     </listOfSpecies>
  Totalfail = Totalfail + fail_unless( length(m.species) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.species.id, 's'));
  Totalfail = Totalfail + fail_unless( strcmp(m.species.compartment, 'a'));
  Totalfail = Totalfail + fail_unless( m.species.initialAmount == 0);

%     <listOfParameters>
%       <parameter id="p" value="2" units="second" constant="false"/>
%       <parameter id="p1" value="2" units="litre" constant="false"/>
%       <parameter id="p2" value="2" units="litre" constant="false"/>
%       <parameter id="p3" value="2" units="litre" constant="false"/>
%       <parameter id="x" value="2" units="dimensionless" constant="false"/>
%     </listOfParameters>
  Totalfail = Totalfail + fail_unless( length(m.parameter) == 5);

  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(1).id, 'p'));
  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(1).units, 'second'));
  Totalfail = Totalfail + fail_unless( m.parameter(1).constant == 0);
  Totalfail = Totalfail + fail_unless( m.parameter(1).value == 2);

  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(2).id, 'p1'));
  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(2).units, 'litre'));
  Totalfail = Totalfail + fail_unless( m.parameter(2).constant == 0);
  Totalfail = Totalfail + fail_unless( m.parameter(2).value == 2);

  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(3).id, 'p2'));
  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(3).units, 'litre'));
  Totalfail = Totalfail + fail_unless( m.parameter(3).constant == 0);
  Totalfail = Totalfail + fail_unless( m.parameter(3).value == 2);

  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(4).id, 'p3'));
  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(4).units, 'litre'));
  Totalfail = Totalfail + fail_unless( m.parameter(4).constant == 0);
  Totalfail = Totalfail + fail_unless( m.parameter(4).value == 2);

  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(5).id, 'x'));
  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(5).units, 'dimensionless'));
  Totalfail = Totalfail + fail_unless( m.parameter(5).constant == 0);
  Totalfail = Totalfail + fail_unless( m.parameter(5).value == 2);

%     <listOfInitialAssignments>
%       <initialAssignment symbol="p1">
%         <math xmlns="http://www.w3.org/1998/Math/MathML">
%           <apply>
%             <times/>
%             <ci> x </ci>
%             <ci> p3 </ci>
%           </apply>
%         </math>
%       </initialAssignment>
%     </listOfInitialAssignments>
  Totalfail = Totalfail + fail_unless( length(m.initialAssignment) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.initialAssignment.symbol, 'p1'));
  Totalfail = Totalfail + fail_unless( strcmp(m.initialAssignment.math, 'x*p3'));

%     <listOfRules>
%       <algebraicRule>
%         <math xmlns="http://www.w3.org/1998/Math/MathML">
%           <apply>
%             <power/>
%             <ci> x </ci>
%             <cn type="integer"> 3 </cn>
%           </apply>
%         </math>
%       </algebraicRule>
%       <assignmentRule variable="p2">
%         <math xmlns="http://www.w3.org/1998/Math/MathML">
%           <apply>
%             <times/>
%             <ci> x </ci>
%             <ci> p3 </ci>
%           </apply>
%         </math>
%       </assignmentRule>
%       <rateRule variable="p3">
%         <math xmlns="http://www.w3.org/1998/Math/MathML">
%           <apply>
%             <divide/>
%             <ci> p1 </ci>
%             <ci> p </ci>
%           </apply>
%         </math>
%       </rateRule>
%     </listOfRules>
  Totalfail = Totalfail + fail_unless( length(m.rule) == 3);

  Totalfail = Totalfail + fail_unless( strcmp(m.rule(1).typecode, 'SBML_ALGEBRAIC_RULE'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(1).formula, 'power(x,3)'));

  Totalfail = Totalfail + fail_unless( strcmp(m.rule(2).typecode, 'SBML_ASSIGNMENT_RULE'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(2).formula, 'x*p3'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(2).variable, 'p2'));

  Totalfail = Totalfail + fail_unless( strcmp(m.rule(3).typecode, 'SBML_RATE_RULE'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(3).formula, 'p1/p'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(3).variable, 'p3'));

%     <listOfConstraints>
%       <constraint>
%         <math xmlns="http://www.w3.org/1998/Math/MathML">
%           <apply>
%             <lt/>
%             <ci> x </ci>
%             <cn type="integer"> 3 </cn>
%           </apply>
%         </math>
%       </constraint>
%     </listOfConstraints>
  Totalfail = Totalfail + fail_unless( length(m.constraint) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.constraint.math, 'lt(x,3)'));

%     <listOfReactions>
%       <reaction id="r">
%         <listOfReactants>
%           <speciesReference species="s">
%             <stoichiometryMath>
%               <math xmlns="http://www.w3.org/1998/Math/MathML">
%                 <apply>
%                   <times/>
%                   <ci> s </ci>
%                   <ci> p </ci>
%                 </apply>
%               </math>
%             </stoichiometryMath>
%           </speciesReference>
%         </listOfReactants>
%         <kineticLaw>
%           <math xmlns="http://www.w3.org/1998/Math/MathML">
%             <apply>
%               <divide/>
%               <apply>
%                 <times/>
%                 <ci> s </ci>
%                 <ci> k </ci>
%               </apply>
%               <ci> p </ci>
%             </apply>
%           </math>
%           <listOfParameters>
%             <parameter id="k" value="9" units="litre"/>
%           </listOfParameters>
%         </kineticLaw>
%       </reaction>
%     </listOfReactions>
  Totalfail = Totalfail + fail_unless( length(m.reaction) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction.id, 'r'));
  Totalfail = Totalfail + fail_unless( length(m.reaction.reactant) == 1);
  Totalfail = Totalfail + fail_unless( length(m.reaction.product) == 0);
  Totalfail = Totalfail + fail_unless( length(m.reaction.modifier) == 0);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction.reactant.species, 's'));
  Totalfail = Totalfail + fail_unless( strcmp(m.reaction.reactant.stoichiometryMath.math, 's*p'));

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction.kineticLaw.math, 's * k / p'));
  Totalfail = Totalfail + fail_unless( length(m.reaction.kineticLaw.parameter) == 1);
  
  Totalfail = Totalfail + fail_unless( strcmp(m.reaction.kineticLaw.parameter(1).id, 'k'));
  Totalfail = Totalfail + fail_unless( strcmp(m.reaction.kineticLaw.parameter(1).units, 'litre'));
  Totalfail = Totalfail + fail_unless( m.reaction.kineticLaw.parameter(1).constant == 1);
  Totalfail = Totalfail + fail_unless( m.reaction.kineticLaw.parameter(1).value == 9);

%     <listOfEvents>
%      <event useValuesFromTriggerTime="false">
%         <trigger>
%           <math xmlns="http://www.w3.org/1998/Math/MathML">
%             <apply>
%               <lt/>
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
%                 <times/>
%                 <ci> x </ci>
%                 <ci> p3 </ci>
%               </apply>
%             </math>
%           </eventAssignment>
%         </listOfEventAssignments>
%       </event>
%     </listOfEvents>
  Totalfail = Totalfail + fail_unless( length(m.event) == 1);

  Totalfail = Totalfail + fail_unless( m.event.useValuesFromTriggerTime == 0);
  
  Totalfail = Totalfail + fail_unless( strcmp(m.event.trigger.math, 'lt(x,3)'));
  
  Totalfail = Totalfail + fail_unless( length(m.event.eventAssignment) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.event.eventAssignment.variable, 'a'));
  Totalfail = Totalfail + fail_unless( strcmp(m.event.eventAssignment.math, 'x*p3'));
  
  
  
if (silent == 0)
disp('Testing readFromFile12:');
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
    
