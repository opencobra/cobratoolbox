function y = testReadFromFile13(silent)

filename = fullfile(pwd,'test-data', 'l3v1core.xml');

m = TranslateSBML(filename);

test = 0;
Totalfail = 0;

Totalfail = Totalfail + fail_unless(m.SBML_level == 3);
Totalfail = Totalfail + fail_unless(m.SBML_version == 1);

test = test + 2;

%   <model id="l3_all" timeUnits="time"
%            name="m1"
%            substanceUnits="mole" volumeUnits="litre"
%            lengthUnits="metre" conversionFactor="d" extentUnits="mole"
%            areaUnits="area" metaid="hh">

Totalfail = Totalfail + fail_unless(strcmp(m.id, 'l3_all'));
Totalfail = Totalfail + fail_unless(strcmp(m.name, 'm1'));
Totalfail = Totalfail + fail_unless(strcmp(m.timeUnits, 'time'));
Totalfail = Totalfail + fail_unless(strcmp(m.substanceUnits, 'mole'));
Totalfail = Totalfail + fail_unless(strcmp(m.lengthUnits, 'metre'));
Totalfail = Totalfail + fail_unless(strcmp(m.areaUnits, 'area'));
Totalfail = Totalfail + fail_unless(strcmp(m.volumeUnits, 'litre'));
Totalfail = Totalfail + fail_unless(strcmp(m.extentUnits, 'mole'));
Totalfail = Totalfail + fail_unless(strcmp(m.conversionFactor, 'd'));
Totalfail = Totalfail + fail_unless(strcmp(m.metaid, 'hh'));

test = test + 10;


%     <listOfFunctionDefinitions>
%       <functionDefinition id="fd" name="ggh" metaid="_tt">
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
  Totalfail = Totalfail + fail_unless( strcmp(m.functionDefinition.name, 'ggh'));
  Totalfail = Totalfail + fail_unless( strcmp(m.functionDefinition.metaid, '_tt'));
  Totalfail = Totalfail + fail_unless( strcmp(m.functionDefinition.math, 'lambda(x,power(x,3))'));
  Totalfail = Totalfail + fail_unless( strcmp(m.functionDefinition.typecode, 'SBML_FUNCTION_DEFINITION'));
  Totalfail = Totalfail + fail_unless( m.functionDefinition.sboTerm == -1);

  test = test + 7;
  
