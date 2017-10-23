function sbmlModel = writeSBML(model,fileName,compSymbolList,compNameList)
% Exports a COBRA structure into an SBML FBCv2 file. A SBMLFBCv2 file  a file is written to the current Matlab path.
%
% USAGE:
%
%    sbmlModel = writeSBML(model, fileName, compSymbolList, compNameList)
%
% INPUTS:
%    model:             COBRA model structure
%    fileName:          File name for output file
%
% OPTIONAL INPUTS:
%    compSymbolList:    List of compartment symbols
%    compNameList:      List of copmartment names corresponding to compSymbolList
%
% OUTPUT:
%    sbmlModel:         SBML MATLAB structure
%
% .. Author: - Longfei Mao 24/09/15
%            - Thomas Pfau May 2017 Updates to libsbml 5.15

%% Compartments
if nargin<3 || ~exist('compSymbolList','var') || isempty(compSymbolList) || ~isfield(model, 'compNames')
    if isfield(model, 'comps') && ~isfield(model,'compNames')
        model.compNames = model.comps;
    else
        [model.comps,model.compNames] = getDefaultCompartments();
    end
else
    model.comps = compSymbolList;
    model.compNames = compNameList;
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
        
        sbmlModel.(list{i})='COBRAModel';
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
[tokens tmp_met_struct] = regexp(model.mets,'(?<met>.+)\[(?<comp>.+)\]','tokens','names'); % add the third type for parsing the string such as "M_10fthf5glu_c"
%if we have any compartment, we will use unknown as compartment ID for
%metabolites without compartment.
if any(cellfun(@isempty, tmp_met_struct))
    unknownComp = 'u';
else
    unknownComp = 'c';
end

