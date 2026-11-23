% The COBRAToolbox: testFindBondsBrokenAndFormed.m
%
% Purpose:
%     - findBondsBrokenAndFormed(model, rxnList, rxnDir, printLevel) counts, for each reaction
%       of rxnList, the bonds broken and formed according to its atom-mapped RXN file (0 for
%       exchange reactions without a file, NaN for missing or unbalanced reactions) and the
%       total mass of its substrates. The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): the exchange test compares the loop index with a
%       logical vector, so exchange reactions without a file get NaN and the first reaction
%       without a file gets 0; no assertion about the function is made.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/reactions/findBondsBrokenAndFormed.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a hand-built model (createModel) and RXN files written to a tempname folder;
%     no solver.
%
% Coverage exemptions:
%     every line - findBondsBrokenAndFormed is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Exchange reactions without an RXN file get NaN, and the first reaction gets 0
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'R1', 'EX_h2', 'R3'}, {'', '', ''}, {'h2[c] -> 2 h[c]',
%         'h2[c] <=> ', 'h[c] -> q[c]'}, 'printLevel', 0); a folder holding only R1.rxn
%         (H2 -> H + H, one single bond broken); findBondsBrokenAndFormed(model, {'R3';
%         'EX_h2'; 'R1'}, folder, 0)
%       OBSERVED: (R2025a, 2026-11-23) [0 NaN 1]: line 223 tests ismember(i, exIdx) with
%         exIdx = ExchRxnBool(rxnsIdx) a logical vector, which is true only for i = 1 when
%         the list holds an exchange reaction
%       EXPECTED: [NaN 0 1] as the help says (R3 has no file, EX_h2 is an exchange
%         reaction), i.e. exIdx(i) as in findEnthalpyChange
%       LINES: 223, 226, 231
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindBondsBrokenAndFormed'));
cd(fileDir);

% the function is quarantined: no requirement is declared and nothing calls it
prepareTest();

% change the directory
cd(currentDir)
