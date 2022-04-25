function model = annotateModel(model, annotateRxns, annotateMets,modelID,modelName,modelAnnotation)
% This function annotates a model with VMH reaction and metabolite
% identifiers.
%
% function model = annotateModel(model, annotateRxns,annotateMets)
%
% INPUT
% model         Model structure
% annotateRxns  default: 1
% annotateMets  default: 1
%
% Optional:
% modelID       ID of model
% modelName     model Name
%
% OUTPUT
% model         Updated model structure
%
% Ines Thiele October 2019

if ~exist('annotateRxns','var')
    annotateRxns = 1;
end

if ~exist('annotateMets','var')
    annotateMets = 1;
end

if exist('modelID','var')
    model.modelID = modelID;
end

if exist('modelID','var')
    model.modelName = modelName;
end
if exist('modelAnnotation','var')
    model.modelAnnotation = modelAnnotation;
end
%% read input files
if annotateRxns == 1
    % load reactions from VMH
    VMH_rxns = tdfread('VMH_Reactions.tsv');
end

if annotateMets == 1
    % load metabolites from VMH
    VMH_mets = tdfread('VMH_Metabolites.tsv');
end
%% reactions
if annotateRxns == 1
    % redefine fields that should be updated
    %model.rxnNames = {};
    %model.rxnNames(1:length(model.rxns),1) = {''};
    model.rxnECNumbers = {};
    model.rxnECNumbers(1:length(model.rxns),1) = {''};
    %model.subSystems = {};
    %model.subSystems(1:length(model.rxns),1) = {''};
    model.rxnMetaNetXID = {};
    model.rxnMetaNetXID(1:length(model.rxns),1) = {''};
    model.rxnKEGGID = {};
    model.rxnKEGGID(1:length(model.rxns),1) = {''};
    model.rxnSBOTerms = {};
    model.rxnSBOTerms(1:length(model.rxns),1) = {''};
    model.rxnSEEDID = {};
    model.rxnSEEDID(1:length(model.rxns),1) = {''};
    
    VMH_rxns2.abbreviation = strcat('_',VMH_rxns.abbreviation);
    [a,remDash] = strtok(model.rxns,'_');
    [remDashBrak,rem2] = strtok(remDash,'['); % remove [
    [remBrak] = strtok(model.rxns,'['); % remove [
    [remDBrak,rem2] = strtok(model.rxns,'_['); % remove [
    for i = 1 : length(VMH_rxns.abbreviation)
        m =[];
        % check for organ in front and [
        tokVMH = strtok(VMH_rxns2.abbreviation(i,:),'['); % remove [
        tokVMH = strtok(tokVMH,' '); % remove space
        m = strmatch(tokVMH,remDash,'exact');
        if isempty(m)
            % no organ in front but [
            tokVMH = strtok(VMH_rxns.abbreviation(i,:),'['); % remove [
            m = strmatch(tokVMH,remBrak,'exact');
            if isempty(m)
                m = strmatch(tokVMH,remDBrak,'exact');
            end
        end
        if ~isempty(m)
            model.rxnECNumbers(m,1) = cellstr(VMH_rxns.ecnumber(i,:));
            model.rxnNames(m,1) = cellstr(VMH_rxns.description(i,:));
            model.subSystems(m,1) = cellstr(regexprep(VMH_rxns.subsystem(i,:),'"',''));
            model.rxnMetaNetXID(m,1) = cellstr(VMH_rxns.metanetx(i,:));
            model.rxnKEGGID(m,1) = cellstr(VMH_rxns.keggId(i,:));
            model.rxnSEEDID(m,1) = cellstr(VMH_rxns.seed(i,:));
            % annotate reaction SBO terms:
            if  ~isempty(strfind(VMH_rxns.abbreviation(i,:),'biomass')) ||  ~isempty(strfind(VMH_rxns.abbreviation(i,:),'Biomass'))
                % biomass reaction
                model.rxnSBOTerms(m,1) = cellstr('SBO:0000629');
                % Exchange reaction
            elseif ~isempty(strmatch('EX_',VMH_rxns.abbreviation(i,:))) ||  ~isempty(strmatch('Ex_',VMH_rxns.abbreviation(i,:)))
                model.rxnSBOTerms(m,1) = cellstr('SBO:0000627');
            elseif ~isempty(strmatch('DM_',VMH_rxns.abbreviation(i,:)))
                model.rxnSBOTerms(m,1) = cellstr('SBO:0000628');
            elseif  ~isempty(strmatch('sink_',VMH_rxns.abbreviation(i,:)))
                model.rxnSBOTerms(m,1) = cellstr('SBO:0000632');
            elseif  ~isempty(strmatch('Transport',regexprep(VMH_rxns.subsystem(i,:),'"','')))
                model.rxnSBOTerms(m,1) = cellstr('SBO:0000185');
            elseif  ~isempty(strmatch('Exchange',VMH_rxns.subsystem(i,:)))
                model.rxnSBOTerms(m,1) = cellstr('SBO:0000628');
            else % metabolicx reaction
                model.rxnSBOTerms(m,1) = cellstr('SBO:0000176');
            end
        end
        
    end
end
% check for biomass reaction separately again in case that the named one
% was not in the vmh file
BM1 = strmatch('biomass',model.rxns);
BM2 = strmatch('Biomass',model.rxns);
BM3 = strmatch('bio',model.rxns);
BM = unique([BM1;BM2;BM3]);
for i = 1 : length(BM)
    model.rxnSBOTerms(BM(i),1) = cellstr('SBO:0000629');
end

Sink = strmatch('sink_',model.rxns);
for i = 1 : length(Sink)
    model.rxnSBOTerms(Sink(i),1) = cellstr('SBO:0000632');
end

% annotate missing transport reactions based on subSystem with SBO term
for i = 1:length(model.rxns)
    if ~isempty(strmatch('Transport',model.subSystems(i)))
        model.rxnSBOTerms(i,1) = cellstr('SBO:0000185');
    elseif ~isempty(find(~cellfun(@isempty,strfind(model.rxns,'EX_'))))
        model.rxnSBOTerms(i,1) = cellstr('SBO:0000628');
    elseif ~isempty(find(~cellfun(@isempty,strfind(model.rxns,'DM_'))))
        model.rxnSBOTerms(i,1) = cellstr('SBO:0000627');
    elseif  ~isempty(strmatch('Demand',model.subSystems(i)))
        model.rxnSBOTerms(i,1) = cellstr('SBO:0000185');
    end
end

%% Metabolites
if annotateMets == 1
    model.metNames= {};
    model.metNames(1:length(model.mets),1) = {''};
    model.metFormulas= {};
    model.metFormulas(1:length(model.mets),1) = {''};
    model.metCharges = [];
    model.metCharges(1:length(model.mets),1) = 0;
    model.metChEBIID={};
    model.metChEBIID(1:length(model.mets),1) = {''};
    model.metHMDBID= {};
    model.metHMDBID(1:length(model.mets),1) = {''};
    model.metInChIString= {};
    model.metInChIString(1:length(model.mets),1) = {''};
    model.metKEGGID= {};
    model.metKEGGID(1:length(model.mets),1) = {''};
    model.metSmiles= {};
    model.metSmiles(1:length(model.mets),1) = {''};
    model.metMetaNetXID= {};
    model.metMetaNetXID(1:length(model.mets),1) = {''};
    model.metPubChemID= {};
    model.metPubChemID(1:length(model.mets),1) = {''};
    model.metBiGGID= {};
    model.metBiGGID(1:length(model.mets),1) = {''};
    model.metBioCycID= {};
    model.metBioCycID(1:length(model.mets),1) = {''};
    model.metSEEDID= {};
    model.metSEEDID(1:length(model.mets),1) = {''};
    model.metSBOTerms= {};
    model.metSBOTerms(1:length(model.mets),1) = {''};
    model.metChemSpider= {};
    model.metChemSpider(1:length(model.mets),1) = {''};
    model.metInchiKey= {};
    model.metInchiKey(1:length(model.mets),1) = {''};
    
    % note that there are a few metabolites that are not present
    [a,rem] = strtok(model.mets,'_');
    [rem,rem2] = strtok(a,'[');
    
    % add _ to Recon3D.mets
    VMH_mets2 = VMH_mets;
    % VMH_mets2.abbreviation = strcat('_',VMH_mets.abbreviation);
    % match both metabolite lists
    [LIA,LOCB] = ismember(rem,VMH_mets2.abbreviation);
    for i = 1 : length(LOCB)
        if LOCB(i) >0 && ~strcmp(a(i),'slack')
            model.metCharges(i,1) = str2num(VMH_mets2.charge(LOCB(i),:));
            model.metFormulas(i,1) = cellstr(VMH_mets2.chargedFormula(LOCB(i),:));
            model.metNames(i,1) =  cellstr(VMH_mets2.fullName(LOCB(i),:));
            if ~isempty(regexprep(VMH_mets2.cheBlId(LOCB(i),:),' ',''))% remove space in string
                model.metChEBIID(i,1) =  cellstr(strcat('CHEBI:',num2str(VMH_mets2.cheBlId(LOCB(i),:))));
            end
            model.metHMDBID(i,1) =  cellstr(VMH_mets2.hmdb(LOCB(i),:));
            model.metInChIString(i,1) =  cellstr(regexprep(VMH_mets2.inchiString(LOCB(i),:),'"',''));
            model.metKEGGID(i,1) =  cellstr(VMH_mets2.keggId(LOCB(i),:));
            model.metSmiles(i,1) =  cellstr(VMH_mets2.smile(LOCB(i),:));
            model.metPubChemID(i,1) =  cellstr(num2str(VMH_mets2.pubChemId(LOCB(i),:)));
            model.metMetaNetXID(i,1) =  cellstr(VMH_mets2.metanetx(LOCB(i),:));
            model.metBiGGID(i,1) =  cellstr(VMH_mets2.biggId(LOCB(i),:));
            model.metBioCycID(i,1) =  cellstr(VMH_mets2.biocyc(LOCB(i),:));
            model.metSEEDID(i,1) =  cellstr(VMH_mets2.seed(LOCB(i),:));
            model.metSBOTerms(i,1) =  cellstr('SBO:0000247'); % simple molecule
            if ~isempty(VMH_mets2.chemspider(LOCB(i),:)) %&& ~isnan(VMH_mets2.chemspider(LOCB(i),:))
                model.metChemSpider(i,1) =  cellstr(num2str(VMH_mets2.chemspider(LOCB(i),:)));
            end
            model.metInchiKey(i,1) =  cellstr(VMH_mets2.inchiKey(LOCB(i),:));
        end
    end
    % catch also those metabolites that have no organ_ in front of it
    [rem,rem2] = strtok(model.mets,'[');
    
    [LIA,LOCBa] = ismember(rem,VMH_mets.abbreviation);
    for i = 1 : length(LOCBa)
        if LOCBa(i) >0 && ~strcmp(a(i),'slack')
            model.metCharges(i,1) = str2num(VMH_mets2.charge(LOCBa(i),:));
            model.metFormulas(i,1) = cellstr(VMH_mets2.chargedFormula(LOCBa(i),:));
            model.metNames(i,1) =  cellstr(VMH_mets2.fullName(LOCBa(i),:));
            if ~isempty(regexprep(VMH_mets2.cheBlId(LOCBa(i),:),' ',''))% remove space in string
                model.metChEBIID(i,1) =  cellstr(strcat('CHEBI:',num2str(VMH_mets2.cheBlId(LOCBa(i),:))));
            end
            model.metHMDBID(i,1) =  cellstr(VMH_mets2.hmdb(LOCBa(i),:));
            model.metInChIString(i,1) =  cellstr(regexprep(VMH_mets2.inchiString(LOCBa(i),:),'"',''));
            model.metKEGGID(i,1) =  cellstr(VMH_mets2.keggId(LOCBa(i),:));
            model.metSmiles(i,1) =  cellstr(VMH_mets2.smile(LOCBa(i),:));
            model.metPubChemID(i,1) =  cellstr(num2str(VMH_mets2.pubChemId(LOCBa(i),:)));
            model.metMetaNetXID(i,1) =  cellstr(VMH_mets2.metanetx(LOCBa(i),:));
            model.metBiGGID(i,1) =  cellstr(VMH_mets2.biggId(LOCBa(i),:));
            model.metBioCycID(i,1) =  cellstr(VMH_mets2.biocyc(LOCBa(i),:));
            model.metSEEDID(i,1) =  cellstr(VMH_mets2.seed(LOCBa(i),:));
            model.metSBOTerms(i,1) =  cellstr('SBO:0000247'); % simple molecule
            if ~isempty(VMH_mets2.chemspider(LOCBa(i),:))% && ~isnan(VMH_mets2.chemspider(LOCBa(i),:))
                model.metChemSpider(i,1) =  cellstr(num2str(VMH_mets2.chemspider(LOCBa(i),:)));
            end
            model.metInchiKey(i,1) =  cellstr(VMH_mets2.inchiKey(LOCBa(i),:));
        end
    end
end
