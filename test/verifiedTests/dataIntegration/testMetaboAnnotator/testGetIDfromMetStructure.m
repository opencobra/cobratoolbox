% The COBRAToolbox: testGetIDfromMetStructure.m
%
% Purpose:
%     - getIDfromMetStructure reads one identifier (idName) of every metabolite of a metabolite
%       structure and returns three lists: all metabolites with the identifier as text, the
%       metabolites whose identifier is not NaN (with the identifier, the VMHId and the name
%       from metNames, or from rxnNames when metNames is absent) and the metabolites whose
%       identifier is NaN. This test checks a hand-built structure with a text identifier, a
%       numeric identifier, an empty identifier and a NaN identifier, and a structure in which
%       every identifier is NaN. Expected values follow from the documentation.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/analyseMetStruct/getIDfromMetStructure.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
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
fileDir = fileparts(which('testGetIDfromMetStructure'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% four metabolites: a text KEGG identifier, a missing (NaN) one, a numeric one (on an entry that
% carries rxnNames instead of metNames) and an empty one
metaboliteStructure = struct();
metaboliteStructure.VMH_glc_D = struct('VMHId', 'glc_D', 'metNames', 'D-Glucose', 'keggId', 'C00031');
metaboliteStructure.VMH_atp = struct('VMHId', 'atp', 'metNames', 'ATP', 'keggId', NaN);
metaboliteStructure.VMH_h2o = struct('VMHId', 'h2o', 'rxnNames', 'Water', 'keggId', 1);
metaboliteStructure.VMH_xyz = struct('VMHId', 'xyz', 'metNames', 'Unknown', 'keggId', '');

%% all, present and missing identifiers

[mappingAll, mappingPresent, mappingMissing] = getIDfromMetStructure(metaboliteStructure, 'keggId');
% all metabolites, in the order of the structure, with the identifier as text (num2str)
assert(isequal(mappingAll, {'VMH_glc_D', 'C00031'; 'VMH_atp', 'NaN'; 'VMH_h2o', '1'; 'VMH_xyz', ''}));
% the metabolites whose identifier is not NaN: identifier, VMHId and name (rxnNames for the
% entry without metNames); an empty identifier is not NaN, so it counts as present
assert(isequal(mappingPresent, {'VMH_glc_D', 'C00031', 'glc_D', 'D-Glucose'; ...
    'VMH_h2o', '1', 'h2o', 'Water'; 'VMH_xyz', '', 'xyz', 'Unknown'}));
% the metabolites whose identifier is NaN
assert(isequal(mappingMissing, {'VMH_atp'}));

%% every identifier present: the list of missing identifiers stays empty

[mappingAll, mappingPresent, mappingMissing] = getIDfromMetStructure(metaboliteStructure, 'VMHId');
% the VMHId of every metabolite is text, so nothing is missing
assert(isequal(mappingAll(:, 2), {'glc_D'; 'atp'; 'h2o'; 'xyz'}));
assert(size(mappingPresent, 1) == 4 && isempty(mappingMissing) && ischar(mappingMissing));

%% every identifier missing: the list of present identifiers stays empty

missingStructure = struct();
missingStructure.VMH_atp = struct('VMHId', 'atp', 'metNames', 'ATP', 'hmdb', NaN);
[mappingAll, mappingPresent, mappingMissing] = getIDfromMetStructure(missingStructure, 'hmdb');
assert(isequal(mappingAll, {'VMH_atp', 'NaN'}));
assert(isempty(mappingPresent) && ischar(mappingPresent));
assert(isequal(mappingMissing, {'VMH_atp'}));

% change the directory
cd(currentDir)
