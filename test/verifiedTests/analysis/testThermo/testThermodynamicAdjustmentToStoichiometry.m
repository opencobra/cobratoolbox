% The COBRAToolbox: testThermodynamicAdjustmentToStoichiometry.m
%
% Purpose:
%     - thermodynamicAdjustmentToStoichiometry(model) rewrites the formula of carbon dioxide as
%       H2CO3, adds one H2O to the other side of every internal reaction for each CO2 it
%       involves (Alberty 2003, p150), keeps the original matrix in model.oldS, and, in each
%       compartment with fad, fadh2, fum and succ, replaces FAD/FADH2 in succinate dehydrogenase
%       by enzyme-bound species with two new binding reactions. Quarantined: no behaviour of
%       thermodynamicAdjustmentToStoichiometry is asserted until the defects below are fixed.
%
% Function under test:
%     src/analysis/thermo/reactantContribution/thermodynamicAdjustmentToStoichiometry.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; a test would use a hand-built model with S, mets,
%     rxns, metFormulas, metNames, rxnNames, subSystems and SIntRxnBool.
%
% Coverage exemptions:
%     every line - thermodynamicAdjustmentToStoichiometry is quarantined for the defects below
%     (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call stops at getCompartment with Too many input arguments
%       SEVERITY: error
%       TRIGGER: any call that passes the carbon dioxide step, for example model.S =
%         sparse([-1; 1]), mets {'a[c]'; 'b[c]'}, rxns {'r1'}, metFormulas {'C'; 'C'},
%         metNames {'a'; 'b'}, rxnNames {'r'}, subSystems {{''}}, SIntRxnBool true
%       OBSERVED: MATLAB R2025a, 2026-11-16: "Too many input arguments." (MATLAB:TooManyInputs)
%         at line 153: getCompartment(model.mets, numChar) passes a second argument, but
%         src/analysis/thermo/vonBertalanffy/getCompartment.m, the only getCompartment on the
%         path, takes one input (mets)
%       EXPECTED: the model is returned with oldS, SIntRxnBool and SExRxnBool, unchanged
%         otherwise (no carbon dioxide, no succinate dehydrogenase)
%       LINES: 152-153
%     - DEFECT: An internal reaction with carbon dioxide stops with an index error
%       SEVERITY: error
%       TRIGGER: the model above with mets {'a[c]'; 'co2[c]'; 'h2o[c]'}, metFormulas
%         {'C'; 'CO2'; 'H2O'}, metNames {'a'; 'c'; 'w'} and S = sparse([-1; 1; 0]) (a -> co2)
%       OBSERVED: MATLAB R2025a, 2026-11-16: after "Formula for carbon dioxide [c] is now H2CO3 =
%         CO2.H20" the call stops with "Index exceeds the number of array elements. Index must
%         not exceed 1." (MATLAB:badsubscript) at line 124: model.mets(co2MatchBool) is a 1 x 1
%         cell, so abbr(4:6) indexes the cell, not the identifier; lines 106-107 and 113-114 (two
%         carbon dioxide species in one reaction) use the same pattern
%       EXPECTED: S(h2o[c], r1) = -1, one H2O added to the substrate side for the CO2 produced,
%         as the help text says
%       LINES: 106-107, 113-114, 123-124
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testThermodynamicAdjustmentToStoichiometry'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
