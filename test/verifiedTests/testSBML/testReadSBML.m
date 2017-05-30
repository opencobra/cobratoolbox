% The COBRAToolbox: testReadSBML.m
%
% Purpose:
%     - reads all the sbml files in this folder and
%       checks if all the parameters are correctly written
%     - loads certain xml files, runs and FBA, and compares the
%       solution to pre-calculated values from FBAs run with .mat files
%
% Authors:
%     - Partial original file: Joseph Kang 04/07/09
%     - CI integration: Laurent Heirendt
%
% Note:
%     - The solver libraries must be included separately

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadSBML'));
cd(fileDir);
%{
% load the test models
testModel = readCbModel('Ec_iJR904.xml');
load('Ec_iJR904.mat', 'model');

% test the sizes of the .mat model and the .xml model
assert(length(model.rxns) == length(testModel.rxns))
assert(length(model.mets) == length(testModel.mets))
assert(size(model.S, 1) == size(testModel.S, 1))
assert(size(model.S, 2) == size(testModel.S, 2))
assert(length(model.lb) == length(testModel.lb))
assert(length(model.ub) == length(testModel.ub))
assert(length(model.c) == length(testModel.c))
assert(length(model.rules) == length(testModel.rules))
assert(length(model.genes) == length(testModel.genes))
assert(length(model.rxnGeneMat) == length(testModel.rxnGeneMat))
assert(length(model.grRules) == length(testModel.grRules))
assert(length(model.subSystems) == length(testModel.subSystems))
assert(length(model.rxnNames) == length(testModel.rxnNames))
assert(length(model.metNames) == length(testModel.metNames))
assert(length(model.metFormulas) == length(testModel.metFormulas))
assert(length(model.b) == length(testModel.b))

% initialize the test
cd([CBTDIR, filesep, 'test', filesep, 'models']);

% define the solver packages to be used to run this test
solverPkgs = {'gurobi6', 'tomlab_cplex', 'glpk'};


% load the models
modelArr = {'Abiotrophia_defectiva_ATCC_49176.xml', 'STM_v1.0.xml', 'iIT341.xml', 'Ec_iAF1260_flux1.xml'};

% loop through the models
for i = 1:length(modelArr)
    %reading the models takes quite a bit of time, so only do it once for
    %all solvers.
    % output a line before launching the test for model i
    fprintf('   Testing %s ...\n', modelArr{i});

    % load the model (actually supply the full filename of the path
    % where the model is found)
    model = readCbModel(which(modelArr{i}));

    for k = 1:length(solverPkgs)

        % set the solver
        solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

        if solverOK == 1
            fprintf('   Testing with solver %s ... \n', solverPkgs{k});

            % set the tolerance
            tol = 1e-6;


            % define the maximum objective values calculated from pre-converted .mat files
            modelFBAf_max = [0.149475406282249; 0.477833660760744; 0.692812693473487; 0.736700938865275];

            % define the minimum objective values
            modelFBAf_min = [0.0; 0.0; 0.0; 0.0];

            % solve the maximisation problem
            FBA = optimizeCbModel(model, 'max');

            % test the maximisation solution
            assert(FBA.stat == 1);
            assert(abs(FBA.f - modelFBAf_max(i)) < tol);
            assert(norm(model.S * FBA.x) < tol);

            % solve the minimisation problem
            FBA = optimizeCbModel(model, 'min');

            % test the minimisation solution
            assert(FBA.stat == 1);
            assert(abs(FBA.f - modelFBAf_min(i)) < tol);
            assert(norm(model.S * FBA.x) < tol);

            % print a line for success of loop i
            fprintf(' Done.\n');
        end
    end
end
%}
% test reading COBRA models with symbols in objective reactions and multiple objective reactions
for jTest = 1:2
    if jTest == 1
        % test objective reactions with symbols
        fprintf('   Testing readSBML for models with symbols in objective reactions ...\n');
        model = createModel({'EX_a(e)'; 'EX_b(e)'}, {'Test A'; 'Test B'}, {'a[e] <=>'; 'b[e] <=>'});
        model.c = [1; 0];

    elseif jTest == 2
        % test more than one objective reactions with >1 objective reactions
        fprintf('   Testing readSBML for models with >1 objective reactions ...\n');
        model = createModel({'EX_a'; 'EX_b'}, {'Test A'; 'Test B'}, {'a[e] <=>'; 'b[e] <=>'});
        model.c = [1; -2];
    end

    model.lb = model.lb(:);
    model.ub = model.ub(:);

    % add the fields outputted by readSBML
    [model.modelVersion.SBML_level, model.modelVersion.SBML_version, model.modelVersion.fbc_version] = deal(3, 1, 2);
    metField = {; 'metChEBIID'; 'metHMDBID'; 'metInChIString'; 'metKEGGID'; 'metPubChemID'};

    for j = 1:numel(metField)
        model.(metField{j}) = repmat({''}, numel(model.mets), 1);
    end

    model.metCharges = zeros(numel(model.mets), 1);
    model.metFormulas = {'C'; 'C'};
    rxnField = {'rxnConfidenceScores'; 'rxnECNumbers'; 'rxnNotes'; 'rxnReferences'};

    for j = 1:numel(rxnField)
        model.(rxnField{j}) = repmat({''}, numel(model.rxns), 1);
    end

    model.osense = -1;
    model.description = 'test_sbml_obj.xml';
    model.genes = {'gene1'; 'gene2'};
    model.rules = {''; ''};
    model.rxnGeneMat = zeros(2, 2);

    model = convertOldStyleModel(model);

    % write the model
    writeCbModel(model, 'sbml', 'test_sbml_obj');


    % read in the model
    model2 = readCbModel('test_sbml_obj.xml');

    % explicit testing of each field (eases debugging)
    assert(isequal(model.S, model2.S));
    assert(isequal(model.b, model2.b));
    assert(isequal(model.csense, model2.csense));
    assert(isequal(model.lb, model2.lb));
    assert(isequal(model.ub, model2.ub));
    assert(isequal(model.c, model2.c));
    assert(isequal(model.osense, model2.osense));
    assert(isequal(model.rxns, model2.rxns));
    assert(isequal(model.mets, model2.mets));
    assert(isequal(model.genes, model2.genes));
    assert(isequal(model.rules, model2.rules));
    assert(isequal(model.metCharges, model2.metCharges));
    assert(isequal(model.metFormulas, model2.metFormulas));
    assert(isequal(model.metNames, model2.metNames));
    assert(isequal(model.metHMDBID, model2.metHMDBID));
    assert(isequal(model.metInChIString, model2.metInChIString));
    assert(isequal(model.metKEGGID, model2.metKEGGID));
    assert(isequal(model.metChEBIID, model2.metChEBIID));
    assert(isequal(model.metPubChemID, model2.metPubChemID));
    assert(isequal(model.description, model2.description));
    assert(isequal(model.modelVersion, model2.modelVersion));
    assert(isequal(model.grRules, model2.grRules));
    assert(isequal(model.rxnGeneMat, model2.rxnGeneMat));
    assert(isequal(model.rxnConfidenceScores, model2.rxnConfidenceScores));
    assert(isequal(model.rxnNames, model2.rxnNames));
    assert(isequal(model.rxnNotes, model2.rxnNotes));
    assert(isequal(model.rxnECNumbers, model2.rxnECNumbers));
    assert(isequal(model.rxnReferences, model2.rxnReferences));
    assert(isequal(model.subSystems, model2.subSystems));

    % check the model structures
    assert(isequal(model, model2));
    fprintf(' Done.\n\n');
end
delete('test_sbml_obj.xml')

% change the directory
cd(currentDir)
