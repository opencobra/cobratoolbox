function [modelNew] = mergeTwoModels(model1,model2,objrxnmodel,mergeRxnGeneMat)
%% function [modelNew] = mergeTwoModels(model1,model2,objrxnmodel,mergeRxnGeneMat)
%
% Inputs
%
% model1          - model 1
% model2          - model 2
% objrxnmodel     - Set as 1 or 2 to set objective reaction from
%                 desired model
% mergeRxnGeneMat - if false, do not merge rxnGeneMat
%
% Outputs
%
% modelNew        - merged model
%
% based on[model_metE] = CreateMetE(model_E,model_M)) (Aarash Bordbar,
% 07/06/07);
% 11/10/2007 IT

if ~exist('objrxnmodel','var') || isempty(objrxnmodel)
    objrxnmodel = 1;
end
if ~exist('mergeRxnGeneMat','var') || isempty(mergeRxnGeneMat)
    mergeRxnGeneMat = true;
end

% Creating Universal Metabolite Names

% Only needed if metabolite names vary, in the specific instance of iAF1260
% the metabolites vary by a [c] at the end, which is removed by the script
% fprintf('Fixing metabolite names: ');
% for i = 1:size(model2.mets,1)
%     model2.mets(i,1) = strrep(model2.mets(i,1), '[c]' ,'');
% end
% fprintf('Finished\n');

% Combining Reaction List
fprintf('Combining reaction lists: ');
modelNew.rxns = model1.rxns;
modelNew.rxns(size(model1.rxns,1)+1:size(model1.rxns,1)+size(model2.rxns,1),1) = model2.rxns;
lengthreaction = size(modelNew.rxns,1);
fprintf('Finished, %i Distinct Reactions\n',lengthreaction);

% Combining Metabolite List
fprintf('Combining metabolite lists: ');
showprogress(0, 'Combining Metabolites in Progress ...');
modelNew.mets = model1.mets;

sizemets = size(modelNew.mets,1)+1;
HTABLE = java.util.Hashtable;
for i = 1:length(model1.mets)
    HTABLE.put(model1.mets{i}, i);
end
for i = 1:size(model2.mets,1)
    %tmp2 = strmatch(model2.mets(i,1),model1.mets,'exact')
    tmp = HTABLE.get(model2.mets{i,1});
%     if ~isempty(tmp) || ~isempty(tmp2)
%         if any(tmp2 ~= tmp)
%             pause;
%         end
%     end
    if isempty(tmp) == 1
        modelNew.mets(sizemets,1) = model2.mets(i,1);
        if isfield(model1,'metNames') && isfield(model2,'metNames') && length(model2.metNames)>0
            modelNew.metNames(sizemets,1) = model2.metNames(i,1);
        end
        if isfield(model1,'metFormulas') && isfield(model2,'metFormulas')&& length(model2.metFormulas)>0
            modelNew.metFormulas(sizemets,1) = model2.metFormulas(i,1);
        end
        % causes errors when joining with enterocyte model
         if isfield(model1,'metCharge')&& isfield(model2,'metCharge')&& length(model2.metCharge)>0
             modelNew.metCharge(sizemets,1) = model2.metCharge(i,1);
         end
        sizemets = sizemets+1;
    end
    showprogress(i/size(model2.mets,1));
end

lengthmet = size(modelNew.mets,1);
fprintf('Finished, %i Distinct Metabolites\n',lengthmet);


% Combining lb List
fprintf('Combining LB list: ');
modelNew.lb = model1.lb;
floatingmodel = model2.lb;
modelNew.lb(size(model1.lb,1)+1:size(model1.lb,1)+size(model2.lb,1),1) = floatingmodel;
fprintf('Finished\n');

% Combining ub List
fprintf('Combining UB list: ');
modelNew.ub = model1.ub;
modelNew2.ub = model2.ub;
modelNew.ub(size(model1.ub,1)+1:size(model1.ub,1)+size(model2.ub,1),1) = modelNew2.ub;
fprintf('Finished\n');

