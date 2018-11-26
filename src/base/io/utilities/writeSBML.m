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

%First, define the used packages and the used sbmlLevel and Version:
%Set 
sbmlLevel=3;
sbmlVersion=1;
sbmlPackages = {'fbc','groups'};
sbmlPackageVersions = [2,1];

%Some defaults
emptyChar = '';

%For IDs which are converted to SBML IDs check whether they have the
%appropriate format:
if any(cellfun(@isempty, regexp(convertSBMLID(model.mets),'^[_a-zA-Z]')))
    %If any ID does not start with letter or _, add M_
    metabolitePrefix = 'M_';
else
    metabolitePrefix = '';
end

if any(cellfun(@isempty, regexp(convertSBMLID(model.rxns),'^[_a-zA-Z]')))
    %If any ID does not start with letter or _, add M_
    reactionPrefix = 'R_';
else
    reactionPrefix = '';
end

if any(cellfun(@isempty, regexp(convertSBMLID(model.genes),'^[_a-zA-Z]')))
    %If any ID does not start with letter or _, add M_
    genePrefix = 'G_';
else
    genePrefix = '';
end

if any(cellfun(@isempty, regexp(convertSBMLID(model.comps),'^[_a-zA-Z]')))
    %If any ID does not start with letter or _, add M_
    compPrefix = 'C_';
else
    compPrefix = '';
end

%% sbmlModel.constraint
sbmlModel = getSBMLDefaultStruct('Model',sbmlLevel, sbmlVersion,sbmlPackages, sbmlPackageVersions);

tmp_unitDefinition = getSBMLDefaultStruct('UnitDefinition',sbmlLevel, sbmlVersion,sbmlPackages, sbmlPackageVersions);
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
tmp_unit = getSBMLDefaultStruct('Unit',sbmlLevel, sbmlVersion,sbmlPackages, sbmlPackageVersions);
for i = 1:size(unit_kinds, 2)
    cunit = tmp_unit;
    cunit.kind = unit_kinds{ i };
    cunit.exponent = unit_exponents(i);
    cunit.scale = unit_scales(i);
    cunit.multiplier = unit_multipliers(i);
    %      tmp_unit_definition = UnitDefinition_addUnit(tmp_unit_definition, tmp_unit);
    if i==1
        sbmlModel.unitDefinition.unit=cunit;
    else
        sbmlModel.unitDefinition.unit=[sbmlModel.unitDefinition.unit,cunit];
    end
end

if isfield(model,'modelName')
    sbmlModel.name = model.modelName;    
else
    sbmlModel.name = 'Model Exported from COBRA Toolbox';    
end

if isfield(model,'modelID')
    sbmlModel.id = ['M_' convertSBMLID(model.modelID)];
else
    sbmlModel.id = 'COBRAModel';
end


%Set some model properties
if isfield(model,'description')
    sbmlModel.metaid = model.description;
end


%% Species

% Construct a list of compartment names
% List to hold the compartment ids.
tmp_metCompartment = {};


species_struct = getSBMLDefaultStruct('Species',sbmlLevel, sbmlVersion,sbmlPackages, sbmlPackageVersions);

sbmlModel.species=species_struct;


