% The COBRAToolbox: testReplaceVMHIds.m
%
% Purpose:
%     - replaceVMHIds overwrites curated annotation entries (identifiers and names) in metabolite
%     and reaction structures that are indexed by VMH identifier, recording the source of each
%     replacement.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/buildMetStruct/replaceVMHIds.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 302-303, the replacement by NaN for reactions: no entry of the reaction table is marked
%     NaN, so the branch cannot run.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReplaceVMHIds'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% curated metabolite entries replace the existing value and record the source

metabolites.VMH_glc_D.pdmapName = 'old';
[metabolites, reactions] = replaceVMHIds(metabolites, struct());
assert(strcmp(metabolites.VMH_glc_D.pdmapName, 'glucose'));
% the source records who made the change, how and when: curator (IT):manual:verified:<date>
assert(startsWith(metabolites.VMH_glc_D.pdmapName_source, 'curator (IT):manual:verified:'));
assert(isstruct(reactions) && isempty(fieldnames(reactions)));

%% an entry that is marked as not a number

metabolites = struct('VMH_3oh_dlor', struct('inchiString', 'InChI=1S/x', 'inchiString_source', 'src'));
metabolites = replaceVMHIds(metabolites, struct());
assert(isnan(metabolites.VMH_3oh_dlor.inchiString) && isnan(metabolites.VMH_3oh_dlor.inchiString_source));

%% several entries of one metabolite

metabolites = struct('VMH_cgz', struct());
metabolites = replaceVMHIds(metabolites, struct());
assert(strcmp(metabolites.VMH_cgz.drugbank, 'DBMET01328'));
assert(strcmp(metabolites.VMH_cgz.inchiKey, 'DSNDPTBTZSQWJS-TXEJJXNPSA-N'));

%% metabolites that are not in the table are left unchanged

metabolites = struct('VMH_notInTable', struct('pdmapName', 'keep'));
result = replaceVMHIds(metabolites, struct());
assert(isequal(result, metabolites));

%% reaction entries

reactions = struct('VMH_PYLALDOX', struct('wikipedia', 'old'));
[~, reactions] = replaceVMHIds(struct(), reactions);
assert(strcmp(reactions.VMH_PYLALDOX.wikipedia, 'Perillyl-alcohol_dehydrogenase'));
assert(strcmp(reactions.VMH_PYLALDOX.keggID, 'R03945'));
assert(startsWith(reactions.VMH_PYLALDOX.keggID_source, 'curator (IT):manual:verified:'));

%% structures that are not given default to empty text

[metabolites, reactions] = replaceVMHIds();
assert(isempty(metabolites) && isempty(reactions));

% change the directory
cd(currentDir)
