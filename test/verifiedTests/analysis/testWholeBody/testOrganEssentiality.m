% The COBRAToolbox: testOrganEssentiality.m
%
% Purpose:
%     - organEssentiality sets the LP solver, bounds the whole-body objective reaction to
%       [0, 1000] and, for each organ of OrganLists, removes the organ's biomass metabolite
%       from the whole-body objective, closes every reaction whose identifier starts with the
%       organ's name and maximises the whole-body objective with optimizeWBModel, reporting
%       the maximum and the solver status per organ. The function is quarantined for the
%       defects below. This file only opens the test; it asserts nothing about the function.
%     - The model of the reproductions (seven reactions, male): EX_a ( -> a, ub 10),
%       Heart_biomass_maintenance (a -> Heart_biomass_maintenance_dummy_objective),
%       Liver_biomass_maintenance (a -> Liver_biomass_maintenance_dummy_objective),
%       Whole_body_objective_rxn (both dummy metabolites -> ), EX_b ( -> b), Brain_x (b -> c),
%       EX_c (c -> , lb 1), built with createModel, metabolite identifiers without compartment,
%       model.sex = 'male'. With gurobi it gives 10 for Heart and Liver, 5 for every other
%       organ and NaN (infeasible) for Brain, which the construction predicts.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/organEssentiality.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LPs through optimizeWBModel on a hand-built whole-body stand-in (createModel);
%     the PSCM-validated LP solvers gurobi and ibm_cplex, whichever are available.
%
% Coverage exemptions:
%     every line - organEssentiality is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A solve without a solution stops the function with an undefined-function error
%       SEVERITY: error
%       TRIGGER: any organ whose LP returns stat -1 (time limit, numerical failure; the time
%         limit is the 100 s that optimizeWBModel sets) or 2; reproduced with a stand-in
%         optimizeWBModel first on the path that returns struct('f', NaN, 'v', [], 'stat', -1,
%         'origStat', 'TIME_LIMIT'), then organEssentiality(model, 'gurobi') with the model of
%         the Purpose
%       OBSERVED: (R2025a, 2026-11-25) "Undefined function 'fprinf' for input arguments of type
%         'char'." (MATLAB:UndefinedFunction) at line 87, after the first organ; fprinf is a
%         misspelling of fprintf
%       EXPECTED: the message and the solution are displayed, the row of the organ is filled
%         with NaN and the loop goes on to the next organ (lines 86-94)
%       LINES: 87
%     - DEFECT: The documented LPSolver value 'ILOGcomplex' stops the function with an error
%       SEVERITY: unusable-option
%       TRIGGER: organEssentiality(model, 'ILOGcomplex') with any model, e.g. the model of the Purpose
%       OBSERVED: (R2025a, 2026-11-25) changeCobraSolver('ILOGcomplex', 'LP') at line 38:
%         "changeCobraSolver: The solver ILOGcomplex is not available to the COBRA Toolbox on
%         your machine." - 'ILOGcomplex' is an interface name of the former solveCobraLPCPLEX,
%         not a COBRA solver name, and line 38 now passes LPSolver to changeCobraSolver
%       EXPECTED: the ILOG CPLEX solver is used, as the help of LPSolver lists ('ILOGcomplex',
%         'tomlab_cplex' default)
%       LINES: 38
%     - DEFECT: The status column holds the solver's own status, not the documented codes
%       SEVERITY: limitation
%       TRIGGER: organEssentiality(model, 'gurobi') with the model of the Purpose
%       OBSERVED: (R2025a, gurobi, 2026-11-25) column 4 is 'OPTIMAL' for the feasible organs
%         and 'INFEASIBLE' for Brain: num2str(FBA.origStat) is the original status of the
%         solver, which is text for gurobi
%       EXPECTED: the documented codes (1 feasible, 5 feasible with numerical difficulties,
%         3 infeasible), which only CPLEX returns
%       LINES: 83, 94
%     - DEFECT: The time per organ is printed in exponential notation
%       SEVERITY: cosmetic
%       TRIGGER: organEssentiality(model, 'gurobi') with the model of the Purpose
%       OBSERVED: (R2025a, gurobi, 2026-11-25) "2.985500e-02 sec. Heart obj = 10.000000": the
%         seconds (not an integer) are printed with %u
%       EXPECTED: "0.029855 sec. Heart obj = 10.000000"
%       LINES: 69
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOrganEssentiality'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file runs no
% solver; the call is the standard opening of a COBRA test and the place where the
% requirements (an LP solver validated for the PSCM toolbox) are added when the test is
% written
prepareTest();

% change the directory
cd(currentDir)
