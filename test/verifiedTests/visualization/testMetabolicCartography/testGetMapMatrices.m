% The COBRAToolbox: testGetMapMatrices.m
%
% Purpose:
%     - getMapMatrices adds to a CellDesigner map structure the species-by-reaction matrix
%       sID and the alias-by-reaction matrix sAlias (-1 for base and secondary reactants,
%       +1 for base and secondary products, 0 otherwise) and the species-by-alias incidence
%       idAlias. Species or aliases named in a reaction but absent from the map are skipped.
%       Expected matrices are written by hand from the documentation.
%
% Function under test:
%     src/visualization/metabolicCartography/getMapMatrices.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built map structure.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetMapMatrices'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% four species, five aliases (sa5 is a second drawing of s1), three reactions
%   re1: s1 (sa1) + s2 (sa2, secondary) -> s3 (sa3) + s4 (sa4, secondary)
%   re2: s3 (sa3) + sX (saX, not in the map) + sZ (saZ, secondary, not in the map)
%        -> s1 (sa5) + sY (saY, secondary, not in the map); s4 drawn by the unknown alias saQ
%   re3: s2 (sa2) -> s2 (sa2), the same species on both sides
map.specID = {'s1'; 's2'; 's3'; 's4'};
map.molAlias = {'sa1'; 'sa2'; 'sa3'; 'sa4'; 'sa5'};
map.molID = {'s1'; 's2'; 's3'; 's4'; 's1'};
map.rxnID = {'re1'; 're2'; 're3'};
map.rxnBaseReactantID = {{'s1'}; {'s3'; 'sX'; 's4'}; {'s2'}};
map.rxnBaseReactantAlias = {{'sa1'}; {'sa3'; 'saX'; 'saQ'}; {'sa2'}};
map.rxnReactantID = {{'s2'}; {'sZ'}; {}};
map.rxnReactantAlias = {{'sa2'}; {'saZ'}; {}};
map.rxnBaseProductID = {{'s3'}; {'s1'}; {'s2'}};
map.rxnBaseProductAlias = {{'sa3'}; {'sa5'}; {'sa2'}};
map.rxnProductID = {{'s4'}; {'sY'}; {}};
map.rxnProductAlias = {{'sa4'}; {'saY'}; {}};

newMap = getMapMatrices(map);

%% species-by-reaction matrix: -1 reactants, +1 products, unknown species skipped

expectedSID = [-1  1  0;   % s1: reactant of re1, product of re2 (through alias sa5)
               -1  0  1;   % s2: secondary reactant of re1; re3 (both sides): the product loop runs last
                1 -1  0;   % s3
                1 -1  0];  % s4: secondary product of re1, base reactant of re2 (alias unknown)
% integer entries, so exact comparison
assert(issparse(newMap.sID));
assert(isequal(full(newMap.sID), expectedSID));

%% alias-by-reaction matrix: the same rule on aliases; unknown aliases (saQ, saX...) skipped

expectedSAlias = [-1  0  0;   % sa1
                  -1  0  1;   % sa2
                   1 -1  0;   % sa3
                   1  0  0;   % sa4 (re2 names s4 through the unknown alias saQ)
                   0  1  0];  % sa5
assert(issparse(newMap.sAlias));
assert(isequal(full(newMap.sAlias), expectedSAlias));

%% species-by-alias incidence: 1 where the alias draws the species

expectedIdAlias = [1 0 0 0 1;
                   0 1 0 0 0;
                   0 0 1 0 0;
                   0 0 0 1 0];
assert(issparse(newMap.idAlias));
assert(isequal(full(newMap.idAlias), expectedIdAlias));

%% the input fields are kept unchanged

assert(isequal(rmfield(newMap, {'sID', 'sAlias', 'idAlias'}), map));

% change the directory
cd(currentDir)
