% The COBRAToolbox: testGDLS.m
%
% Purpose:
%     - testGDLS tests the functionality of GDLS.
%
% Authors:
%     - CI integration: Laurent Heirendt April 2017
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGDLS'));
cd(fileDir);

% load model
model = getDistributedModel('ecoli_core_model.mat');

% Set conditions to anaerobic and glucose uptake of 20
model = changeRxnBounds(model, {'EX_o2(e)', 'EX_glc(e)'}, [0 - 20], 'l');

% Select reactions that can be knocked out
selectedRxns = {model.rxns{1}, model.rxns{3:5}, model.rxns{7:8}, ...
                model.rxns{10}, model.rxns{12}, model.rxns{15:16}, model.rxns{18}, ...
                model.rxns{40:41}, model.rxns{44}, model.rxns{46}, model.rxns{48:49}, ...
                model.rxns{51}, model.rxns{53:55}, model.rxns{57}, model.rxns{59:62}, ...
                model.rxns{64:68}, model.rxns{71:77}, model.rxns{79:83}, ...
                model.rxns{85:86}, model.rxns{89:95}}';

solverPkgs = {'gurobi'};

for k = 1: length(solverPkgs)

    solverOK = changeCobraSolver(solverPkgs{k}, 'MILP', 0);

    if solverOK
        fprintf(['Running testGDLS using ', solverPkgs{k}, ' ... '])
        % run GDLS
        [gdlsSolution] = GDLS(model, 'EX_succ(e)', 'minGrowth', 0.05, 'selectedRxns', selectedRxns, 'maxKO', 5, 'nbhdsz', 3);

        % check solution
        assert(length(gdlsSolution.KOs) == 5)
        assert(all(ismember(gdlsSolution.KOs, {'ACALD'; 'ALCD2x'; 'GLUDy'; 'LDH_D'; 'PFL'; 'THD2'; 'CYTBD'})))

        % print a success message
        fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)
