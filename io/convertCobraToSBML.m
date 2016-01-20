function sbmlModel = convertCobraToSBML(model,sbmlLevel,sbmlVersion,compSymbolList,compNameList,debug_function)
%convertCobraToSBML converts a cobra structure to an sbml
%structure using the structures provided in the SBML toolbox 3.1.0
%
% sbmlModel = convertCobraToSBML(model,sbmlLevel,sbmlVersion,compSymbolList,compNameList)
%
%INPUTS
% model             COBRA model structure
%
%OPTIONAL INPUTS
% sbmlLevel         SBML Level (default = 2)
% sbmlVersion       SBML Version (default = 1)
% compSymbolList    List of compartment symbols
% compNameList      List of copmartment names correspoding to compSymbolList
%
%OUTPUT
% sbmlModel         SBML MATLAB structure
%
%

%NOTE: The name mangling of reaction and metabolite ids is necessary
%for compliance with the SBML sID standard.
%
%NOTE: Sometimes the Model_create function doesn't listen to the
%sbmlVersion parameter, so it is essential that the items that
%are added to the sbmlModel are defined with the sbmlModel's level
%and version:  sbmlModel.SBML_level,sbmlModel.SBML_version
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
%POTENTIAL FUTURE BUG: To speed things up, sbml structs have been
%recycled and are directly appended into lists instead of using _addItem
if (~exist('sbmlLevel','var') || isempty(sbmlLevel))
    sbmlLevel = 2;
end
if (~exist('sbmlVersion','var') || isempty(sbmlVersion))
    sbmlVersion = 1;
end
if (~exist('debug_function','var') || isempty(debug_function))
  debug_function = 0;
end
reaction_units = 'mmol_per_gDW_per_hr';
sbmlModel = Model_create(sbmlLevel, sbmlVersion);

sbmlModel.namespaces = struct();
sbmlModel.namespaces.prefix = '';
sbmlModel.namespaces.uri = 'http://www.sbml.org/sbml/level2';
if isfield(model,'description')
    sbmlModel.id = strrep(strrep(strrep(model.description,'.','_'), filesep, '_'), ':','_');
else
    sbmlModel.id = '';
end
%POTENTIAL FUTURE BUG: Create temporary structs to speed things up.
tmp_unit = Unit_create(sbmlModel.SBML_level, sbmlModel.SBML_version);
tmp_species = Species_create(sbmlModel.SBML_level, sbmlModel.SBML_version);
sbml_tmp_compartment = Compartment_create(sbmlModel.SBML_level, sbmlModel.SBML_version);
sbml_tmp_parameter = Parameter_create(sbmlModel.SBML_level, sbmlModel.SBML_version);
sbml_tmp_species_ref = SpeciesReference_create(sbmlModel.SBML_level, sbmlModel.SBML_version);
sbml_tmp_reaction = Reaction_create(sbmlModel.SBML_level, sbmlModel.SBML_version);
sbml_tmp_law = KineticLaw_create(sbmlModel.SBML_level, sbmlModel.SBML_version);
tmp_unit_definition = UnitDefinition_create(sbmlModel.SBML_level, sbmlModel.SBML_version);

%% Compartments
if ~exist('compSymbolList','var') || isempty(compSymbolList)
    compSymbolList = {'c','m','v','x','e','t','g','r','n','p','l'};
    compNameList = {'Cytoplasm','Mitochondrion','Vacuole','Peroxisome','Extracellular','Pool','Golgi','Endoplasmic_reticulum','Nucleus','Periplasm','Lysosome'};
end

%Create and add the unit definition to the sbml model struct.
tmp_unit_definition.id =  reaction_units;
%The 4 following lists are in matched order for each unit.
unit_kinds = {'mole','gram','second'};
unit_exponents = [1 -1 -1];
unit_scales = [-3 0 0];
unit_multipliers = [1 1 1.0/60/60];
%Add the units to the unit definition
for i = 1:size(unit_kinds, 2)
    tmp_unit.kind = unit_kinds{ i };
    tmp_unit.exponent = unit_exponents(i);
    tmp_unit.scale = unit_scales(i);
    tmp_unit.multiplier = unit_multipliers(i);
    tmp_unit_definition = UnitDefinition_addUnit(tmp_unit_definition, tmp_unit);
