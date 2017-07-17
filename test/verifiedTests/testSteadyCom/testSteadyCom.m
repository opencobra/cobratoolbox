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

% initialize the test
fileDir = fileparts(which('testSteadyCom'));
cd(fileDir);

% create a toy model
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
modelJoint = createMultipleSpeciesModel({org1; org2}, {'Org1'; 'Org2'});

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
diary('printUptakeBoundCom.txt');
printUptakeBoundCom(modelJoint, 1);
diary off;

text1 = importdata('printUptakeBoundCom.txt');
text2 = importdata('refData_printUptakeBoundCom.txt');
assert(isequal(text1, text2));
delete('printUptakeBoundCom.txt');  % remove the generated file

% TEST createMultipleSpeciesModel and printUptakeBoundCom with a model with host organism
% build a model with host
modelWtHost = createMultipleSpeciesModel({org1; org2}, {'Org1'; 'Org2'}, org1, 'Org3');
% get IDs
[modelWtHost.infoCom, modelWtHost.indCom] = getMultiSpeciesModelId(modelWtHost, {'Org1'; 'Org2'}, 'Org3');
% change some uptake bounds
modelWtHost = changeRxnBounds(modelWtHost, modelWtHost.infoCom.EXcom(aCom), -10, 'l');
modelWtHost = changeRxnBounds(modelWtHost, modelWtHost.infoCom.EXcom(bCom | cCom), 0, 'l');
modelWtHost = changeRxnBounds(modelWtHost, modelWtHost.infoCom.EXsp(bCom | cCom, :), -5, 'l');
modelWtHost = changeRxnBounds(modelWtHost, modelWtHost.infoCom.EXhost(bCom | cCom, :), -5, 'l');
modelWtHost = changeRxnBounds(modelWtHost, modelWtHost.infoCom.EXhost(aCom, :), 0, 'l');
% print uptake bounds and compare
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
modelWtBiomass = createMultipleSpeciesModel({model; model}, nameTags);
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
        solverPrefer = {'gurobi'; 'glpk'; 'tomlab_cplex'; 'cplex_direct'; 'mosek'; 'dqqMinos'; 'quadMinos'}; 
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
        if ~cont
            cont = changeCobraSolver(origSolver, 'LP');
        end
    end

    if cont
        switch CBT_LP_SOLVER
            case {'gurobi', 'ibm_cplex', 'tomlab_cplex', 'cplex_direct', 'glpk', 'dqqMinos', 'quadMinos'}
                feasTol = 1e-8;  % feasibility tolerance
                tol = 1e-3;  % tolerance for comparing results
            case {'mosek', 'matlab'}
                feasTol = 1e-6;  % feasibility tolerance
                tol = 1e-3;  % tolerance for comparing results
            otherwise
                feasTol = 1e-4;  % feasibility tolerance
                tol = 1e-2;  % tolerance for comparing results
        end

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
        options = struct('feasCrit', 2, 'solveGR0', true, 'algorithm', 2);
        [~, resultFC] = SteadyCom(modelJoint, options, 'feasTol', feasTol);
        assert(abs(resultFC.GRmax - 0.166663) < tol);
        
        % test options given by name-value arguments
        diary('SteadyCom_saveModel.txt');
        [~, resultNVarg] = SteadyCom(modelJoint, [], 'printLevel', 0, 'minNorm', 1, 'saveInput', 'testSteadyComSaveModel');
        diary off;
        % check max. growth rate and sum of absolute fluxes
        assert(abs(resultNVarg.GRmax - 0.142857) < tol);
        assert(abs(sum(abs(resultNVarg.flux)) - 53.6493) / 53.6493 < tol)
        % check that nothing is printed
        text1 = importdata('SteadyCom_saveModel.txt');
        assert(isempty(text1));
        delete('SteadyCom_saveModel.txt');
        % check saved files
        if jTest == 1
            assert(exist('testSteadyComSaveModel.bas', 'file') & exist('testSteadyComSaveModel.mps', 'file') ...
                & exist('testSteadyComSaveModel.prm', 'file'))
            delete('testSteadyComSaveModel.bas', 'testSteadyComSaveModel.mps', 'testSteadyComSaveModel.prm')
        else
            assert(logical(exist('testSteadyComSaveModel.mat', 'file')))
            delete('testSteadyComSaveModel.mat')
        end
        
        % test an infeasible model
        % require export of B by organism 1 and export of C by organism 2
        modelTest = changeRxnBounds(modelJoint, modelJoint.infoCom.EXsp(bCom, 1), 0.1, 'l');
        modelTest = changeRxnBounds(modelTest, modelTest.infoCom.EXsp(cCom, 2), 0.1, 'l');
        [~, resultInfeas] = SteadyCom(modelTest, options);
        assert(strcmp(resultInfeas.stat, 'infeasible'))
        
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
        
        % TEST SteadyComFVA
        options = struct('GRtol', 1e-6);
        options.optGRpercent = [100 90 80];
        options.rxnNameList = {'X_Org1'; 'X_Org2'};
        [minFlux, maxFlux, ~, ~, GRvector] = SteadyComFVA(modelJoint, options, 'feasTol', feasTol);
        data = load('refData_SteadyComFVA', 'minFlux', 'maxFlux', 'GRvector');

        % Different solvers may give slightly different results. Give a percentage tolerance
        assert(max(max(abs(minFlux - data.minFlux) ./ data.minFlux)) < tol)
        assert(max(max(abs(maxFlux - data.maxFlux) ./ data.maxFlux)) < tol)
        assert(max(abs(GRvector - data.GRvector) ./ data.GRvector) < tol)

        % TEST SteadyComPOA
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
        assert(devPOA < tol)
        assert(max(max(max(abs(fluxRange - data.fluxRange) ./ abs(data.fluxRange)))) < tol)
        assert(devSt < tol)
        assert(max(abs(GRvector - data.GRvector) ./ data.GRvector) < tol)
        % delete created files
        rmdir([pwd filesep 'testSteadyComPOA'], 's')
    end
end
% change back to the original solver
if ~strcmp(CBT_LP_SOLVER, origSolver)
    changeCobraSolver(origSolver, 'LP');
end

% change the directory
cd(currentDir)
