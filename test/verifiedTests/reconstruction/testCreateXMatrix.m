% The COBRAToolbox: testCreateXMatrix.m
%
% Purpose:
%     - tests the createXMatrix function to generate exchangers for a given
%     set of metabolites to a given compartment.
%
% Authors:
%     - Thomas Pfau  October 2017



oldDir = pwd;

testDir = fileparts(which('testCreateXMatrix.m'));

cd(testDir);

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
cd(oldDir)