% Combining subsystem List
fprintf('Combining Subsystem List: ');
modelNew.subSystems = model1.subSystems;
modelNew.subSystems(size(model1.subSystems,1)+1:size(model1.subSystems,1)+size(model2.subSystems)) = model2.subSystems;
modelNew.rxnNames = model1.rxnNames;
modelNew.rxnNames(size(model1.rxnNames,1)+1:size(model1.rxnNames,1)+size(model2.rxnNames)) = model2.rxnNames;
if isfield(model1,'rxnKeggID') && isfield(model2,'rxnKeggID')
    modelNew.rxnKeggID = model1.rxnKeggID;
    modelNew.rxnKeggID(size(model1.rxnKeggID,1)+1:size(model1.rxnKeggID,1)+size(model2.rxnKeggID)) = model2.rxnKeggID;
end
if isfield(model1,'rxnConfidenceEcoIDA') && isfield(model2,'rxnConfidenceEcoIDA')
    modelNew.rxnConfidenceEcoIDA = model1.rxnConfidenceEcoIDA;
    modelNew.rxnConfidenceEcoIDA(size(model1.rxnConfidenceEcoIDA,1)+1:size(model1.rxnConfidenceEcoIDA,1)+size(model2.rxnConfidenceEcoIDA)) = model2.rxnConfidenceEcoIDA;
end
if isfield(model1,'rxnConfidenceScores') && isfield(model2,'rxnConfidenceScores')
    modelNew.rxnConfidenceScores = model1.rxnConfidenceScores;
    modelNew.rxnConfidenceScores(size(model1.rxnConfidenceScores,1)+1:size(model1.rxnConfidenceScores,1)+size(model2.rxnConfidenceScores)) = model2.rxnConfidenceScores;
end
if isfield(model1,'rxnsboTerm') && isfield(model2,'rxnsboTerm')
    modelNew.rxnsboTerm = model1.rxnsboTerm;
    modelNew.rxnsboTerm(size(model1.rxnsboTerm,1)+1:size(model1.rxnsboTerm,1)+size(model2.rxnsboTerm)) = model2.rxnsboTerm;
end
if isfield(model1,'rxnReferences') && isfield(model2,'rxnReferences')
    modelNew.rxnReferences = model1.rxnReferences;
    modelNew.rxnReferences(size(model1.rxnReferences,1)+1:size(model1.rxnReferences,1)+size(model2.rxnReferences)) = model2.rxnReferences;
end
if isfield(model1,'rxnECNumbers') && isfield(model2,'rxnECNumbers')
    modelNew.rxnECNumbers = model1.rxnECNumbers;
    modelNew.rxnECNumbers(size(model1.rxnECNumbers,1)+1:size(model1.rxnECNumbers,1)+size(model2.rxnECNumbers)) = model2.rxnECNumbers;
end
if isfield(model1,'rxnNotes') && isfield(model2,'rxnNotes')
    modelNew.rxnNotes = model1.rxnNotes;
    modelNew.rxnNotes(size(model1.rxnNotes,1)+1:size(model1.rxnNotes,1)+size(model2.rxnNotes)) = model2.rxnNotes;
end


% modelNew.metChEBIID = model1.metChEBIID;
% modelNew.metChEBIID(size(model1.metChEBIID,1)+1:size(model1.metChEBIID,1)+size(model2.metChEBIID)) = model2.metChEBIID;
% modelNew.metKeggID = model1.metKeggID;
% modelNew.metKeggID(size(model1.metKeggID,1)+1:size(model1.metKeggID,1)+size(model2.metKeggID)) = model2.metKeggID;
% modelNew.metPubChemID = model1.metPubChemID;
% modelNew.metPubChemID(size(model1.metPubChemID,1)+1:size(model1.metPubChemID,1)+size(model2.metPubChemID)) = model2.metPubChemID;
% modelNew.metInchiString = model1.metInchiString;
% modelNew.metInchiString(size(model1.metInchiString,1)+1:size(model1.metInchiString,1)+size(model2.metInchiString)) = model2.metInchiString;

