% The COBRAToolbox: testFindOptExchRxns.m
%
% Purpose:
%     - findOptExchRxns(model, Ex_Rxns, parFVA) runs flux variability (1% of the optimum) on
%       the exchange reactions Ex_Rxns and returns those that are neither obligate uptake
%       nor obligate secretion. The function is quarantined for the defects below: this file
%       asserts nothing about it.
%
% Function under test:
%     src/dataIntegration/metabotools/findOptExchRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - flux variability (LP) (quarantined: no solver is used here).
%
% Coverage exemptions:
%     every line - findOptExchRxns is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An exchange that can both take up and secrete is returned twice
%       SEVERITY: wrong-result
%       TRIGGER: any exchange in Ex_Rxns whose flux range includes values below -1e-6 and
%         above 1e-6; reproduction: model = createModel({'EX_a'; 'EX_b'; 'T'}, {''; ''; ''},
%         {'a[e] <=> '; 'b[e] <=> '; 'a[e] <=> b[e]'}, 'printLevel', 0); model.c(:) = 0;
%         OptExchRxns = findOptExchRxns(model, {'EX_a'; 'EX_b'})
%       OBSERVED: (R2025a, 2026-11-25, gurobi) OptExchRxns = {'EX_a'; 'EX_b'; 'EX_a'; 'EX_b'}:
%         line 44 concatenates the reactions that can take up (OptUptake) and those that can
%         secrete (OptSecr), and a reversible exchange is in both. With T irreversible
%         (lower bound 0: EX_a uptake only, EX_b secretion only) the result is {'EX_a'; 'EX_b'}
%       EXPECTED: each exchange that is neither obligate uptake nor obligate secretion once
%         (help text); the caller generateCompactExchModel compares length(OptExchRxns)
%         between iterations
%       LINES: 35-44
%     - DEFECT: Ex_Rxns given as a row vector gives a matrix of names or stops
%       SEVERITY: error
%       TRIGGER: Ex_Rxns as a row cell array ("Vector of exchange reactions" in the help);
%         with the model above: findOptExchRxns(model, {'EX_a', 'EX_b'}); with six exchanges
%         {'EX_up', 'EX_opt', 'EX_sec', 'EX_oblsec', 'EX_bi', 'EX_blk'} of a hand-built model
%         whose FVA ranges are [-10,-1], [-10,-1], [1,10], [1,10], [-10,8], [0,0]
%       OBSERVED: (R2025a, 2026-11-25, gurobi) a 2x2 cell array {'EX_a', 'EX_b'; 'EX_a',
%         'EX_b'} for the first call; "Dimensions of arrays being concatenated are not
%         consistent." at line 37 for the second: the row results of lines 36 and 41 are
%         stacked with ";"
%       EXPECTED: the same list as for the column vector
%       LINES: 36-37, 41-42, 44
%     - DEFECT: The documented option parFVA has no effect
%       SEVERITY: unusable-option
%       TRIGGER: findOptExchRxns(model, Ex_Rxns, 1)
%       OBSERVED: (R2025a, 2026-11-25) parFVA is only compared with 0 (line 25) and sets the
%         unused variable matlabpool; the call of line 32 is the same for every parFVA, so
%         the analysis is never parallelised by this option (the same result and the same
%         solver calls as with parFVA = 0)
%       EXPECTED: parFVA = 1 uses parallelization of the flux variability analysis (help text)
%       LINES: 25-29, 32
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindOptExchRxns'));
cd(fileDir);

% findOptExchRxns is quarantined: the standard opening only, no requirement is declared
% because nothing is solved
prepareTest();

% change the directory
cd(currentDir)
