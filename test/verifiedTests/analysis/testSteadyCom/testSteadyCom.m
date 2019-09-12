% The COBRAToolbox: testSteadyCom.m
%
% Purpose:
%    - This script aims to test the SteadyCom module and compare the results
%      with the expected data. All functions involved will be called explicitly or implicitly.
%
% Authors:
%    - Siu Hung Joshua Chan July 2017

% choose tolerance according to the solver used
global CBT_LP_SOLVER
global SOLVERS

% save the current path
currentDir = pwd;

requireOneSolverOf = {'gurobi'; 'glpk'; 'tomlab_cplex'; 'cplex_direct'; 'mosek'};
prepareTest('needsQP',true,'requireOneSolverOf', requireOneSolverOf);


% initialize the test
fileDir = fileparts(which('testSteadyCom'));
cd(fileDir);
%Test for parallel toolbox
try
    poolobj = gcp('nocreate');% create a toy model
    parWorks = true;
catch
    parWorks = false;
end

rxns = {'EX_a(e)'; 'EX_b(e)'; 'EX_c(e)'; 'TransA'; 'TransB'; 'TransC'; 'A2B'; 'A2C'; 'BIOMASS'};
rxnNames = {'Exchange of a'; 'Exchange of b'; 'Exchange of c'; ...
    'Transport of a'; 'Transport of b'; 'Transport of c'; ...
    'Convert A to B'; 'Convert A to C'; 'Biomass reaction'};
rxnEqs = {'a[e] <=>'; 'b[e] <=>'; 'c[e] <=>'; ...
    'a[e] <=> a[c]'; 'b[e] <=> b[c]'; 'c[e] <=> c[c]'; ...
    'a[c] -> b[c]'; 'a[c] -> 0.5 c[c]'; '30 b[c] + 20 c[c] ->'};
model = createModel(rxns, rxnNames, rxnEqs, 'lowerBoundList', [-1; 0; 0; -1000; -1000; -1000; 0; 0; 0]);

% two copies of the model, each with one intracellular reaction KO
org1 = changeRxnBounds(model, 'A2B', 0);
org2 = changeRxnBounds(model, 'A2C', 0);

% construct a community model
modelJoint = createMultipleSpeciesModel({org1; org2}, 'nameTagsModels', {'Org1'; 'Org2'});

% TEST getMultiSpeciesModelId to retreive reaction/metabolite IDs
[modelJoint.infoCom, modelJoint.indCom] = getMultiSpeciesModelId(modelJoint, {'Org1'; 'Org2'});
data = load('refData_getMultiSpeciesModelId', 'infoCom', 'indCom');
assert(isequal(data.infoCom, modelJoint.infoCom))
assert(isequal(data.indCom, modelJoint.indCom))

% No community uptake for b and c but only for a
aCom = strcmp(modelJoint.infoCom.Mcom, 'a[u]');
bCom = strcmp(modelJoint.infoCom.Mcom, 'b[u]');
cCom = strcmp(modelJoint.infoCom.Mcom, 'c[u]');
modelJoint = changeRxnBounds(modelJoint, modelJoint.infoCom.EXcom(aCom), -10, 'l');
modelJoint = changeRxnBounds(modelJoint, modelJoint.infoCom.EXcom(bCom | cCom), 0, 'l');
% organism-specific uptake rate for b and c set at a finite value
modelJoint = changeRxnBounds(modelJoint, modelJoint.infoCom.EXsp(bCom | cCom, :), -5, 'l');
modelJoint = changeRxnBounds(modelJoint, modelJoint.infoCom.EXsp(bCom | cCom, :), 5, 'u');

% TEST printUptakeBoundCom to look at the uptake bound for community model
if exist('printUptakeBoundCom.txt', 'file')
    delete('printUptakeBoundCom.txt');
end
diary('printUptakeBoundCom.txt');
[printMatrix, printMet] = printUptakeBoundCom(modelJoint, 1);
diary off;

% check the printed text
text1 = importdata('printUptakeBoundCom.txt');
text2 = importdata('refData_printUptakeBoundCom.txt');
assert(isequal(text1, text2));
delete('printUptakeBoundCom.txt');  % remove the generated file
% check the returned data is the same as what is printed
assert(isequal(printMatrix, [-10, -1000, -1000; 0, -5, -5; 0, -5, -5]))
assert(isequal(printMet, {'(1) a';'(2) b';'(3) c'}))

