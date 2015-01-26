function sbml_model = cobra_struct_to_sbml_struct( model, sbml_level,sbml_version )
%  cobra_struct_to_sbml_struct converts a cobra structure to an sbml
%  structure using the structures provided in the SBML toolbox 3.0.0
%
% sbmlModel = convertCobraToSBML(cobraModel,noInitDigitFlag)
%
%NOTE: The name mangling of reaction and metabolite ids is necessary
%for compliance with the SBML sID standard.
%
%NOTE: Sometimes the Model_create function doesn't listen to the
%sbml_version parameter, so it is essential that the items that
%are added to the sbml_model are defined with the sbml_model's level 
%and version:  sbml_model.SBML_level,sbml_model.SBML_version
%
%NOTE:  Some of the structures are recycled to reduce to overhead for
%their creation.  There's a chance this can cause bugs in the future.
%
%NOTE: Currently, I don't add in the boundary metabolites.
%
%NOTE: Speed could probably be improved by directly adding structures to
%lists in a struct instead of using the SBML _addItem function, but this
%could break in future versions of the SBML toolbox. 
%
%POTENTIAL BUG: Assumes that the compartment abbreviation is 1 character.
%
%POTENTIAL FUTURE BUG: To speed things up, sbml structs have been
%recycled and are directly appended into lists instead of using _addItem
 
  %A flag to know if the user is using the older version of the sbml toolbox.
  sbml_toolbox_v3 = true;
  if (size(strfind( help('Model_create'), 'sbmlVersion' ),1)==0)
    sbml_toolbox_v3 = false;
    sbml_level = 2;
  end
