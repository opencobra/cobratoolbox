% The COBRAToolbox: testLrsRun.m
%
% Purpose:
%     - lrsRun(modelName, param) runs lrs on <modelName>.ine (vertex enumeration) or
%       <modelName>.ext (facet enumeration), the name taking the _pos_ineq/_neg_ineq and _noR
%       suffixes chosen by param when it has no extension, optionally removes redundant
%       facets with redund, or runs <modelName>.sh instead (shell-script mode), and returns
%       the name of the output file; a failing command raises lrsRun:commandFailed. The test
%       writes the H- and V-representations of the positive quadrant by hand in a temporary
%       folder, so the expected vertices, rays and facets are known: vertex (0, 0), rays
%       (1, 0) and (0, 1), facets x1 >= 0 and x2 >= 0 (lrs adds the trivial row 1 >= 0, which
%       redund removes). Failing commands and a machine without lrs are simulated with
%       stand-in scripts placed first on the PATH, which is restored.
%
% Function under test:
%     src/analysis/topology/extremeRays/lrs/lrsInterface/lrsRun.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - no solver; needs the external programs lrs and redund (lrslib), declared with
%     prepareTest('requiredSoftwares', {'lrs'}), and a Unix shell.
%
% Coverage exemptions:
%     Lines 133-135: unreachable, uselrsRedundOption is set to 0 on line 128.
%     Line 150: non-Unix branch (OS-specific); the test needs a Unix shell for lrs.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLrsRun'));
cd(fileDir);

% declare the requirements of this test: the lrs program (lrslib)
prepareTest('requiredSoftwares', {'lrs'});

% all files are written to a temporary folder, removed at the end
workDir = tempname;
mkdir(workDir);
cd(workDir);

% H-representation of the positive quadrant {x1 >= 0, x2 >= 0}
quadrantIne = sprintf('quadrant\nH-representation\nbegin\n2 3 integer\n0 1 0\n0 0 1\nend\n');
% V-representation: the vertex (0, 0) and the rays (1, 0) and (0, 1); lrs writes the row
% count as ***** in its output, lrsRun replaces it (lrsSpecifyRows) before lrs reads the file
quadrantExt = sprintf('quadrant\nV-representation\nbegin\n***** 3 rational\n1 0 0\n0 1 0\n0 0 1\nend\n');
quadrantVertices = [0 0 1; 0 1 0; 1 0 0];
quadrantFacets = [0 0 1; 0 1 0; 1 0 0];
quadrantFacetsNoRedundancy = [0 0 1; 0 1 0];

%% vertex enumeration of a named .ine file, all parameters by default

writeText('q1.ine', quadrantIne);
fileNameOut = lrsRun('q1.ine');
assert(strcmp(fileNameOut, 'q1.ext'));
% the rows of an lrs V-representation are exact integers here: compare as sorted sets
assert(isequal(sortrows(readLrsRows('q1.ext')), quadrantVertices));
assert(contains(fileread('q1.ext'), 'V-representation'));

%% facet enumeration of a named .ext file (facetEnumeration defaults to 1)

writeText('q2.ext', quadrantExt);
fileNameOut = lrsRun('q2.ext', struct('redund', 1));
assert(strcmp(fileNameOut, 'q2.ine'));
assert(isequal(sortrows(readLrsRows('q2.ine')), quadrantFacets));
assert(contains(fileread('q2.ine'), 'H-representation'));

%% file names built from a name without extension

% inequality = 0: no suffix
writeText('q3.ine', quadrantIne);
fileNameOut = lrsRun('q3', struct('inequality', 0, 'facetEnumeration', 0));
assert(strcmp(fileNameOut, 'q3.ext') && isequal(sortrows(readLrsRows('q3.ext')), quadrantVertices));
% inequality = 1: _pos_ineq or _neg_ineq after positivity
writeText('q4_pos_ineq.ine', quadrantIne);
fileNameOut = lrsRun('q4', struct('inequality', 1, 'positivity', 1, 'facetEnumeration', 0));
assert(strcmp(fileNameOut, 'q4_pos_ineq.ext') && isequal(sortrows(readLrsRows(fileNameOut)), quadrantVertices));
writeText('q5_neg_ineq.ine', quadrantIne);
fileNameOut = lrsRun('q5', struct('inequality', 1, 'positivity', 0, 'facetEnumeration', 0));
assert(strcmp(fileNameOut, 'q5_neg_ineq.ext') && isequal(sortrows(readLrsRows(fileNameOut)), quadrantVertices));

%% redund = 0: the name takes _noR, and the facets are passed through redund