%     <listOfUnitDefinitions>
%       <unitDefinition id="area">
%         <listOfUnits>
%           <unit kind="metre" exponent="2" scale="0" multiplier="1"/>
%         </listOfUnits>
%       </unitDefinition>
%       <unitDefinition id="volume">
%         <listOfUnits>
%           <unit kind="litre" exponent="1" scale="0" multiplier="1"/>
%         </listOfUnits>
%       </unitDefinition>
%       <unitDefinition id="substance" name="ddd" sboTerm="SBO:0000001">
%         <listOfUnits>
%           <unit kind="mole" exponent="1" scale="0" multiplier="1"/>
%         </listOfUnits>
%       </unitDefinition>
%       <unitDefinition id="time">
%         <listOfUnits>
%           <unit kind="second" exponent="1" scale="0" multiplier="1"/>
%         </listOfUnits>
%       </unitDefinition>
%       <unitDefinition id="ud1">
%         <listOfUnits>
%           <unit kind="second" exponent="1.4" scale="0" multiplier="1"/>
%         </listOfUnits>
%       </unitDefinition>
%     </listOfUnitDefinitions>
%     
  Totalfail = Totalfail + fail_unless( length(m.unitDefinition) == 5);

  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition(1).id, 'area'));
  Totalfail = Totalfail + fail_unless( isempty(m.unitDefinition(1).name));
  Totalfail = Totalfail + fail_unless( isempty(m.unitDefinition(1).metaid));
  Totalfail = Totalfail + fail_unless( m.unitDefinition(1).sboTerm == -1);
  
  Totalfail = Totalfail + fail_unless( length(m.unitDefinition(1).unit) == 1);
  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition(1).unit.kind, 'metre'));
  Totalfail = Totalfail + fail_unless( m.unitDefinition(1).unit.exponent == 2);
  Totalfail = Totalfail + fail_unless( m.unitDefinition(1).unit.scale == 0);
  Totalfail = Totalfail + fail_unless( m.unitDefinition(1).unit.multiplier == 1);
  Totalfail = Totalfail + fail_unless( isempty(m.unitDefinition(1).unit.metaid));
  Totalfail = Totalfail + fail_unless( m.unitDefinition(1).unit.sboTerm == -1);

  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition(2).id, 'volume'));
  Totalfail = Totalfail + fail_unless( isempty(m.unitDefinition(2).name));
  Totalfail = Totalfail + fail_unless( isempty(m.unitDefinition(2).metaid));
  Totalfail = Totalfail + fail_unless( m.unitDefinition(2).sboTerm == -1);
  
  Totalfail = Totalfail + fail_unless( length(m.unitDefinition(2).unit) == 1);
  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition(2).unit.kind, 'litre'));
  Totalfail = Totalfail + fail_unless( m.unitDefinition(2).unit.exponent == 1);
  Totalfail = Totalfail + fail_unless( m.unitDefinition(2).unit.scale == 0);
  Totalfail = Totalfail + fail_unless( m.unitDefinition(2).unit.multiplier == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition(3).id, 'substance'));
  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition(3).name, 'ddd'));
  Totalfail = Totalfail + fail_unless( m.unitDefinition(3).sboTerm == 1);
  Totalfail = Totalfail + fail_unless( isempty(m.unitDefinition(3).metaid));
  
  Totalfail = Totalfail + fail_unless( length(m.unitDefinition(3).unit) == 1);
  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition(3).unit.kind, 'mole'));
  Totalfail = Totalfail + fail_unless( m.unitDefinition(3).unit.exponent == 1);
  Totalfail = Totalfail + fail_unless( m.unitDefinition(3).unit.scale == 0);
  Totalfail = Totalfail + fail_unless( m.unitDefinition(3).unit.multiplier == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition(4).id, 'time'));
  Totalfail = Totalfail + fail_unless( isempty(m.unitDefinition(4).name));
  Totalfail = Totalfail + fail_unless( m.unitDefinition(4).sboTerm == -1);
  Totalfail = Totalfail + fail_unless( isempty(m.unitDefinition(4).metaid));
  
  Totalfail = Totalfail + fail_unless( length(m.unitDefinition(4).unit) == 1);
  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition(4).unit.kind, 'second'));
  Totalfail = Totalfail + fail_unless( m.unitDefinition(4).unit.exponent == 1);
  Totalfail = Totalfail + fail_unless( m.unitDefinition(4).unit.scale == 0);
  Totalfail = Totalfail + fail_unless( m.unitDefinition(4).unit.multiplier == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition(5).id, 'ud1'));
  Totalfail = Totalfail + fail_unless( isempty(m.unitDefinition(5).name));
  Totalfail = Totalfail + fail_unless( m.unitDefinition(5).sboTerm == -1);
  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition(5).metaid, 'll'));
  
  Totalfail = Totalfail + fail_unless( length(m.unitDefinition(5).unit) == 1);
  Totalfail = Totalfail + fail_unless( strcmp(m.unitDefinition(5).unit.kind, 'second'));
  Totalfail = Totalfail + fail_unless( m.unitDefinition(5).unit.exponent == 1.4);
  Totalfail = Totalfail + fail_unless( m.unitDefinition(5).unit.scale == 0);
  Totalfail = Totalfail + fail_unless( m.unitDefinition(5).unit.multiplier == 1);
  
  test = test + 48;