tmp_species=struct('typecode','SBML_SPECIES',...
    'metaid',emptyChar,...
    'notes',emptyChar,...
    'annotation',emptyChar,...
    'sboTerm',299,...
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
    if  ~isempty(tmp_met_struct{i})          % If there are metabolites without compartment.
        tmp_met = tmp_met_struct{i}.met;
    else
        tmp_met = model.mets{i};
    end
    
    if isempty(tmp_met_struct{i})
        %Change id to correspond to SBML id specifications
        tmp_met = strcat('M_', (tmp_met), '_', unknownComp);
    else
        tmp_met = strcat('M_', (tmp_met), '_', tmp_met_struct{i}.comp);
    end
    
    tmp_met= convertSBMLID(tmp_met);
    %     model.mets{ i } = convertSBMLID(tmp_met); % remove illegal symbols
    %     tmp_species.id = convertSBMLID(tmp_met);  % remove illegal symbols
    if isfield(model, 'metNames')
        tmp_metName = (model.metNames{i});
    else
        tmp_metName=emptyChar;
    end
    
    if isfield(model, 'metFormulas')
        tmp_metFormulas = model.metFormulas{i};
    else
        tmp_metFormulas=emptyChar; %cell(0,1)% {''};%0;%emptyChar;
    end
    
    if isfield(model, 'metCharges')
        if ~isnan(model.metCharges(i))
            tmp_metCharge=model.metCharges(i);
            tmp_isSetfbc_charge=1;
        else
            tmp_metCharge=0;
            tmp_isSetfbc_charge=0;
        end
    else
        tmp_metCharge=0;
        tmp_isSetfbc_charge=0;
    end
    
    if isfield(model,'metSBOTerms')
        if ~isempty(model.metSBOTerms{i})
            tmp_Sboterm = num2str(regexprep(model.metSBOTerms{i},'^SBO:0*([1-9][0-9]*)$','$1'));
        else
            tmp_Sboterm = defaultSboTerm;
        end
    else
        %Not existent.
        tmp_Sboterm = defaultSboTerm;
    end
    %% here notes can be formulated to include more annotations.
    tmp_species.id=convertSBMLID(tmp_met);
    tmp_species.metaid = tmp_species.id;
    tmp_species.name=tmp_metName;
    tmp_species.sboTerm = tmp_Sboterm;
    try
        tmp_species.compartment=convertSBMLID(tmp_met_struct{i}.comp);
        %% Clean up the species names
        tmp_metCompartment{ i } = convertSBMLID(tmp_met_struct{i}.comp); % remove illegal symbols
    catch   % if no compartment symbol is found in the metabolite names
        tmp_species.compartment=convertSBMLID(unknownComp);
        %% Clean up the species names
        tmp_metCompartment{ i } = unknownComp; % remove illegal symbols
    end
    tmp_species.fbc_charge=tmp_metCharge;
    tmp_species.fbc_chemicalFormula=tmp_metFormulas;
    tmp_species.isSetfbc_charge=tmp_isSetfbc_charge;
    %% Add annotations for metaoblites to the reconstruction
    tmp_species.metaid=tmp_species.id;  % set the metaid for each species
    [tmp_annot,met_notes] = makeSBMLAnnotationString(model,tmp_species.metaid,'met',i);
    
    tmp_note = emptyChar;
    if ~isempty(met_notes)
        for noteid = 1:size(met_notes,1)
            tmp_note = [ tmp_note ' <p>' regexprep(met_notes{noteid,1},'^rxn','') ':' met_notes{noteid,2} '</p>'];
        end
    end
    if isfield(model,'metNotes')
        %Lets test whether the field is correctly formatted
        COBRA_STYLE_NOTE_FIELDS = strsplit(model.metNotes{i},'\n');
        for pos = 1:length(COBRA_STYLE_NOTE_FIELDS)
            current = COBRA_STYLE_NOTE_FIELDS{pos};
            if isempty(current)
                continue;
            end
            if any(strfind(current,':'))
                %If it has a title, we use that one, otherwise its just a
                %note.
                tmp_note = [ tmp_note ' <p>' current '</p>'];
            else
                tmp_note = [ tmp_note ' <p>NOTES: ' current '</p>'];
            end
        end
    end
    if ~isempty(tmp_note)
        tmp_note = ['<body xmlns="http://www.w3.org/1999/xhtml">' tmp_note '</body>'];
    end
    tmp_species.notes = tmp_note;
    tmp_species.annotation=tmp_annot;
    
    if i==1
        sbmlModel.species=tmp_species;
    else
        sbmlModel.species=[sbmlModel.species, tmp_species];
    end
    
    % sbmlModel.species = [ sbmlModel.species, tmp_species ];
    %This is where the compartment symbols are aggregated.
    
end


%% Add a list of unique compartments.

tmp_metCompartment = unique(tmp_metCompartment);

tmp_compartment=struct('typecode','SBML_COMPARTMENT',...
    'metaid',emptyChar,...
    'notes',emptyChar,...
    'annotation',emptyChar,...
    'sboTerm',240,... %% physical compartment
    'name',emptyChar,... %%
    'id',emptyChar,...     %%
    'spatialDimensions',3,... %% emptyChar,...
    'size',1,...
    'units',emptyChar,...
    'constant',int32(1),... %We assume constant compartments, i.e. sizes do not change during a simulation.
    'isSetSize',1,...
    'isSetSpatialDimensions',1,...
    'level',defaultLevel,...
    'version',defaultVersion);

for i=1:size(tmp_metCompartment,2)
    if ~isempty(tmp_metCompartment) % in the case of an empty model
        tmp_id = convertSBMLID(tmp_metCompartment{1,i});
        tmp_symbol_index = find(strcmp(convertSBMLID(model.comps),tmp_id));
        %Check that symbol is in compSymbolList
        if ~isempty(tmp_symbol_index)
            tmp_name = model.compNames{tmp_symbol_index};
        else
            warning on;
            warning(['Unknown compartment: ' tmp_id '.' tmp_id ' can be specified in compSymbolList and compNameList.']);
            tmp_name=['unknownCompartment',num2str(i)];
        end
        tmp_id = convertSBMLID(tmp_id);
        
        %    sbmlModel = Model_addCompartment(sbmlModel, sbml_tmp_compartment);
        
        tmp_compartment.id=tmp_id;
        tmp_compartment.metaid = tmp_id;
        tmp_compartment.name=tmp_name;
        tmp_compartment.annotation = makeSBMLAnnotationString(model,tmp_compartment.metaid,'comp',i);
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


tmp_Rxn=struct('typecode','SBML_REACTION',...
    'metaid',emptyChar,...
    'notes',emptyChar,... %%
    'annotation',emptyChar,...
    'sboTerm',176,...%% Biochemical or transport reaction, lets assume, that we don't have something odd...
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

model.genes = cellfun(@convertSBMLID,model.genes,'UniformOutput',0);
%this is always possible, and now we have acceptable gene IDs.
model = creategrRulesField(model);
for i=1:size(model.rxns, 1)
    tmp_rxnID =  strcat('R_', convertSBMLID(model.rxns{i}));
    tmp_Rxn.metaid = tmp_rxnID;
    [tmp_Rxn.annotation,rxn_notes] = makeSBMLAnnotationString(model,tmp_Rxn.metaid,'rxn',i);
    tmp_note = emptyChar;
    if ~isempty(rxn_notes)
        for noteid = 1:size(rxn_notes,1)
            tmp_note = [ tmp_note ' <p>' regexprep(rxn_notes{noteid,1},'^rxn','') ':' rxn_notes{noteid,2} '</p>'];
        end
    end
    
    if isfield(model, 'subSystems')
        tmp_note = [ tmp_note ' <p>SUBSYSTEM: ' strjoin(model.subSystems{i},';') '</p>'];
    end
    if isfield(model, 'rxnConfidenceScores')
        if iscell(model.rxnConfidenceScores)
            %This is for old style models which provide confidence scores
            %as strings.
            tmp_note = [ tmp_note ' <p>Confidence Level: ' model.rxnConfidenceScores{i} '</p>'];
        else
            tmp_note = [ tmp_note ' <p>Confidence Level: ' num2str(model.rxnConfidenceScores(i)) '</p>'];
        end
    end
    if isfield(model, 'rxnNotes')
        %Lets test whether the field is correctly formatted
        COBRA_STYLE_NOTE_FIELDS = strsplit(model.rxnNotes{i},'\n');
        for pos = 1:length(COBRA_STYLE_NOTE_FIELDS)
            current = COBRA_STYLE_NOTE_FIELDS{pos};
            if isempty(current)
                continue;
            end
            if any(strfind(current,':'))
                %If it has a title, we use that one, otherwise its just a
                %note.
                tmp_note = [ tmp_note ' <p>' current '</p>'];
            else
                tmp_note = [ tmp_note ' <p>NOTES: ' current '</p>'];
            end
        end
    end
    if ~isempty(tmp_note)
        tmp_note = ['<body xmlns="http://www.w3.org/1999/xhtml">' tmp_note '</body>'];
    end
    tmp_Rxn.notes=tmp_note;
    
    tmp_rxnName=emptyChar;
    if isfield(model, 'rxnNames')
        tmp_rxnName = model.rxnNames{i};
    end
    
    if isfield(model,'rxnSBOTerms')
        if ~isempty(model.rxnSBOTerms{i})
            tmp_Sboterm = num2str(regexprep(model.rxnSBOTerms{i},'^SBO:0*([1-9][0-9]*)$','$1'));
        else
            tmp_Sboterm = defaultSboTerm;
        end
    else
        %Not existent.
        tmp_Sboterm = -1;
    end
    
    tmp_rxnRev= (model.lb(i) < 0) + 0;
    tmp_Rxn.id=tmp_rxnID;
    tmp_Rxn.metaid = tmp_rxnID;
    tmp_Rxn.name=tmp_rxnName;
    tmp_Rxn.reversible=tmp_rxnRev;
    tmp_Rxn.sboTerm = tmp_Sboterm;
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
        tmp_Rxn.fbc_geneProductAssociation.fbc_association.fbc_association=sbml_tmp_grRules{1};
    end
    
    if defaultFbcVersion==2 % in the cae of FBCv2
        tmp_Rxn.fbc_lowerFluxBound=totalNames{i}; % num2str(model.lb(i));
        tmp_Rxn.fbc_upperFluxBound=totalNames{length(model.lb)+i}; % num2str(model.ub(i));
    end
    
    if i==1
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

GeneProductAnnotations = {'gene',{'isEncodedBy','encoder'},'protein',{}};

if isfield(model,'genes')
    for i=1:length(model.genes)
        tmp_fbc_geneProduct.fbc_id=convertSBMLID(model.genes{i}); % This is a modified ID already.
        tmp_fbc_geneProduct.metaid=convertSBMLID(model.genes{i});
        if isfield(model,'geneNames')
            tmp_fbc_geneProduct.fbc_label=model.geneNames{i};
        else
            tmp_fbc_geneProduct.fbc_label=model.genes{i};
        end
        
        if isfield(model,'proteins')
            tmp_fbc_geneProduct.fbc_name = model.proteins{i};
        end
        
        tmp_fbc_geneProduct.annotation = makeSBMLAnnotationString(model,tmp_fbc_geneProduct.fbc_id,GeneProductAnnotations,i);
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

if isfield(model,'osense') && model.osense == 1
    objectiveSense = 'minimize';
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
    for i=1:length(ind)
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
OutputSBML(sbmlModel,fileName,1,0,[1,0]);
end
