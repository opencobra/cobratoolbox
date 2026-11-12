% The COBRAToolbox:testMetanetxMapper.m
%
% Purpose:
%     - testing functionality of metanetxMapper function. The first part runs offline against a
%       stand-in for webread; the last part asks the real server and is skipped when it is out of reach.
%
% Stand-in:
%     webread is replaced by a stand-in for the offline part only (MetaNetX is a web service, not a
%     solver). The replies were recorded from https://beta.metanetx.org on 2026-11-04 and cut to fewer
%     xrefs. The real server was not seen to use hmdb:, slm:, kegg.compound: or bigg.metabolite: as a
%     reference (it writes chebi:, biggM: or vmhM:), so those four replies are the recorded one with
%     the reference edited by hand. They show how the function treats such a reference, not that the
%     server sends one.
%
% Function under test:
%     src/dataIntegration/metanetxMapper/metanetxMapper.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Name search stops with an error when the search replies have the same field order
%       SEVERITY: error
%       TRIGGER: a name search with more than one result whose JSON objects list their fields in the
%         same order, which webread then returns as a struct array instead of a cell array
%       OBSERVED: the brace index response{1} stops with "Brace indexing is not supported"
%       EXPECTED: the first result taken from a struct array as well as from a cell array
%       LINES: 137
%
% Authors:
%     - Farid Zare 03/07/2024
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% require the specified toolboxes and solvers, along with a UNIX OS
solversPkgs = prepareTest();

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));
restoreFolder = onCleanup(@() cd(currentDir));

% determine the test path for references
testPath = pwd;

fprintf(' -- Running testMetanetxMapper ... \n');

%% stand-in for webread, in a temporary folder that only this part of the test has on the path
% each call takes the next reply of a queue and records its arguments
standInFolder = tempname;
mkdir(standInFolder);
fid = fopen(fullfile(standInFolder, 'webread.m'), 'w');
fprintf(fid, '%s\n', 'function reply = webread(url, varargin)', ...
    '% stand-in for webread, written by testMetanetxMapper', ...
    'queue = getappdata(0, ''metanetxMapperReplies'');', ...
    'reply = jsondecode(queue{1});', ...
    'setappdata(0, ''metanetxMapperReplies'', queue(2:end));', ...
    'calls = getappdata(0, ''metanetxMapperCalls'');', ...
    'setappdata(0, ''metanetxMapperCalls'', [calls; {url, varargin}]);', ...
    'end');
fclose(fid);
addpath(standInFolder);
removeStandIn = onCleanup(@() removeWebreadStandIn(standInFolder));

idMapperUrl = 'https://beta.metanetx.org/cgi-bin/mnxweb/id-mapper';
searchUrl = 'https://beta.metanetx.org/cgi-bin/mnxweb/search';

% a recorded reply of the id-mapper, cut to fewer xrefs; %s is the reference identifier
glucoseReply = ['{"key":{"mnx_id":"MNXM1583539","name":"D-glucopyranose","reference":"%s",' ...
    '"InChI":"InChI=1S/C6H12O6/c7-1-2-3(8)4(9)5(10)6(11)12-2/h2-11H,1H2/t2-,3-,4+,5-,6?/m1/s1",' ...
    '"InChIkey":"WQZGKKKJIJFFOK-GASJEMHNSA-N","SMILES":"OC[C@H]1OC(O)[C@H](O)[C@@H](O)[C@@H]1O",' ...
    '"xrefs":["CHEBI:4167","bigg.metabolite:glc__D","biggM:M_glc__D","hmdb:HMDB0304632",' ...
    '"kegg.compound:C00031","keggC:C00031","vmhM:glc_D"]}}'];
% a recorded reply for a lipid: it is the only kind with a SwissLipids identifier
lipidReply = ['{"SLM:000390086":{"mnx_id":"MNXM1101229","name":"isovaleryl-L-carnitine",' ...
    '"reference":"chebi:70819","xrefs":["CHEBI:70819","SLM:000390086","bigg.metabolite:ivcrn",' ...
    '"hmdb:HMDB0000688","kegg.compound:C20826","slm:000390086","vmhM:ivcrn"]}}'];

