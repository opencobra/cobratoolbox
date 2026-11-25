% The COBRAToolbox: testOptStoic.m
%
% Purpose:
%     - tests loadOptStoicDatabase on the database of optstoic-gams
%       (Chowdhury and Maranas, 2015) distributed with the toolbox
%     - tests optStoic against the outputs of the GAMS implementation
%       (optStoic_output.csv: maximum yield of acetate and 1,3-propanediol
%       from glucose) and its options: enumeration of alternative
%       stoichiometries, maximum number of metabolites, integer
%       coefficients, minimization, objective weights, bounds, elements and
%       wrong inputs
%     - tests minFlux on the database against the output of the GAMS
%       implementation (minFlux_output.txt: glucose -> 3 acetate). Since
%       this MILP takes several minutes with GLPK, it is only solved with
%       commercial solvers
%
% Authors:
%     - Sebastián N. Mendoza, 13/10/2026
%     - COBRA test format, options and wrong inputs: Sebastián N. Mendoza, 24/11/2026
%

global CBTDIR

% require LP and MILP solvers (no MATLAB toolbox is needed)
solvers = prepareTest('needsLP', true, 'needsMILP', true, 'useSolversIfAvailable', {'glpk', 'gurobi', 'ibm_cplex'});

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% set the tolerance
tol = 1e-6;

% load the database of optstoic-gams
dataDir = fullfile(fileparts(which('loadOptStoicDatabase')), 'optstoic-gams', 'data');
database = loadOptStoicDatabase(dataDir, 'printLevel', 0);
assert(numel(database.mets) == 5752 && numel(database.rxns) == 6871);
assert(sum(database.lb == 0 & database.ub > 0) == 1850 && sum(database.lb < 0 & database.ub > 0) == 4331);
assert(sum(database.lb < 0 & database.ub == 0) == 300 && sum(database.lb == 0 & database.ub == 0) == 390);
assert(numel(database.incorrectStoichRxns) == 388 && numel(database.blockedRxns) == 4211);
% metabolites with formula and known Gibbs free energy of formation
hasData = database.metHasFormula & ~isnan(database.metDeltaGf);
assert(sum(database.metHasFormula) == 4933 && sum(hasData) == 4258);
glc = strcmp(database.mets, 'C00267');
assert(strcmp(database.metFormulas{glc}, 'C6H12O6') && abs(database.metDeltaGf(glc) + 218.28) < tol);
assert(strcmp(database.metNames{glc}, 'Glucose'));
ac = strcmp(database.mets, 'C00033');
assert(strcmp(database.metFormulas{ac}, 'C2H3O2') && database.metCharges(ac) == -1 && strcmp(database.metNames{ac}, 'ACET'));
% annotations of reaction_db.xlsx
ack = strcmp(database.rxns, 'R00315');
assert(strcmp(database.rxnNames{ack}, 'ATP:acetate phosphotransferase') && strcmp(database.rxnAbbreviations{ack}, 'ACK'));
assert(strcmp(database.rxnECNumbers{ack}, '2.7.2.1|2.7.2.15') && abs(database.rxnDeltaGr(ack) - 11.5) < tol);
assert(database.lb(ack) == -1000 && database.ub(ack) == 1000);
assert(database.lb(strcmp(database.rxns, 'R00317')) == 0);
assert(all(database.lb(strcmp(database.rxns, 'NAD_ATP')) == 0 & database.ub(strcmp(database.rxns, 'NAD_ATP')) == 0));

allowedMets = {'C00007', 'C00267', 'C00011', 'C00080', 'C00001', 'C02457', 'C00033'};
% metabolite with formula but unknown Gibbs free energy of formation
unknownMet = database.mets{find(database.metHasFormula & isnan(database.metDeltaGf), 1)};

