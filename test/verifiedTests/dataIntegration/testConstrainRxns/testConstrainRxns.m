function tests = testConstrainRxns
    % - tests whether quadratic relaxation works
    %   in a gecko-style model (model with extra variables
    %   and matrices C,D and E):
    %   * a bound of an extra variable can be relaxed by
    %     quadratic relaxation.
    %   * model is feaible after relaxation 
    tests = functiontests(localfunctions);
end
function setupOnce(testCase)
    % create structure wih results to be used by test functions
    
    % create toy gecko style model
    [model, specificData, param] = createToyGeckoModel();
    % specificData.exoMet contains
    % experimental data (mean, sd) for the extra variable/enzyme usage. 
    % param.weight*_e_default are the default values of weight for
    % lb/ub relaxation of all enzyme usage/extra variables.
    % specific weights can be given to specific variables when
    % param.weight*_e_default is a vector

    % apply quadratic relaxation
    [relaxModel, ~, ~, ~] = ...
        constrainRxns(model, specificData, param, 'allConstraints', 0); % 0 is printLevel

    % simulate LP after relaxation
    LP = buildOptProblemFromModel(relaxModel, true, struct());
    sol = solveCobraLP(LP);
    
    testCase.TestData.model = model;
    testCase.TestData.relaxModel = relaxModel;
    testCase.TestData.solution = sol;
end

function testFeasAfterRelax(testCase)
    sol = testCase.TestData.solution;
    testCase.assertEqual(sol.stat, 1);
end

function testExtVarUpBdRelax(testCase)
    relaxModel = testCase.TestData.relaxModel;
    % ub of epool was 1 but experimental mean was 10, so a relaxation is
    % expected on the upper bound:
    epoolEvarIdx = strcmp(relaxModel.evars, 'epool');
    isrelaxEvarUb = relaxModel.exometRelaxation.evarupperBoundBool; % true when ub was relaxed
    testCase.assertTrue(isrelaxEvarUb(epoolEvarIdx));
end

function testEnzUsgFlxCoupling(testCase)
    % test wether enzyme usage and reaction flux coupling in gecko model
    % (coupling constraints with extra variables) is kept:

    relaxModel = testCase.TestData.relaxModel;
    relaxSol = testCase.TestData.solution;

    nRxn = numel(relaxModel.rxns);
    solFlx = relaxSol.full(1:nRxn);
    solEzUsg = relaxSol.full(nRxn+1:end);
    
    v1Idx = ismember(relaxModel.rxns, 'v1');
    v2Idx = ismember(relaxModel.rxns, 'v2');
    e1Idx = ismember(relaxModel.evars, 'e1');
    e2Idx = ismember(relaxModel.evars, 'e2');
    epoolIdx = ismember(relaxModel.evars, 'epool');
    tol = 1e-6;
    testCase.verifyLessThanOrEqual(abs(solFlx(v1Idx) - solEzUsg(e1Idx)), tol); % v1 - e1 = 0
    testCase.verifyLessThanOrEqual(abs(solFlx(v2Idx) - solEzUsg(e2Idx)), tol); % v2 - e2 = 0
    testCase.verifyLessThanOrEqual(abs(solEzUsg(e1Idx) + solEzUsg(e2Idx) - solEzUsg(epoolIdx)), tol); % e1 + e2 - epool = 0
end