%% an identifier: the request, and every field of the result
setCannedReplies({sprintf(glucoseReply, 'chebi:4167')});
metData = metanetxMapper('MNXM1583539');
calls = getappdata(0, 'metanetxMapperCalls');
assert(size(calls, 1) == 1 && strcmp(calls{1, 1}, idMapperUrl));
% a + in front of the identifier asks the server for an exact match
assert(isequal(calls{1, 2}(1:6), {'query_index', 'chem', 'output_format', 'JSON', 'query_list', '+MNXM1583539'}));
assert(metData.metMetaNetXID == "MNXM1583539");
assert(metData.metName == "D-glucopyranose");
assert(metData.metInChIkey == "WQZGKKKJIJFFOK-GASJEMHNSA-N");
assert(startsWith(metData.metInChIString, "InChI=1S/C6H12O6"));
assert(metData.metSmiles == "OC[C@H]1OC(O)[C@H](O)[C@@H](O)[C@@H]1O");
% the identifiers come from the part after the colon of the first matching cross reference
assert(metData.metCheBIID == "4167");
assert(metData.metHMDBID == "HMDB0304632");
assert(metData.metVMHID == "glc_D");
assert(metData.metKEGGID == "C00031");
assert(metData.metBiGGID == "glc__D");
assert(metData.metSwissLipidsID == "");

%% input kinds: an existing + is kept, and a cell or a string works like a char array
setCannedReplies({sprintf(glucoseReply, 'chebi:4167')});
metData = metanetxMapper({'+MNXM1583539'});
calls = getappdata(0, 'metanetxMapperCalls');
assert(strcmp(calls{1, 2}{6}, '+MNXM1583539'));
assert(metData.metMetaNetXID == "MNXM1583539");
setCannedReplies({sprintf(glucoseReply, 'chebi:4167')});
metData = metanetxMapper("MNXM1583539");
assert(metData.metMetaNetXID == "MNXM1583539");

%% the identifier type sets the prefix of the query, in any letter case
setCannedReplies({sprintf(glucoseReply, 'chebi:4167')});
metanetxMapper('glc_D', 'VMH');
calls = getappdata(0, 'metanetxMapperCalls');
assert(strcmp(calls{1, 2}{6}, '+vmhM:glc_D'));
setCannedReplies({sprintf(glucoseReply, 'chebi:4167')});
metanetxMapper('4167', 'chebi');
calls = getappdata(0, 'metanetxMapperCalls');
assert(strcmp(calls{1, 2}{6}, '+CHEBI:4167'));

%% an unknown identifier type is refused before any request
setCannedReplies({});
assert(verifyCobraFunctionError('metanetxMapper', 'inputs', {'glc_D', 'kegg'}, 'testMessage', ...
    'Unrecognized input type of data. Input data type should be either "name" or "id"'));
assert(isempty(getappdata(0, 'metanetxMapperCalls')));

%% an empty name gives the empty result without any request
setCannedReplies({});
metData = metanetxMapper('');
assert(isempty(getappdata(0, 'metanetxMapperCalls')));
assert(all(structfun(@(value) value == "", metData)));

%% an identifier the server does not know: an empty reply leaves the result empty
setCannedReplies({'{"vmhM:M02733":{}}'});
metData = metanetxMapper('M02733', 'vmh');
assert(all(structfun(@(value) value == "", metData)));

%% a name search takes the first result, then asks the id-mapper for its identifier
% the fields of the search results are in a different order, as the server sends them
setCannedReplies({['[{"weight":34768,"mnx_id":"MNXM1583539","desc":"D-glucopyranose","index":"chem"},' ...
    '{"index":"chem","weight":26768,"mnx_id":"MNXM727787","desc":"other"}]'], ...
    sprintf(glucoseReply, 'chebi:4167')});
metData = metanetxMapper('D-glucopyranose', 'name');
calls = getappdata(0, 'metanetxMapperCalls');
assert(size(calls, 1) == 2);
assert(strcmp(calls{1, 1}, searchUrl) && strcmp(calls{2, 1}, idMapperUrl));
assert(strcmp(calls{1, 2}{6}, '+D-glucopyranose') && strcmp(calls{2, 2}{6}, 'MNXM1583539'));
assert(metData.metMetaNetXID == "MNXM1583539");

%% a name search with a single result
setCannedReplies({'[{"weight":34768,"mnx_id":"MNXM1583539","desc":"D-glucopyranose","index":"chem"}]', ...
    sprintf(glucoseReply, 'chebi:4167')});
