% The COBRAToolbox: testCreateMultipleSpeciesModel.m
%
% Purpose:
%     - tests the basic functionality of createMultipleSpeciesModel
%
% Authors:
%     - Original file: Almut Heinken - March 2017
%     - CI integration: Laurent Heirendt - March 2017
%
% Note:
%     - The solver libraries must be included separately

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreateMultipleSpeciesModel'));
cd(fileDir);

% load the model
load([CBTDIR, filesep, 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');

% set the tolerance
tol = 1e-6;

% also as "host"
host = model;

% define the solver packages to be used to run this test
solverPkgs = {'glpk', 'gurobi6', 'tomlab_cplex'};

for k = 1:length(solverPkgs)

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverOK == 1
        % loop through the test cases
        for j = 1:3
            fprintf('   Testing createMultipleSpeciesModel using %s ... ', solverPkgs{k});

            % define an empty cell
            microbeModels = {};

            if j == 1  % test joining of one microbe model with/without host
                microbeModels{1, 1} = model;

            elseif j == 2  % test joining of two microbes with/without host
                for p = 1:2
                    microbeModels{p, 1} = model;
                end

            elseif j == 3  % test joining of three  microbes with/without host
                for p = 1:3
                    microbeModels{p, 1} = model;
                end

                % use custom nametags
                microbeNameTags = {'ecoli1_'; 'ecoli2_'; 'ecoli3_'};
                hostNameTag = 'modelHost_';
            end


            if j == 1 || j == 2
                % only one microbe entered
                [modelJoint] = createMultipleSpeciesModel(microbeModels);

                % one microbe model with host
                [modelJointHost] = createMultipleSpeciesModel(microbeModels, [], host);
            else
                % three microbe models with host
                [modelJointHost] = createMultipleSpeciesModel(microbeModels, microbeNameTags, host, hostNameTag);

                % three microbe models without host
                [modelJoint] = createMultipleSpeciesModel(microbeModels, microbeNameTags);
            end

            for i = 1:j
                if j == 1 || j == 2
                    tmpTag = 'model';
                else
                    tmpTag = 'ecoli';
                end

                assert(length(model.rxns) == length(strmatch(strcat(tmpTag, num2str(i), '_'), modelJoint.rxns)))
                assert(length(model.mets) == length(strmatch(strcat(tmpTag, num2str(i), '_'), modelJoint.mets)))
                assert(length(model.rxns) == length(strmatch(strcat(tmpTag, num2str(i), '_'), modelJointHost.rxns)))
                assert(length(model.mets) == length(strmatch(strcat(tmpTag, num2str(i), '_'), modelJointHost.mets)))

                if j == 2 || j == 3
                    % test the biomass production of modelJoint
                    modelJoint = changeObjective(modelJoint, strcat(tmpTag, num2str(i), '_', 'Biomass_Ecoli_core_w_GAM'));
                    FBA = optimizeCbModel(modelJoint, 'max');
                    assert(FBA.f > tol);

                    % test the biomass production of modelJointHost
                    modelJointHost = changeObjective(modelJointHost, strcat(tmpTag, num2str(i), '_', 'Biomass_Ecoli_core_w_GAM'));
                    FBA = optimizeCbModel(modelJointHost, 'max');
                    assert(FBA.f > tol);
                end
            end

            % count the number of extracellular reactions in host to determine number
            % of body fluid compartment reactions added
            exRxns = {};
            rxnCnt = 1;
            metCnt = 1;

            for ii = 1:length(host.mets)
                if ~isempty(strfind(host.mets{ii}, '[e]'))
                    exMets{metCnt, 1} = host.mets{ii};
                    metCnt = metCnt + 1;

                    % find all reactions associated - copy and rename
                    ERxnind = find(host.S(ii, :));
                    for jj = 1:length(ERxnind)
                        exRxns{rxnCnt, 1} = host.rxns{ERxnind(jj), 1};
                        rxnCnt = rxnCnt + 1;
                    end
                end
            end

            exRxns = unique(exRxns);
            exch = strmatch('EX_', exRxns);

            % now compare total number of reactions
            % NOTE: some large host reconstructions (e.g., Recon2) are too complex and/or already have lumen compartment-in this j, the test won't work

            if j == 1 || j == 2
                assert(length(exch) == length(strmatch('Host_EX', modelJointHost.rxns)));
                assert(length(host.rxns) + length(exRxns) == length(strmatch('Host_', modelJointHost.rxns)));
                assert(length(host.mets) + length(exMets) == length(strmatch('Host_', modelJointHost.mets)));

            elseif j == 3
                assert(length(exch) == length(strmatch('modelHost_EX', modelJointHost.rxns)))
                assert(length(host.rxns) + length(exRxns) == length(strmatch('modelHost_', modelJointHost.rxns)))
                assert(length(host.mets) + length(exMets) == length(strmatch('modelHost_', modelJointHost.mets)))

                % test host biomass
                modelJointHost = changeObjective(modelJointHost, 'modelHost_Biomass_Ecoli_core_w_GAM');
                FBA = optimizeCbModel(modelJointHost, 'max');
                assert(FBA.f > tol)
            end
        end
    end

    % output a success message
    fprintf('Done.\n');
end

% change the directory
cd(currentDir)
