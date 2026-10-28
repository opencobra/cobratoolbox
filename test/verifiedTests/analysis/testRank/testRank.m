% The COBRAToolbox: testRank.m
%
% Purpose:
%     - tests the computation of the rank of a matrix using the LU solver termed
%
% Authors:
%     - LUSOL developed by Michael A. Saunders
%     - original test file: Ronan Fleming
%     - CI integration: Laurent Heirendt

global CBTDIR

prepareTest('needsUnix',true);

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRank'));
cd(fileDir);

% load the model
iAF1260 = getDistributedModel('iAF1260.mat');
A = iAF1260.S;
printLevel = 1;

% calculate the rank with minimum i/o arguments
rankA = getRankLUSOL(A);

% test the rank
assert(rankA == 1630);

for printLevel = 0:1
    % calculate the rank using LUSOL
    [rankA, p, q] = getRankLUSOL(A, printLevel);
    
    % test the rank
    assert(rankA == 1630);
    
    % compare the norms of the permutations vectors
    assert(abs(norm(p) - 3.934854424244942e+04) < 1e-6);
    assert(abs(norm(q) - 6.714114249102409e+04) < 1e-6);
end

% when LUSOL fails or is not on the path, getRankLUSOL falls back to MATLAB's LU: at
% printLevel 0 it prints nothing but one getRankLUSOL:lusolFallback warning per MATLAB
% session, and the rank is unchanged (the console is captured with diary, so these
% checks are meaningful under matlab -batch, as on CI)
B = sparse([1 2 0; 2 4 0; 0 1 1; 1 3 1]);
expectedRank = rank(full(B));

% LUSOL call fails: first fallback of the session warns once, with the cause
[printedText, rankB, warningId] = rankWithFallback(B, 0, 'failingLusol', true);
assert(rankB == expectedRank);
assert(strcmp(warningId, 'getRankLUSOL:lusolFallback'), 'last warning was %s', warningId);
assert(contains(regexprep(printedText, '\s+', ' '), 'stand-in lusol_obj failure'), 'fallback warning lacks the cause: %s', printedText);
assert(isempty(removeExpectedWarnings(printedText)), 'getRankLUSOL printed at printLevel 0: %s', printedText);
% later fallbacks in the same session are silent at printLevel 0
[printedText, rankB] = rankWithFallback(B, 0, 'failingLusol', false);
assert(rankB == expectedRank);
assert(isempty(strtrim(printedText)), 'getRankLUSOL printed on a repeated fallback: %s', printedText);
% printLevel 1 still explains every fallback
[printedText, rankB] = rankWithFallback(B, 1, 'failingLusol', false);
assert(rankB == expectedRank);
assert(contains(printedText, 'Caught error using lusol interface'), 'no fallback message at printLevel 1: %s', printedText);

% LUSOL interface not on the path: handled as a fallback in the same way
[printedText, rankB, warningId] = rankWithFallback(B, 0, 'noLusol', true);
assert(rankB == expectedRank);
assert(strcmp(warningId, 'getRankLUSOL:lusolFallback'), 'last warning was %s', warningId);
assert(contains(regexprep(printedText, '\s+', ' '), 'lusol_obj.m not found'), 'fallback warning lacks the cause: %s', printedText);
assert(isempty(removeExpectedWarnings(printedText)), 'getRankLUSOL printed at printLevel 0: %s', printedText);
[printedText, rankB] = rankWithFallback(B, 0, 'noLusol', false);
assert(rankB == expectedRank);
assert(isempty(strtrim(printedText)), 'getRankLUSOL printed on a repeated fallback: %s', printedText);
clear getRankLUSOL

% change the directory
cd(currentDir)

function [printedText, rankA, warningId] = rankWithFallback(A, printLevel, lusolState, newSession)
% calls getRankLUSOL with the LUSOL interface replaced by a failing stand-in
% ('failingLusol') or removed from the path ('noLusol'), and returns the console text;
% the MATLAB path is restored on return, also when an assertion fails
previousPath = path;
restorePath = onCleanup(@() path(previousPath));
switch lusolState
    case 'failingLusol'
        standInDir = tempname;
        mkdir(standInDir);
        removeStandIn = onCleanup(@() rmdir(standInDir, 's'));
        % a class like lusol_obj whose default options load but whose factorisation fails
        standInFid = fopen(fullfile(standInDir, 'lusol_obj.m'), 'w');
        fprintf(standInFid, ['classdef lusol_obj\nmethods (Static)\n' ...
            'function options = luset()\noptions = struct();\nend\nend\nmethods\n' ...
            'function obj = lusol_obj(varargin)\n' ...
            'error(''testRank:standIn'', ''stand-in lusol_obj failure'');\nend\nend\nend\n']);
        fclose(standInFid);
        addpath(standInDir, '-begin');
    case 'noLusol'
        while ~isempty(which('lusol_obj'))
            rmpath(fileparts(which('lusol_obj')));
        end
end
rehash
if newSession
    clear getRankLUSOL
end
lastwarn('');
previousDiaryFile = get(0, 'DiaryFile');
previousDiaryState = get(0, 'Diary');
diary('off');
captureFile = [tempname '.txt'];
diary(captureFile);
rankA = getRankLUSOL(A, printLevel);
diary('off');
set(0, 'DiaryFile', previousDiaryFile);
if strcmp(previousDiaryState, 'on')
    diary('on');
end
printedText = fileread(captureFile);
delete(captureFile);
[~, warningId] = lastwarn;
end

function text = removeExpectedWarnings(text)
% removes the getRankLUSOL fallback warning in full, in the form matlab -batch writes it
% ("[Warning: ...]" with backspace characters after the brackets, wrapped, then a
% bracketed "[> In ...]" backtrace) and in the desktop form; any other text is kept
message = strrep(regexptranslate('escape', 'getRankLUSOL: LUSOL unavailable'), ' ', '\s+');
text = regexprep(text, ['\[\x08?Warning: ' message '[^\]]*\]\x08?\s*(\[\x08?> In [^\]]*\]\x08?\s*)?'], '');
text = regexprep(text, ['Warning: ' message '[^\n]*\n?(\s*(> )?In [^\n]*\(line \d+\)[^\n]*\n?)*'], '');
text = strtrim(text);
end
