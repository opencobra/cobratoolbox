% The COBRAToolbox: testTransformKEGG2Model.m
%
% Purpose:
%     - transformKEGG2Model replaces the KEGG compound identifiers of a KEGG model by model
%       abbreviations: with a dictionary it first maps them through mapMetName2KEGGID, without
%       one it uses the metsAbr field already present; metabolites without an abbreviation keep
%       their KEGG identifier, and the temporary field metsAbr is removed. Expected values are
%       read off the hand-built dictionary.
%
% Function under test:
%     src/base/io/KEGG/transformKEGG2Model.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - renaming of a three-metabolite hand-built model, no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTransformKEGG2Model'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% with a dictionary: KEGG identifiers are mapped to abbreviations, compartments kept

% glucose in the cytosol and ATP outside the cell are in the dictionary, C99999 is not;
% the dictionary entry with an empty KEGG identifier is ignored
keggModel.mets = {'C00031[c]'; 'C00002[e]'; 'C99999[c]'};
dictionary = {'glc-D', 'C00031'; 'atp', 'C00002'; 'h2o', ''};
model = transformKEGG2Model(keggModel, dictionary);
% exact: the abbreviation takes the compartment of the KEGG identifier; the unknown compound
% keeps its KEGG identifier; metKEGGID keeps the original identifiers
assert(isequal(model.mets, {'glc-D[c]'; 'atp[e]'; 'C99999[c]'}));
assert(isequal(model.metKEGGID, keggModel.mets));
assert(~isfield(model, 'metsAbr'));

%% without a dictionary: the metsAbr field of the input is used

keggModel = struct();
keggModel.metsAbr = {'glc-D[c]'; []};
keggModel.metKEGGID = {'C00031[c]'; 'C99999[c]'};
model = transformKEGG2Model(keggModel);
% exact: the empty abbreviation is replaced by the KEGG identifier, metsAbr removed
assert(isequal(model.mets, {'glc-D[c]'; 'C99999[c]'}));
assert(isequal(model.metKEGGID, keggModel.metKEGGID));
assert(~isfield(model, 'metsAbr'));

% change the directory
cd(currentDir)