%   
%     <listOfCompartments>
%       <compartment id="a" spatialDimensions="4.5" size="1" units="volume" constant="false"/>
%       <compartment id="a1" constant="true"/>
%     </listOfCompartments>
  Totalfail = Totalfail + fail_unless( length(m.compartment) == 2);

  Totalfail = Totalfail + fail_unless( strcmp(m.compartment(1).id, 'a'));
  Totalfail = Totalfail + fail_unless( m.compartment(1).constant == 0);
  Totalfail = Totalfail + fail_unless( m.compartment(1).size == 1);
  Totalfail = Totalfail + fail_unless( m.compartment(1).spatialDimensions == 4.5);
  Totalfail = Totalfail + fail_unless( strcmp(m.compartment(1).units, 'volume'));
  Totalfail = Totalfail + fail_unless( isempty(m.compartment(1).metaid));
  Totalfail = Totalfail + fail_unless( m.compartment(1).sboTerm == -1);
  Totalfail = Totalfail + fail_unless( m.compartment(1).isSetSpatialDimensions == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.compartment(2).id, 'a1'));
  Totalfail = Totalfail + fail_unless( strcmp(m.compartment(2).metaid, 'smk'));
  Totalfail = Totalfail + fail_unless( m.compartment(2).constant == 1);
  Totalfail = Totalfail + fail_unless( isnan(m.compartment(2).size));
  Totalfail = Totalfail + fail_unless( isnan(m.compartment(2).spatialDimensions));
  Totalfail = Totalfail + fail_unless( m.compartment(2).isSetSpatialDimensions == 0);

  test = test + 15;

%     <listOfSpecies>
%       <species id="s" compartment="a" initialAmount="0" substanceUnits="substance" 
%                hasOnlySubstanceUnits="false" boundaryCondition="false" constant="false" conversionFactor="d"/>
%       <species id="s1" compartment="a" initialConcentration="2.2" substanceUnits="substance" 
%                hasOnlySubstanceUnits="true" boundaryCondition="true" constant="true" conversionFactor="d"/>
%       <species id="s2" compartment="a" 
%                hasOnlySubstanceUnits="false" boundaryCondition="false" constant="false"/>
%     </listOfSpecies>
  Totalfail = Totalfail + fail_unless( length(m.species) == 3);

  Totalfail = Totalfail + fail_unless( strcmp(m.species(1).id, 's'));
  Totalfail = Totalfail + fail_unless( strcmp(m.species(1).compartment, 'a'));
  Totalfail = Totalfail + fail_unless( m.species(1).initialAmount == 0);
  Totalfail = Totalfail + fail_unless( isnan(m.species(1).initialConcentration));
  Totalfail = Totalfail + fail_unless( strcmp(m.species(1).substanceUnits, 'substance'));
  Totalfail = Totalfail + fail_unless( m.species(1).hasOnlySubstanceUnits == 0);
  Totalfail = Totalfail + fail_unless( m.species(1).boundaryCondition == 0);
  Totalfail = Totalfail + fail_unless( m.species(1).constant == 0);
  Totalfail = Totalfail + fail_unless( strcmp(m.species(1).conversionFactor, 'd'));
  Totalfail = Totalfail + fail_unless( m.species(1).isSetInitialAmount == 1);
  Totalfail = Totalfail + fail_unless( m.species(1).isSetInitialConcentration == 0);
  Totalfail = Totalfail + fail_unless( isempty(m.species(1).metaid));

  Totalfail = Totalfail + fail_unless( strcmp(m.species(2).id, 's1'));
  Totalfail = Totalfail + fail_unless( strcmp(m.species(2).compartment, 'a'));
  Totalfail = Totalfail + fail_unless( isnan(m.species(2).initialAmount));
  Totalfail = Totalfail + fail_unless( m.species(2).initialConcentration == 2.2);
  Totalfail = Totalfail + fail_unless( strcmp(m.species(2).substanceUnits, 'substance'));
  Totalfail = Totalfail + fail_unless( m.species(2).hasOnlySubstanceUnits == 1);
  Totalfail = Totalfail + fail_unless( m.species(2).boundaryCondition == 1);
  Totalfail = Totalfail + fail_unless( m.species(2).constant == 1);
  Totalfail = Totalfail + fail_unless( strcmp(m.species(2).conversionFactor, 'd'));
  Totalfail = Totalfail + fail_unless( m.species(2).isSetInitialAmount == 0);
  Totalfail = Totalfail + fail_unless( m.species(2).isSetInitialConcentration == 1);
  Totalfail = Totalfail + fail_unless( m.species(2).sboTerm == -1);

  Totalfail = Totalfail + fail_unless( strcmp(m.species(3).id, 's2'));
  Totalfail = Totalfail + fail_unless( strcmp(m.species(3).compartment, 'a'));
  Totalfail = Totalfail + fail_unless( isnan(m.species(3).initialAmount));
  Totalfail = Totalfail + fail_unless( isnan(m.species(3).initialConcentration));
  Totalfail = Totalfail + fail_unless( isempty(m.species(3).substanceUnits));
  Totalfail = Totalfail + fail_unless( m.species(3).hasOnlySubstanceUnits == 0);
  Totalfail = Totalfail + fail_unless( m.species(3).boundaryCondition == 0);
  Totalfail = Totalfail + fail_unless( m.species(3).constant == 0);
  Totalfail = Totalfail + fail_unless( isempty(m.species(3).conversionFactor));
  Totalfail = Totalfail + fail_unless( m.species(3).isSetInitialAmount == 0);
  Totalfail = Totalfail + fail_unless( m.species(3).isSetInitialConcentration == 0);

  test = test + 36;
  
