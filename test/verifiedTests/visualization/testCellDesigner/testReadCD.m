% The COBRAToolbox: testReadCD.m
%
% Purpose:
%     - readCD converts the per-reaction parsed CellDesigner structure (one field per reaction,
%       as produced by parseCD, plus the field r_info) into a per-property structure: ID holds
%       the reaction field names followed by the columns of each reaction's name entry, and every
%       other attribute of the first reaction becomes a matrix with one row per reaction (shorter
%       rows padded with empty entries or zeros). The species list of parsed.r_info is copied
%       when present.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Expected values are derived by hand from the hand-built parsed structures (the field
%       layout of parseCD, with r_info as the last field).
%
% Function under test:
%     src/visualization/cellDesigner/readCD.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Debug output of the attribute list and of the whole partial result
%       SEVERITY: cosmetic
%       TRIGGER: any call
%       OBSERVED: lines 33 and 41 lack a terminating semicolon, so the attribute list and the
%         whole partially built structure are printed after every single entry copied
%       EXPECTED: no output
%       LINES: 33, 41
%     - DEFECT: Attributes missing from the first reaction are dropped for all reactions
%       SEVERITY: limitation
%       TRIGGER: a parsed structure whose first reaction has no field that a later reaction has
%         (e.g. reactant only in the second reaction)
%       OBSERVED: the attribute list is taken from the first reaction only, so that attribute is
%         absent from the result
%       EXPECTED: every attribute of any reaction collected (the comment at line 39 says that
%         some entries may lack a field)
%       LINES: 33
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadCD'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% two reactions with every attribute: one row per reaction, shorter rows padded

parsed = struct();
parsed.re1.name = {'re1', 'HEX1'};
parsed.re1.width = {'1.0', '2.0'};
parsed.re1.color = {'ff000000', 'ffff0000'};
parsed.re1.number = [12 15];
parsed.re2.name = {'re2', 'PGI'};
parsed.re2.width = {'3.0'};
parsed.re2.color = {'ff00ff00'};
parsed.re2.number = 20;
parsed.r_info.species = {'s1', 'glc_D[c]'; 's2', 'g6p[c]'};

r_info = readCD(parsed);

% the attributes of the first reaction become fields; name is folded into ID
assert(isequal(fieldnames(r_info), {'ID'; 'width'; 'color'; 'number'; 'species'}));
% ID: reaction field name, then the two columns of the name entry
assert(isequal(r_info.ID, {'re1', 're1', 'HEX1'; 're2', 're2', 'PGI'}));
% cell attributes are padded with empty entries, numeric attributes with zeros
assert(isequal(r_info.width, {'1.0', '2.0'; '3.0', []}));
assert(isequal(r_info.color, {'ff000000', 'ffff0000'; 'ff00ff00', []}));
assert(isequal(r_info.number, [12 15; 20 0]));
% the species list is copied unchanged
assert(isequal(r_info.species, parsed.r_info.species));

%% an attribute missing from a later reaction leaves an empty row for that reaction

parsed = struct();
parsed.re1.name = {'re1', 'ENO'};
parsed.re1.color = {'ff000000'};
parsed.re2.name = {'re2', 'PYK'};
parsed.re3.name = {'re3', 'PGK'};
parsed.re3.color = {'ffff0000'};
parsed.r_info.species = {'s1', 'pep[c]'};

r_info = readCD(parsed);
assert(isequal(r_info.ID, {'re1', 're1', 'ENO'; 're2', 're2', 'PYK'; 're3', 're3', 'PGK'}));
assert(isequal(r_info.color, {'ff000000'; []; 'ffff0000'}));
assert(isequal(r_info.species, {'s1', 'pep[c]'}));

%% without a species list in r_info the result has no species field

parsed = struct();
parsed.re1.name = {'re1', 'TPI'};
parsed.re1.number = 7;
parsed.r_info.ID = {};

r_info = readCD(parsed);
assert(isequal(fieldnames(r_info), {'ID'; 'number'}));
assert(isequal(r_info.ID, {'re1', 're1', 'TPI'}));
assert(isequal(r_info.number, 7));

% change the directory
cd(currentDir)
