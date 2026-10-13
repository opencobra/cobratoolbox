% The COBRAToolbox: testSanityCheckMetIds.m
%
% Purpose:
%     - sanityCheckMetIds checks the identifier fields of a metabolite structure (numeric fields are
%     numeric; database identifiers have the expected prefix or pattern), returns a list of the
%     entries that fail, and optionally removes them.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/buildMetStruct/sanityCheckMetIds.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Metabolites without a charge field make the check fail
%       SEVERITY: limitation
%       TRIGGER: a metabolite structure without the field charge
%       OBSERVED: the charge is read for every metabolite without an isfield test, so a missing
%         field raises an error
%       EXPECTED: a missing charge treated like any other optional field
%       LINES: 35
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSanityCheckMetIds'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a metabolite whose identifier fields are all valid
validMetabolite = struct('charge', 0, 'avgmolweight', 18, 'monoisotopicweight', 18, 'pubChemId', 962, ...
    'cheBIId', 15377, 'chemspider', 937, 'metlin', 1, 'keggId', 'C00001', 'hmdb', 'HMDB0002111', ...
    'food_db', 'FDB000001', 'metanetx', 'MNXM2', 'epa_id', 'DTXSID1', 'seed', 'cpd00001', ...
    'casRegistry', '7732-18-5', 'inchiKey', 'XLYOFNOQVPJJNP-UHFFFAOYSA-N', 'inchiString', 'InChI=1S/H2O/h1H2');

% for each field: an invalid value and the reason that is reported for it
checks = {'charge', 'abc', 'charge is not numeric';
          'avgmolweight', 'abc', 'avgmolweight is not numeric';
          'monoisotopicweight', 'abc', 'monoisotopicweight is not numeric';
          'pubChemId', 'abc', 'pubChemId is not numeric';
          'cheBIId', 'abc', 'cheBIId is not numeric';
          'chemspider', 'abc', 'chemspider is not numeric';
          'metlin', 'abc', 'metlin is not numeric';
          'keggId', 'X1', 'keggId does not start with C,D, or G';
          'hmdb', 'H1', 'hmdb does not start with HMDB';
          'food_db', 'F1', 'food_db does not start with FDB';
          'metanetx', 'M1', 'metanetx does not start with MNXM';
          'epa_id', 'D1', 'epa_id does not start with DTX';
          'seed', 'c1', 'seed does not start with cpd';
          'casRegistry', 'abc', 'casRegistry does not follow \d*-\d*-\d*';
          'inchiKey', 'abc', 'inchiKey does not follow [A-Z]+-[A-Z]+-[A-Z]+';
          'inchiString', 'abc', 'inchiString does not follow ^InChI='};

%% a valid metabolite: no entry is reported and nothing changes

metabolites.good = validMetabolite;
[checked, errorFlag] = sanityCheckMetIds(metabolites);
assert(isempty(errorFlag));
assert(isequal(checked, metabolites));

%% every field is checked: one entry (metabolite, value, reason) per invalid field

for k = 1:size(checks, 1)
    metabolites = struct();
    metabolites.bad = validMetabolite;
    metabolites.bad.(checks{k, 1}) = checks{k, 2};
    [checked, errorFlag] = sanityCheckMetIds(metabolites);
    assert(isequal(errorFlag, {'bad', checks{k, 2}, checks{k, 3}}), ['wrong report for ' checks{k, 1}]);
    % without removal the structure is returned unchanged
    assert(isequal(checked, metabolites));
end

%% with removal the invalid value becomes NaN and its _source entry is emptied (charge is only reported)

for k = 1:size(checks, 1)
    metabolites = struct();
    metabolites.bad = validMetabolite;
    metabolites.bad.(checks{k, 1}) = checks{k, 2};
    [checked, errorFlag] = sanityCheckMetIds(metabolites, 1);
    assert(size(errorFlag, 1) == 1);
    if strcmp(checks{k, 1}, 'charge')
        assert(isequal(checked.bad.charge, 'abc'));
    else
        assert(isnan(checked.bad.(checks{k, 1})), ['not removed: ' checks{k, 1}]);
        assert(isfield(checked.bad, [checks{k, 1} '_source']));
    end
end

%% valid values of the prefix checks: other allowed prefixes, and missing values (NaN) are not errors

metabolites = struct();
metabolites.good = validMetabolite;
metabolites.good.keggId = 'G00001';
assert(isempty(nonEmptyFlag(metabolites)));
metabolites.good.keggId = 'D00001';
assert(isempty(nonEmptyFlag(metabolites)));
metabolites.good.hmdb = NaN;
assert(isempty(nonEmptyFlag(metabolites)));
% a number where a text identifier is expected is an error
metabolites.good.hmdb = 5;
[~, errorFlag] = sanityCheckMetIds(metabolites);
assert(isequal(errorFlag(:, 3), {'hmdb does not start with HMDB'}));

%% several metabolites: the report lists them in order

metabolites = struct('x', validMetabolite, 'y', validMetabolite);
metabolites.x.charge = 'q';
metabolites.y.hmdb = 'bad';
metabolites.y.seed = 'bad';
[~, errorFlag] = sanityCheckMetIds(metabolites);
assert(isequal(errorFlag(:, [1 3]), {'x', 'charge is not numeric'; 'y', 'hmdb does not start with HMDB'; 'y', 'seed does not start with cpd'}));

function errorFlag = nonEmptyFlag(metabolites)
% local helper: only the report of the check
    [~, errorFlag] = sanityCheckMetIds(metabolites);
end

% change the directory
cd(currentDir)