%     <listOfParameters>
%       <parameter id="p" value="2" units="second" constant="false"/>
%       <parameter id="p1" value="2" units="litre" constant="false"/>
%       <parameter id="p2" value="2" units="litre" constant="false"/>
%       <parameter id="p3" value="2" units="litre" constant="false"/>
%       <parameter id="x" value="2" units="dimensionless" constant="false"/>
%       <parameter id="d" units="dimensionless" constant="true"/>
%     </listOfParameters>
  Totalfail = Totalfail + fail_unless( length(m.parameter) == 6);

  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(1).id, 'p'));
  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(1).units, 'second'));
  Totalfail = Totalfail + fail_unless( m.parameter(1).constant == 0);
  Totalfail = Totalfail + fail_unless( m.parameter(1).value == 2);
  Totalfail = Totalfail + fail_unless( isempty(m.parameter(1).metaid));

  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(2).id, 'p1'));
  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(2).units, 'litre'));
  Totalfail = Totalfail + fail_unless( m.parameter(2).constant == 0);
  Totalfail = Totalfail + fail_unless( m.parameter(2).value == 2);

  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(3).id, 'p2'));
  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(3).units, 'litre'));
  Totalfail = Totalfail + fail_unless( m.parameter(3).constant == 0);
  Totalfail = Totalfail + fail_unless( m.parameter(3).value == 2);
  Totalfail = Totalfail + fail_unless( m.parameter(3).sboTerm == -1);

  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(4).id, 'p3'));
  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(4).units, 'litre'));
  Totalfail = Totalfail + fail_unless( m.parameter(4).constant == 0);
  Totalfail = Totalfail + fail_unless( m.parameter(4).value == 2);

  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(5).id, 'x'));
  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(5).units, 'dimensionless'));
  Totalfail = Totalfail + fail_unless( m.parameter(5).constant == 0);
  Totalfail = Totalfail + fail_unless( m.parameter(5).value == 2);

  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(6).id, 'd'));
  Totalfail = Totalfail + fail_unless( strcmp(m.parameter(6).units, 'dimensionless'));
  Totalfail = Totalfail + fail_unless( m.parameter(6).constant == 1);
  Totalfail = Totalfail + fail_unless( isnan(m.parameter(6).value));
  
  test = test + 27;
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
  Totalfail = Totalfail + fail_unless( m.initialAssignment.sboTerm == -1);
  Totalfail = Totalfail + fail_unless( isempty(m.initialAssignment(1).metaid));

  test = test + 5;
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
%       <rateRule variable="p3"  sboTerm="SBO:0000064">
%         <math xmlns="http://www.w3.org/1998/Math/MathML">
%           <apply>
%             <divide/>
%             <ci> p1 </ci>
%             <ci> p </ci>
%           </apply>
%         </math>
%       </rateRule>
%     </listOfRules>
  Totalfail = Totalfail + fail_unless( length(m.rule) == 4);

  Totalfail = Totalfail + fail_unless( strcmp(m.rule(1).typecode, 'SBML_ALGEBRAIC_RULE'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(1).formula, 'power(x,3)'));
  Totalfail = Totalfail + fail_unless( isempty(m.rule(1).variable) );
  Totalfail = Totalfail + fail_unless( m.rule(1).sboTerm == -1 );
  Totalfail = Totalfail + fail_unless( isempty(m.rule(1).metaid));

  Totalfail = Totalfail + fail_unless( strcmp(m.rule(2).typecode, 'SBML_ASSIGNMENT_RULE'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(2).formula, 'x*p3'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(2).variable, 'p2'));
  Totalfail = Totalfail + fail_unless( m.rule(2).sboTerm == -1 );

  Totalfail = Totalfail + fail_unless( strcmp(m.rule(3).typecode, 'SBML_RATE_RULE'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(3).formula, 'p1/p'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(3).variable, 'p3'));
  Totalfail = Totalfail + fail_unless( m.rule(3).sboTerm == 64 );
  
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(4).typecode, 'SBML_ASSIGNMENT_RULE'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(4).formula, 's*p'));
  Totalfail = Totalfail + fail_unless( strcmp(m.rule(4).variable, 'generatedId_0'));
  Totalfail = Totalfail + fail_unless( m.rule(4).sboTerm == -1 );

  test = test + 18;

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
  Totalfail = Totalfail + fail_unless( m.constraint.sboTerm == -1 );
  Totalfail = Totalfail + fail_unless( isempty(m.constraint.message) );
  Totalfail = Totalfail + fail_unless( isempty(m.constraint(1).metaid));
 
  test = test + 5;