%% Metabolites
for i=1:size(model.mets, 1)
    tmp_species = species_struct;
    tmp_notes='';
    tmp_met = strcat(metabolitePrefix,  convertSBMLID(model.mets{i}));                    
    if isfield(model, 'metNames')
        tmp_metName = (model.metNames{i});
    else
        tmp_metName=emptyChar;
    end
    % create annotations and notes
    tmp_species.metaid=tmp_species.id;  % set the metaid for each species
    [tmp_annot,met_notes] = makeSBMLAnnotationString(model,tmp_species.metaid,'met',i);

    
    if isfield(model, 'metFormulas')
        % check the chemical formula
        tmp_metFormulas = model.metFormulas{i};        
        if ~isempty(model.metFormulas{i})
            coefs = regexp(model.metFormulas{i},'(?<nums>[\.0-9]+)','names');
            intVals = cellfun(@(x) mod(str2double(x),1) == 0,{coefs.nums});
            if any(~intVals)
                warning('Metabolite %s has formula %s. FBC 2.1 only allows integer values for coefficients.\nDiscarding the formula.',model.mets{i},model.metFormulas{i});
                met_notes(end+1,1:2) = {'FORMULA',tmp_metFormulas};
                tmp_metFormulas = emptyChar;                
            end
        end
        
    else
        tmp_metFormulas=emptyChar; %cell(0,1)% {''};%0;%emptyChar;
    end
    
    if isfield(model, 'metCharges')
        if ~isnan(model.metCharges(i))
            if mod(model.metCharges(i),1) ~= 0
                warning('Metabolite %s has a charge of %f. FBC 2.1 only allows integer values for charges.\nDiscarding the value.',model.mets{i},model.metCharges(i));
                met_notes(end+1,1:2) = {'CHARGE',num2str(model.metCharges(i))};
                tmp_metCharge=0;
                tmp_isSetfbc_charge=0;
            else
                tmp_metCharge=model.metCharges(i);
                tmp_isSetfbc_charge=1;
            end
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
            tmp_species.sboTerm = str2num(regexprep(model.metSBOTerms{i},'^SBO:0*([1-9][0-9]*)$','$1'));
        end    
    end
    %% here notes can be formulated to include more annotations.
    tmp_species.id=tmp_met;
    tmp_species.metaid = tmp_species.id;
    tmp_species.name=tmp_metName;    
	tmp_species.compartment=[compPrefix, convertSBMLID(model.metComp{i})];            
    tmp_species.fbc_charge=tmp_metCharge;
    tmp_species.fbc_chemicalFormula=tmp_metFormulas;
    tmp_species.isSetfbc_charge=tmp_isSetfbc_charge;
    %% Add annotations for metaoblites to the reconstruction
    
    tmp_note = emptyChar;
    if ~isempty(met_notes)
        for noteid = 1:size(met_notes,1)
            tmp_note = [ tmp_note ' <p>' regexprep(met_notes{noteid,1},'^met','') ':' met_notes{noteid,2} '</p>'];
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


tmp_compartment=getSBMLDefaultStruct('Compartment',sbmlLevel, sbmlVersion,sbmlPackages, sbmlPackageVersions);
    

for i=1:numel(model.comps)
        tmp_id = convertSBMLID(model.comps{i});
        %Check that symbol is in compSymbolList
        if isfield(model, 'compNames')
            tmp_name = model.compNames{i};
        else
            warning on;
            warning(['Unknown compartment: ' tmp_id '.' tmp_id ' can be specified in compSymbolList and compNameList.']);
            tmp_name=getCompartmentNameForID(model.comps{i});
        end       
        %    sbmlModel = Model_addCompartment(sbmlModel, sbml_tmp_compartment);        
        tmp_compartment.id= [compPrefix, tmp_id];
        tmp_compartment.metaid = tmp_compartment.id;
        tmp_compartment.name=tmp_name;
        tmp_compartment.annotation = makeSBMLAnnotationString(model,tmp_compartment.metaid,'comp',i);    
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

%% Genes
%% geneProduct, i.e., list of genes in the SBML file, which are stored in the <fbc:listOfGeneProducts> attribute
tmp_fbc_geneProduct=getSBMLDefaultStruct('GeneProduct',sbmlLevel, sbmlVersion,sbmlPackages, sbmlPackageVersions);

sbmlModel.fbc_geneProduct=tmp_fbc_geneProduct; % generate an default empty fbc_geneProduct field for the libSBML matlab structure

GeneProductAnnotations = {'gene',{'isEncodedBy','encoder'},'protein',{}};

if isfield(model,'genes')
    for i=1:length(model.genes)
        tmp_fbc_geneProduct.fbc_id=['G_' convertSBMLID(model.genes{i})]; % This is a modified ID already.
        tmp_fbc_geneProduct.metaid=['G_' convertSBMLID(model.genes{i})];
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

%Gene IDS:
geneIDs = {sbmlModel.fbc_geneProduct.fbc_id};
getGeneID = @(x) geneIDs{str2num(x)};