end
if debug_function
  if ~isSBML_Unit(tmp_unit_definition)
    error('unit definition failed')
  end
end
sbmlModel = Model_addUnitDefinition(sbmlModel, tmp_unit_definition);


%List to hold the compartment ids.
the_compartments = {};
%separate metabolite and compartment
[tokens tmp_met_struct] = regexp(model.mets,'(?<met>.+)\[(?<comp>.+)\]|(?<met>.+)\((?<comp>.+)\)','tokens','names');
for (i=1:size(model.mets, 1))
    tmp_notes='';
    tmp_met = tmp_met_struct{i}.met;
    %Change id to correspond to SBML id specifications
    tmp_met = strcat('M_', (tmp_met), '_', tmp_met_struct{i}.comp);
    model.mets{ i } = formatForSBMLID(tmp_met);
    tmp_species.id = formatForSBMLID(tmp_met);
    tmp_species.compartment = formatForSBMLID(tmp_met_struct{i}.comp);
    if isfield(model, 'metNames')
        tmp_species.name = (model.metNames{i});
    end
    if isfield(model, 'metFormulas')
        tmp_notes = [tmp_notes '<p>FORMULA: ' model.metFormulas{i} '</p>'];
    end
    if isfield(model, 'metCharge')
        %NOTE: charge is being removed in SBML level 3
%         tmp_species.charge = model.metCharge(i);
%         tmp_species.isSetCharge = 1;
        tmp_notes = [tmp_notes '<p>CHARGE: ' num2str(model.metCharge(i)) '</p>'];
    end


    if ~isempty(tmp_notes)
        tmp_species.notes = ['<body xmlns="http://www.w3.org/1999/xhtml">' tmp_notes '</body>'];
    end
    sbmlModel.species = [ sbmlModel.species tmp_species ];
    %This is where the compartment symbols are aggregated.
    the_compartments{ i } = tmp_species.compartment ;
end
if debug_function
  for (i = 1:size(sbmlModel.species, 2))
    if ~isSBML_Species(sbmlModel.species(i), sbmlLevel, sbmlVersion)
      error('SBML species failed to pass test')
    end
  end
end
%Add the unique compartments to the model struct.
the_compartments = unique(the_compartments);
for (i=1:size(the_compartments,2))
    tmp_id = the_compartments{1,i};
    tmp_symbol_index = find(strcmp(formatForSBMLID(compSymbolList),tmp_id));
    %Check that symbol is in compSymbolList
    if ~isempty(tmp_symbol_index)
        tmp_name = compNameList{tmp_symbol_index};
    else
        error(['Unknown compartment: ' tmp_id '. Be sure that ' tmp_id ' is specified in compSymbolList and compNameList.'])
    end
    tmp_id = formatForSBMLID(tmp_id);
    sbml_tmp_compartment.id = tmp_id;
    sbml_tmp_compartment.name = tmp_name;
    sbmlModel = Model_addCompartment(sbmlModel, sbml_tmp_compartment);
end
if debug_function
  for (i = 1:size(sbmlModel.compartment, 2))
    if ~isSBML_Compartment(sbmlModel.compartment(i), sbmlLevel, sbmlVersion)
      error('SBML compartment failed to pass test')
    end
  end