%     <listOfReactions>
%       <reaction id="r" reversible="true" fast="false" compartment="a">
%         <listOfReactants>
%           <speciesReference id="generatedId_0" species="s" constant="false"/>
%         </listOfReactants>
%         <listOfProducts>
%           <speciesReference metaid="_0" species="s2" constant="false" sboTerm="SBO:0000001"/>
%           <speciesReference species="s1" constant="false" sboTerm="SBO:0000001"/>
%         </listOfProducts>
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
%           <listOfLocalParameters>
%             <localParameter id="k" value="9" units="litre"/>
%           </listOfLocalParameters>
%         </kineticLaw>
%       </reaction>
%     </listOfReactions>
  Totalfail = Totalfail + fail_unless( length(m.reaction) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction.id, 'r'));
  Totalfail = Totalfail + fail_unless( m.reaction.fast == 0 );
  Totalfail = Totalfail + fail_unless( strcmp(m.reaction.compartment, 'a'));
  Totalfail = Totalfail + fail_unless( m.reaction.reversible == 1 );
  Totalfail = Totalfail + fail_unless( isempty(m.reaction.metaid));
  Totalfail = Totalfail + fail_unless( m.reaction.sboTerm == -1 );
  Totalfail = Totalfail + fail_unless( isempty(m.reaction(1).metaid));
    
  Totalfail = Totalfail + fail_unless( length(m.reaction.reactant) == 1);
  Totalfail = Totalfail + fail_unless( length(m.reaction.product) == 2);
  Totalfail = Totalfail + fail_unless( length(m.reaction.modifier) == 0);

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction.reactant.species, 's'));
  Totalfail = Totalfail + fail_unless( strcmp(m.reaction.reactant.id, 'generatedId_0'));
  Totalfail = Totalfail + fail_unless( isempty(m.reaction.reactant.metaid));
  Totalfail = Totalfail + fail_unless( isempty(m.reaction.reactant.name));
  Totalfail = Totalfail + fail_unless( m.reaction.reactant.sboTerm == -1 );
  Totalfail = Totalfail + fail_unless( m.reaction.reactant.constant == 0 );
  Totalfail = Totalfail + fail_unless( m.reaction.reactant.isSetStoichiometry == 0 );

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction.product(1).species, 's2'));
  Totalfail = Totalfail + fail_unless( strcmp(m.reaction.product(1).metaid, '_0'));
  Totalfail = Totalfail + fail_unless( isempty(m.reaction.product(1).id));
  Totalfail = Totalfail + fail_unless( isempty(m.reaction.product(1).name));
  Totalfail = Totalfail + fail_unless( m.reaction.product(1).sboTerm == 1 );
  Totalfail = Totalfail + fail_unless( m.reaction.product(1).constant == 0 );
  Totalfail = Totalfail + fail_unless( m.reaction.product(1).isSetStoichiometry == 1 );
  Totalfail = Totalfail + fail_unless( m.reaction.product(1).stoichiometry == 1 );

  Totalfail = Totalfail + fail_unless( strcmp(m.reaction.kineticLaw.math, 's*k/p'));
  Totalfail = Totalfail + fail_unless( length(m.reaction.kineticLaw.localParameter) == 1);
  Totalfail = Totalfail + fail_unless( isempty(m.reaction.kineticLaw.metaid));
  Totalfail = Totalfail + fail_unless( m.reaction.kineticLaw.sboTerm == -1 );
  
  Totalfail = Totalfail + fail_unless( strcmp(m.reaction.kineticLaw.localParameter(1).id, 'k'));
  Totalfail = Totalfail + fail_unless( strcmp(m.reaction.kineticLaw.localParameter(1).units, 'litre'));
  Totalfail = Totalfail + fail_unless( m.reaction.kineticLaw.localParameter(1).value == 9);
  Totalfail = Totalfail + fail_unless( isempty(m.reaction.kineticLaw.localParameter(1).metaid));
  Totalfail = Totalfail + fail_unless( isempty(m.reaction.kineticLaw.localParameter(1).name));
  Totalfail = Totalfail + fail_unless( m.reaction.kineticLaw.localParameter(1).sboTerm == -1 );
  Totalfail = Totalfail + fail_unless( strcmp(m.reaction.kineticLaw.localParameter(1).typecode, 'SBML_LOCAL_PARAMETER'));

  test = test + 33;
