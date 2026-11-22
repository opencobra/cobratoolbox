% The COBRAToolbox: testGetMultiSpeciesModelId.m
%
% Purpose:
%     - getMultiSpeciesModelId lists, for a joint multi-species model, the community exchange
%       reactions and metabolites ([u]), the species-community exchange reactions and their
%       [e] metabolites per species, the host-specific exchanges ([b]) and the species of
%       every reaction and metabolite. This test builds three small joint models with
%       createModel (two species; two species and a host; one species) whose expected lists
%       are read off the reaction formulas, and checks every output field, the defaults,
%       bracketed compartment identifiers, a host tag given as a cell, a single tag given as
%       a character array, the re-ordering of the host metabolites to the community order and
%       the error for tags that do not separate the species.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/getMultiSpeciesModelId.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built joint models (createModel), no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The compartmentalization error never names the species
%       SEVERITY: cosmetic
%       TRIGGER: getMultiSpeciesModelId(modelJoint, {'Org1'; 'Org2A'}) on the two-species
%         model of this test (the second tag matches metabolites but no reaction)
%       OBSERVED: the message reads 'The model for species %s is not correctly
%         compartmentalized. Check the name tags.' (MATLAB R2025a): error is called with a
%         format specifier but without the argument, so %s is printed literally
%       EXPECTED: the tag of the species in the message
%       LINES: 118
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetMultiSpeciesModelId'));
cd(fileDir);

% declare the requirements of this test: a Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system
prepareTest();

%% two species Org1 and Org2 sharing the community metabolites A[u] and B[u]

% species-specific identifiers start with the tag (the default regular expression '^%s');
% Org2DM_A has a single non-zero coefficient but touches no [u] metabolite, so it must not be
% listed among the community exchanges
rxnList = {'Org1R1'; 'Org1TrA'; 'Org1TrB'; 'Org1IEX_A[u]tr'; 'Org1IEX_B[u]tr'; ...
    'Org2TrA'; 'Org2DM_A'; 'Org2IEX_A[u]tr'; 'EX_A[u]'; 'EX_B[u]'};
formulaList = {'Org1A[c] -> Org1B[c]'; 'Org1A[e] <=> Org1A[c]'; 'Org1B[c] -> Org1B[e]'; ...
    'A[u] <=> Org1A[e]'; 'B[u] <=> Org1B[e]'; 'Org2A[e] -> Org2A[c]'; 'Org2A[c] -> '; ...
    'A[u] <=> Org2A[e]'; 'A[u] <=> '; 'B[u] <=> '};
modelJoint = createModel(rxnList, rxnList, formulaList, 'printLevel', 0);

% the species of a reaction or metabolite follows from its prefix; everything else is 'com'
expectedRxnSps = repmat({'com'}, numel(modelJoint.rxns), 1);
expectedRxnSps(startsWith(modelJoint.rxns, 'Org1')) = {'Org1'};
expectedRxnSps(startsWith(modelJoint.rxns, 'Org2')) = {'Org2'};
expectedMetSps = repmat({'com'}, numel(modelJoint.mets), 1);
expectedMetSps(startsWith(modelJoint.mets, 'Org1')) = {'Org1'};
expectedMetSps(startsWith(modelJoint.mets, 'Org2')) = {'Org2'};

% all optional inputs at their defaults (no host, '^%s' tags, compartments u and b)
[names, ids] = getMultiSpeciesModelId(modelJoint, {'Org1'; 'Org2'});

% one entry per reaction and metabolite of the model
assert(numel(names.rxnSps) == size(modelJoint.S, 2) && numel(ids.rxnSps) == size(modelJoint.S, 2));
assert(numel(names.metSps) == size(modelJoint.S, 1) && numel(ids.metSps) == size(modelJoint.S, 1));

