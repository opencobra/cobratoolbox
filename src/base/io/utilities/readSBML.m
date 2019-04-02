function [model,modelSBML] = readSBML(fileName,defaultBound)
% Reads in a SBML format model as a COBRA matlab structure
%
% USAGE:
%
%    model = readSBML(fileName, defaultBound)
%
% INPUTS:
%    fileName:          File name for file to read in
%
% OPTIONAL INPUTS:
%    defaultBound:      Maximum bound for model (Default = 1000)
%
% OUTPUT:
%    model:             COBRA model structure
%
% .. Authors:
%       - Markus Herrgard 1/25/08
%       - Ines Thiele 01/27/2010 - I added new field to be read-in from SBML file
%       - Longfei Mao 23/09/15 - Added support for the FBCv2 format 
%       - Thomas Pfau May 2017 - Updated to libsbml 5.15

currentDir = pwd;
[folder,name,extension] = fileparts(fileName);
if ~isempty(folder)
    cd(folder);
end
fileDir = pwd;
cd(currentDir);
fileName = [fileDir filesep name extension];
modelSBML = TranslateSBML(fileName,0,0,[1 1]);
model = struct();
%TODO: Fix Model Annotation/Notes IO.
if ~isempty(modelSBML.annotation)
    model.modelAnnotation = modelSBML.annotation;
end
if ~isempty(modelSBML.notes)
    model.modelNotes = modelSBML.notes;
end
modelVersion.SBML_level = modelSBML.SBML_level;
modelVersion.SBML_version = modelSBML.SBML_version;
if isfield(modelSBML,'fbc_version')
    modelVersion.fbc_version = modelSBML.fbc_version;
end
model.modelVersion = modelVersion;

%Recover the modelName
model.modelID = regexprep(convertSBMLID(modelSBML.id,false),'^M_','');
if strcmp(model.modelID,'COBRAModel')
    %This is the default, and indicates, that no name was originally
    %present
    model = rmfield(model,'modelID');
end
%Recover the name
if ~strcmp(modelSBML.name,'Model Exported from COBRA Toolbox') && ~isempty(modelSBML.name)
    model.modelName = modelSBML.name;
end

    