% TEST createMultipleSpeciesModel and printUptakeBoundCom with a model with host organism
% build a model with host
modelWtHost = createMultipleSpeciesModel({org1; org2}, 'nameTagsModels', {'Org1'; 'Org2'}, 'modelHost', org1, 'nameTagHost', 'Org3');
% get IDs
[modelWtHost.infoCom, modelWtHost.indCom] = getMultiSpeciesModelId(modelWtHost, {'Org1'; 'Org2'}, 'Org3');
% change some uptake bounds
modelWtHost = changeRxnBounds(modelWtHost, modelWtHost.infoCom.EXcom(aCom), -10, 'l');
modelWtHost = changeRxnBounds(modelWtHost, modelWtHost.infoCom.EXcom(bCom | cCom), 0, 'l');
modelWtHost = changeRxnBounds(modelWtHost, modelWtHost.infoCom.EXsp(bCom | cCom, :), -5, 'l');
modelWtHost = changeRxnBounds(modelWtHost, modelWtHost.infoCom.EXhost(bCom | cCom, :), -5, 'l');
modelWtHost = changeRxnBounds(modelWtHost, modelWtHost.infoCom.EXhost(aCom, :), 0, 'l');
% print uptake bounds and compare
if exist('printUptakeBoundCom_wt_host.txt', 'file')
    delete('printUptakeBoundCom_wt_host.txt');
end
diary('printUptakeBoundCom_wt_host.txt');
printUptakeBoundCom(modelWtHost, 1);
diary off;
text1 = importdata('printUptakeBoundCom_wt_host.txt');
text2 = importdata('refData_printUptakeBoundCom_wt_host.txt');
assert(isequal(text1, text2));
delete('printUptakeBoundCom_wt_host.txt');  % remove the generated file

%TEST createMultipleSpeciesModel and getMultiSpeciesModelId with a model with
%the 'biomass[c]' metabolite (special treatment by createMultipleSpeciesModel)
[metBm, rxnExBm, nameTags] = deal('biomass[c]', 'EX_biomass(c)', {'Org1'; 'Org2'});
rxnEqs{end} = ['30 b[c] + 20 c[c] -> ' metBm];
model = createModel([rxns; {'EX_biomass(c)'}], [rxnNames; {'biomass export'}], [rxnEqs; {[metBm ' ->']}], ...
    'lowerBoundList', [-1; 0; 0; -1000; -1000; -1000; 0; 0; 0; 0]);
modelWtBiomass = createMultipleSpeciesModel({model; model}, 'nameTagsModels', nameTags);
[modelWtBiomass.infoCom, modelWtBiomass.indCom] = getMultiSpeciesModelId(modelWtBiomass, nameTags);
% biomass community exchange reaction and metabolite Ids unchanged
bmCom = strcmp(modelWtBiomass.infoCom.EXcom, regexprep(rxnExBm, '\(([^\)]+)\)', '\[$1\]'));
assert(sum(bmCom) == 1 & isequal(bmCom, strcmp(modelWtBiomass.infoCom.Mcom, metBm)))
% the orders of organism biomass export reactions and metabolites preserve
for jSp = 1:numel(nameTags)
    assert(isequal(bmCom, strcmp(modelWtBiomass.infoCom.EXsp(:,jSp), [nameTags{jSp}, 'I' regexprep(rxnExBm, '\(([^\)]+)\)', '\[$1\]tr')])))
    assert(isequal(bmCom, strcmp(modelWtBiomass.infoCom.Msp(:,jSp), [nameTags{jSp}, metBm])))
end

% specify biomass reactions
modelJoint.infoCom.spBm = {'Org1BIOMASS'; 'Org2BIOMASS'};
modelJoint.indCom.spBm = findRxnIDs(modelJoint, modelJoint.infoCom.spBm);

% TEST SteadyComSubroutines('infoCom2indCom')
indCom = SteadyComSubroutines('infoCom2indCom', modelJoint);  % get indCom from infoCom
assert(isequal(indCom, modelJoint.indCom))
infoCom = SteadyComSubroutines('infoCom2indCom', modelJoint, modelJoint.indCom, true, {'Org1'; 'Org2'});  % get infoCom from indCom
assert(isequal(infoCom, modelJoint.infoCom))

origSolver = CBT_LP_SOLVER;  %original solver