%     <listOfEvents>
%      <event useValuesFromTriggerTime="false">
%         <trigger initialValue="false" persistent="false">
%           <math xmlns="http://www.w3.org/1998/Math/MathML">
%             <apply>
%               <lt/>
%               <ci> x </ci>
%               <cn type="integer"> 3 </cn>
%             </apply>
%           </math>
%         </trigger>
%          <priority>
%             <math xmlns="http://www.w3.org/1998/Math/MathML">
%                 <cn> 1 </cn>
%             </math>
%          </priority>
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
  Totalfail = Totalfail + fail_unless( m.event.sboTerm == -1);
  Totalfail = Totalfail + fail_unless( isempty(m.event.metaid ));
  
  Totalfail = Totalfail + fail_unless( strcmp(m.event.trigger.math, 'lt(x,3)'));
  Totalfail = Totalfail + fail_unless( isempty(m.event.trigger.metaid ));
  Totalfail = Totalfail + fail_unless( m.event.trigger.sboTerm == -1);
  Totalfail = Totalfail + fail_unless( m.event.trigger.persistent == 0);
  Totalfail = Totalfail + fail_unless( m.event.trigger.initialValue == 0);
  
  Totalfail = Totalfail + fail_unless( strcmp(m.event.priority.math, '1'));
  Totalfail = Totalfail + fail_unless( isempty(m.event.priority.metaid ));
  Totalfail = Totalfail + fail_unless( m.event.priority.sboTerm == -1);

  Totalfail = Totalfail + fail_unless( strcmp(m.event.delay.math, 'x*3'));
  Totalfail = Totalfail + fail_unless( isempty(m.event.delay.metaid ));
  Totalfail = Totalfail + fail_unless( m.event.delay.sboTerm == 64);
  
  Totalfail = Totalfail + fail_unless( length(m.event.eventAssignment) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.event.eventAssignment.variable, 'a'));
  Totalfail = Totalfail + fail_unless( strcmp(m.event.eventAssignment.math, 'x*p3'));
  Totalfail = Totalfail + fail_unless( strcmp(m.event.eventAssignment.metaid, 'kkl'));
  Totalfail = Totalfail + fail_unless( m.event.eventAssignment.sboTerm == -1);
  
  test = test + 20;
  
if (silent == 0)
disp('Testing readFromFile13:');
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
    
