function sbmlModel = writeSBML(model,fileName,compSymbolList,compNameList)

% writeSBML exports a COBRA structure into an SBML FBCv2 file.
%
%
%INPUTS
% model             COBRA model structure
% fileName          File name for output file
%
%OPTIONAL INPUTS
% compSymbolList    List of compartment symbols
% compNameList      List of copmartment names corresponding to compSymbolList
%
%OUTPUT
% sbmlModel         SBML MATLAB structure
% a SBMLFBCv2 file  a file is written to the current Matlab path
%
% Longfei Mao 24/09/15
%

%% Compartments
if nargin<3 || ~exist('compSymbolList','var') || isempty(compSymbolList)
    compSymbolList = {'c','m','v','x','e','t','g','r','n','p','l'};
    compNameList = {'Cytoplasm','Mitochondrion','Vacuole','Peroxisome','Extracellular','Pool','Golgi','Endoplasmic_reticulum','Nucleus','Periplasm','Lysosome'};
end

if nargin<2
    fileName='output';
end
% % debug_function=0; % implement SBML toolbox's debug function
% five types of funcitons for initilising the variables

initFunList={'struct()';
    'cell(1,1)';
    'zeros(1,1)';
    'sparse(1,0)';
    'cell(1,0)';
    '{}'};

emptyChar='';

% set default SBML & FBC package versions
defaultLevel=3;
defaultVersion=1;
defaultFbcVersion=2;
defaultSboTerm=-1; % empty sboTerm
defaultIsSetValue=1;

% initialise the structures
% % %% sbmlModel.parameter
% % sbmlModel.parameter=struct('typecode','SBML_PARAMETER',...
% %     'metaid',eval(initFunList{5}),...
% %     'notes',eval(initFunList{5}),...
% %     'annotation',eval(initFunList{5}),...
% %     'sboTerm',defaultSboTerm,...
% %     'name',eval(initFunList{5}),...
% %     'id',eval(initFunList{5}),...
% %     'value',eval(initFunList{5}),...
% %     'units',eval(initFunList{5}),...
% %     'constant',eval(initFunList{5}),...
% %     'isSetValue',eval(initFunList{5}),...
% %     'level',defaultLevel,...
% %     'version',defaultVersion);

%% sbmlModel.constraint
sbmlModel.constraint=struct('typecode',eval(initFunList{5}),...
    'metaid',eval(initFunList{5}),...
    'notes',eval(initFunList{5}),...
    'annotation',eval(initFunList{5}),...
    'sboTerm',defaultSboTerm,...
    'math',eval(initFunList{5}),...
    'message',eval(initFunList{5}),...
    'level',defaultLevel,...
    'version',defaultVersion);

%% sbmlModel.functionDefinition
sbmlModel.functionDefinition=struct('typecode',eval(initFunList{5}),...
    'metaid',eval(initFunList{5}),...
    'notes',eval(initFunList{5}),...
    'annotation',eval(initFunList{5}),...
    'sboTerm',defaultSboTerm,...
    'name',eval(initFunList{5}),...
    'id',eval(initFunList{5}),...
    'math',eval(initFunList{5}),...
    'level',defaultLevel,...
    'version',defaultVersion);

%% sbmlModel.event
sbmlModel.event=struct('typecode',eval(initFunList{5}),...
    'metaid',eval(initFunList{5}),...
    'notes',eval(initFunList{5}),...
    'annotation',eval(initFunList{5}),...
    'sboTerm',defaultSboTerm,...
    'name',eval(initFunList{5}),...
    'id',eval(initFunList{5}),...
    'useValuesFromTriggerTime',eval(initFunList{5}),...
    'trigger',eval(initFunList{5}),...
    'delay',eval(initFunList{5}),...
    'priority',eval(initFunList{5}),...
    'eventAssignment',eval(initFunList{5}),...
    'level',defaultLevel,...
    'version',defaultVersion);

%% sbmlModel.rule
sbmlModel.rule=struct('typecode',eval(initFunList{5}),...
    'metaid',eval(initFunList{5}),...
    'notes',eval(initFunList{5}),...
    'annotation',eval(initFunList{5}),...
    'sboTerm',defaultSboTerm,...
    'formula',eval(initFunList{5}),...
    'variable',eval(initFunList{5}),...
    'species',eval(initFunList{5}),...
    'compartment',eval(initFunList{5}),...
    'name',eval(initFunList{5}),...
    'units',eval(initFunList{5}),...
    'level',defaultLevel,...
    'version',defaultVersion);

%% sbmlModel.unitDefinition
tmp_unitDefinition=struct('typecode','SBML_UNIT_DEFINITION',...
    'metaid',emptyChar,...
    'notes',emptyChar,...
    'annotation',emptyChar,...
    'sboTerm',defaultSboTerm,...
    'name',emptyChar,...
    'id',emptyChar,...
    'unit',emptyChar,...
    'level',defaultLevel,...
    'version',defaultVersion);

tmp_unitDefinition.unit =struct('typecode','SBML_UNIT',...
    'metaid',emptyChar,...
    'notes',emptyChar,...
    'annotation',emptyChar,...
    'sboTerm',defaultSboTerm,...
    'kind',emptyChar,...
    'exponent',emptyChar,...
    'scale',emptyChar,...
    'multiplier',emptyChar,...
    'level',defaultLevel,...
    'version',defaultVersion);