%% Reaction

% % % % % % sbml_tmp_parameter.units = reaction_units;
% % % % % % sbml_tmp_parameter.isSetValue = 1;
%%%%%%%% Rxn definitions


tmp_Rxn=getSBMLDefaultStruct('Reaction',sbmlLevel, sbmlVersion,sbmlPackages, sbmlPackageVersions);

sbml_tmp_species_ref=getSBMLDefaultStruct('SpeciesReference',sbmlLevel, sbmlVersion,sbmlPackages, sbmlPackageVersions);

% fieldnames(converted.reaction.modifier{1})
%tmp_Rxn.modifier=getSBMLDefaultStruct('ModifierSpeciesReference',sbmlLevel, sbmlVersion,sbmlPackages, sbmlPackageVersions);

% fieldnames(converted.reaction.kineticLaw{1})

%tmp_Rxn.kineticLaw=getSBMLDefaultStruct('KineticLaw',sbmlLevel, sbmlVersion,sbmlPackages, sbmlPackageVersions);

%% sbmlModel.parameter
tmp_parameter=getSBMLDefaultStruct('SBML_PARAMETER',sbmlLevel, sbmlVersion,sbmlPackages, sbmlPackageVersions);
fbc_parameter = tmp_parameter;
fbc_parameter.constant = 1;
fbc_parameter.isSetValue = 1;
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
        
        fbc_parameter.id=listUniqueNames{i,1};
        fbc_parameter.value=listUniqueValues(i);
        if i==1
            sbmlModel.parameter=fbc_parameter;
        else
            sbmlModel.parameter=[sbmlModel.parameter,fbc_parameter];
        end
    end
else
    sbmlModel.parameter=fbc_parameter;
end

tmp_Rxn.fbc_geneProductAssociation=getSBMLDefaultStruct('SBML_FBC_GENE_PRODUCT_ASSOCIATION',sbmlLevel, sbmlVersion,sbmlPackages, sbmlPackageVersions);

tmp_Rxn.fbc_geneProductAssociation.fbc_association = getSBMLDefaultStruct('SBML_FBC_GENE_PRODUCT_ASSOCIATION',sbmlLevel, sbmlVersion,sbmlPackages, sbmlPackageVersions);
%And set the association of the concrete one to OR:
tmp_Rxn.fbc_geneProductAssociation.fbc_association.typecode = 'SBML_FBC_OR';


sbmlModel.reaction=tmp_Rxn;

model.genes = cellfun(@convertSBMLID,model.genes,'UniformOutput',0);
%this is always possible, and now we have acceptable gene IDs.
model = creategrRulesField(model);
model.rxns = strcat(reactionPrefix,convertSBMLID(model.rxns));

