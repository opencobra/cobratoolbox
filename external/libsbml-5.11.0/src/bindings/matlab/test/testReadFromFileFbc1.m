function y = testReadFromFileFbc1(silent)

filename = fullfile(pwd,'test-data', 'fbc.xml');

m = TranslateSBML(filename);

test = 56;
Totalfail = 0;

Totalfail = Totalfail + fail_unless(m.SBML_level == 3);
Totalfail = Totalfail + fail_unless(m.SBML_version == 1);
Totalfail = Totalfail + fail_unless(m.fbc_version == 1);

%     <listOfCompartments>
%       <compartment id="c" constant="true" spatialDimensions="3"/>
%     </listOfCompartments>

  Totalfail = Totalfail + fail_unless( length(m.compartment) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.compartment.id, 'c'));

  Totalfail = Totalfail + fail_unless( m.compartment.constant == 1);

  Totalfail = Totalfail + fail_unless( m.compartment.spatialDimensions == 3);

%     <listOfSpecies>
%      <species id="S" compartment="c" hasOnlySubstanceUnits="false" 
%                        boundaryCondition="false" constant="false" 
%                        fbc:charge="2" fbc:chemicalFormula="s20"/>
%       <species id="S1" compartment="c" hasOnlySubstanceUnits="false" 
%                        boundaryCondition="false" constant="false" 
%                        fbc:charge="2" fbc:chemicalFormula="s20"/>
%       <species id="S2" compartment="c" hasOnlySubstanceUnits="false" 
%                        boundaryCondition="false" constant="false"/>
%       <species id="S3" compartment="c" hasOnlySubstanceUnits="false" 
%                        boundaryCondition="false" constant="false" 
%                        fbc:charge="2" fbc:chemicalFormula="s20"/>
%       <species id="S4" compartment="c" hasOnlySubstanceUnits="false" 
%                        boundaryCondition="false" constant="false" 
%                        fbc:charge="2" fbc:chemicalFormula="s20"/>
%     </listOfSpecies>

  Totalfail = Totalfail + fail_unless( length(m.species) == 5);

  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).id, 'S'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).compartment, 'c' ));
  Totalfail = Totalfail + fail_unless( m.species(1).isSetInitialAmount == 1);
  Totalfail = Totalfail + fail_unless( m.species(1).isSetInitialConcentration == 0);
  Totalfail = Totalfail + fail_unless( m.species(1).fbc_charge == 2);
  Totalfail = Totalfail + fail_unless( m.species(1).isSetfbc_charge == 1);
  Totalfail = Totalfail + fail_unless( strcmp( m.species(1).fbc_chemicalFormula, 'S20'             ));

  Totalfail = Totalfail + fail_unless( strcmp( m.species(2).id, 'S1'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(2).compartment, 'c' ));
  Totalfail = Totalfail + fail_unless( m.species(2).isSetInitialAmount == 1);
  Totalfail = Totalfail + fail_unless( m.species(2).isSetInitialConcentration == 0);
  Totalfail = Totalfail + fail_unless( m.species(2).fbc_charge == 2);
  Totalfail = Totalfail + fail_unless( m.species(2).isSetfbc_charge == 1);
  Totalfail = Totalfail + fail_unless( strcmp( m.species(2).fbc_chemicalFormula, 'S20'             ));

  Totalfail = Totalfail + fail_unless( strcmp( m.species(3).id, 'S2'             ));
  Totalfail = Totalfail + fail_unless( strcmp( m.species(3).compartment, 'c' ));
  Totalfail = Totalfail + fail_unless( m.species(3).isSetInitialAmount == 1);
  Totalfail = Totalfail + fail_unless( m.species(3).isSetInitialConcentration == 0);
  Totalfail = Totalfail + fail_unless( m.species(3).isSetfbc_charge == 0);
  Totalfail = Totalfail + fail_unless( ~isempty( m.species(2).fbc_chemicalFormula));

  Totalfail = Totalfail + fail_unless( m.species(3).level == 3);
  Totalfail = Totalfail + fail_unless( m.species(3).version == 1);
  Totalfail = Totalfail + fail_unless( m.species(3).fbc_version == 1);
  
