% The COBRAToolbox: testFastLeakTest.m
%
% Purpose:
%     - Test Fast Leak Test on an E.Coli Model 
%     - Modify the model to give rise to some leaking metabolites.
%
% Authors:
%     - Thomas Pfau
%

model = readCbModel(which('ecoli_core_model.mat'));

%First, we have to remove all flux forcing constraints, because they interfere with leak testing.
model.lb(model.lb > 0) = 0;
model.ub(model.ub < 0) = 0;

[LeakMets, modelClosed, FluxExV] = fastLeakTest(model, {}, 'true');

assert(isempty(LeakMets));

%We will add 2 reactions which together produce one unit of the second metabolite
modelWithLeaks = addReaction(model,'A1','metaboliteList',{model.mets{1},model.mets{2}},'stoichCoeffList',[-1 2],'printLevel',-1);
modelWithLeaks = addReaction(modelWithLeaks,'A2','metaboliteList',{model.mets{2},model.mets{1}},'stoichCoeffList',[-1 1],'printLevel',-1);

[LeakMets, modelClosed, FluxExV] = fastLeakTest(modelWithLeaks, {}, 'true');

assert(any(ismember(['DM_' model.mets{2}],LeakMets))|| any(ismember(['DM_' model.mets{2}],LeakMets)));

%Now, we also test for protons (there should only be other protons then, as
%nothing else can be leaked from only protons - normally
modelWithLeaks = addReaction(model,'A1','metaboliteList',{'h[c]','h[x]'},'stoichCoeffList',[-1 2],'printLevel',-1);
modelWithLeaks = addReaction(modelWithLeaks,'A2','metaboliteList',{'h[x]','h[c]'},'stoichCoeffList',[-1 1],'printLevel',-1);

[LeakMets, modelClosed, FluxExV] = fastLeakTest(modelWithLeaks, {}, 'true');

%Only Protons in the leaks.
assert(all(~cellfun(@isempty, regexp(LeakMets,'^(DM_)|(EX_)h\[[a-z]\]$'))));