% species abbreviations and names are the tags; the community exchanges and metabolites are
% the two [u] metabolites and their system exchanges, in metabolite order; no host
assert(isequal(names.spAbbr, {'Org1'; 'Org2'}) && isequal(names.spName, {'Org1'; 'Org2'}));
assert(isequal(names.EXcom, {'EX_A[u]'; 'EX_B[u]'}));
assert(isequal(ids.EXcom, findRxnIDs(modelJoint, {'EX_A[u]'; 'EX_B[u]'})));
assert(isequal(names.Mcom, {'A[u]'; 'B[u]'}) && isequal(ids.Mcom, findMetIDs(modelJoint, {'A[u]'; 'B[u]'})));
assert(isempty(names.EXhost) && isempty(ids.EXhost) && isempty(names.Mhost) && isempty(ids.Mhost));

% species-community exchanges (rows: A[u], B[u]; columns: Org1, Org2) and the [e] metabolite
% each of them exchanges; Org2 has no exchange for B, which leaves '' and 0
assert(isequal(names.EXsp, {'Org1IEX_A[u]tr', 'Org2IEX_A[u]tr'; 'Org1IEX_B[u]tr', ''}));
assert(isequal(ids.EXsp, [findRxnIDs(modelJoint, {'Org1IEX_A[u]tr', 'Org2IEX_A[u]tr'}); ...
    findRxnIDs(modelJoint, 'Org1IEX_B[u]tr'), 0]));
assert(isequal(names.Msp, {'Org1A[e]', 'Org2A[e]'; 'Org1B[e]', ''}));
assert(isequal(ids.Msp, [findMetIDs(modelJoint, {'Org1A[e]', 'Org2A[e]'}); ...
    findMetIDs(modelJoint, 'Org1B[e]'), 0]));

% the species of every reaction and metabolite, as names and as indices (0 = community)
assert(isequal(names.rxnSps, expectedRxnSps) && isequal(names.metSps, expectedMetSps));
assert(isequal(ids.rxnSps, strcmp(expectedRxnSps, 'Org1') + 2 * strcmp(expectedRxnSps, 'Org2')));
assert(isequal(ids.metSps, strcmp(expectedMetSps, 'Org1') + 2 * strcmp(expectedMetSps, 'Org2')));

%% two species and a host with its own exchange compartment [b]

rxnListHost = [rxnList; {'HostIEX_A[u]tr'; 'HostTrA'; 'HostTrbB'; 'HostTrbA'; 'EX_B[b]'; 'EX_A[b]'}];
formulaListHost = [formulaList; {'A[u] <=> HostA[e]'; 'HostA[e] <=> HostA[c]'; ...
    'HostA[c] -> HostB[b]'; 'HostA[c] <=> HostA[b]'; 'HostB[b] <=> '; 'HostA[b] <=> '}];
modelHost = createModel(rxnListHost, rxnListHost, formulaListHost, 'printLevel', 0);

% createModel sorts the metabolites, so swap the two [b] metabolites (rows of S and the
% metabolite fields) to make the re-ordering of the host metabolites to the order of the
% community metabolites (line 92) visible
metOrder = 1:numel(modelHost.mets);
metOrder(findMetIDs(modelHost, {'HostA[b]', 'HostB[b]'})) = findMetIDs(modelHost, {'HostB[b]', 'HostA[b]'});
modelHost.S = modelHost.S(metOrder, :);
for metField = {'mets', 'metNames', 'b', 'csense'}
    modelHost.(metField{1}) = modelHost.(metField{1})(metOrder);
end
assert(find(strcmp(modelHost.mets, 'HostB[b]')) < find(strcmp(modelHost.mets, 'HostA[b]')));

% every optional input given: the host tag as a cell, explicit regular expressions and the
% compartment identifiers with brackets, which are stripped
[namesHost, idsHost] = getMultiSpeciesModelId(modelHost, {'Org1'; 'Org2'}, {'Host'}, '^%s', '^%s', '[u]', '[b]');

% the host is appended to the species; community lists as before
assert(isequal(namesHost.spAbbr, {'Org1'; 'Org2'; 'Host'}) && isequal(namesHost.spName, namesHost.spAbbr));
assert(isequal(namesHost.EXcom, {'EX_A[u]'; 'EX_B[u]'}) && isequal(namesHost.Mcom, {'A[u]'; 'B[u]'}));