%     <fbc:listOfFluxBounds>
%       <fbc:fluxBound id="s" reaction="J0" operation="equal" value="10"/>
%       <fbc:fluxBound fbc:reaction="J0" />
%     </fbc:listOfFluxBounds>
% 
  Totalfail = Totalfail + fail_unless( length(m.fbc_fluxBound) == 2);

  Totalfail = Totalfail + fail_unless( strcmp(m.fbc_fluxBound(1).typecode, 'SBML_FBC_FLUXBOUND'));
  Totalfail = Totalfail + fail_unless( strcmp(m.fbc_fluxBound(1).fbc_id, 's'));
  Totalfail = Totalfail + fail_unless( strcmp(m.fbc_fluxBound(1).fbc_reaction, 'J0'));
  Totalfail = Totalfail + fail_unless( strcmp(m.fbc_fluxBound(1).fbc_operation, 'equal'));
  Totalfail = Totalfail + fail_unless( m.fbc_fluxBound(1).fbc_value == 10);
  Totalfail = Totalfail + fail_unless( m.fbc_fluxBound(1).isSetfbc_value == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.fbc_fluxBound(2).typecode, 'SBML_FBC_FLUXBOUND'));
  Totalfail = Totalfail + fail_unless( strcmp(m.fbc_fluxBound(2).fbc_id, ''));
  Totalfail = Totalfail + fail_unless( strcmp(m.fbc_fluxBound(2).fbc_reaction, 'J0'));
  Totalfail = Totalfail + fail_unless( strcmp(m.fbc_fluxBound(2).fbc_operation, 'lessEqual'));
  Totalfail = Totalfail + fail_unless( m.fbc_fluxBound(2).isSetfbc_value == 1);


%     <fbc:listOfObjectives activeObjective="obj1">
%       <fbc:objective id="c" type="maximize">
%         <fbc:listOfFluxes>
%           <fbc:fluxObjective reaction="J8" coefficient="1"/>
%           <fbc:fluxObjective fbc:reaction="J8"/>
%         </fbc:listOfFluxes>
%       </fbc:objective>
%     </fbc:listOfObjectives>

  Totalfail = Totalfail + fail_unless( length(m.fbc_objective) == 1);

  Totalfail = Totalfail + fail_unless( strcmp(m.fbc_objective(1).typecode, 'SBML_FBC_OBJECTIVE'));
  Totalfail = Totalfail + fail_unless( strcmp(m.fbc_objective(1).fbc_id, 'c'));
  Totalfail = Totalfail + fail_unless( strcmp(m.fbc_objective(1).fbc_type, 'maximize'));

  Totalfail = Totalfail + fail_unless( length(m.fbc_objective(1).fbc_fluxObjective) == 2);
  
  Totalfail = Totalfail + fail_unless( strcmp(m.fbc_objective(1).fbc_fluxObjective(1).typecode, 'SBML_FBC_FLUXOBJECTIVE'));
  Totalfail = Totalfail + fail_unless( strcmp(m.fbc_objective(1).fbc_fluxObjective(1).fbc_reaction, 'J8'));
  Totalfail = Totalfail + fail_unless( m.fbc_objective(1).fbc_fluxObjective(1).fbc_coefficient == 1);
  Totalfail = Totalfail + fail_unless( m.fbc_objective(1).fbc_fluxObjective(1).isSetfbc_coefficient == 1);
  
  Totalfail = Totalfail + fail_unless( strcmp(m.fbc_objective(1).fbc_fluxObjective(2).typecode, 'SBML_FBC_FLUXOBJECTIVE'));
  Totalfail = Totalfail + fail_unless( strcmp(m.fbc_objective(1).fbc_fluxObjective(2).fbc_reaction, 'J8'));
  Totalfail = Totalfail + fail_unless( m.fbc_objective(1).fbc_fluxObjective(2).isSetfbc_coefficient == 1);
  
  Totalfail = Totalfail + fail_unless( strcmp(m.fbc_activeObjective, 'obj1'));
  

if (silent == 0)
disp('Testing readFromFileFbc1:');
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
    
