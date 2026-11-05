% The COBRAToolbox: testCreateXMatrix.m
%
% Purpose:
%     - tests the createXMatrix function to generate exchangers for a given
%     set of metabolites to a given compartment.
%
% Function under test:
%     src/reconstruction/refinement/createXMatrix.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Thomas Pfau  October 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.



oldDir = pwd;

testDir = fileparts(which('testCreateXMatrix.m'));

cd(testDir);

% this test needs no solver, MATLAB toolbox or particular operating system
prepareTest();

metList = {'A','B','C','D'};

model = createXMatrix(metList);

%This creates sink reactions.
assert(isequal(model.mets,strcat(metList,'[c]')'));
assert(isequal(model.S,-speye(4)));

%Test a different compartment.
model = createXMatrix(metList,0,'[m]');
assert(isequal(model.mets,strcat(metList,'[m]')'));
assert(isequal(model.S,-speye(4)));

%Now, create Transports between cytosol and mitochondrion, along with
%exchangers etc.
model = createXMatrix(metList,1,'[m]');
assert(all(ismember(model.mets,[strcat(metList,'[m]'),strcat(metList,'[e]'),strcat(metList,'[c]')])));
%Also check, that all reactions have the right stoichiometry
for i = 1:length(metList)
    %The reactions have the form: EX_MetName[e], for the exchanger
    %MetNametcompNamer for the compartment to [c] exchanger and metNametr for the
    %exchanger to the extracellular space.
    %Check Exchanger
    rxnName = ['Ex_' metList{i} '[e]'];
    metStoich = model.S(:,ismember(model.rxns,rxnName));
    activeMets = find(metStoich);
    assert(metStoich(activeMets) == -1);
    assert(isequal(model.mets{activeMets},[metList{i},'[e]']));
    %Check transporter to cytosplasm
    rxnName = [metList{i} 'tmr'];
    metStoich = model.S(:,ismember(model.rxns,rxnName));
    activeMets = find(metStoich);
    assert(all(ismember(metStoich(activeMets),[-1,1]))); %This shoudl have a -1 and a 1
    assert(all(ismember(model.mets(activeMets),{[metList{i},'[c]'],[metList{i},'[m]']})));
    %Check transporter to extracellular space
    rxnName = [metList{i} 'tr'];
    metStoich = model.S(:,ismember(model.rxns,rxnName));
    activeMets = find(metStoich);
    assert(all(ismember(metStoich(activeMets),[-1,1]))); %This shoudl have a -1 and a 1
    assert(all(ismember(model.mets(activeMets),{[metList{i},'[e]'],[metList{i},'[m]']})));
end

%% with the default compartment, each metabolite gets one exchanger and one transporter to [c]

model = createXMatrix(metList, 1);
assert(isequal(sort(model.mets), sort([strcat(metList, '[e]'), strcat(metList, '[c]')]')));
assert(numel(model.rxns) == 2 * numel(metList));
for i = 1:length(metList)
    % the exchanger takes up or releases the metabolite in [e], and nothing else
    exchanger = model.S(:, strcmp(model.rxns, ['Ex_' metList{i} '[e]']));
    assert(nnz(exchanger) == 1);
    assert(exchanger(strcmp(model.mets, [metList{i} '[e]'])) == -1);
    % the transporter moves the metabolite from [e] to [c]
    transporter = model.S(:, strcmp(model.rxns, [metList{i} 'tr']));
    assert(nnz(transporter) == 2);
    assert(transporter(strcmp(model.mets, [metList{i} '[e]'])) == -1);
    assert(transporter(strcmp(model.mets, [metList{i} '[c]'])) == 1);
end

%% the external compartment cannot be the target compartment

assert(verifyCobraFunctionError('createXMatrix', 'inputs', {metList, 0, '[e]'}, ...
    'testMessage', 'Cannot use the external compartment as target compartment'));

cd(oldDir)