%
reaction_units = 'mmol_per_gDW_per_hr';

% Create and add the unit definition to the sbml model struct.

tmp_unitDefinition.id =  reaction_units;

% The 4 following lists are in the right order for each unit.

unit_kinds = {'mole','gram','second'};
unit_exponents = [1 -1 -1];
unit_scales = [-3 0 0];
unit_multipliers = [1 1 1*60*60];

% Add the units to the unit definition

sbmlModel.unitDefinition=tmp_unitDefinition;

for i = 1:size(unit_kinds, 2)
    tmp_unitDefinition.unit.kind = unit_kinds{ i };
    tmp_unitDefinition.unit.exponent = unit_exponents(i);
    tmp_unitDefinition.unit.scale = unit_scales(i);
    tmp_unitDefinition.unit.multiplier = unit_multipliers(i);
    %      tmp_unit_definition = UnitDefinition_addUnit(tmp_unit_definition, tmp_unit);
    if i==1
        sbmlModel.unitDefinition.unit=tmp_unitDefinition.unit;
    else
        sbmlModel.unitDefinition.unit=[sbmlModel.unitDefinition.unit,tmp_unitDefinition.unit];
    end
end

%% error missing
% Errors reported: Invalid FBC Model
% Invalid Model structure
% missing typecode field
% % if debug_function %% call the SBML toolbox functions to validate the built model structure.
% %     if ~isSBML_Unit(tmp_unit_definition)
% %         error('unit definition failed')
% %     end
% % end

%% sbmlModel.initialAssignment

sbmlModel.initialAssignment=struct('typecode',eval(initFunList{5}),...
    'metaid',eval(initFunList{5}),...
    'notes',eval(initFunList{5}),...
    'annotation',eval(initFunList{5}),...
    'sboTerm',defaultSboTerm,...
    'symbol',eval(initFunList{5}),...
    'math',eval(initFunList{5}),...
    'level',defaultLevel,...
    'version',defaultVersion);

%% Other fields

list={'SBML_level';
    'SBML_version';
    'annotation';
    'areaUnits';
    'avogadro_symbol';
    'conversionFactor';
    'delay_symbol';
    'extentUnits';
    'fbc_activeObjective';
    'fbc_version';
    'id';
    'lengthUnits';
    'metaid';
    'name';
    'notes';
    'sboTerm';
    'substanceUnits';
    'timeUnits';
    'time_symbol';
    'typecode';
    'volumeUnits'};

for i=1:length(list)
    if strfind(list{i},'SBML_level')
        sbmlModel.(list{i})=defaultLevel;
    elseif strfind(list{i},'SBML_version')
        sbmlModel.(list{i})=defaultVersion;
    elseif strfind(list{i},'fbc_version')
        sbmlModel.(list{i})= defaultFbcVersion;
    elseif strfind(list{i},'typecode')
        sbmlModel.(list{i})='SBML_MODEL';
    elseif strfind(list{i},'fbc_activeObjective')
        sbmlModel.(list{i})='obj'; % a default fbc_activeObjective field is assigned.
    elseif strfind(list{i},'id')
        if isfield(model,'id')
            sbmlModel.(list{i})=model.id;
        else
            sbmlModel.(list{i})='emptyModelID';
        end
    elseif strfind(list{i},'metaid')
        if isfield(model,'description')
            sbmlModel.(list{i})=model.description;
        else
            sbmlModel.(list{i})='emptyModelMetaid';
        end
        
    elseif strfind(list{i},'sboTerm')
        sbmlModel.(list{i})=defaultSboTerm; % a default fbc_activeObjective field is assigned.
    else
        sbmlModel.(list{i})=emptyChar; %eval(initFunList{2});
    end
    
end

%% Species

% Construct a list of compartment names
% List to hold the compartment ids.
tmp_metCompartment = {};
% separate metabolite and compartment to obtain a list of compartments
[tokens tmp_met_struct] = regexp(model.mets,'(?<met>.+)\[(?<comp>.+)\]|(?<met>.+)\((?<comp>.+)\)','tokens','names'); % add the third type for parsing the string such as "M_10fthf5glu_c"
% |(?<met>.+)\_(?<comp>.+)

