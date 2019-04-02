function MatricesSUX = generateSUXMatrix(model, dictionary, KEGGFilename, KEGGBlackList, compartment, addModel)
% Creates the matrices for matlab smiley -- > combines `S`, `U`, (`KEGG`), `X` (transport)
%
% USAGE:
%
%    MatricesSUX = generateSUXMatrix(model, dictionary, KEGGFilename, KEGGBlackList, compartment, addModel)
%
% INPUTS:
%    model:          model structure
%    dictionary:     disctionary used to transform KEGG model
%
% OPTIONAL INPUTS:
%    KEGGID:         List of KEGGIDs for compounds
%    KEGGFilename:   File name containing KEGG database
%    KEGGBlackList:  Contains black list, default = {}
%    compartment:    [c] --> transport from cytoplasm [c] to extracellulat space
%                    [e] (default), [p] creates transport from [c] to [p] and from [p] to [c],
%                    if '' - no exchange reactions/transport will be added to the matrix.
%    addModel:       model structure, containing an additional matrix or model
%                    that should be combined with SUX matrix.% Note that the naming of metabolites in this matrix has to be identical to
%                    model naming. Also, the list should be unique.
%
%  .. Author: - IT, 11-10-07

if nargin < 6
    addModel = '';
end

if nargin < 5
    compartment = '[c]';
end
if nargin < 4
    KEGGBlackList = {};
end
if nargin < 3
    KEGGFilename = '11-20-08-KEGG-reaction.lst';
end

% checks if model.mets has () or [] for compartment, or adds cytosol to
% compounds if no compartment is specified
model = CheckMetName(model);


% create KEGG Matrix - U
KEGG = createUniversalReactionModel(KEGGFilename, KEGGBlackList);
KEGG = transformKEGG2Model(KEGG,dictionary);


%merge all 3 matrixes
% 1. S with U

model.RxnSubsystem = model.subSystems;
KEGG.RxnSubsystem = KEGG.subSystems;
[model_SU] = mergeTwoModels(model,KEGG,1);

% Adds an additional matrix if given as input
% Note that the naming of metabolites in this matrix has to be identical to
% model naming. Also, the list should be unique.
if isstruct(addModel)
    addModel = CheckMetName(addModel);
    [model_SU] = mergeTwoModels(model_SU,addModel,1);
end

if ~isempty(compartment)
    ExchangeRxnMatrix = createXMatrix(model_SU.mets,1,compartment);
    % 2. SU with X
    ExchangeRxnMatrix.RxnSubsystem = ExchangeRxnMatrix.subSystems;
    %model_SU.RxnSubsystem = model_SU.subSystems;
    [MatricesSUX] = mergeTwoModels(model_SU,ExchangeRxnMatrix,1);
    % creates a vector assigning the origin of the reactions to the parentfprintf(1,'Converting merged model into an irreversible model...');
else
    MatricesSUX=model_SU;
end

MatricesSUX.rxnGeneMat(length(MatricesSUX.rxns),length(MatricesSUX.genes))=0;
MatricesSUX.rxnGeneMat = sparse(MatricesSUX.rxnGeneMat);
MatricesSUX = convertToIrreversible(MatricesSUX,'orderReactions',true);

% MatrixPart indicates in which area of MatricesSUX the model reactions,
% kegg reactions, and exchange/transport reactions are located (ie. 1 -
% model, 2 - kegg, 3 - X)

tmp=find(model.lb < 0);
MatricesSUX.MatrixPart(1:length(model.rxns)+length(tmp),1)=1; % model reactions
MatricesSUX.MatrixPart(length(MatricesSUX.MatrixPart)+1:length(MatricesSUX.MatrixPart)+length(KEGG.rxns)+length(find(KEGG.lb < 0)),1)=2;%KEGG DB reactions
MatricesSUX.MatrixPart(length(MatricesSUX.MatrixPart)+1:length(MatricesSUX.rxns),1)=3; %exchange and transport reactions

function model = CheckMetName(model)
% replace () compartment localisation
model.mets = regexprep(model.mets,'\(([^]])\)$','[$1]');
% fixes metabolites names if no compartment has been added to metabolites.
% It assumes that the metabolites without compartment are in the cytosol
for i = 1 :length(model.mets)
    if  isempty(regexp(model.mets{i},'\[[^\]]+\]$'))
        model.mets{i} = strcat(model.mets{i}, model.metComps{i});
    end
end