metData = metanetxMapper('D-glucopyranose', 'name');
assert(size(getappdata(0, 'metanetxMapperCalls'), 1) == 2);
assert(metData.metMetaNetXID == "MNXM1583539");

%% a name search without a result stops after the search
% the server answers 204 without a body, which webread returns as an empty array
setCannedReplies({'[]'});
metData = metanetxMapper('no such metabolite', 'name');
assert(size(getappdata(0, 'metanetxMapperCalls'), 1) == 1);
assert(all(structfun(@(value) value == "", metData)));

%% a reply for a lipid holds the SwissLipids identifier with its prefix
setCannedReplies({lipidReply});
metData = metanetxMapper('SLM:000390086');
assert(metData.metSwissLipidsID == "SLM:000390086");
assert(metData.metVMHID == "ivcrn");

%% the reference identifier replaces the identifier found in the cross references
% recorded: the reference of vmhM:xolest2_hs is a vmhM identifier
setCannedReplies({sprintf(glucoseReply, 'vmhM:xol_X')});
metData = metanetxMapper('glc_D', 'vmh');
assert(metData.metVMHID == "xol_X");
% edited by hand, see the header: the other kinds of reference
setCannedReplies({sprintf(glucoseReply, 'hmdb:HMDB0000122')});
metData = metanetxMapper('MNXM1583539');
assert(metData.metHMDBID == "HMDB0000122");
setCannedReplies({sprintf(glucoseReply, 'slm:000390086')});
metData = metanetxMapper('MNXM1583539');
assert(metData.metSwissLipidsID == "slm:000390086");
setCannedReplies({sprintf(glucoseReply, 'kegg.compound:C00267')});
metData = metanetxMapper('MNXM1583539');
assert(metData.metKEGGID == "C00267");
setCannedReplies({sprintf(glucoseReply, 'bigg.metabolite:glc__bD')});
metData = metanetxMapper('MNXM1583539');
assert(metData.metBiGGID == "glc__bD");

% from here on the real webread is used
clear removeStandIn
assert(~contains(which('webread'), standInFolder));

%% the real server: the fields of the result
prepareTest('needsWebAddress','https://beta.metanetx.org');

% Run MetanetxMapper
metData = metanetxMapper('MNXM1364063');
% Field presence
assert(isfield(metData, 'metHMDBID'));
assert(isfield(metData, 'metName'));
assert(isfield(metData, 'metKEGGID'));
assert(isfield(metData, 'metBiGGID'));
assert(isfield(metData, 'metInChIkey'));
assert(isfield(metData, 'metSmiles'));

% Run MetanetxMapper with metabolite name
metData = metanetxMapper('L-glutamate', 'name');
% Field presence
assert(isfield(metData, 'metHMDBID'));
assert(isfield(metData, 'metName'));
assert(isfield(metData, 'metKEGGID'));
assert(isfield(metData, 'metBiGGID'));
assert(isfield(metData, 'metInChIkey'));
assert(isfield(metData, 'metSmiles'));

% Run MetanetxMapper with metabolite name
metData = metanetxMapper('glc_D', 'vmh');
% Field presence
assert(isfield(metData, 'metHMDBID'));
assert(isfield(metData, 'metName'));
assert(isfield(metData, 'metKEGGID'));
assert(isfield(metData, 'metBiGGID'));
assert(isfield(metData, 'metInChIkey'));
assert(isfield(metData, 'metSmiles'));

% Run MetanetxMapper with chebi ID
metData = metanetxMapper('4167', 'chebi');
assert(isfield(metData, 'metHMDBID'));
assert(isfield(metData, 'metName'));
assert(isfield(metData, 'metKEGGID'));
assert(isfield(metData, 'metBiGGID'));
assert(isfield(metData, 'metInChIkey'));
assert(isfield(metData, 'metSmiles'));


fprintf('Done.\n');
fprintf('testMetanetxMapper passed successfully.\n');

% change the directory
cd(currentDir);

function setCannedReplies(replies)
% queue the replies of the webread stand-in and forget the calls made so far
setappdata(0, 'metanetxMapperReplies', replies);
setappdata(0, 'metanetxMapperCalls', cell(0, 2));
end

function removeWebreadStandIn(standInFolder)
% take the stand-in off the path and delete it, also when the test stops early
rmpath(standInFolder);
rmdir(standInFolder, 's');
rmappdata(0, 'metanetxMapperReplies');
rmappdata(0, 'metanetxMapperCalls');
end