tmp_species=struct('typecode','SBML_SPECIES',...
    'metaid',emptyChar,...
    'notes',emptyChar,...
    'annotation',emptyChar,...
    'sboTerm',defaultSboTerm,...
    'name',emptyChar,...
    'id',emptyChar,...  %%
    'compartment',emptyChar,... %%
    'initialAmount',1,...  % (Modeling Practice Guideline #80601) As a principle of best modeling practice, the <species> should set an initial value (amount or concentration) rather than be left undefined.
    'initialConcentration',emptyChar,...
    'substanceUnits',emptyChar,...
    'hasOnlySubstanceUnits',0,...
    'boundaryCondition',0,...
    'constant',0,...
    'conversionFactor',emptyChar,...
    'isSetInitialAmount',1,...
    'isSetInitialConcentration',emptyChar,...
    'fbc_charge',emptyChar,...             %%
    'fbc_chemicalFormula',emptyChar,...  %%
    'isSetfbc_charge',emptyChar,...  %%
    'level',defaultLevel,...    'version',1,...
    'version',defaultVersion,...
    'fbc_version',defaultFbcVersion);

sbmlModel.species=tmp_species;

%% Metabolites
for i=1:size(model.mets, 1)
    tmp_notes='';
    if  ~isempty(tmp_met_struct{1})          % if the metbaolite names don't contain any compartament abbreviations.
        tmp_met = tmp_met_struct{i}.met;
    else
        tmp_met = model.mets{i};
    end
    
    if isempty(tmp_met_struct{1})
        %Change id to correspond to SBML id specifications
        tmp_met = strcat('M_', (tmp_met), '_', '[c]');
    else
        tmp_met = strcat('M_', (tmp_met), '_', tmp_met_struct{i}.comp);
    end
    
    tmp_met= formatForSBMLID(tmp_met);
    %     model.mets{ i } = formatForSBMLID(tmp_met); % remove illegal symbols
    %     tmp_species.id = formatForSBMLID(tmp_met);  % remove illegal symbols
    if isfield(model, 'metNames')
        tmp_metName = (model.metNames{i});
    else
        tmp_metName=emptyChar;
    end
    
    % % %     if isfield(model, 'metFormulas')
    % % %
    % % %         if isempty(model.metFormulas)||numel(model.metFormulas)<i; % when the charges are not missing from the COBRA model structure.
    % % %             model.metFormulas(i)={num2str(0)};
    % % %         end
    % % %         tmp_notes = [tmp_notes '<p>FORMULA: ' model.metFormulas{i} '</p>'];
    % % %
    % % %     end
    if isfield(model, 'metFormulas')
        if isempty(model.metFormulas)||numel(model.metFormulas)<i; % when the charges are not missing from the COBRA model structure.
            model.metFormulas(i)={num2str(0)};
        end
        tmp_metFormulas = model.metFormulas{i};
    else
        tmp_metFormulas=emptyChar; %cell(0,1)% {''};%0;%emptyChar;
    end
    % % %     if isfield(model, 'metCharge')
    % % %         %NOTE: charge is being removed in SBML level 3
    % % % %         tmp_species.charge = model.metCharge(i);
    % % % %         tmp_species.isSetCharge = 1;
    % % %        if isempty(model.metCharge)||numel(model.metCharge)<i; % when the charges are not missing from the COBRA model structure.
    % % %            fprintf('metCharge doesn''t exist for metaboli %d \n', i);
    % % %            model.metCharge(i)=0;
    % % %        end
    % % %
    % % %         tmp_notes = [tmp_notes '<p>CHARGE: ' num2str(model.metCharge(i)) '</p>'];
    % % %     end
    
    %%
    % % %     if ~isfield(model,'metSboTerm') % if the sboTerms for the metabolites are not avaliable. %% NTOE: most of COBRA model structures don't have such fields
    % % %         model.sboTerm(i)=-1;
    % % %     end
    % % %     %%
    if isfield(model, 'metCharge')
        %NOTE: charge is being removed in SBML level 3
        %         tmp_species.charge = model.metCharge(i);
        %         tmp_species.isSetCharge = 1;
        if isempty(model.metCharge)||numel(model.metCharge)<i; % when the charges are not missing from the COBRA model structure.
            fprintf('metCharge doesn''t exist for metaboli %d \n', i);
            model.metCharge(i)=0;
        end
        tmp_metCharge=model.metCharge(i);
        tmp_isSetfbc_charge=1;
        %         tmp_notes = [tmp_notes '<p>CHARGE: ' num2str(model.metCharge(i)) '</p>'];
    else
        tmp_metCharge=0;
        tmp_isSetfbc_charge=0;
    end
    %% here notes can be formulated to include more annotations.
    % % %     if ~isempty(tmp_notes)
    % % %         tmp_species.notes = ['<body xmlns="http://www.w3.org/1999/xhtml">' tmp_notes '</body>'];
    tmp_species.id=formatForSBMLID(tmp_met);
    tmp_species.name=tmp_metName;
    try
        tmp_species.compartment=formatForSBMLID(tmp_met_struct{i}.comp);
        %% Clean up the species names
        tmp_metCompartment{ i } = formatForSBMLID(tmp_met_struct{i}.comp); % remove illegal symbols
    catch   % if no compartment symbol is found in the metabolite names
        tmp_species.compartment=formatForSBMLID('c');
        %% Clean up the species names
        tmp_metCompartment{ i } = 'c'; % remove illegal symbols
    end
    tmp_species.fbc_charge=tmp_metCharge;
    tmp_species.fbc_chemicalFormula=tmp_metFormulas;
    tmp_species.isSetfbc_charge=tmp_isSetfbc_charge;
    %% Add annotations for metaoblites to the reconstruction
    tmp_species.metaid=tmp_species.id;  % set the metaid for each species
    tmp_note = '<annotation xmlns:sbml="http://www.sbml.org/sbml/level3/version1/core">   <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">';
    tmp_note=[tmp_note,' <rdf:Description rdf:about="#',tmp_species.id,'">','<bqbiol:is>','<rdf:Bag>'];
    
    if isfield(model, 'metChEBIID')&&~isempty(model.metChEBIID{i})
        tmp_note = [tmp_note ' <rdf:li rdf:resource="http://identifiers.org/chebi/CHEBI:' model.metChEBIID{i} '"/>' ];
    end
    if isfield(model, 'metPubChemID')&&~isempty(model.metPubChemID{i})
        tmp_note = [ tmp_note ' <rdf:li rdf:resource="http://identifiers.org/pubchem.substance/' model.metPubChemID{i} '"/>'];
    end
    
    if isfield(model, 'metKEGGID')&&~isempty(model.metKEGGID{i})
        tmp_note = [ tmp_note ' <rdf:li rdf:resource="http://identifiers.org/kegg.compound/' model.metKEGGID{i} '"/>'];
    end
    
    if isfield(model, 'metHMDB')&&~isempty(model.metHMDB{i})
        tmp_note = [ tmp_note ' <rdf:li rdf:resource="http://identifiers.org/hmdb/' model.metHMDB{i} '"/>'];
    end
    
    if isfield(model, 'metInChIString')&&~isempty(model.metInChIString{i})
        tmp_note = [ tmp_note ' <rdf:li rdf:resource="http://identifiers.org/inchi/' model.metInChIString{i} '"/>'];
    end
    tmp_note = [ tmp_note, ' </rdf:Bag> </bqbiol:is> </rdf:Description> </rdf:RDF> </annotation>']; % ending syntax
    % %     if isfield(model, 'rxnReferences')
    % %         tmp_note = [ tmp_note ' <p>AUTHORS: ' model.rxnReferences{i} '</p>'];
    % %     end
    % %     if isfield(model, 'rxnNotes')
    % %         tmp_note = [ tmp_note ' <p>' model.rxnNotes{i} '</p>'];
    % %     end
    % %     if ~isempty(tmp_note)
    % %         tmp_note = ['<body xmlns="http://www.w3.org/1999/xhtml">' tmp_note '</body>'];
    % %     end
    tmp_species.annotation=tmp_note;
    
    if i==1
        sbmlModel.species=tmp_species;
    else
        sbmlModel.species=[sbmlModel.species, tmp_species];
    end
    
    % sbmlModel.species = [ sbmlModel.species, tmp_species ];
    %This is where the compartment symbols are aggregated.
    
end
% % for i=1:size(model.mets, 1) % The following code block converts COBRA formats of the speicies structure into FBC formats.
% %     if isfield(model,'fbc2str')||strcmp(fbc,'true');
% %         listSpeciesField={'fbc_charge';'fbc_chemicalFormula';'isSetfbc_charge';'fbc_version'};
% %         listSpeciesCobra={'metCharge';'metFormulas';'isSetfbc_charge';'fbc_version'};
% %         for s=1:length(listSpeciesField);
% %             try
% %                 sbmlModel.species(i).(listSpeciesField{s})=model.(listSpeciesCobra{s}){i};
% %             catch
% %                 try
% %                     sbmlModel.species(i).(listSpeciesField{s})=model.(listSpeciesCobra{s})(i);
% %                 catch
% %                     if s~=4
% %                         sbmlModel.species(i).(listSpeciesField{s})=0;
% %                     else
% %                         sbmlModel.species(i).(listSpeciesField{s})=1;
% %                     end
% %                 end
% %             end
% %         end
% %     end
% % end

% % if debug_function
% %     for (i = 1:size(sbmlModel.species, 2))
% %         if ~isSBML_Species(sbmlModel.species(i), sbmlLevel, sbmlVersion)
% %             error('SBML species failed to pass test')
% %         end
% %     end
% % end

%% Add a list of unique compartments.

tmp_metCompartment = unique(tmp_metCompartment);

tmp_compartment=struct('typecode','SBML_COMPARTMENT',...
    'metaid',emptyChar,...
    'notes',emptyChar,...
    'annotation',emptyChar,...
    'sboTerm',defaultSboTerm,...
    'name',emptyChar,... %%
    'id',emptyChar,...     %%
    'spatialDimensions',3,... %% emptyChar,...
    'size',1,...
    'units',emptyChar,...
    'constant',emptyChar,...
    'isSetSize',1,...
    'isSetSpatialDimensions',1,...
    'level',defaultLevel,...
    'version',defaultVersion);

for i=1:size(tmp_metCompartment,2)
    if ~isempty(tmp_metCompartment) % in the case of an empty model
        tmp_id = tmp_metCompartment{1,i};
        tmp_symbol_index = find(strcmp(formatForSBMLID(compSymbolList),tmp_id));
        %Check that symbol is in compSymbolList
        if ~isempty(tmp_symbol_index)
            tmp_name = compNameList{tmp_symbol_index};
        else
            warning on;
            warning(['Unknown compartment: ' tmp_id '.' tmp_id ' can be specified in compSymbolList and compNameList.']);
            tmp_name=['unknownCompartment',num2str(i)];
        end
        tmp_id = formatForSBMLID(tmp_id);
        
        %    sbmlModel = Model_addCompartment(sbmlModel, sbml_tmp_compartment);
        
        tmp_compartment.id=tmp_id;
        tmp_compartment.name=tmp_name;
    end
    
    if i==1
        sbmlModel.compartment=tmp_compartment;
    else
        sbmlModel.compartment=[sbmlModel.compartment, tmp_compartment];
    end
end
% % if debug_function
% %     for (i = 1:size(sbmlModel.compartment, 2))
% %         if ~isSBML_Compartment(sbmlModel.compartment(i), sbmlLevel, sbmlVersion)
% %             error('SBML compartment failed to pass test')
% %         end
% %     end
% % end

%% Reaction

% % % % % % sbml_tmp_parameter.units = reaction_units;
% % % % % % sbml_tmp_parameter.isSetValue = 1;
%%%%%%%% Rxn definitions


if defaultFbcVersion==1
    
    tmp_Rxn=struct('typecode','SBML_REACTION',...
        'metaid',emptyChar,...
        'notes',emptyChar,... %%
        'annotation',emptyChar,...
        'sboTerm',defaultSboTerm,...
        'name',emptyChar,... %%
        'id',emptyChar,... %%
        'reactant',emptyChar,...
        'product',emptyChar,...
        'modifier',emptyChar,...
        'kineticLaw',emptyChar,...
        'reversible',emptyChar,... %%
        'fast',emptyChar,...
        'compartment',emptyChar,...
        'isSetFast',emptyChar,...
        'level',defaultLevel,...
        'version',defaultVersion);
    
else defaultFbcVersion==2
    
    tmp_Rxn=struct('typecode','SBML_REACTION',...
        'metaid',emptyChar,...
        'notes',emptyChar,... %%
        'annotation',emptyChar,...
        'sboTerm',defaultSboTerm,...
        'name',emptyChar,... %%
        'id',emptyChar,... %%
        'reactant',emptyChar,...
        'product',emptyChar,...
        'modifier',emptyChar,...
        'kineticLaw',emptyChar,...
        'reversible',emptyChar,... %%
        'fast',emptyChar,...
        'compartment',emptyChar,...
        'isSetFast',emptyChar,...
        'fbc_lowerFluxBound',emptyChar,...
        'fbc_upperFluxBound',emptyChar,...
        'fbc_geneProductAssociation',emptyChar,...
        'level',defaultLevel,...
        'version',defaultVersion,...
        'fbc_version',defaultFbcVersion);
end

sbml_tmp_species_ref=struct('typecode','SBML_SPECIES_REFERENCE',... %
    'metaid',emptyChar,...
    'notes',emptyChar,...
    'annotation',emptyChar,...
    'sboTerm',defaultSboTerm,...
    'species',emptyChar,... %%
    'id',emptyChar,...
    'name',emptyChar,...
    'stoichiometry',emptyChar,... %%
    'constant',emptyChar,...
    'isSetStoichiometry',emptyChar,...
    'level',defaultLevel,...
    'version',defaultVersion);

% fieldnames(converted.reaction.modifier{1})
tmp_Rxn.modifier=struct('typecode',eval(initFunList{5}),...
    'metaid',eval(initFunList{5}),...
    'notes',eval(initFunList{5}),...
    'annotation',eval(initFunList{5}),...
    'sboTerm',defaultSboTerm,...
    'species',eval(initFunList{5}),...
    'id',eval(initFunList{5}),...
    'name',eval(initFunList{5}),...
    'level',defaultLevel,...
    'version',defaultVersion);

% fieldnames(converted.reaction.kineticLaw{1})

tmp_Rxn.kineticLaw=struct('typecode',eval(initFunList{5}),...
    'metaid',eval(initFunList{5}),...
    'notes',eval(initFunList{5}),...
    'annotation',eval(initFunList{5}),...
    'sboTerm',defaultSboTerm,...
    'math',eval(initFunList{5}),...
    'localParameter',eval(initFunList{5}),...
    'level',defaultLevel,...
    'version',defaultVersion);
%
tmp_fbc_fluxBound=struct('typecode','SBML_FBC_FLUXBOUND',...
    'metaid',emptyChar,...
    'notes',emptyChar,...
    'annotation',emptyChar,...
    'sboTerm',defaultSboTerm,...
    'fbc_id',emptyChar,...
    'fbc_reaction',emptyChar,... %%
    'fbc_operation',emptyChar,...
    'fbc_value',emptyChar,...    %%
    'isSetfbc_value',emptyChar,...
    'level',defaultLevel,...
    'version',defaultVersion,...
    'fbc_version',defaultFbcVersion);

%% sbmlModel.parameter
tmp_parameter=struct('typecode','SBML_PARAMETER',...
    'metaid',emptyChar,...
    'notes',emptyChar,...
    'annotation',emptyChar,...
    'sboTerm',defaultSboTerm,...
    'name',emptyChar,...%
    'id','noID',... %
    'value',emptyChar,...
    'units',emptyChar,...
    'constant',1,...  % set constant to 'true';
    'isSetValue',defaultIsSetValue,...
    'level',defaultLevel,...
    'version',defaultVersion);

%% Generate a list of unqiue fbc_bound names
totalValues=[model.lb; model.ub];
totalNames=cell(size(totalValues,1),1);

listUniqueValues=unique(totalValues);

for i=1:length(listUniqueValues)
    listUniqueNames{i,1}=['FB',num2str(i),'N',num2str(abs(round(listUniqueValues(i))))]; % create unique flux bound IDs.
    ind=find(ismember(totalValues,listUniqueValues(i)));
    totalNames(ind)=listUniqueNames(i,1);
end

if ~isempty(listUniqueValues)
    for i=1:length(listUniqueNames)
        
        tmp_parameter.id=listUniqueNames{i,1};
        tmp_parameter.value=listUniqueValues(i);
        if i==1
            sbmlModel.parameter=tmp_parameter;
        else
            sbmlModel.parameter=[sbmlModel.parameter,tmp_parameter];
        end
    end
else
    sbmlModel.parameter=tmp_parameter;
end

tmp_fbc_fluxBoundUb=tmp_fbc_fluxBound;
tmp_fbc_fluxBoundLb=tmp_fbc_fluxBound;

tmp_Rxn.fbc_geneProductAssociation=struct('typecode','SBML_FBC_GENE_PRODUCT_ASSOCIATION',...
    'metaid',emptyChar,...
    'notes',emptyChar,...
    'annotation',emptyChar,...
    'sboTerm',defaultSboTerm,...
    'fbc_id',emptyChar,...
    'fbc_name',emptyChar,...
    'fbc_association',emptyChar,...
    'level',defaultLevel,...
    'version',defaultVersion,...
    'fbc_version',defaultFbcVersion);


tmp_Rxn.fbc_geneProductAssociation.fbc_association=struct('typecode','SBML_FBC_OR',...
    'metaid',emptyChar,... % 'ss'
    'notes',emptyChar,...
    'annotation',emptyChar,...
    'sboTerm',defaultSboTerm,...
    'fbc_association',emptyChar,...
    'level',defaultLevel,...
    'version',defaultVersion,...
    'fbc_version',defaultFbcVersion);


sbmlModel.reaction=tmp_Rxn;
sbmlModel.fbc_fluxBound=[tmp_fbc_fluxBoundLb,tmp_fbc_fluxBoundUb];

for i=1:size(model.rxns, 1)
    % % %     sbml_tmp_law.parameter = [];
    % % %     sbml_tmp_law.formula = 'FLUX_VALUE';
    % % %     sbml_tmp_parameter.id = 'LOWER_BOUND';
    % % %     sbml_tmp_parameter.value = model.lb(i);
    % % %     sbml_tmp_law.parameter = [ sbml_tmp_law.parameter sbml_tmp_parameter ];
    % % %     sbml_tmp_parameter.id = 'UPPER_BOUND';
    % % %     sbml_tmp_parameter.value = model.ub(i);
    % % %     sbml_tmp_law.parameter = [ sbml_tmp_law.parameter sbml_tmp_parameter ];
    % % %     sbml_tmp_parameter.id = 'FLUX_VALUE';
    % % %     sbml_tmp_parameter.value = 0;
    % % %     sbml_tmp_law.parameter = [ sbml_tmp_law.parameter sbml_tmp_parameter ];
    % % %     sbml_tmp_parameter.id = 'OBJECTIVE_COEFFICIENT';
    % % %     sbml_tmp_parameter.value = model.c(i);
    % % %     sbml_tmp_law.parameter = [ sbml_tmp_law.parameter sbml_tmp_parameter ];
    % % %     sbml_tmp_reaction.kineticLaw = sbml_tmp_law;
    %     sbml_tmp_reaction.notes = '';
    
    % Add in other notes
    
    %% gene association support for the case of FBCv1
    
    tmp_note = emptyChar;
    if defaultFbcVersion~=2 % only when fbc version is not 2;
        if isfield(model, 'grRules')
            tmp_note = [tmp_note '<p>GENE_ASSOCIATION: ' model.grRules{i} '</p>' ];
        end
    end
    if isfield(model, 'subSystems')&&i<=length(model.subSystems)% &&~isempty(model.subSystems{i})
        tmp_note = [ tmp_note ' <p>SUBSYSTEM: ' model.subSystems{i} '</p>'];
    end
    if isfield(model, 'rxnECNumbers')&&i<=length(model.rxnECNumbers)%&&~isempty(model.rxnECNumbers{i})
        tmp_note = [ tmp_note ' <p>EC Number: ' model.rxnECNumbers{i} '</p>'];
    end
    if isfield(model, 'confidenceScores')&&i<=length(model.confidenceScores)%&&~isempty(model.confidenceScores{i})
        tmp_note = [ tmp_note ' <p>Confidence Level: ' model.confidenceScores{i} '</p>'];
    end
    if isfield(model, 'rxnReferences')&&i<=length(model.rxnReferences)%&&~isempty(model.rxnReferences{i})
        tmp_note = [ tmp_note ' <p>AUTHORS: ' model.rxnReferences{i} '</p>'];
    end
    if isfield(model, 'rxnNotes')&&i<=length(model.rxnNotes)%&&~isempty(model.rxnNotes{i})
        tmp_note = [ tmp_note ' <p>NOTES: ' model.rxnNotes{i} '</p>'];
    end
    if ~isempty(tmp_note)
        tmp_note = ['<body xmlns="http://www.w3.org/1999/xhtml">' tmp_note '</body>'];
    end
    tmp_Rxn.notes=tmp_note;
    
    % % % %     tmp_noteArray{i,1}=tmp_note;
    
    %Reset the fields that have been filled.
    
    %     sbml_tmp_reaction.reactant = [];
    %     sbml_tmp_reaction.product = [];
    %     sbml_tmp_reaction.kineticLaw = [];
    %
    % % % %     tmp_rxnID{i,1} =  strcat('R_', formatForSBMLID(model.rxns{i}));
    % % % %
    % % % %      tmp_rxnName{i,1}=emptyChar;
    % % % %     if isfield(model, 'rxnNames')
    % % % %         tmp_rxnName{i,1} = model.rxnNames{i};
    % % % %     end
    % % % %
    % % % %     if isfield(model, 'rev')
    % % % %         tmp_rxnRev(i,1) = model.rev(i);
    % % % %     else
    % % % %         tmp_rxnRev(i,1)=0;
    % % % %     end
    
    tmp_rxnID =  strcat('R_', formatForSBMLID(model.rxns{i}));
    
    tmp_rxnName=emptyChar;
    if isfield(model, 'rxnNames')
        tmp_rxnName = model.rxnNames{i};
    end
    
    if isfield(model, 'rev')
        tmp_rxnRev= model.rev(i);
    else
        tmp_rxnRev=0;
    end
    
    if isfield(model, 'rxnsboTerm')
        tmp_Rxn.sboTerm= model.rxnsboTerm(i);
    end
    
    tmp_Rxn.id=tmp_rxnID;
    tmp_Rxn.name=tmp_rxnName;
    tmp_Rxn.reversible=tmp_rxnRev;
    
    tmp_Rxn.fast=0;
    tmp_Rxn.isSetFast=1;
    
    %Add in the reactants and products
    met_idx = find(model.S(:, i));
    tmp_Rxn.product=[];
    tmp_Rxn.reactant=[];
    for (j_met=1:size(met_idx,1))
        tmp_idx = met_idx(j_met,1);
        sbml_tmp_species_ref.species = sbmlModel.species(tmp_idx).id; % model.mets{tmp_idx};
        met_stoich = model.S(tmp_idx, i);
        sbml_tmp_species_ref.stoichiometry = abs(met_stoich);
        sbml_tmp_species_ref.isSetStoichiometry=1;
        sbml_tmp_species_ref.constant=1;
        if (met_stoich > 0)
            tmp_Rxn.product = [ tmp_Rxn.product, sbml_tmp_species_ref ];
        else
            tmp_Rxn.reactant = [ tmp_Rxn.reactant, sbml_tmp_species_ref];
        end
    end
    %% grRules
    
    if isfield(model, 'grRules')
        sbml_tmp_grRules= model.grRules(i);
        %% need to be improved since the fbc_id for the gene association is not provided.
        
        tmp_fbc_id=['gene',num2str(i)]; % set a default gene name.
        %     tmp_Rxn.tmp_fbc_geneProductAssociation=[];
        %         if i==1;
        tmp_Rxn.fbc_geneProductAssociation.fbc_id=tmp_fbc_id;
        tmp_Rxn.fbc_geneProductAssociation.fbc_association.fbc_association=sbml_tmp_grRules{1};
        %         else
        %     sbmlModel.reaction=[sbmlModel.reaction,sbml_tmp_grRules];
        %         end
    end
    
    if defaultFbcVersion==2 % in the cae of FBCv2
        tmp_Rxn.fbc_lowerFluxBound=totalNames{i}; % num2str(model.lb(i));
        tmp_Rxn.fbc_upperFluxBound=totalNames{length(model.lb)+i}; % num2str(model.ub(i));
    end
    
    if i==1;
        sbmlModel.reaction=tmp_Rxn;
    else
        sbmlModel.reaction=[sbmlModel.reaction,tmp_Rxn];
    end
    %% bounds
    if defaultFbcVersion==1  % in the cae of FBCv1
        % generate the sbmlModel.reaction.
        
        % %         if i==1;
        % %             sbmlModel.reaction=tmp_Rxn;
        % %         else
        % %             sbmlModel.reaction=[sbmlModel.reaction,tmp_Rxn];
        % %         end
        
        tmp_fbc_fluxBoundLb.fbc_reaction=tmp_rxnID; % Reaction ID
        tmp_fbc_fluxBoundUb.fbc_reaction=tmp_rxnID;
        
        tmp_fbc_fluxBoundLb.fbc_value=model.lb(i);
        tmp_fbc_fluxBoundUb.fbc_value=model.ub(i);
        
        if i==1
            sbmlModel.fbc_fluxBound=[tmp_fbc_fluxBoundLb,tmp_fbc_fluxBoundUb];
        else
            sbmlModel.fbc_fluxBound=[sbmlModel.fbc_fluxBound,tmp_fbc_fluxBoundLb,tmp_fbc_fluxBoundUb];
        end
    end
    
end

% % if debug_function
% %     for (i = 1:size(sbmlModel.reaction, 2))
% %         if ~isSBML_Reaction(sbmlModel.reaction(i), sbmlLevel, sbmlVersion)
% %             error('SBML reaction failed to pass test')
% %         end
% %     end
% % end
%% geneProduct, i.e., list of genes in the SBML file, which are stored in the <fbc:listOfGeneProducts> attribute
tmp_fbc_geneProduct=struct('typecode','SBML_FBC_GENE_PRODUCT',...
    'metaid',emptyChar,... % 'ss'
    'notes',emptyChar,...
    'annotation',emptyChar,...
    'sboTerm',defaultSboTerm,...
    'fbc_id',emptyChar,...
    'fbc_name',emptyChar,...
    'fbc_label',emptyChar,...
    'fbc_associatedSpecies',emptyChar,...
    'level',defaultLevel,...
    'version',defaultVersion,...
    'fbc_version',defaultFbcVersion);

sbmlModel.fbc_geneProduct=tmp_fbc_geneProduct; % generate an default empty fbc_geneProduct field for the libSBML matlab structure

if isfield(model,'genes')
    for i=1:length(model.genes)
        tmp_fbc_geneProduct.fbc_id=['g',num2str(i)]; % generate fbc_id values
        tmp_fbc_geneProduct.fbc_label=model.genes{i};
        if i==1
            sbmlModel.fbc_geneProduct=tmp_fbc_geneProduct;
        else
            sbmlModel.fbc_geneProduct=[sbmlModel.fbc_geneProduct,tmp_fbc_geneProduct];
        end
    end
end

%Set the objective sense of the FBC objective according to the osenseStr in
%the model.
objectiveSense = 'maximize';

if isfield(model,'osenseStr') && strcmp('min',model.osenseStr)
    objectiveSense = 'minimize'
end

tmp_fbc_objective=struct('typecode','SBML_FBC_OBJECTIVE',...   % Create templates of new structures defined in the FBCv2 scheme (i.e., field names and default values are initilised)
    'metaid',emptyChar,...
    'notes',emptyChar,...
    'annotation',emptyChar,...
    'sboTerm',defaultSboTerm,...
    'fbc_id','obj',... % define a term (No. 6)
    'fbc_type', objectiveSense,... % define the type (No.7)
    'fbc_fluxObjective',emptyChar,... % is acturally a structure (No.8)
    'level', defaultLevel,...
    'version', defaultVersion,...
    'fbc_version',defaultFbcVersion);

tmp_fbc_objective.fbc_fluxObjective=struct('typecode','SBML_FBC_FLUXOBJECTIVE',...
    'metaid',emptyChar,...
    'notes',emptyChar,...
    'annotation',emptyChar,...
    'sboTerm',defaultSboTerm,...
    'fbc_reaction',emptyChar,...      % No. 6
    'fbc_coefficient',emptyChar,...            % No. 7
    'isSetfbc_coefficient',emptyChar,...
    'level',defaultLevel,...
    'version',defaultVersion,...
    'fbc_version',defaultFbcVersion);

%%%%% multiple objectives
if ~isnumeric(model.c)
    model.c=double(cell2mat(model.c)); % convert the variable type to double
end
% check=~isempty(model.c(model.c~=0)) the following block is necessry for
% libSBML library 5.11
% % % % % % % if isempty(model.c(model.c~=0)) % if no objective function is defined, the first reaction is set as the objective function.
% % % % % % %     model.c(1)=1;
% % % % % % % end
%if ~isempty(model.c(model.c~=0))
% Construct a default structure of objective reactions and set intial values.
%     fbc_objective.fbc_fluxObjective=fbc_fluxObjective;
ind=find(model.c); % Find the index numbers for the objective reactions
% The fields of a COBRA model are converted into respective fields of a FBCv2 structure.
if isempty(ind)
    tmp_fbc_objective.fbc_fluxObjective.fbc_coefficient=0; % no objective function is set
    sbmlModel.fbc_objective=tmp_fbc_objective;
else
    for i=1:length(ind);
        %     model.c(ind(i));
        values=model.c(model.c~=0);
        tmp_fbc_objective.fbc_fluxObjective.fbc_reaction=sbmlModel.reaction(ind(i)).id; % the reaction.id contains the  % model.rxns{ind(i)};
        tmp_fbc_objective.fbc_fluxObjective.fbc_coefficient=values(i);
        tmp_fbc_objective.fbc_fluxObjective.isSetfbc_coefficient=1;
        if i==1
            sbmlModel.fbc_objective=tmp_fbc_objective;
        else
            sbmlModel.fbc_objective.fbc_fluxObjective=[sbmlModel.fbc_objective.fbc_fluxObjective,tmp_fbc_objective.fbc_fluxObjective];
        end
    end
end

%end
fbcStr=['http://www.sbml.org/sbml/level3/version1/','fbc/version',num2str(defaultFbcVersion)];

sbmlModel.namespaces=struct('prefix',{'','fbc'},...
    'uri',{'http://www.sbml.org/sbml/level3/version1/core',...
    fbcStr});

if defaultFbcVersion==2
    sbmlModel.fbc_strict=1; % the new FBCv2 field
end
OutputSBML(sbmlModel,fileName);
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
end