%% generate Groups
tmp_group_member_struct= getSBMLDefaultStruct('SBML_GROUPS_MEMBER',sbmlLevel, sbmlVersion,sbmlPackages, sbmlPackageVersions);
tmp_group=getSBMLDefaultStruct('SBML_GROUPS_GROUP',sbmlLevel, sbmlVersion,sbmlPackages, sbmlPackageVersions);
tmp_group.groups_kind = 'partonomy';
tmp_group.sboTerm = 633;
modelSubSystems = getModelSubSystems(model); 
if ~isempty(modelSubSystems)    
    sbmlModel.groups_version = 1;    
    %Build the groups for the group package.
    groupIDs = strcat('group',cellfun(@num2str, num2cell(1:length(modelSubSystems))','UniformOutput',false));    
    for i = 1:length(modelSubSystems)
        cgroup = tmp_group;
        groupMembers = findRxnsFromSubSystem(model,modelSubSystems{i});
        for j = 1:numel(groupMembers)            
            cMember = tmp_group_member_struct;
            cMember.groups_idRef = groupMembers{j};
            if j == 1
                cgroup.groups_member = cMember;
            else
                cgroup.groups_member(j) = cMember;
            end
        end
        cgroup.groups_id = groupIDs{i};
        cgroup.groups_name = modelSubSystems{i};
        if i == 1
            sbmlModel.groups_group = cgroup;
        else
            sbmlModel.groups_group(i) = cgroup;
        end
    end
end

%% Reactions
for i=1:size(model.rxns, 1)
    tmp_rxnID =  model.rxns{i};
    tmp_Rxn.metaid = tmp_rxnID;
    [tmp_Rxn.annotation,rxn_notes] = makeSBMLAnnotationString(model,tmp_Rxn.metaid,'rxn',i);
    tmp_note = emptyChar;
    if ~isempty(rxn_notes)
        for noteid = 1:size(rxn_notes,1)
            tmp_note = [ tmp_note ' <p>' regexprep(rxn_notes{noteid,1},'^rxn','') ':' rxn_notes{noteid,2} '</p>'];
        end
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
            tmp_Sboterm = str2num(regexprep(model.rxnSBOTerms{i},'^SBO:0*([1-9][0-9]*)$','$1'));
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
    if isfield(model, 'rules') %we will create the logic from the rules field.                
        sbml_tmp_grRules= model.rules{i};
        %now, replace all occurences of | by or and & by and
        sbml_tmp_grRules = strrep(sbml_tmp_grRules,'|','or');
        sbml_tmp_grRules = strrep(sbml_tmp_grRules,'&','and');
        %and replace all x([0-9]+) occurences by their corresponding gene
        %ID
        sbml_tmp_grRules = regexprep(sbml_tmp_grRules,'x\(([0-9]+)\)','${getGeneID($1)}');
        tmp_Rxn.fbc_geneProductAssociation.fbc_association.fbc_association=sbml_tmp_grRules;
    end
    %% bounds
    tmp_Rxn.fbc_lowerFluxBound=totalNames{i}; % num2str(model.lb(i));
    tmp_Rxn.fbc_upperFluxBound=totalNames{length(model.lb)+i}; % num2str(model.ub(i));
    
    if i==1
        sbmlModel.reaction=tmp_Rxn;
    else
        sbmlModel.reaction=[sbmlModel.reaction,tmp_Rxn];
    end
  
    
end

%% Set the objective sense of the FBC objective according to the osenseStr in
%the model.
%%%%% multiple objectives
if ~isnumeric(model.c)
    model.c=double(cell2mat(model.c)); % convert the variable type to double
end
if ~all(model.c == 0)
    
    
    objectiveSense = 'maximize';
    
    if isfield(model,'osenseStr') && strcmpi(model.osenseStr,'min')
        objectiveSense = 'minimize';
    end
    
    tmp_fbc_objective=getSBMLDefaultStruct('SBML_FBC_OBJECTIVE',sbmlLevel, sbmlVersion,sbmlPackages, sbmlPackageVersions);
    tmp_fbc_objective.fbc_id = 'obj';
    tmp_fbc_objective.fbc_type = objectiveSense;
    sbmlModel.fbc_activeObjective = 'obj';
    
    tmp_fbc_objective.fbc_fluxObjective=getSBMLDefaultStruct('SBML_FBC_FLUXOBJECTIVE',sbmlLevel, sbmlVersion,sbmlPackages, sbmlPackageVersions);
    
    
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
end



%end

sbmlModel.namespaces=struct('prefix',{'','fbc','groups'},...
    'uri',{'http://www.sbml.org/sbml/level3/version1/core',...
    'http://www.sbml.org/sbml/level3/version1/fbc/version2',...
    'http://www.sbml.org/sbml/level3/version1/groups/version1'});

sbmlModel.fbc_strict=1;

OutputSBML(sbmlModel,fileName,1,0,[1,0]);
end

function sbmlStruct = getSBMLDefaultStruct(field_type, sbmlLevel, sbmlVersion, packages, packageVersions)
fieldData = [getStructureFieldnames(field_type,sbmlLevel,sbmlVersion,packages,packageVersions);getDefaultValues(field_type,sbmlLevel,sbmlVersion,packages,packageVersions)];
fieldData = reshape(fieldData,numel(fieldData),1);
sbmlStruct = struct(fieldData{:});
sbmlStruct = addLevelVersion(sbmlStruct,sbmlLevel,sbmlVersion);
end