%  load 'model.mat'; %Just for initial function development and debugging.
%  a_tic = tic;
  if (~exist('sbml_level','var') )
    sbml_level = 2;
  end
  if (~exist('sbml_version','var') )
    sbml_version = 1;
  end
  reaction_units = 'mmol_per_gDW_per_hr';
  if sbml_toolbox_v3 
    sbml_model = Model_create( sbml_level, sbml_version );
  else
    sbml_model = Model_create( sbml_level );
  end
  sbml_model.namespaces = struct();
  sbml_model.namespaces.prefix = '';
  sbml_model.namespaces.uri = 'http://www.sbml.org/sbml/level2';
  sbml_model.id = strrep( strrep( strrep(model.description,'.','_'), filesep, '_' ), ':','_' );
  %POTENTIAL FUTURE BUG: Create temporary structs to speed things up.

  if sbml_toolbox_v3
    tmp_unit = Unit_create(  sbml_model.SBML_level, sbml_model.SBML_version );
    tmp_species = Species_create( sbml_model.SBML_level, sbml_model.SBML_version );
    sbml_tmp_compartment = Compartment_create( sbml_model.SBML_level, sbml_model.SBML_version );
    sbml_tmp_parameter = Parameter_create( sbml_model.SBML_level, sbml_model.SBML_version );
    sbml_tmp_species_ref = SpeciesReference_create( sbml_model.SBML_level, sbml_model.SBML_version );
    sbml_tmp_reaction = Reaction_create( sbml_model.SBML_level, sbml_model.SBML_version );
    sbml_tmp_law = KineticLaw_create( sbml_model.SBML_level, sbml_model.SBML_version );
    tmp_unit_definition = UnitDefinition_create( sbml_model.SBML_level, sbml_model.SBML_version );
  else
    tmp_unit = Unit_create(  sbml_model.SBML_level);
    tmp_species = Species_create( sbml_model.SBML_level);
    sbml_tmp_compartment = Compartment_create( sbml_model.SBML_level);
    sbml_tmp_parameter = Parameter_create( sbml_model.SBML_level);
    sbml_tmp_species_ref = SpeciesReference_create( sbml_model.SBML_level);
    sbml_tmp_reaction = Reaction_create( sbml_model.SBML_level);
    sbml_tmp_law = KineticLaw_create( sbml_model.SBML_level);
    tmp_unit_definition = UnitDefinition_create( sbml_model.SBML_level);
  end
  
  compartment_symbols = {'c','m','v','x','e','t','g','r','n','p','l','y'};
  compartment_names = {'Cytoplasm','Mitochondrion','Vacuole','Peroxisome','Extracellular','Pool','Golgi','Endoplasmic_reticulum','Nucleus','Periplasm','Lysosome','Glycosome'};
  
  %Create and add the unit definition to the sbml model struct.
  tmp_unit_definition.id =  reaction_units;
  %The 4 following lists are in matched order for each unit.
  unit_kinds = {'mole','gram','second'};
  unit_exponents = [1 -1 -1];
  unit_scales = [-3 0 0];
  unit_multipliers = [1 1 1.0/60/60];
  %Add the units to the unit definition
  for i = 1:size( unit_kinds, 2 )
    tmp_unit.kind = unit_kinds{ i };
    tmp_unit.exponent = unit_exponents( i );
    tmp_unit.scale = unit_scales( i );
    tmp_unit.multiplier = unit_multipliers( i );
    tmp_unit_definition = UnitDefinition_addUnit( tmp_unit_definition, tmp_unit );
  end
  sbml_model = Model_addUnitDefinition( sbml_model, tmp_unit_definition );
  
 
  %List to hold the compartment ids.
  the_compartments = {};
  for ( i=1:size( model.mets, 1 ) )
    tmp_met = model.mets{i};
    %Change id to correspond to SBML id specifications
    if ( tmp_met( size( tmp_met, 2 ) ) == ']' );
      tmp_compartment = tmp_met( size( tmp_met, 2 ) - 1 );
      tmp_met = strrep( tmp_met, strcat( '[', tmp_compartment, ']' ),  strcat( '_', tmp_compartment ) );
    end
    tmp_met = strcat( 'M_', strrep(tmp_met, '-', '_' ) );
    model.mets{ i } = tmp_met;
    tmp_species.id = tmp_met;
    tmp_species.compartment = tmp_met( size( tmp_met, 2 ) );
    if isfield( model, 'metNames' )
      tmp_species.name = model.metNames{i}; 
    end
    if isfield( model, 'metFormulas' )
      tmp_species.notes = ['<html xmlns="http://www.w3.org/1999/xhtml"><p>FORMULA: ' model.metFormulas{i} '</p></html>'];
    end
    if isfield( model, 'charges' )
      %NOTE: charge is being removed in SBML level 3
      tmp_species.charge = model.charges(i);
    end
    sbml_model.species = [ sbml_model.species tmp_species ];
    %This is where the compartment symbols are aggregated.
    the_compartments{ i } = tmp_species.compartment ;
  end

  %Add the unique compartments to the model struct.
  the_compartments = unique( the_compartments );
  for (i=1:size(the_compartments,2))
    tmp_id = the_compartments{1,i};
    tmp_name = compartment_names{ find( strcmp( compartment_symbols, tmp_id ) ) };
    sbml_tmp_compartment.id = tmp_id;
    sbml_tmp_compartment.name = tmp_name;
    sbml_model = Model_addCompartment( sbml_model, sbml_tmp_compartment );
  end
    
  %Add the reactions to the model struct.  Use the species references.
  sbml_tmp_parameter.units = reaction_units;
  sbml_tmp_parameter.isSetValue = 1;
  for (i=1:size( model.rxns, 1 ) )
    tmp_id =  strcat( 'R_', strrep( strrep(model.rxns{i}, '-', '_' ), '(e)', '_e' ) );
    model.rxns{i} = tmp_id;
    met_idx = find( model.S(:, i ) );
    sbml_tmp_reaction.notes = '';
    %Reset the fields that have been filled.
    sbml_tmp_reaction.reactant = [];
    sbml_tmp_reaction.product = [];
    sbml_tmp_reaction.kineticLaw = [];
    sbml_tmp_reaction.id = tmp_id;
    if isfield( model, 'rxnNames' )
      sbml_tmp_reaction.name = model.rxnNames{i};
    end
    if isfield( model, 'rev' )
      sbml_tmp_reaction.reversible = model.rev(i);
    end
    sbml_tmp_law.parameter = [];
    sbml_tmp_law.formula = 'FLUX_VALUE';
    sbml_tmp_parameter.id = 'LOWER_BOUND';
    sbml_tmp_parameter.value = model.lb( i );
    sbml_tmp_law.parameter = [ sbml_tmp_law.parameter sbml_tmp_parameter ];
    sbml_tmp_parameter.id = 'UPPER_BOUND';
    sbml_tmp_parameter.value = model.ub( i );
    sbml_tmp_law.parameter = [ sbml_tmp_law.parameter sbml_tmp_parameter ];
    sbml_tmp_parameter.id = 'FLUX_VALUE';
    sbml_tmp_parameter.value = 0;
    sbml_tmp_law.parameter = [ sbml_tmp_law.parameter sbml_tmp_parameter ];
    sbml_tmp_parameter.id = 'OBJECTIVE_COEFFICIENT';
    sbml_tmp_parameter.value = model.c( i );
    sbml_tmp_law.parameter = [ sbml_tmp_law.parameter sbml_tmp_parameter ];
    sbml_tmp_reaction.kineticLaw = sbml_tmp_law;
    %Add in other notes
    if ( isfield( model, 'grRules' ) ||  isfield( model, 'subSystems' ) )
      tmp_note = '<html xmlns="http://www.w3.org/1999/xhtml">';
      if isfield( model, 'grRules' )
        tmp_note = [tmp_note '<p>GENE_ASSOCIATION: ' model.grRules{i} '</p>' ];
      end
      if isfield( model, 'subSystems' ) 
        tmp_note = [ tmp_note ' <p>SUBSYSTEM: ' model.subSystems{i} '</p>'];
      end
      tmp_note = [tmp_note '</html>'];
      sbml_tmp_reaction.notes = tmp_note;
    end
    %Add in the reactants and products
    for (j_met=1:size(met_idx,1)    )
      tmp_idx = met_idx(j_met,1);
      sbml_tmp_species_ref.species = model.mets{tmp_idx};
      met_stoich = model.S( tmp_idx, i );
      sbml_tmp_species_ref.stoichiometry = abs( met_stoich );
      if ( met_stoich > 0 )
        sbml_tmp_reaction.product = [ sbml_tmp_reaction.product sbml_tmp_species_ref ];
      else
        sbml_tmp_reaction.reactant = [ sbml_tmp_reaction.reactant sbml_tmp_species_ref];
      end
    end
    sbml_model.reaction = [ sbml_model.reaction sbml_tmp_reaction ];
  end


%toc(a_tic)
%  save -MAT 'sbml.mat' sbml_model; %just for development purposes.