fprintf('Finished\n');

% Combining S Matrices (using sparse allocation)
fprintf('Combining S matrices: ');
[a1,b1] = find(model1.S);
[a2,b2] = find(model2.S);
model1_num = length(a1);
model2_num = length(a2);
modelNew.S = spalloc(size(modelNew.mets,1),size(modelNew.rxns,1),model1_num+model2_num);

showprogress(0, 'Adding Matrix 1 in Progress ...');
for i = 1:size(a1,1)
    modelNew.S(a1(i),b1(i)) = model1.S(a1(i),b1(i));
    showprogress(i/size(a1,1));
end

HTABLE = java.util.Hashtable;
for i = 1:length(modelNew.mets)
    HTABLE.put(modelNew.mets{i}, i);
end

showprogress(0, 'Adding Matrix 2 in Progress ...');
for i = 1:size(model2.S,2)
    compounds = find(model2.S(:,i));
    for j = 1:size(compounds,1)
        metnames(j,1) = model2.mets(compounds(j));
        tmp = HTABLE.get(metnames{j,1});
        modelNew.S(tmp,i+size(model1.S,2)) = model2.S(compounds(j),i);
    end
    showprogress(i/size(model2.S,2));
end


fprintf('Finished\n');

% Creating b
fprintf('Combining b lists: ');
modelNew.b = zeros(size(modelNew.mets,1),1);
fprintf('Finished\n');

% Creating c (no objective function optimization)
fprintf('Combining c lists: ');
modelNew.c = zeros(size(modelNew.rxns,1),1);
fprintf('Finished\n');

% Optimization Parameters in modelNew.c
fprintf('Setting up optimization parameters: ');
switch objrxnmodel
    case 1
        modelNew.c(find(model1.c),1) = 1;
    case 2
        modelNew.c(find(model2.c)+size(model1.c,1),1) = 1;
end
fprintf('Finished\n');

% Creating rev
fprintf('Combining rev lists: ');
modelNew.rev = model1.rev;
modelNew.rev(size(model1.rev,1)+1:size(model1.rev,1)+size(model2.rev,1),1) = model2.rev;
fprintf('Finished\n');

% % Creating GPR Rules
fprintf('Combining Genes: ');
modelNew.genes = model1.genes;
a=1;
for i = 1:length(model2.genes)
    if isempty(strmatch(model2.genes{i},modelNew.genes,'exact')) == 1
        modelNew.genes(size(model1.genes,1)+a) = model2.genes(i);
        a=a+1;
    end
end
fprintf('Finished\n');

if mergeRxnGeneMat
fprintf('Combining Remaining Genetic Information: ');
showprogress(0, 'Combining Genetic Info ...');
end

modelNew.rxnGeneMat = model1.rxnGeneMat;

for i = 1:size(model2.rxnGeneMat,1)
    R = find(model2.rxnGeneMat(i,:));
    if ~isempty(R)
        for j = 1:length(R)
            geneLoc = find(ismember(modelNew.genes,model2.genes(R(j))));
            T = find(ismember(modelNew.rxns,model2.rxns(i)));
            modelNew.rxnGeneMat(T,geneLoc) = 1;
        end
    else
        T = find(ismember(modelNew.rxns,model2.rxns(i)));
        modelNew.rxnGeneMat(T,:) = 0;
    end
    showprogress(i/size(model2.rxnGeneMat,1));
end

modelNew.grRules = model1.grRules;
modelNew.grRules(size(model1.grRules,1)+1:size(model1.grRules,1)+size(model2.grRules,1)) = model2.grRules;
if isfield(model1,'rules')
    modelNew.rules = model1.rules;
    modelNew.rules(size(model1.rules,1)+1:size(model1.rules,1)+size(model2.rules,1)) = model2.rules;
end
fprintf('Finished\n');