%% first look for defined compartments (this can be aweful if someone uses

%one compartment but different ids..
model.comps = columnVector({modelSBML.compartment.id});
model.compNames = columnVector({modelSBML.compartment.name});
emptyComps = cellfun(@isempty, model.compNames);
model.compNames(emptyComps) = model.comps(emptyComps);
if isfield(modelSBML.compartment,'cvterms')
    %Extract the cvterms, we will not individually parse annotation
    %strings that do not adhere to miriam style annotations.
    cvterms = [modelSBML.compartment.cvterms];
    if isstruct(cvterms)
        cvterms = {modelSBML.compartment.cvterms};
        [databases,identifiers,qualifiers] = cellfun(@parseCVTerms, cvterms,'UniformOutput',0);
        model = mapAnnotationsToFields(model,databases,identifiers,qualifiers,'comp');
    end
end

%% Then, we have to set up the metabolites.
%We are only interested in non-boundary metabolites. (hopefully marked as
%boundary) %we'll have to do a sanityCheck later to potentially remove _b
%metabolites...
sbmlSpecies = modelSBML.species(~[modelSBML.species.boundaryCondition]);

%Lets extract the important fields.
sbmlids = {sbmlSpecies.id};
[~,~,model.metFormulas,~,~,model.metNotes,~,model.metCharges] = cellfun(@parseSBMLNotesField , {sbmlSpecies.notes}','UniformOutput',0);
%The charges are numbers
model.metCharges = cell2mat(model.metCharges);
%Now, for V2 compatability, check the charge field.
%Adjust Charges and Formulas
if modelSBML.SBML_level == 2
    if isfield(sbmlSpecies,'charge')
        %set charges override the notes field.
        charges = double([sbmlSpecies.charge]);
        setCharges =  logical([sbmlSpecies.isSetCharge]);
        model.metCharges(setCharges) = charges(setCharges);
    end
else
    if isfield(modelSBML,'fbc_version') && modelSBML.fbc_version == 2; %This might have to be adjusted to >2 if the fields stay...
        %Update Charges if set in FBC
        charges = [sbmlSpecies.fbc_charge];
        setCharges =  logical([sbmlSpecies.isSetfbc_charge]);
        model.metCharges(setCharges) = charges(setCharges);
        %Update Formulas, if present in FBC.
        formulas = extractfield(sbmlSpecies, 'fbc_chemicalFormula');
        setFormulas = ~cellfun(@isempty, formulas);
        model.metFormulas(setFormulas) = formulas(setFormulas);
    end   
end

%This is independent on the SBML version. 
if isfield(sbmlSpecies,'cvterms')
    %Extract the cvterms, we will not individually parse annotation
    %strings that do not adhere to miriam style annotations.
    cvterms = [sbmlSpecies.cvterms];
    if isstruct(cvterms)
        %we need a cell array, but we need to be sure, that its not
        %empty, i.e. that it actually is the struct we are looking for.
        cvterms = {sbmlSpecies.cvterms};
        [databases,identifiers,qualifiers] = cellfun(@parseCVTerms, cvterms,'UniformOutput',0);
        model = mapAnnotationsToFields(model,databases,identifiers,qualifiers,'met');
    end
end

model.mets = columnVector(sbmlids);
model.metNames = columnVector({sbmlSpecies.name});
if isfield(sbmlSpecies,'sboTerm')
    SBOExists = false(size(model.mets));
    if isfield(model,'metSBOTerms')
        SBOExists = ~cellfun(@isempty, model.metSBOTerms);        
    else
        model.metSBOTerms = repmat({''},size(model.mets));
    end
    SBOTerms = columnVector({sbmlSpecies.sboTerm});
    SBOToUse = ~SBOExists & ~cellfun(@(x) x == -1, SBOTerms);    
    try
        model.metSBOTerms(SBOToUse) = cellfun(@(x) strcat('SBO:',pad(num2str(x),7,'left','0')),SBOTerms(SBOToUse),'UniformOutput',0);    
    catch
        %This fails if the version is prior to 2016b, since pad was only
        %introduced at that time.
        %So, we have to use repmat 
        model.metSBOTerms(SBOToUse) = cellfun(@(x) strcat('SBO:', repmat('0',1,7-length(num2str(x))),num2str(x) ),SBOTerms(SBOToUse),'UniformOutput',0);
    end                
end
emptyNames = cellfun(@isempty, model.metNames);
model.metNames(emptyNames) = model.mets(emptyNames);
model.b = zeros(numel(model.mets),1);
model.csense = repmat('E',numel(model.mets),1);
model.metFormulas = columnVector( model.metFormulas);
model.metCharges = columnVector( model.metCharges);
model.metNotes = columnVector( model.metNotes);
metComps = columnVector({sbmlSpecies.compartment});

%% Now, this is the metabolites done (except for name polishing and stuff,
%which we will do in the very end - as this otherwise interferes with the
%labels..

%% We now have to set up the genes/reactions. If we have fbc-genes
%We ignore the GENE_ASSOCIATION fields.
if(isfield(modelSBML,'fbc_geneProduct') && ~isempty(modelSBML.fbc_geneProduct))
    %there is an fbc-gene field, and its not empty, so lets parse it.
    %A gene product commonly refers to the enzyme
    %So, we assume the following: if a GeneProduct "isEncodedBy", than this
    %is a gene annotation. If it is an is, this would be a protein
    %annotation (and thus not a gene id).
    proteinFieldsFromGeneProducts = struct();
    if isfield(modelSBML.fbc_geneProduct,'cvterms')
        cvterms = [modelSBML.fbc_geneProduct.cvterms];
        if isstruct(cvterms)
            %If cvterms is not a cell, there is no data in cvterms, so we skip
            %the annotation
            cvterms = {modelSBML.fbc_geneProduct.cvterms};
            [databases,identifiers,qualifiers] = cellfun(@parseCVTerms, cvterms,'UniformOutput',0);
            model = mapAnnotationsToFields(model,databases,identifiers,qualifiers,'gene',{'isEncodedBy','encoder'},true);
            %TODO: We currently don't use Protein information. And we will miss, if
            %the geneProduct is incorrectly annotated as protein (i.e. anything but the isEncodedBy relation).
            proteinFieldsFromGeneProducts = mapAnnotationsToFields(struct(),databases,identifiers,qualifiers,'protein',{'isEncodedBy','encoder'});
            %For now - This is potentially going to change in the future:
            %We will use the IDs as geneIDs. We will use Labels as geneNames and we
            %will use name as "protein" ids.
            %For now: There is a 1<->1 link between protein and gene, and anything else is discounted.
            %Proteins will only be generated, if there is at least one proteinField
            %i.e. one "is" relation or at least one fbc geneproduct with a non empty name
        end
    end
    proteinNames = {modelSBML.fbc_geneProduct.fbc_name};
    emptyProts = cellfun(@isempty, proteinNames);
    if ~isempty(proteinFieldsFromGeneProducts) || all(emptyProts)
        %We assign them only if they are all undefined or if there is other
        %data.
        emptyProteinNames = strcat('COBRAProtein',cellfun(@num2str, num2cell(1:sum(emptyProts)),'UniformOutput',0));
        proteinNames(emptyProts) = emptyProteinNames;
        model.proteins = columnVector(proteinNames);
        proteinFields = fieldnames(proteinFieldsFromGeneProducts);
        for i = 1:length(proteinFields)
            model.(proteinFields{i}) = proteinFieldsFromGeneProducts.(proteinFields{i});
        end
    end
    model.genes = columnVector({modelSBML.fbc_geneProduct.fbc_id});
    model.geneNames = columnVector({modelSBML.fbc_geneProduct.fbc_label});
else
    model.genes = {};
end

%% So lets start the reactions.
%if we don't have fbc_genes, we will have to do this during the reaction
%parsing...
%so, now set up the reactions.
sbmlReactions = modelSBML.reaction;
%First, extract the notes field.
[model.subSystems,grRule,~,model.rxnConfidenceScores,rxnReferences,model.rxnNotes,rxnECNumbers,~] = cellfun(@parseSBMLNotesField , {sbmlReactions.notes}','UniformOutput',0);
model.rxnConfidenceScores = columnVector(cell2mat(model.rxnConfidenceScores));

%Then set up the S Matrix.
substrates = columnVector({sbmlReactions.reactant});
products = columnVector({sbmlReactions.product});
S = cellfun(@(reacs,prods) addSBMLReaction(reacs,prods,model.mets),substrates, products,'UniformOutput',0);

model.S = cell2mat(S)';
%And extract Names/ids
model.rxns = columnVector({sbmlReactions.id});
model.rxnNames = columnVector({sbmlReactions.name});
emptyNames = cellfun(@isempty, model.rxnNames);
model.rxnNames(emptyNames) = model.rxns(emptyNames);

%% Extract Annotations.
if isfield(sbmlReactions,'cvterms')
    cvterms = [sbmlReactions.cvterms];
    if isstruct(cvterms)
        cvterms = {sbmlReactions.cvterms};
        [databases,identifiers,qualifiers] = cellfun(@parseCVTerms, cvterms,'UniformOutput',0);
        model = mapAnnotationsToFields(model,databases,identifiers,qualifiers,'rxn');
    end
end
%Now, set up the GPR Rules (if this is an fbc model we will use FBC)
if isfield(sbmlReactions,'fbc_geneProductAssociation')
    gprAssoc = {sbmlReactions.fbc_geneProductAssociation};
    fbc_grRules = cellfun(@(x) getFBCAssoc(x) , gprAssoc,'UniformOutput',0);
    model.rules = cellfun(@(x) parseGPR(x,model.genes),fbc_grRules','UniformOutput',0);
else
    %otherwise use the grRules extracted.
    model.rules = cell(numel(model.rxns),1);
    model.rules(:) = {''};
    if~isfield(model,'genes')
        model.genes = {};
    end
    for i = 1:numel(grRule)
        [rule,cgenes] = parseGPR(grRule{i},model.genes);
        model.genes = cgenes;
        model.rules{i} = rule;
        model.genes = columnVector(model.genes);
    end
end

%Set up the SBO Term

if isfield(sbmlReactions,'sboTerm')
    SBOExists = false(size(model.rxns));
    if isfield(model,'rxnSBOTerms')
        SBOExists = ~cellfun(@isempty, model.rxnSBOTerms);        
    else
        model.rxnSBOTerms = repmat({''},size(model.rxns));
    end
    SBOTerms = columnVector({sbmlReactions.sboTerm});
    SBOToUse = ~SBOExists & ~cellfun(@(x) x == -1, SBOTerms);        
    try
        model.rxnSBOTerms(SBOToUse) = cellfun(@(x) strcat('SBO:',pad(num2str(x),7,'left','0')),SBOTerms(SBOToUse),'UniformOutput',0);    
    catch
        %This fails if the version is prior to 2016b, since pad was only
        %introduced at that time.
        %So, we have to use repmat 
        model.rxnSBOTerms(SBOToUse) = cellfun(@(x) strcat('SBO:', repmat('0',1,7-length(num2str(x))),num2str(x) ),SBOTerms(SBOToUse),'UniformOutput',0);
    end  
end

%% Finally, parse the Flux constraints.
%This can either be in fbc (and if it is, we use that) or it can be in
if isfield(modelSBML,'fbc_version') && modelSBML.fbc_version == 2
    %get the parameters (needed for fluxes), we can extract the data from
    %the fluxes.
    parameterids = {modelSBML.parameter.id};
    paramvalues = [modelSBML.parameter.value];
    lbvals = {sbmlReactions.fbc_lowerFluxBound};
    ubvals = {sbmlReactions.fbc_upperFluxBound};
    [pres,pos] = ismember(ubvals,parameterids);
    model.ub = defaultBound*ones(numel(model.rxns),1);
    model.ub(pres) = double(paramvalues(pos(pres))); %Conversion to double
    model.lb = -defaultBound*ones(numel(model.rxns),1).*double([sbmlReactions.reversible]');
    [pres,pos] = ismember(lbvals,parameterids);
    model.lb(pres) = double(paramvalues(pos(pres)));%Conversion to double
else
    %if there is a kineticLaw field, we might have old cobra style
    %annotations.
    if isfield(sbmlReactions,'kineticLaw')
        kineticLaws = {sbmlReactions.kineticLaw};
        %if there are none use defautlts.
        if all(cellfun(@isempty, kineticLaws))
            model.ub = defaultBound*ones(numel(model.rxns),1);
            model.lb = -defaultBound*ones(numel(model.rxns),1).*double([sbmlReactions.reversible]');
            model.c = zeros(numel(model.rxns),1);
        else
            %or parse the annotations.
            [lb,ub,obj] = cellfun(@(x,y) extractBounds(x,defaultBound,y),kineticLaws, num2cell([sbmlReactions.reversible]));
            model.lb = columnVector(lb);
            model.ub = columnVector(ub);
            model.c = columnVector(obj);
        end
    else
        model.ub = defaultBound*ones(numel(model.rxns),1);
        model.lb = -defaultBound*ones(numel(model.rxns),1).*double([sbmlReactions.reversible]');
        model.c = zeros(numel(model.rxns),1);
    end
end



%% Set up the objective. The default is maximisation.
model.osenseStr = 'max';
if isfield(modelSBML,'fbc_objective')
    %We only support the first one we find
    if ~isempty(modelSBML.fbc_objective)
        osenseStr = modelSBML.fbc_objective(1).fbc_type;
        model.osenseStr = lower(osenseStr(1:3)); %should be either min or max
        objReac = {modelSBML.fbc_objective(1).fbc_fluxObjective.fbc_reaction};
        coef = 1;
        coefsset = [modelSBML.fbc_objective(1).fbc_fluxObjective.isSetfbc_coefficient];        
        if all(coefsset)
            coef = [modelSBML.fbc_objective(1).fbc_fluxObjective.fbc_coefficient];
        end
        [reacpres,reacpos] = ismember(model.rxns,objReac);
        model.c = zeros(numel(model.rxns),1);
        model.c(reacpres) = double(coef(reacpos(reacpres)));
    end
end



%% Merge fields. This mainly concerns rxnReferences and rxnECNumbers
if isfield(model,'rxnECNumbers')
    emptyECs = cellfun(@isempty, model.rxnECNumbers);
    model.rxnECNumbers(emptyECs) = rxnECNumbers(emptyECs);
else
    if ~all(isempty(rxnECNumbers))
        model.rxnECNumbers = columnVector(rxnECNumbers);
    end
end
if isfield(model,'rxnReferences')
    emptyRefs = cellfun(@isempty, model.rxnReferences);
    model.rxnReferences(emptyRefs) = rxnReferences(emptyRefs);
else
    if ~all(isempty(rxnReferences))
        model.rxnReferences = columnVector(rxnReferences);
    end
end

if isfield(modelSBML,'groups_version') && modelSBML.groups_version == 1 
    %There is a groups field, we will override existing information for all
    %elements in groups if its non empty.
    if isfield(modelSBML,'groups_group') && ~isempty(modelSBML.groups_group)
        group_ids = {modelSBML.groups_group.groups_id};
        group_names = {modelSBML.groups_group.groups_name};
        group_member_set = {modelSBML.groups_group.groups_member};
        group_members = cellfun(@(x) {x.groups_idRef},group_member_set,'Uniformoutput',false);
        groups = cellfun(@(x) getMembersForGroup(x,group_ids,group_members),group_ids,'UniformOutput',false);
        %For now, we only assign groups to reactions.
        for i = 1:size(group_names,2)
            model = addSubSystemsToReactions(model,model.rxns(ismember(model.rxns,groups{i})),group_names{i});
        end
    end
end
    

%% Some finishing touches (e.g. check for naming schemes, and compartment
%ids.
%The first thing we will do is "correct" the Compartments, i.e. if they all
%start with C_, we assume, that they are created by "us"
if all(~cellfun(@isempty , regexp(model.comps,'^C_')))
    %And check, that the metabolites are not using these ids.
    model.comps = regexprep(model.comps,'^C_','');
    model.mets = regexprep(model.mets,'\[C_(.*)\]$','[$1]'); %Replace the C_ in the metabolite ids as well.
end
%now, check whether all metabolites start with an M_
if all(~cellfun(@isempty, regexp(model.mets,'^M_')))
    model.mets = regexprep(model.mets,'^M_','');
end
%Also update Reaction IDs.
if all(~cellfun(@isempty, regexp(model.rxns,'^R_')))
    model.rxns= regexprep(model.rxns,'^R_','');
end
%And Gene IDs
if all(~cellfun(@isempty, regexp(model.genes,'^G_')))
    model.genes= regexprep(model.genes,'^G_','');
end

%And convert the IDs from SBML.
model.mets = cellfun(@(x) convertSBMLID(x,false),model.mets,'UniformOutput',0);
model.rxns = cellfun(@(x) convertSBMLID(x,false),model.rxns,'UniformOutput',0);
model.comps = cellfun(@(x) convertSBMLID(x,false),model.comps,'UniformOutput',0);
model.genes = cellfun(@(x) convertSBMLID(x,false),model.genes,'UniformOutput',0);
%Stay consistent in between IO. so we always generate geneNames, and
%proteins.
if ~isfield(model,'geneNames')
    model.geneNames = model.genes;
end

if ~isfield(model,'proteins')
    model.proteins = strcat(repmat({'COBRAProtein'},numel(model.genes),1),cellfun(@num2str, num2cell(1:numel(model.genes))','UniformOutput',0));
else
    model.proteins = cellfun(@(x) convertSBMLID(x,false),model.proteins,'UniformOutput',0);
end

if isfield(model, 'proteins')
    model.proteins = cellfun(@(x) convertSBMLID(x,false),model.proteins,'UniformOutput',0);
end


%Finally, assign proper compartment ids.
model = polishCompartments(model,metComps);

%% And clean up empty fields
modelFields = fieldnames(model);
%We will keep a set of default fields. 
for i = 1:numel(modelFields)
    if iscell(model.(modelFields{i})) && all(cellfun(@isempty , model.(modelFields{i})))
        model = rmfield(model,modelFields{i});
        continue;
    end
    %IF a field is full of NaN this also indicates no information, so it
    %can be removed.
    if isnumeric(model.(modelFields{i})) && all(all(isnan(model.(modelFields{i}))))
        model = rmfield(model,modelFields{i});
        continue;
    end
end


end



function model = polishCompartments(model,metComps)

if all(~cellfun(@isempty, regexp(model.mets,'_[a-z]$')))
    %Ok, all metabolites end on a single id, we assume this to be
    %metabolite IDs.
    %replace them all
    model.mets = cellfun(@(id,compID) regexprep(id,'_[a-z]$',['[' compID ']']),model.mets,metComps,'UniformOutput',0);
else
    %if everything has its id at the end. also replace it.
    if all(~cellfun(@(met,comp) isempty(regexp(met,['_' regexptranslate('escape',comp) '$'])),model.mets,metComps))
        model.mets = cellfun(@(id,compID) regexprep(id,['_' regexptranslate('escape',compID) '$'],['[' compID ']']),model.mets,metComps,'UniformOutput',0);
    else
        %Lets check if there is already an id in here:
        if ~all(~cellfun(@isempty, regexp(model.mets,'\[[^\[]*\]$')))
            % if not, append the compartmentID
            model.mets = strcat(model.mets,'[',convertSBMLID(metComps,false),']');
        end
        %Otherwise we have a set up model.
    end        
end
model.metComps = metComps;

end


function [lb,ub,obj_coef] = extractBounds(kineticLawStruct,defaultBound, reversibility)
defaults = double([-defaultBound*reversibility,defaultBound,0]);
if isfield(kineticLawStruct,'parameter')
    %these are the parameters that we extract.
    validnames = {'LOWER_BOUND','UPPER_BOUND','OBJECTIVE_COEFFICIENT'};
    paramNames = {kineticLawStruct.parameter.id};
    paramvals = [kineticLawStruct.parameter.value];
    [pres,pos] = ismember(validnames,paramNames);
    defaults(pres) = double(paramvals(pos(pres))); %Convert to double.
end
[lb,ub,obj_coef] = deal(defaults(1),defaults(2),defaults(3));
end

function stoichiometry = addSBMLReaction(reacs,prods,mets)
%Extract the stoichiometry given the reactant structs, the product
%structs and the available metabolites.
stoichiometry = zeros(1,size(mets,1));
if ~isempty(reacs)
    reacids = {reacs.species};
    reacstoichs = [reacs.stoichiometry];
    [pres,pos] = ismember(mets,reacids);    
    stoichiometry(pres) = -reacstoichs(pos(pres));
end
if ~isempty(prods)
    prodids = {prods.species};
    prodstoichs = [prods.stoichiometry];    
    [pres,pos] = ismember(mets,prodids);    
    stoichiometry(pres) = prodstoichs(pos(pres));    
end
end

function rule = getFBCAssoc(fbc_gprAssoc)
%extract the fbc_associations fbc_association field or return an empty
%string
if isempty(fbc_gprAssoc) || isempty(fbc_gprAssoc.fbc_association)
    rule = '';
    return
end
rule = fbc_gprAssoc.fbc_association.fbc_association;
end

function field = extractfield(startstruct,fieldname)

if ~isfield(startstruct,fieldname)
    error('Field %s does not exist',fieldname)
end
field = {startstruct.(fieldname)};
end


function members = getMembersForGroup(groupID, groupIDs, groupMembers, groupsDone)
%Get all members from a list of groups, which can reference themselves.
if ~exist('groupsDone','var')
    groupsDone = {groupID};    
end
currentMembers = groupMembers{ismember(groupIDs,groupID)};
groupsInMembers = ismember(groupIDs,currentMembers);
currentGroups = setdiff(groupIDs(groupsInMembers),groupsDone);
groupsDone = union(currentGroups,groupsDone);

members = cellfun(@(x) getMembersForGroup(x,groupIDs,groupMembers,groupsDone),currentGroups,'UniformOutput',false);

members = setdiff(union(currentMembers,vertcat(members{:})),groupsDone);

end