for k = 1:numel(solvers.MILP)
    fprintf(' -- Running testOptStoic using the solver interface: %s ... ', solvers.MILP{k});
    solverOK = changeCobraSolver(solvers.MILP{k}, 'LP', 0) && changeCobraSolver(solvers.MILP{k}, 'MILP', 0);
    if solverOK
        % example 1 of optStoic.gms: glucose -> acetate
        sol = optStoic(database, 'C00267', {'C00033', 'C02457'}, 'allowedMets', allowedMets, ...
            'boundMets', {'C00007', 'C02457', 'C00033'}, 'boundLB', [0, 0, 1], 'boundUB', [0, 0, 15], 'printLevel', 0);
        assert(sol.stat == 1 && abs(sol.objValue - 3) < tol && abs(sol.dGrNormalized + 75.18) < tol);
        assert(abs(sol.stoichiometry(strcmp(sol.allowedMets, 'C00080')) - 3) < tol);
        assert(isequal(sol.mets, {'C00267'; 'C00080'; 'C00033'}) && isequal(sol.coefs, [-1; 3; 3]));
        assert(strcmp(sol.equation, '1 C00267 -> 3 C00080 + 3 C00033'));
        assert(strcmp(sol.equationNames, '1 Glucose -> 3 H+ + 3 ACET'));
        % database without metabolite names: the equation uses the IDs
        sol = optStoic(rmfield(database, 'metNames'), 'C00267', {'C00033'}, 'allowedMets', allowedMets, ...
            'boundMets', {'C00007', 'C02457'}, 'boundLB', [0, 0], 'boundUB', [0, 0], 'printLevel', 0);
        assert(strcmp(sol.equationNames, sol.equation) && isequal(sol.metNames, sol.mets));
        % example 2 of optStoic.gms: glucose -> 1,3-propanediol
        sol = optStoic(database, 'C00267', {'C00033', 'C02457'}, 'allowedMets', allowedMets, ...
            'boundMets', {'C00007', 'C02457', 'C00033'}, 'boundLB', [-15, 1, 0], 'boundUB', [0, 15, 0], 'printLevel', 0);
        assert(sol.stat == 1 && abs(sol.objValue - 1.5) < tol && abs(sol.dGrNormalized + 37.32) < tol);
        assert(abs(sol.stoichiometry(strcmp(sol.allowedMets, 'C00011')) - 1.5) < tol);

        % enumeration of alternative stoichiometries: after the first one, the
        % only participating optional metabolite (H+) must be excluded, which
        % is infeasible
        output = evalc(['sol = optStoic(database, ''C00267'', ''C00033'', ''allowedMets'', allowedMets, ', ...
            '''boundMets'', {''C00007'', ''C02457''}, ''boundLB'', [0, 0], ''boundUB'', [0, 0], ''nSolutions'', 4);']);
        assert(numel(sol) == 1 && abs(sol.objValue - 3) < tol && contains(output, 'optStoic solution 1'));
        % no participating optional metabolite: the enumeration stops
        sol = optStoic(database, 'C00267', {'C00033'}, 'allowedMets', allowedMets, 'boundMets', {'C00007', 'C02457'}, ...
            'boundLB', [0, 0], 'boundUB', [0, 0], 'optionalMets', {'C00011'}, 'nSolutions', 2, 'printLevel', 0);
        assert(numel(sol) == 1);
        % maximum number of optional metabolites
        sol = optStoic(database, 'C00267', {'C00033'}, 'allowedMets', allowedMets, 'boundMets', {'C00007', 'C02457'}, ...
            'boundLB', [0, 0], 'boundUB', [0, 0], 'maxNumMets', 1, 'printLevel', 0);
        assert(sol.stat == 1 && abs(sol.objValue - 3) < tol);
        % integer coefficients with 2 moles of glucose
        sol = optStoic(database, 'C00267', {'C02457'}, 'allowedMets', allowedMets, 'boundMets', {'C00007', 'C00033'}, ...
            'boundLB', [-15, 0], 'boundUB', [0, 0], 'integerCoefficients', true, 'normalizationValue', -2, 'printLevel', 0);
        assert(sol.stat == 1 && abs(sol.objValue - 3) < tol && isequal(sol.coefs, [-2; 3; 3]));
        assert(abs(sol.dGr + 74.64) < tol && abs(sol.dGrNormalized + 37.32) < tol);
        % minimization without charge balance and with given elements
        sol = optStoic(database, 'C00267', {'C00011'}, 'allowedMets', allowedMets, 'osenseStr', 'min', ...
            'boundMets', {'C00007'}, 'boundLB', 0, 'boundUB', 0, 'balanceCharge', false, 'elements', {'C', 'H', 'O'}, ...
            'printLevel', 0);
        assert(sol.stat == 1 && abs(sol.objValue + 11.3457) < 1e-3);
        % objective weights and default bounds of the coefficients
        sol = optStoic(database, 'C00267', {'C00033', 'C02457'}, 'objectiveWeights', [1, 2], 'allowedMets', allowedMets, ...
            'boundMets', {'C00007'}, 'boundLB', 0, 'boundUB', 0, 'defaultBounds', [-5, 5], 'printLevel', 0);
        assert(sol.stat == 1 && abs(sol.objValue - 3) < tol);
        assert(all(abs(sol.stoichiometry) <= 5 + tol) && sol.dGrNormalized <= -5 + tol);
        % infeasible conversion
        output = evalc(['sol = optStoic(database, ''C00267'', {''C00033''}, ''allowedMets'', allowedMets, ', ...
            '''boundMets'', {''C00007''}, ''boundLB'', 0, ''boundUB'', 0, ''dGmax'', -1000);']);
        assert(numel(sol) == 1 && sol.stat ~= 1 && contains(output, 'no optimal solution'));
        % all metabolites with formula and known Gibbs free energy of formation
        sol = optStoic(database, 'C00267', {'C00033'}, 'printLevel', 0);
        assert(sol.stat == 1 && numel(sol.allowedMets) == 4258 && ~ismember(unknownMet, sol.allowedMets));
        assert(sol.objValue <= 15 + tol && sol.dGrNormalized <= -5 + tol);

        % minFlux: first pathway of minFlux_output.txt (glucose -> 3 acetate)
        if ismember(solvers.MILP{k}, {'gurobi', 'ibm_cplex'})
            pathways = optStoicMinFlux(database, {'C00267', 'C00033'}, [-1, 3], 'flexibleMets', {'C00080'}, ...
                'flexibleBounds', [-10, 10], 'nSolutions', 2, 'printLevel', 0);
            refRxns = {'R00315'; 'R00317'; 'R00760'; 'R00761'; 'R00878'; 'R01015'; 'R01056'; 'R01529'; ...
                'R01621'; 'R01641'; 'R01829'; 'R01845'};
            refFluxes = [-1; 2; 1; 1; 1; 1; 1; 1; 2; 1; -1; 1];
            assert(isequal(pathways(1).rxns, refRxns) && isequal(pathways(1).fluxes, refFluxes));
            assert(pathways(1).totalFlux == 14 && abs(pathways(1).objValue - 14) < tol);
            assert(isequal(pathways(1).exchangeFluxes(1:2), [-1; 3]));
            assert(strcmp(pathways(1).table.abbreviation{1}, 'ACK'));
            assert(numel(pathways) == 2 && pathways(2).totalFlux == 15);
        end
    end
    fprintf('Done.\n');
end

% wrong inputs (checked before solving)
assert(verifyCobraFunctionError('optStoic', 'inputs', {database, 'C00267', {'C00033'}, 'objectiveWeights', [1, 2]}));
assert(verifyCobraFunctionError('optStoic', 'inputs', {database, 'C00267', {'C00033'}, 'boundMets', {'C00011'}}));
assert(verifyCobraFunctionError('optStoic', 'inputs', {database, 'C00267', {'C00033'}, 'allowedMets', {'X00000'}}));
assert(verifyCobraFunctionError('optStoic', 'inputs', {database, 'C00267', {'C00033'}, 'allowedMets', {unknownMet}}));
assert(verifyCobraFunctionError('optStoic', 'inputs', {database, 'C00267', {'C00033'}, 'allowedMets', allowedMets, ...
    'boundMets', {'C00022'}, 'boundLB', 0, 'boundUB', 1}));
assert(verifyCobraFunctionError('optStoic', 'inputs', {database, 'C00267', {'C00033'}, 'allowedMets', allowedMets, ...
    'elements', {'Xx'}}));
assert(verifyCobraFunctionError('optStoic', 'inputs', {database, 'C00267', {'C00033'}, 'allowedMets', allowedMets, ...
    'boundMets', {'C00011'}, 'boundLB', 1, 'boundUB', 0}));
assert(verifyCobraFunctionError('optStoic', 'inputs', {database, 'C00267', {'C00033'}, 'allowedMets', allowedMets, ...
    'nSolutions', 2, 'optionalMets', {'C00022'}}));
assert(verifyCobraFunctionError('optStoic', 'inputs', {database, 'C00267', {'C00033'}, 'normalizationValue', 0}));

% change the directory
cd(currentDir)
