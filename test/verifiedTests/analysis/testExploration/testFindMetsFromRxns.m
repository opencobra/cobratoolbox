% The COBRAToolbox: testFindMetsFromRxns.m
%
% Purpose:
%     - tests that metabolites are found when a set of reactions is
%     provided 
%
% Authors:
%     - Original file: Thomas Pfau Jan 2018
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindMetsFromRxns'));
cd(fileDir);

% load model
model = getDistributedModel('ecoli_core_model.mat');

% Take reactions 4 and 8 
reacNames = model.rxns([4 8]);
reacPos = [4,8];

%Assert both are equal.
metsFromNames = findMetsFromRxns(model,reacNames);
metsFromIDs = findMetsFromRxns(model,reacPos);
assert(isequal(metsFromNames,metsFromIDs));

%Assert that a warning is thrown, but that the output is the same (as all
% other reactions are ignored)
invalidRxns = {'A',model.rxns{4},'B',model.rxns{8},'D'};
metsFromInvalidNames = findMetsFromRxns(model,invalidRxns);
assert(isequal(lastwarn, sprintf('The following reactions are not in the model:\n%s',strjoin({'A','B','D'},'; '))));                       

%Now, add two reactions and check that the outputs for those are fine.
mets = {{'A[c]','B[c]','C[c]'};
        {'B[c]','A[c]','D[c]', 'E[c]'}};
stoich = {[-1 -2 3]'; [-1 -1 1 2]'};
model = addReaction(model,'R1','metaboliteList', mets{1},'stoichCoeffList',stoich{1});
model = addReaction(model,'R2','metaboliteList', mets{2},'stoichCoeffList',stoich{2});

[returnedMets,returnedStoich] = findMetsFromRxns(model,{'R1','R2'});
assert(all(cellfun(@(x,y) isempty(setxor(x,y)),mets,returnedMets)));
%This can be reordered
for i = 1:2
    [pres,pos] = ismember(returnedMets{i},mets{i});
    cstoich = stoich{i};
    assert(isequal(cstoich(pos),returnedStoich{i}));
end

%Now test that invalid positions are empty, and that the order is correct:
[returnedMets,returnedStoich] = findMetsFromRxns(model,{'R2','R1'});
assert(all(cellfun(@(x,y) isempty(setxor(x,y)),mets,returnedMets(end:-1:1))));
for i = 1:2
    [pres,pos] = ismember(returnedMets{end-i+1},mets{i});
    cstoich = stoich{i};
    assert(isequal(cstoich(pos),returnedStoich{end-i+1}));
end

%And now, check that we are fine with invalids.

[returnedMets,returnedStoich] = findMetsFromRxns(model,{'R2','A','B','R1','C'});
assert(all(cellfun(@(x,y) isempty(setxor(x,y)),mets,returnedMets([4,1]))));
reacpos = [4,1];
for i = 1:2
    [pres,pos] = ismember(returnedMets{reacpos(i)},mets{i});
    cstoich = stoich{i};
    assert(isequal(cstoich(pos),returnedStoich{reacpos(i)}));
end

% change the directory
cd(currentDir)
