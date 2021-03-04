function MatricesSUX =generateSUXComp(model, dictionary, KEGGFilename, KEGGBlackList, listCompartments,KEGGMatrixLoad)
% Creates the matrices for gap filling for compartmentalized metabolic models (`S`) such
% that the universal database (`U`, e.g., KEGG) is placed in each compartment
% specified and reversible transport reactions (`X`) are added for each compound present in
% `U` and `S`, between the compartment and the cytosol. Additionally, exchange
% reactions are added for each metabolite in the extracellular space.
%
% USAGE:
%
%    MatricesSUX =generateSUXComp(model, dictionary, KEGGFilename, KEGGBlackList, listCompartments)
%
% INPUTS:
%    model:               Model structure
%    dictionary:          List of universal database IDs and their counterpart in the model (e.g.,
%                         `KEGG_dictionary.xls`)
%    KEGGFilename:        File name containing the universal database (e.g., KEGG - `reaction.lst`)
%    KEGGBlackList:       List of excluded reactions from the universal database
%                         (e.g., `KEGG`)
%    listCompartments:    List of intracellular compartments in the model
%                         (optional input, default compartments to be considered: '[c]' ,'[m]', '[l]', '[g]', '[r]', '[x]', '[n]')
%    KEGGMatrixLoad       load precomputed KEGG matrix (default: 0)
% OUTPUT:
%    MatricesSUX:         SUX matrix
%
% Based on `generateSUX.m` but updated and expanded for compartmentalized
% gap filling efforts.
%
% .. Author: - Ines Thiele, June 2013, http://thielelab.eu
% - Ines Thiele, Jan 2021, added the option to preload KEGG matrix and
% KeggExchangeRxnMatrix, if multiple reconstructions will be tested this is
% faster

if ~exist('KEGGBlackList', 'var')
    KEGGBlackList = {};
end
if ~exist('KEGGFilename', 'var')
    KEGGFilename = 'reaction.lst';
end

if ~exist('listCompartments', 'var')
    listCompartments = {'[c]','[m]','[l]','[g]','[r]','[x]','[n]'}';
end

% create KEGG Matrix - U
if ~exist('KEGGMatrixLoad', 'var')
    KEGGMatrixLoad = 1;
end
if KEGGMatrixLoad
    load KEGGMatrix
else
    KEGG = createUniversalReactionModel2(KEGGFilename, KEGGBlackList);
    KEGG = transformKEGG2Model(KEGG,dictionary);
    KEGG.RxnSubsystem = KEGG.subSystems;
    save KEGGMatrix KEGG
end
% checks if model.mets has () or [] for compartment, or adds cytosol to
% compounds if no compartment is specified
model = CheckMetName(model);
try
    model.RxnSubsystem = model.subSystems;
catch
    model.RxnSubsystem = {};
end

% merge model with KEGG reaction list for each defined compartment
modelExpanded = model;
if KEGGMatrixLoad
    load KeggExchangeRxnM
else
    KEGGOri = KEGG;
    for i = 1 : length(listCompartments)
        KEGGComp = KEGGOri;
        KEGGComp.mets = regexprep(KEGGComp.mets,'\[c\]',listCompartments{i});
        
        % Try changing the reaction IDs so that there is no ambiguity between
        % different compartments for each reaction
        compartmentID = regexprep(listCompartments{i},'[\[\]]','');
        if ~strcmp(compartmentID,'c')
            KEGGComp.rxns = strcat(KEGGComp.rxns,'_',compartmentID);
        end
        
        [KEGG] = mergeTwoModels(KEGG,KEGGComp,1,0);
    end
    %clear  KEGGComp KEGG;
    % create U and X part - for all compartments
    KeggExchangeRxnMatrix = createXMatrix2(KEGG.mets,1,listCompartments);
    if isfield(KeggExchangeRxnMatrix,'subSystems')
        KeggExchangeRxnMatrix.RxnSubsystem = KeggExchangeRxnMatrix.subSystems;
    end
    save KeggExchangeRxnM KeggExchangeRxnMatrix
end
% up to here it is always the same.
modelExchangeRxnMatrix = createXMatrix2(modelExpanded.mets,1,listCompartments);


[MatricesSUX1] = mergeTwoModels(modelExpanded,KEGG,1,0);
[MatricesSUX2] = mergeTwoModels(MatricesSUX1,modelExchangeRxnMatrix,1,0);
[MatricesSUX] = mergeTwoModels(MatricesSUX2,KeggExchangeRxnMatrix,1,0);
if length(MatricesSUX.genes) > 0
    MatricesSUX.rxnGeneMat(length(MatricesSUX.rxns),length(MatricesSUX.genes))=0;
    MatricesSUX.rxnGeneMat = sparse(MatricesSUX.rxnGeneMat);
else
    MatricesSUX.rxnGeneMat = zeros(length(MatricesSUX.rxns),0);
end

% MatrixPart indicates in which area of MatricesSUX the model reactions,
% kegg reactions, and exchange/transport reactions are located (ie. 1 -
% model, 2 - kegg, 3 - X)
MatricesSUX.MatrixPart(1:length(modelExpanded.rxns),1)=1; % model reactions
MatricesSUX.MatrixPart(length(MatricesSUX.MatrixPart)+1:length(KEGG.rxns),1)=2;%KEGG DB reactions
MatricesSUX.MatrixPart(length(MatricesSUX.MatrixPart)+1:length(MatricesSUX.rxns),1)=3; %exchange and transport reactions

clear model*;

function model = CheckMetName(model)
% checks if model.mets has () or [] for compartment
if ~isempty(strfind(model.mets,'(c)')) ||~isempty(strfind(model.mets,'(e)'))
    for i = 1 :length(model.mets)
        model.mets{i} = regexprep(model.mets{i},'(','[');
        model.mets{i} = regexprep(model.mets{i},')',']');
    end
end
% fixes metabolites names if no compartment has been added to metabolites.
% It assumes that the metabolites without compartment are in the cytosol
for i = 1 :length(model.mets)
    if  isempty(regexp(model.mets{i},'\(\w\)')) && isempty(regexp(model.mets{i},'\[\w\]'))
        model.mets{i} = strcat(model.mets{i},'[c]');
    end
end