for jTest = 1:2
    if jTest == 1  % test the ibm_cplex solver if installed (with specialised SteadyCom scripts)
        cont = 0;
        try
            cont = changeCobraSolver('ibm_cplex', 'LP');
        end
    else  % test any one of the other LP solvers
        solverPrefer = {'gurobi'; 'glpk'; 'tomlab_cplex'; 'cplex_direct'; 'mosek'}; %Minos cannot be run using parfor!
        jSolver = 1;
        cont = 0;
        while jSolver <= numel(solverPrefer)
            if SOLVERS.(solverPrefer{jSolver}).installed
                cont = changeCobraSolver(solverPrefer{jSolver}, 'LP');
            end
            if cont
                break
            end
            jSolver = jSolver + 1;
        end
        if ~cont && ~isempty(origSolver)
            cont = changeCobraSolver(origSolver, 'LP');
        end
    end

    if cont
        switch CBT_LP_SOLVER
            case {'gurobi', 'ibm_cplex', 'tomlab_cplex', 'cplex_direct', 'glpk'} % QuadMinos and dqqMinos don' work in parallel settings
                feasTol = 1e-8;  % feasibility tolerance
                tol = 1e-3;  % tolerance for comparing results
            case {'mosek', 'matlab'}
                feasTol = 1e-6;  % feasibility tolerance
                tol = 1e-3;  % tolerance for comparing results
            otherwise
                feasTol = 1e-4;  % feasibility tolerance
                tol = 1e-2;  % tolerance for comparing results
        end
        tolPercent = 0.05;  % tolerance for percentage difference

        % TEST SteadyCom
        % test different algoirthms
        data = load('refData_SteadyCom', 'result');
        for jAlg = 1:3
            options = struct();
            if jAlg == 1
                options.GRtol = 1e-6;
            else
                options.algorithm = jAlg;
            end
            [~, result(jAlg)] = SteadyCom(modelJoint, options, 'feasTol', feasTol);
            % only the maximum growth rate must be equal. Others may differ.
            assert(abs(result(jAlg).GRmax - data.result.GRmax) < tol)
        end

        % test additional constraints
        % 1: constraints on individual growth rates and biomass amounts
        options = struct();
        options.GRfx = [2 0.1];  % fix organism 2's growth rate at 0.1
        % biomass constraint: X_Org1 >= 0.2, X_Org2 <= 0.3
        [options.BMcon, options.BMrhs, options.BMcsense] = deal([1 0; 0 1], [0.2; 0.3], 'GL');
        [~, resultAddConstr] = SteadyCom(modelJoint, options, 'feasTol', feasTol);
        % check that biomass variables are really constrained.
        assert(resultAddConstr.BM(1) >= 0.2 - feasTol & resultAddConstr.BM(2) <= 0.3 + feasTol)
        % check the maximum growth rate
        assert(abs(resultAddConstr.GRmax - 0.071427) < tol)
        % check that organism 2's growth rate really fixed at 0.1
        assert(abs(resultAddConstr.vBM(2) / resultAddConstr.BM(2) - 0.1) < tol)

        % 2: general constraint:
        options = struct();
        [options.MC, options.MCmode] = deal(zeros(size(modelJoint.S, 2) + 2, 1));
        % 2A: system exchange of A >= -0.8, constraint on the original variable
        options.MC(modelJoint.indCom.EXcom(aCom)) = -1;
        options.MCrhs = 0.8;
        [~, resultAddConstr] = SteadyCom(modelJoint, options, 'feasTol', feasTol);
        % check the constraints and max. growth rate
        assert(resultAddConstr.Ut(aCom) <= 0.8 + feasTol & abs(resultAddConstr.GRmax - 0.0114286) < tol)

        % 2B: total organism-specific export  <= 1, constraint only on the +ve parts of the variables
        options.MC(:) = 0;
        options.MC(modelJoint.indCom.EXsp(:)) = 1;
        % set MCmode = 1 to constrain only the +vee parts
        options.MCmode(modelJoint.indCom.EXsp(:)) = 1;
        options.MCrhs = 1;
        [~, resultAddConstr] = SteadyCom(modelJoint, options, 'feasTol', feasTol);
        osExport = resultAddConstr.flux(modelJoint.indCom.EXsp(:));
        osExport(osExport < 0) = 0;  % only look at export reactions
        % check the constraints and max. growth rate
        assert(sum(osExport) <= 1 + feasTol & abs(resultAddConstr.GRmax - 0.046362) < tol)

        % 2C: total organism-specific uptake  >= -1, constraint only on the -ve parts of the variables
        % flux V is decomposed as V^pos - V^neg, the latter is the -ve
        % part, therefore the constraint becomes sum(V^neg_ex) <= 1
        options.MCmode(modelJoint.indCom.EXsp(:)) = 2;  % set MCmode = 2 to constrain only the -ve parts
        [options.MCrhs, options.MClhs] = deal(1, -inf);
        [~, resultAddConstr] = SteadyCom(modelJoint, options, 'feasTol', feasTol);
        osUptake = resultAddConstr.flux(modelJoint.indCom.EXsp(:));
        osUptake(osUptake > 0) = 0;  % only look at uptake reactions
        % check the constraints and max. growth rate
        assert(sum(osUptake) >= -1 - feasTol & abs(resultAddConstr.GRmax - 0.011059) < tol)

        % 2D: total intracellular specific activity for each organism <= 5, constraint on the absolute fluxes
        [options.MC, options.MCmode] = deal(zeros(size(modelJoint.S, 2) + 2, 2));
        for jSp = 1:2
            % sum of all absolute fluxes of the intracellular reactions <= 5 X
            % (flux / X = specific activity or specific rate)
            options.MC(modelJoint.indCom.rxnSps == jSp, jSp) = 1;  % all reactions belonging to organism jSp
            options.MC(modelJoint.indCom.EXsp(:), jSp) = 0;  % exclude organism-community exchange reactions
            options.MCmode(options.MC ~= 0) = 3;  % for constraints on the absolute value
            options.MC(numel(modelJoint.rxns) + jSp, jSp) = -5;  % for -5 X
            [options.MCrhs, options.MClhs] = deal(0, -inf);
        end
        [~, resultAddConstr] = SteadyCom(modelJoint, options, 'feasTol', feasTol);
        for jSp = 1:2  % check the constraints
            assert(resultAddConstr.flux' * options.MC(1:numel(modelJoint.rxns), jSp) <= 5 * resultAddConstr.BM(jSp) + feasTol)
        end
        assert(abs(resultAddConstr.GRmax - 0.026035) < tol)

        % test another feasibility criteria implemented
        % (total biomass production rate instead of total biomass amount)
        options = struct('feasCrit', 2, 'solveGR0', true);
        [~, resultFC] = SteadyCom(modelJoint, options, 'feasTol', feasTol);
        assert(abs(resultFC.GRmax - 0.166663) < tol);

        % test options given by name-value arguments
        diary('SteadyCom_saveModel.txt');
        [~, resultNVarg] = SteadyCom(modelJoint, [], 'printLevel', 0, 'minNorm', 1, 'saveInput', 'testSteadyComSaveModel');
        diary off;
        % check max. growth rate and sum of absolute fluxes
        assert(abs(resultNVarg.GRmax - 0.142857) < tol);
        assert(abs(sum(abs(resultNVarg.flux)) - 53.6493) / 53.6493 < tolPercent)
        % check that nothing is printed
        text1 = importdata('SteadyCom_saveModel.txt');
        assert(isempty(text1));
        delete('SteadyCom_saveModel.txt');
        % check saved files
        if jTest == 1
            assert(exist('testSteadyComSaveModel.bas', 'file') & exist('testSteadyComSaveModel.mps', 'file') ...
                & exist('testSteadyComSaveModel.prm', 'file'))
        else
            assert(logical(exist('testSteadyComSaveModel.mat', 'file')))
            delete('testSteadyComSaveModel.mat')
        end

        % test a model unable to growth but still feasible for maintenance (i.e., zero growth rate)
        % require export of C by organism 1 and export of B by organism 2
        % but knockout the biomass reaction of organism 1
        modelTest = changeRxnBounds(modelJoint, modelJoint.infoCom.EXsp(cCom, 1), 0.1, 'l');
        modelTest = changeRxnBounds(modelTest, modelTest.infoCom.EXsp(bCom, 2), 0.1, 'l');
        modelTest = changeRxnBounds(modelTest, modelTest.infoCom.spBm(1), 0, 'u');
        options = struct();
        [options.BMcon, options.BMcsense, options.BMrhs] = deal([1 0], 'G', 1);
        [~, resultMaintenance] = SteadyCom(modelTest, options);
        assert(strcmp(resultMaintenance.stat, 'maintenance') & resultMaintenance.GRmax == 0 ...
            & all(resultMaintenance.vBM <= 1e-5) & abs(resultMaintenance.BM(1) - 1) < tol ...
            & abs(resultMaintenance.BM(2) - 98) < tol)

        % test an infeasible model
        % require export of B by organism 1 and export of C by organism 2
        modelTest = changeRxnBounds(modelJoint, modelJoint.infoCom.EXsp(bCom, 1), 0.1, 'l');
        modelTest = changeRxnBounds(modelTest, modelTest.infoCom.EXsp(cCom, 2), 0.1, 'l');
        [~, resultInfeas] = SteadyCom(modelTest, options);
        assert(strcmp(resultInfeas.stat, 'infeasible'))

        % TEST SteadyComFVA
        options = struct('GRtol', 1e-6);
        options.optGRpercent = [100 90 80];
        options.rxnNameList = {'X_Org1'; 'X_Org2'};
        [minFlux, maxFlux, ~, ~, GRvector] = SteadyComFVA(modelJoint, options, 'feasTol', feasTol);
        data = load('refData_SteadyComFVA', 'minFlux', 'maxFlux', 'GRvector');

        % Different solvers may give slightly different results. Give a percentage tolerance
        assert(max(max(abs(minFlux - data.minFlux) ./ data.minFlux)) < tolPercent)
        assert(max(max(abs(maxFlux - data.maxFlux) ./ data.maxFlux)) < tolPercent)
        assert(max(abs(GRvector - data.GRvector) ./ data.GRvector) < tolPercent)

        % test with an infeasible model
        [minFlux, maxFlux, ~, ~, GRvector] = SteadyComFVA(modelTest);
        assert(all(isnan(minFlux)) & all(isnan(maxFlux)) & isnan(GRvector));

        % test with given growth rate
        options = struct('GRtol', 1e-6, 'GRmax', 0.1);
        [minFlux, maxFlux] = SteadyComFVA(modelJoint, options, 'feasTol', feasTol);
        minFluxRef = [0.2856653; 0.3749391];
        maxFluxRef = [0.6250234; 0.7143061];
        assert(max(max(abs([minFlux, maxFlux] - [minFluxRef, maxFluxRef]) ./ [minFluxRef, maxFluxRef])) < tolPercent)

        % test the sub-function without given growth rate
        [minFlux, maxFlux, ~, ~, ~, gr] = SteadyComFVAgr(modelJoint, struct('GRtol', 1e-6), [], 'feasTol', feasTol);
        assert(max(max(abs([minFlux, maxFlux] - [data.minFlux(:, 1), data.maxFlux(:, 1)]) ./ [data.minFlux(:, 1), data.maxFlux(:, 1)])) < tolPercent)
        assert(abs(gr - 0.142857) < tol)

        % test loading Cplex model
        if jTest == 1
            options = struct('GRtol', 1e-6, 'loadModel', 'testSteadyComSaveModel', 'GRmax', 0.142857, 'optGRpercent', 100);
            [minFlux, maxFlux] = SteadyComFVA(modelJoint, options, 'feasTol', feasTol);
            assert(max(max(abs([minFlux, maxFlux] - [data.minFlux(:, 1), data.maxFlux(:, 1)]) ./ [data.minFlux(:, 1), data.maxFlux(:, 1)])) < tolPercent)
            options = struct('GRtol', 1e-6, 'loadModel', 'testSteadyComSaveModel', 'GR', 0.142857);
            [minFlux, maxFlux] = SteadyComFVAgr(modelJoint, options, [], 'feasTol', feasTol);
            assert(max(max(abs([minFlux, maxFlux] - [data.minFlux(:, 1), data.maxFlux(:, 1)]) ./ [data.minFlux(:, 1), data.maxFlux(:, 1)])) < tolPercent)
        end

        % test saving results
        options = struct('GRtol', 1e-6);
        options.rxnNameList = modelJoint.rxns;
        options.optGRpercent = [100; 90];
        options.saveFVA = ['testSteadyComFVAsave' filesep 'test'];
        SteadyComFVA(modelJoint, options, 'feasTol', feasTol);
        % check existence of saved files
        assert(exist([options.saveFVA, '_model.mat'], 'file') & ...
            exist([options.saveFVA, '_GR0.14.mat'], 'file') & exist([options.saveFVA, '_GR0.13.mat'], 'file'))
        % check values
        refDataSaveFVA = load('refData_SteadyComFVAsave.mat');
        for j1 = {'13', '14'}
            dataSaveFVA = load([options.saveFVA, '_GR0.', j1{:}, '.mat']);
            for j2 = {'min', 'max'}
                vRef = refDataSaveFVA.([j2{:}, 'Flux', j1{:}]);
                v = dataSaveFVA.([j2{:}, 'Flux']);
                for j3 = 1:numel(vRef)
                    if abs(vRef(j3)) < 1e-5
                        assert(abs(vRef(j3) - v(j3)) < 1e-5)
                    else
                        assert(abs(vRef(j3) - v(j3)) / abs(vRef(j3)) < tolPercent)
                    end
                end
            end
        end
        % test continuation from interrupted computation
        % delete partial data
        delete([pwd filesep options.saveFVA '_GR0.13.mat'])
        dataSaveFVA = load([options.saveFVA, '_GR0.14.mat']);
        i0 = 4;
        dataSaveFVA.i0 = i0;
        [dataSaveFVA.minFlux((i0 + 1):end), dataSaveFVA.maxFlux((i0 + 1):end), ...
            dataSaveFVA.minFD(:,(i0 + 1):end), dataSaveFVA.maxFD(:,(i0 + 1):end)] = deal(0);
        save([options.saveFVA, '_GR0.14.mat'], '-struct', 'dataSaveFVA')
        [minFlux, maxFlux] = SteadyComFVA(modelJoint, options, 'feasTol', feasTol);
        for j1 = {'13', '14'}
            dataSaveFVA = load([options.saveFVA, '_GR0.', j1{:}, '.mat']);
            for j2 = {'min', 'max'}
                vRef = refDataSaveFVA.([j2{:}, 'Flux', j1{:}]);
                v = dataSaveFVA.([j2{:}, 'Flux']);
                for j3 = 1:numel(vRef)
                    if abs(vRef(j3)) < 1e-5
                        assert(abs(vRef(j3) - v(j3)) < 1e-5)
                    else
                        assert(abs(vRef(j3) - v(j3)) / abs(vRef(j3)) < tolPercent)
                    end
                end
            end
        end
        % test with already finished and saved results
        diary('SteadyComFVA_saveResults.txt');
        [minFlux2, maxFlux2] = SteadyComFVA(modelJoint, options, 'feasTol', feasTol);
        diary off;
        assert(isequal(minFlux, minFlux2) & isequal(maxFlux, maxFlux2))
        f = fopen('SteadyComFVA_saveResults.txt', 'r');
        l = fgetl(f);
        text = [];
        while ~isequal(l, -1)
            text = [text, l];
            l = fgetl(f);
        end
        fclose(f);
        assert(~isempty(strfind(text, ['FVA was already finished previously and saved in testSteadyComFVAsave' filesep 'test_GR0.'])))
        delete('SteadyComFVA_saveResults.txt');

        % test continuation from interrupted single-thread computation
        delete([pwd filesep options.saveFVA '_GR0.13.mat'])
        dataSaveFVA = load([options.saveFVA, '_GR0.14.mat']);
        i0 = 4;
        dataSaveFVA.i0 = i0;
        [dataSaveFVA.minFlux((i0 + 1):end), dataSaveFVA.maxFlux((i0 + 1):end), ...
            dataSaveFVA.minFD(:,(i0 + 1):end), dataSaveFVA.maxFD(:,(i0 + 1):end)] = deal(0);
        save([options.saveFVA, '_GR0.14.mat'], '-struct', 'dataSaveFVA')
        options.threads = 2;
        SteadyComFVA(modelJoint, options, 'feasTol', feasTol);
        for j1 = {'13', '14'}
            dataSaveFVA = load([options.saveFVA, '_GR0.', j1{:}, '.mat']);
            for j2 = {'min', 'max'}
                vRef = refDataSaveFVA.([j2{:}, 'Flux', j1{:}]);
                v = dataSaveFVA.([j2{:}, 'Flux']);
                for j3 = 1:numel(vRef)
                    if abs(vRef(j3)) < 1e-5
                        assert(abs(vRef(j3) - v(j3)) < 1e-5)
                    else
                        assert(abs(vRef(j3) - v(j3)) / abs(vRef(j3)) < tolPercent)
                    end
                end
            end
        end

        % test parallel computation
        if parWorks
            minWorkers = 2;
            myCluster = parcluster(parallel.defaultClusterProfile);
            if myCluster.NumWorkers >= minWorkers
                poolobj = gcp('nocreate');  % if no pool, do not create new one.
                if isempty(poolobj)
                    parpool(minWorkers);  % launch minWorkers workers
                end

                optionsPar = options;
                optionsPar.threads = 2;
                optionsPar.saveFVA = ['testSteadyComFVAsavePar' filesep 'test'];
                SteadyComFVA(modelJoint, optionsPar, 'feasTol', feasTol);
                % check existence of saved files
                assert(exist([optionsPar.saveFVA, '_model.mat'], 'file') > 0)
                suffix = {''; '_parInfo'; '_thread1'; '_thread2'};
                filenames = strcat(optionsPar.saveFVA, '_GR0.13', suffix, '.mat');
                filenames = [filenames; strrep(filenames, 'GR0.13', 'GR0.14')];
                for jFile = 1:numel(filenames)
                    assert(exist(filenames{jFile}, 'file') > 0)
                end
                % check values
                for j1 = {'13', '14'}
                    dataSaveFVA = load([optionsPar.saveFVA, '_GR0.', j1{:}, '.mat']);
                    for j2 = {'min', 'max'}
                        vRef = refDataSaveFVA.([j2{:}, 'Flux', j1{:}]);
                        v = dataSaveFVA.([j2{:}, 'Flux']);
                        for j3 = 1:numel(vRef)
                            if abs(vRef(j3)) < 1e-5
                                assert(abs(vRef(j3) - v(j3)) < 1e-5)
                            else
                                assert(abs(vRef(j3) - v(j3)) / abs(vRef(j3)) < tolPercent)
                            end
                        end
                    end
                end

                % test continuation from interrupted parallel computation
                for j1 = {'13', '14'}
                    for j2 = {'1', '2'}
                        dataSaveFVA = load([optionsPar.saveFVA, '_GR0.', j1{:}, '_thread', j2{:}, '.mat']);
                        if dataSaveFVA.jP == 1
                            [i0, i1] = deal(5);
                        else
                            [i0, i1] = deal(16,5);
                        end
                        dataSaveFVA.i0 = i0;
                        [dataSaveFVA.minFluxP((i1 + 1):end), dataSaveFVA.maxFluxP((i1 + 1):end), ...
                            dataSaveFVA.minFDP(:,(i1 + 1):end), dataSaveFVA.maxFDP(:,(i1 + 1):end)] = deal(0);
                        save([optionsPar.saveFVA, '_GR0.', j1{:}, '_thread', j2{:}, '.mat'], '-struct', 'dataSaveFVA')
                    end
                end
                [minFlux, maxFlux] = SteadyComFVA(modelJoint, optionsPar, 'feasTol', feasTol);
                % check values
                for j1 = {'13', '14'}
                    dataSaveFVA = load([optionsPar.saveFVA, '_GR0.', j1{:}, '.mat']);
                    for j2 = {'min', 'max'}
                        vRef = refDataSaveFVA.([j2{:}, 'Flux', j1{:}]);
                        v = dataSaveFVA.([j2{:}, 'Flux']);
                        for j3 = 1:numel(vRef)
                            if abs(vRef(j3)) < 1e-5
                                assert(abs(vRef(j3) - v(j3)) < 1e-5)
                            else
                                assert(abs(vRef(j3) - v(j3)) / abs(vRef(j3)) < tolPercent)
                            end
                        end
                    end
                end
            end
            % remove all created files

            rmdir([pwd filesep 'testSteadyComFVAsave'], 's')
            rmdir([pwd filesep 'testSteadyComFVAsavePar'], 's')
        else
            disp('Skipping Parallel Test, No Parallel toolbox installed');
        end


        % TEST SteadyComPOA
        options = struct('GRtol', 1e-6);
        options.optGRpercent = [100 90 80];
        options.savePOA = ['testSteadyComPOA' filesep 'test'];
        % look at the relationship between the abundance of Org1 and its exchange of b and c
        options.rxnNameList = [{'X_Org1'}; modelJoint.infoCom.EXsp(bCom | cCom, 1)];
        options.Nstep = 25;
        [POAtable, fluxRange, Stat, GRvector] = SteadyComPOA(modelJoint, options, 'feasTol', feasTol);
        data = load('refData_SteadyComPOA', 'POAtable', 'fluxRange', 'Stat', 'GRvector');
        devPOA = 0;  % percentage deviation
        devSt = 0;  % absolute deviation of the correlation statistics (since zeros may appear here)
        for i = 1:size(POAtable, 1)
            for j = 1:size(POAtable, 2)
                if ~isempty(POAtable{i, j})
                    devPOA = max(devPOA, max(max(max(abs(POAtable{i, j} - data.POAtable{i, j}) ./ abs(data.POAtable{i, j})))));
                    devSt = max(devSt, max(abs(Stat(i, j).cor - data.Stat(i, j).cor)));
                    devSt = max(devSt, max(abs(Stat(i, j).r2 - data.Stat(i, j).r2)));
                end
            end
        end
        assert(devPOA < tolPercent)
        assert(max(max(max(abs(fluxRange - data.fluxRange) ./ abs(data.fluxRange)))) < tolPercent)
        assert(devSt < tol)
        assert(max(abs(GRvector - data.GRvector) ./ data.GRvector) < tolPercent)

        % test loading Cplex model
        if jTest == 1
            optionsLoad = struct('GRtol', 1e-6, 'loadModel', 'testSteadyComSaveModel', ...
                'GRmax', 0.142857, 'optGRpercent', 100, 'Nstep', 25);
            optionsLoad.rxnNameList = [{'X_Org1'}; modelJoint.infoCom.EXsp(bCom | cCom, 1)];
            [POAtable2, fluxRange2, Stat2] = SteadyComPOA(modelJoint, optionsLoad, 'feasTol', feasTol);
            rmdir([pwd filesep 'POAtmp'], 's')
            optionsLoad.GR = optionsLoad.GRmax;
            [POAtable3, fluxRange3, Stat3] = SteadyComPOAgr(modelJoint, optionsLoad, [], 'feasTol', feasTol);
            rmdir([pwd filesep 'POAtmp'], 's')
            [devPOA2, devPOA3, devSt2, devSt3] = deal(0);
            for i = 1:size(POAtable2, 1)
                for j = 1:size(POAtable2, 2)
                    if ~isempty(POAtable2{i, j})
                        devPOA2 = max(devPOA, max(max(max(abs(POAtable2{i, j} - data.POAtable{i, j}(:, :, 1)) ./ abs(data.POAtable{i, j}(:, :, 1))))));
                        devSt2 = max(devSt2, max(abs(Stat2(i, j).cor - data.Stat(i, j, 1).cor)));
                        devSt2 = max(devSt2, max(abs(Stat2(i, j).r2 - data.Stat(i, j, 1).r2)));
                    end
                    if ~isempty(POAtable3{i, j})
                        devPOA3 = max(devPOA3, max(max(max(abs(POAtable3{i, j} - data.POAtable{i, j}(:, :, 1)) ./ abs(data.POAtable{i, j}(:, :, 1))))));
                        devSt3 = max(devSt3, max(abs(Stat3(i, j).cor - data.Stat(i, j, 1).cor)));
                        devSt3 = max(devSt3, max(abs(Stat3(i, j).r2 - data.Stat(i, j, 1).r2)));
                    end
                end
            end
            assert(devPOA2 < tolPercent)
            assert(max(max(max(abs(fluxRange2 - data.fluxRange(:, :, 1)) ./ abs(data.fluxRange(:, :, 1))))) < tolPercent)
            assert(devSt2 < tol)
            assert(devPOA3 < tolPercent)
            assert(max(max(max(abs(fluxRange3 - data.fluxRange(:,:, 1)) ./ abs(data.fluxRange(:, :, 1))))) < tolPercent)
            assert(devSt3 < tol)
            delete('testSteadyComSaveModel.bas', 'testSteadyComSaveModel.mps', 'testSteadyComSaveModel.prm')
        end

        % test with an infeasible model
        optionsInfeas = struct();
        optionsInfeas.rxnNameList = options.rxnNameList;
        [POAtable, fluxRange, ~, GRvector] = SteadyComPOA(modelTest, optionsInfeas);
        assert(all(all(cellfun(@isempty, POAtable))) & all(all(isnan(fluxRange))) & isnan(GRvector));

        % test contination from interrupted run (same for both parallel and single-thread computation)
        file2delete = strcat(options.savePOA, '_GR0.11', '_j1_k', {'2'; '3'}, '.mat');
        delete([options.savePOA, '_GR0.11.mat'], file2delete{:})
        [POAtable, fluxRange, Stat, GRvector] = SteadyComPOA(modelJoint, options, 'feasTol', feasTol);
        data = load('refData_SteadyComPOA', 'POAtable', 'fluxRange', 'Stat', 'GRvector');
        devPOA = 0;  % percentage deviation
        devSt = 0;  % absolute deviation of the correlation statistics (since zeros may appear here)
        for i = 1:size(POAtable, 1)
            for j = 1:size(POAtable, 2)
                if ~isempty(POAtable{i, j})
                    devPOA = max(devPOA, max(max(max(abs(POAtable{i, j} - data.POAtable{i, j}) ./ abs(data.POAtable{i, j})))));
                    devSt = max(devSt, max(abs(Stat(i, j).cor - data.Stat(i, j).cor)));
                    devSt = max(devSt, max(abs(Stat(i, j).r2 - data.Stat(i, j).r2)));
                end
            end
        end
        assert(devPOA < tolPercent)
        assert(max(max(max(abs(fluxRange - data.fluxRange) ./ abs(data.fluxRange)))) < tolPercent)
        assert(devSt < tol)
        assert(max(abs(GRvector - data.GRvector) ./ data.GRvector) < tolPercent)

        % test parallel computation
        rmdir([pwd filesep 'testSteadyComPOA'], 's')
        if parWorks
            options.threads = 2;
            [POAtable, fluxRange, Stat, GRvector] = SteadyComPOA(modelJoint, options, 'feasTol', feasTol);
            devPOA = 0;  % percentage deviation
            devSt = 0;  % absolute deviation of the correlation statistics (since zeros may appear here)
            for i = 1:size(POAtable, 1)
                for j = 1:size(POAtable, 2)
                    if ~isempty(POAtable{i, j})
                        devPOA = max(devPOA, max(max(max(abs(POAtable{i, j} - data.POAtable{i, j}) ./ abs(data.POAtable{i, j})))));
                        devSt = max(devSt, max(abs(Stat(i, j).cor - data.Stat(i, j).cor)));
                        devSt = max(devSt, max(abs(Stat(i, j).r2 - data.Stat(i, j).r2)));
                    end
                end
            end
            assert(devPOA < tolPercent)
            assert(max(max(max(abs(fluxRange - data.fluxRange) ./ abs(data.fluxRange)))) < tolPercent)
            assert(devSt < tol)
            assert(max(abs(GRvector - data.GRvector) ./ data.GRvector) < tolPercent)
            % delete created files
            rmdir([pwd filesep 'testSteadyComPOA'], 's')
        else
            warning('Skipping Parallel Test, Toolbox not installed')
        end
    end
end
% change back to the original solver if any
if ~isempty(origSolver) && ~strcmp(CBT_LP_SOLVER, origSolver)
    changeCobraSolver(origSolver, 'LP');
end

% change the directory
cd(currentDir)