end
%Add the reactions to the model struct.  Use the species references.
sbml_tmp_parameter.units = reaction_units;
sbml_tmp_parameter.isSetValue = 1;
for (i=1:size(model.rxns, 1))
    tmp_id =  strcat('R_', formatForSBMLID(model.rxns{i}));
    model.rxns{i} = tmp_id;
    met_idx = find(model.S(:, i));
    sbml_tmp_reaction.notes = '';
    %Reset the fields that have been filled.
    sbml_tmp_reaction.reactant = [];
    sbml_tmp_reaction.product = [];
    sbml_tmp_reaction.kineticLaw = [];
    sbml_tmp_reaction.id = tmp_id;
    if isfield(model, 'rxnNames')
        sbml_tmp_reaction.name = model.rxnNames{i};
    end
    if isfield(model, 'rev')
        sbml_tmp_reaction.reversible = model.rev(i);
    end
    sbml_tmp_law.parameter = [];
    sbml_tmp_law.formula = 'FLUX_VALUE';
    sbml_tmp_parameter.id = 'LOWER_BOUND';
    sbml_tmp_parameter.value = model.lb(i);
    sbml_tmp_law.parameter = [ sbml_tmp_law.parameter sbml_tmp_parameter ];
    sbml_tmp_parameter.id = 'UPPER_BOUND';
    sbml_tmp_parameter.value = model.ub(i);
    sbml_tmp_law.parameter = [ sbml_tmp_law.parameter sbml_tmp_parameter ];
    sbml_tmp_parameter.id = 'FLUX_VALUE';
    sbml_tmp_parameter.value = 0;
    sbml_tmp_law.parameter = [ sbml_tmp_law.parameter sbml_tmp_parameter ];
    sbml_tmp_parameter.id = 'OBJECTIVE_COEFFICIENT';
    sbml_tmp_parameter.value = model.c(i);
    sbml_tmp_law.parameter = [ sbml_tmp_law.parameter sbml_tmp_parameter ];
    sbml_tmp_reaction.kineticLaw = sbml_tmp_law;
    %Add in other notes
    tmp_note = '';
    if isfield(model, 'grRules')
        tmp_note = [tmp_note '<p>GENE_ASSOCIATION: ' model.grRules{i} '</p>' ];
    end
    if isfield(model, 'subSystems')
        tmp_note = [ tmp_note ' <p>SUBSYSTEM: ' model.subSystems{i} '</p>'];
    end
    if isfield(model, 'rxnECNumbers')
        tmp_note = [ tmp_note ' <p>EC Number: ' model.rxnECNumbers{i} '</p>'];
    end
    if isfield(model, 'confidenceScores')
        tmp_note = [ tmp_note ' <p>Confidence Level: ' model.confidenceScores{i} '</p>'];
    end
    if isfield(model, 'rxnReferences')
        tmp_note = [ tmp_note ' <p>AUTHORS: ' model.rxnReferences{i} '</p>'];
    end
    if isfield(model, 'rxnNotes')
        tmp_note = [ tmp_note ' <p>' model.rxnNotes{i} '</p>'];
    end
    if ~isempty(tmp_note)
        sbml_tmp_reaction.notes = ['<body xmlns="http://www.w3.org/1999/xhtml">' tmp_note '</body>'];
    end
    %Add in the reactants and products
    for (j_met=1:size(met_idx,1))
        tmp_idx = met_idx(j_met,1);
        sbml_tmp_species_ref.species = model.mets{tmp_idx};
        met_stoich = model.S(tmp_idx, i);
        sbml_tmp_species_ref.stoichiometry = abs(met_stoich);
        if (met_stoich > 0)
            sbml_tmp_reaction.product = [ sbml_tmp_reaction.product sbml_tmp_species_ref ];
        else
            sbml_tmp_reaction.reactant = [ sbml_tmp_reaction.reactant sbml_tmp_species_ref];
        end
    end
    sbmlModel.reaction = [ sbmlModel.reaction sbml_tmp_reaction ];
end
if debug_function
  for (i = 1:size(sbmlModel.reaction, 2))
    if ~isSBML_Reaction(sbmlModel.reaction(i), sbmlLevel, sbmlVersion)
      error('SBML reaction failed to pass test')
    end
  end
end
%% Format For SBML
function str = formatForSBMLID(str)
str = strrep(str,'-','_DASH_');
str = strrep(str,'/','_FSLASH_');
str = strrep(str,'\','_BSLASH_');
str = strrep(str,'(','_LPAREN_');
str = strrep(str,')','_RPAREN_');
str = strrep(str,'[','_LSQBKT_');
str = strrep(str,']','_RSQBKT_');
str = strrep(str,',','_COMMA_');
str = strrep(str,'.','_PERIOD_');
str = strrep(str,'''','_APOS_');
str = regexprep(str,'\(e\)$','_e');
str = strrep(str,'&','&amp;');
str = strrep(str,'<','&lt;');
str = strrep(str,'>','&gt;');
str = strrep(str,'"','&quot;');