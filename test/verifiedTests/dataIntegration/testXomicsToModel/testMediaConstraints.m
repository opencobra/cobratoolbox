% The COBRAToolbox: testMediaConstraints.m
%
% Purpose:
%     - mediaConstraints(model, uptakeRates, uptakeInChi, uptakeNames) maps measured
%       metabolites to model metabolites by InChI and sets the highest uptake rate of each as
%       the lower bound of its EX_ exchange reaction. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): the lower bound it sets is 1e4 times
%       the uptake rate, not the rate the help text describes; no assertion about the function
%       is made. No src/ function calls mediaConstraints (2026-11-23).
%
% Function under test:
%     src/dataIntegration/XomicsToModel/metabolomics/mediaConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a small hand-built model (createModel) with InChI strings, no solver.
%
% Coverage exemptions:
%     every line - mediaConstraints is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The lower bound set is 1e4 times the highest uptake rate
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'EX_a','EX_b','EX_c','R1','DM_d'}, {'a','b','c','d','e'},
%         {' a[e] <=> ',' b[e] <=> ',' c[e] <=> ','a[e] + b[e] -> c[e] + d[c]','d[c] -> '},
%         'lowerBoundList', [-10 -10 -10 0 0], 'upperBoundList', [10 10 10 10 10]);
%         model.metInChIString = {'InChI=a'; 'InChI=b'; 'InChI=c'; 'InChI=d'};
%         m2 = mediaConstraints(model, [-2 -3; 1 4; -1 5], {'InChI=a'; 'InChI=c'; 'InChI=z'},
%         {'nameA'; 'nameC'; 'nameZ'})
%       OBSERVED: (R2025a, 2026-11-23) m2.lb(1) (EX_a) = -30000 for the uptake rates -2 and -3;
%         line 37 multiplies min(min(Rates(i,:)), 0) by 1e4, a factor the help text does not
%         mention (the secretion-only metabolite c correctly gets lower bound 0, the unmapped
%         name nameZ is returned in metsUnmapped)
%       EXPECTED: m2.lb(1) = -3, the highest uptake rate set as the lower bound, as the help text
%         (and the original description: "sets this value as a lower boundary") says
%       LINES: 37
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMediaConstraints'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and is not called, so
% none is listed; the call is the standard opening of a COBRA test and the place where a
% requirement would be added once the defect is fixed
prepareTest();

% change the directory
cd(currentDir)