% host metabolites and exchanges follow the order of the community metabolites (A then B),
% not the order of the model (B[b] before A[b])
assert(isequal(namesHost.Mhost, {'HostA[b]'; 'HostB[b]'}));
assert(isequal(idsHost.Mhost, findMetIDs(modelHost, {'HostA[b]'; 'HostB[b]'})));
assert(isequal(namesHost.EXhost, {'EX_A[b]'; 'EX_B[b]'}));
assert(isequal(idsHost.EXhost, findRxnIDs(modelHost, {'EX_A[b]'; 'EX_B[b]'})));

% the host exchanges A with the community through HostIEX_A[u]tr (third column)
assert(isequal(namesHost.EXsp, {'Org1IEX_A[u]tr', 'Org2IEX_A[u]tr', 'HostIEX_A[u]tr'; 'Org1IEX_B[u]tr', '', ''}));
assert(isequal(idsHost.EXsp(:, 3), [findRxnIDs(modelHost, 'HostIEX_A[u]tr'); 0]));
assert(isequal(namesHost.Msp(:, 3), {'HostA[e]'; ''}));
assert(isequal(idsHost.Msp(:, 3), [findMetIDs(modelHost, 'HostA[e]'); 0]));

% host reactions and metabolites (including the [b] metabolites) belong to the host; the
% system exchanges of [b] and [u] belong to the community
expectedRxnSpsHost = repmat({'com'}, numel(modelHost.rxns), 1);
expectedRxnSpsHost(startsWith(modelHost.rxns, 'Org1')) = {'Org1'};
expectedRxnSpsHost(startsWith(modelHost.rxns, 'Org2')) = {'Org2'};
expectedRxnSpsHost(startsWith(modelHost.rxns, 'Host')) = {'Host'};
expectedMetSpsHost = repmat({'com'}, numel(modelHost.mets), 1);
expectedMetSpsHost(startsWith(modelHost.mets, 'Org1')) = {'Org1'};
expectedMetSpsHost(startsWith(modelHost.mets, 'Org2')) = {'Org2'};
expectedMetSpsHost(startsWith(modelHost.mets, 'Host')) = {'Host'};
assert(isequal(namesHost.rxnSps, expectedRxnSpsHost) && isequal(namesHost.metSps, expectedMetSpsHost));
assert(isequal(idsHost.rxnSps, strcmp(expectedRxnSpsHost, 'Org1') + 2 * strcmp(expectedRxnSpsHost, 'Org2') ...
    + 3 * strcmp(expectedRxnSpsHost, 'Host')));
assert(isequal(idsHost.metSps, strcmp(expectedMetSpsHost, 'Org1') + 2 * strcmp(expectedMetSpsHost, 'Org2') ...
    + 3 * strcmp(expectedMetSpsHost, 'Host')));

%% a single species whose tag is given as a character array

isSingle = startsWith(rxnList, 'Org1') | startsWith(rxnList, 'EX_');
modelSingle = createModel(rxnList(isSingle), rxnList(isSingle), formulaList(isSingle), 'printLevel', 0);
[namesSingle, idsSingle] = getMultiSpeciesModelId(modelSingle, 'Org1');
assert(isequal(namesSingle.spAbbr, {'Org1'}));
assert(isequal(idsSingle.EXsp, findRxnIDs(modelSingle, {'Org1IEX_A[u]tr'; 'Org1IEX_B[u]tr'})));
assert(isequal(namesSingle.Msp, {'Org1A[e]'; 'Org1B[e]'}));
assert(isequal(idsSingle.rxnSps, double(startsWith(modelSingle.rxns, 'Org1'))));
assert(isequal(namesSingle.EXcom, {'EX_A[u]'; 'EX_B[u]'}) && isempty(idsSingle.EXhost));

%% tags that do not separate the species raise the documented error

% 'Org2A' matches the metabolites Org2A[c] and Org2A[e] but no reaction, so the metabolites of
% species 2 take part in reactions of other species (line 116)
assert(verifyCobraFunctionError('getMultiSpeciesModelId', 'inputs', {modelJoint, {'Org1'; 'Org2A'}}));

% change the directory
cd(currentDir)
