function [modelNew] = mergeTwoModels(model1,model2,objrxnmodel)
% function [modelNew] = MergeTwoModels(model1,model2,objrxnmodel)
%
% Inputs
%   model1          model 1
%   model2          model 2
%   objrxnmodel     Set as 1 or 2 to set objective reaction from
%                   desired model
%
% based on[model_metE] = CreateMetE(model_E,model_M)) (Aarash Bordbar,
% 07/06/07);
% 11/10/2007 IT


 
if nargin < 3
    objrxnmodel =1;
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
h = waitbar(0, 'Combining Metabolites in Progress ...');
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
        sizemets = sizemets+1;
    end
    if(mod(i,40) == 0),waitbar(i/size(model2.mets,1),h);end
end

lengthmet = size(modelNew.mets,1);
close(h);
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
% fprintf('Combining Subsystem List: ');
% modelNew.subSystems = model1.RxnSubsystem;
% modelNew.subSystems(size(model1.RxnSubsystem,1)+1:size(model1.RxnSubsystem,1)+size(model2.subSystems)) = model2.subSystems;
% modelNew.rxnNames = model1.rxnNames;
% modelNew.rxnNames(size(model1.rxnNames,1)+1:size(model1.rxnNames,1)+size(model2.rxnNames)) = model2.rxnNames;
% fprintf('Finished\n');

% Combining S Matrices (using sparse allocation)
fprintf('Combining S matrices: ');
[a1,b1] = find(model1.S);
[a2,b2] = find(model2.S);
model1_num = length(a1);
model2_num = length(a2);
modelNew.S = spalloc(size(modelNew.mets,1),size(modelNew.rxns,1),model1_num+model2_num);

h = waitbar(0, 'Adding Matrix 1 in Progress ...');
for i = 1:size(a1,1)
    modelNew.S(a1(i),b1(i)) = model1.S(a1(i),b1(i));
    if mod(i,40) == 0,waitbar(i/size(a1,1),h);end
end
close(h);



HTABLE = java.util.Hashtable;
for i = 1:length(modelNew.mets)
    HTABLE.put(modelNew.mets{i}, i);
end
h = waitbar(0, 'Adding Matrix 2 in Progress ...');
for i = 1:size(model2.S,2)
    compounds = find(model2.S(:,i));
    for j = 1:size(compounds,1)
        metnames(j,1) = model2.mets(compounds(j));
        
        %tmp2 = strmatch(metnames(j,1),modelNew.mets,'exact');
        %metnames(j,1)
        tmp = HTABLE.get(metnames{j,1});
        %if any(tmp2 ~= tmp)
        %    pause;
        %end
        modelNew.S(tmp,i+size(model1.S,2)) = model2.S(compounds(j),i);
    end
    if mod(i,40) == 0,waitbar(i/size(model2.S,2),h);end
end
close(h);
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
for i = 1:length(model2.genes)
    if isempty(strmatch(model2.genes{i},modelNew.genes,'exact')) == 1
        modelNew.genes(size(model.genes,1)+i) = model2.genes{i};
    end
end
fprintf('Finished\n');

fprintf('Combining Remaining Genetic Information: ');
h = waitbar(0, 'Combining Genetic Info ...');
modelNew.rxnGeneMat = model1.rxnGeneMat;
for i = 1:size(model2.rxnGeneMat,1)
    for j = 1:size(model2.rxnGeneMat,2)
        if model2.rxnGeneMat(i,j) ~= 0
            geneLoc = strmatch(model2.genes{j},modelNew.genes,'exact');
            modelNew.rxnGeneMat(length(model1.lb)+i,j) = 1;
        end
    end
    if(mod(i, 40) == 0),waitbar(i/size(model2.rxnGeneMat,1),h);end
end
close(h);

modelNew.grRules = model1.grRules;
modelNew.grRules(size(model1.grRules,1)+1:size(model1.grRules,1)+size(model2.grRules,1)) = model2.grRules;
modelNew.rules = model1.rules;
modelNew.rules(size(model1.rules,1)+1:size(model1.rules,1)+size(model2.rules,1)) = model2.rules;
fprintf('Finished\n');