% vertex enumeration only renames: q6_noR.ine -> q6_noR.ext
writeText('q6_noR.ine', quadrantIne);
fileNameOut = lrsRun('q6', struct('redund', 0, 'facetEnumeration', 0));
assert(strcmp(fileNameOut, 'q6_noR.ext') && isequal(sortrows(readLrsRows(fileNameOut)), quadrantVertices));
% facet enumeration: lrs writes q7_noR.ine, redund writes q7_noR_noR.ine without the
% trivial row 1 >= 0
writeText('q7_noR.ext', quadrantExt);
fileNameOut = lrsRun('q7', struct('redund', 0, 'facetEnumeration', 1));
assert(strcmp(fileNameOut, 'q7_noR_noR.ine'));
assert(isequal(sortrows(readLrsRows('q7_noR.ine')), quadrantFacets));
assert(isequal(sortrows(readLrsRows(fileNameOut)), quadrantFacetsNoRedundancy));
% a name with extension keeps it: q8.ext -> q8.ine -> q8_noR.ine
writeText('q8.ext', quadrantExt);
fileNameOut = lrsRun('q8.ext', struct('redund', 0));
assert(strcmp(fileNameOut, 'q8_noR.ine') && isequal(sortrows(readLrsRows(fileNameOut)), quadrantFacetsNoRedundancy));

%% shell-script mode: exit status 0 returns the output name, another status is an error

writeText('s1.ine', quadrantIne);
writeText('s1.sh', sprintf('#!/bin/sh\nexit 0\n'));
assert(strcmp(lrsRun('s1', struct('shellScript', 1, 'facetEnumeration', 0)), 's1.ext'));
writeText('s1.ext', quadrantExt);
assert(strcmp(lrsRun('s1', struct('shellScript', 1, 'facetEnumeration', 1)), 's1.ine'));
writeText('s1.sh', sprintf('#!/bin/sh\nexit 3\n'));
message = lrsRunErrorMessage('s1', struct('shellScript', 1, 'facetEnumeration', 0));
assert(contains(message, 'failed with exit status 3'));

%% a failing lrs and a machine without lrs (stand-in programs first on the PATH)

writeText('f1.ine', quadrantIne);
message = runWithStandIn('lrs', sprintf('#!/bin/sh\necho stand-in failure\nexit 127\n'), 'f1.ine', struct());
% the message names the command and its status (the output of lrs is redirected to f1.ext)
assert(contains(message, 'failed with exit status 127') && contains(message, 'f1.ine > '));
% a "which" that finds nothing: lrsRun prints a message and returns no output name
writeText('f2.ine', quadrantIne);
message = runWithStandIn('which', sprintf('#!/bin/sh\nexit 1\n'), 'f2.ine', struct());
assert(strcmp(message, 'no error'));
assert(~isfile('f2.ext'));

%% remove the files

cd(fileDir);
rmdir(workDir, 's');

% change the directory
cd(currentDir)

function writeText(fileName, text)
% writes text to fileName in the current folder
fid = fopen(fileName, 'w');
fprintf(fid, '%s', text);
fclose(fid);
end

function rows = readLrsRows(fileName)
% reads the numeric rows between "begin" and "end" of an lrs file, skipping the row and
% column count line that follows "begin"
fileLines = strtrim(strsplit(fileread(fileName), newline))';
first = find(strcmp(fileLines, 'begin'), 1) + 2;
last = find(strcmp(fileLines, 'end'), 1) - 1;
rows = zeros(last - first + 1, 3);
for i = first:last
    rows(i - first + 1, :) = sscanf(fileLines{i}, '%d')';
end
end

function message = lrsRunErrorMessage(modelName, param)
% runs lrsRun, checks that it raises lrsRun:commandFailed, and returns the message
try
    lrsRun(modelName, param);
catch ME
    assert(strcmp(ME.identifier, 'lrsRun:commandFailed'), ...
        'lrsRun raised %s instead of lrsRun:commandFailed: %s (%s line %d)', ...
        ME.identifier, ME.message, ME.stack(1).file, ME.stack(1).line);
    message = ME.message;
    return
end
message = 'no error';
end

function message = runWithStandIn(programName, script, modelName, param)
% runs lrsRun with a stand-in programName first on the PATH; the PATH and the stand-in are
% restored on return, also when an assertion fails
standInDir = tempname;
mkdir(standInDir);
removeStandIn = onCleanup(@() rmdir(standInDir, 's'));
standInFid = fopen(fullfile(standInDir, programName), 'w');
fprintf(standInFid, '%s', script);
fclose(standInFid);
system(['chmod +x ' fullfile(standInDir, programName)]);
previousPath = getenv('PATH');
restorePath = onCleanup(@() setenv('PATH', previousPath));
setenv('PATH', [standInDir pathsep previousPath]);
message = lrsRunErrorMessage(modelName, param);
end
