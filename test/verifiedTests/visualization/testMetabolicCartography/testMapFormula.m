% The COBRAToolbox: testMapFormula.m
%
% Purpose:
%     - mapFormula writes the formula of each reaction of rxnList found in a CellDesigner map
%       structure (species names of base and secondary reactants joined by ' + ', '->' or
%       '<=>' by reversibility, then the products), one formula per drawing of a reaction,
%       and returns the reactions found, the reactions of rxnList absent from the map and the
%       reaction names drawn more than once. Expected formulas are written by hand from the
%       documentation.
%
% Function under test:
%     src/visualization/metabolicCartography/mapFormula.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built map structure.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Fails instead of returning empty lists when no listed reaction is in the map
%       SEVERITY: limitation
%       TRIGGER: a map without the reactions of rxnList, e.g. mapFormula(map, {'RX'}) with the
%         map of this test (also with the first output only)
%       OBSERVED: MATLAB R2025a prints 'Attention : 1 reaction(s) not present in the map!!!'
%         and raises 'Output argument "formulaList" (and possibly others) not assigned a value
%         in the execution with "mapFormula" function.'; formulaList and rxnsList are assigned
%         only inside the loop over the present reactions.
%       EXPECTED: empty formulaList and rxnsList, absentRxns = {'RX'}, duplicatedRxns empty
%       LINES: 51, 99-100
%     - DEFECT: The help text describes absentRxns as reactions of the map not in the model
%       SEVERITY: cosmetic
%       TRIGGER: reading the OUTPUTS of mapFormula
%       OBSERVED: absentRxns = setdiff(rxnList, map.rxnName), the reactions of rxnList that
%         are not in the map
%       EXPECTED: help text 'Reactions of rxnList not in the map'
%       LINES: 30
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMapFormula'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a map of four reaction drawings (HEX1 drawn twice); reactions without secondary
% reactants or products hold '' as transformXML2Map writes it
%   HEX1 (1st): glc + atp (secondary) -> g6p + adp (secondary), irreversible
%   PGI:        g6p <=> f6p
%   HEX1 (2nd): glc -> g6p, irreversible
%   PFK:        f6p + atp -> fdp + adp, not requested below
map.rxnName = {'HEX1'; 'PGI'; 'HEX1'; 'PFK'};
map.specID = {'s1'; 's2'; 's3'; 's4'; 's5'; 's6'};
map.specName = {'glc'; 'atp'; 'g6p'; 'adp'; 'f6p'; 'fdp'};
map.rxnBaseReactantID = {{'s1'}; {'s3'}; {'s1'}; {'s5'}};
map.rxnReactantID = {{'s2'}; ''; ''; {'s2'}};
map.rxnBaseProductID = {{'s3'}; {'s5'}; {'s3'}; {'s6'}};
map.rxnProductID = {{'s4'}; ''; ''; {'s4'}};
map.rxnReversibility = {'false'; 'true'; 'false'; 'false'};

%% formulas of the listed reactions; absent and duplicated reactions are reported

% the present reactions are taken in sorted order (HEX1, PGI) and each drawing gives a row;
% GAPD is not in the map (a message is printed)
[formulaList, rxnsList, absentRxns, duplicatedRxns] = mapFormula(map, {'PGI'; 'HEX1'; 'GAPD'});
assert(isequal(formulaList, {'glc + atp -> g6p + adp'; 'glc -> g6p'; 'g6p <=> f6p'}));
assert(isequal(rxnsList, {'HEX1'; 'HEX1'; 'PGI'}));
assert(isequal(absentRxns, {'GAPD'}));
assert(isequal(duplicatedRxns, {'HEX1'}));

%% all listed reactions present, none duplicated

[formulaList, rxnsList, absentRxns, duplicatedRxns] = mapFormula(map, {'PFK'; 'PGI'});
assert(isequal(formulaList, {'f6p + atp -> fdp + adp'; 'g6p <=> f6p'}));
assert(isequal(rxnsList, {'PFK'; 'PGI'}));
assert(isempty(absentRxns));
assert(isempty(duplicatedRxns));

% change the directory
cd(currentDir)
