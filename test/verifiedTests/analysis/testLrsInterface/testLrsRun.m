% The COBRAToolbox: testLrsRun.m
%
% Purpose:
%     - lrsRun(modelName, param) runs lrs on <modelName>.ine (vertex enumeration) or
%       <modelName>.ext (facet enumeration), the name taking the _pos_ineq/_neg_ineq and _noR
%       suffixes chosen by param when it has no extension, optionally removes redundant
%       facets by running lrs again with its redund option (on a temporary copy of the facet
%       file), or runs <modelName>.sh instead (shell-script mode), and returns
%       the name of the output file; a failing command raises lrsRun:commandFailed. The test
%       writes the H- and V-representations of the positive quadrant by hand in a temporary
%       folder, so the expected vertices, rays and facets are known: vertex (0, 0), rays
%       (1, 0) and (0, 1), facets x1 >= 0 and x2 >= 0 (lrs adds the trivial row 1 >= 0, which
%       the redund option removes). Failing commands and a machine without lrs are simulated
%       with stand-in scripts placed first on the PATH, and a machine without the program
%       redund with a PATH holding only lrs and which; the PATH is restored.
%
% Function under test:
%     src/analysis/topology/extremeRays/lrs/lrsInterface/lrsRun.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - no solver; needs the external program lrs (lrslib 7 or later), declared with
%     prepareTest('requiredSoftwares', {'lrs'}), because lrsRun is the interface to it (COBRA
%     ships it in binary/), and a Unix shell.
%
% Coverage exemptions:
%     Line 156: non-Unix branch (OS-specific); the test needs a Unix shell for lrs.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Declares redund, which the CI machine lacks (T034), 2026-11-20.
%     - lrsRun no longer runs redund: requirement lrs only, checks of the redund option route
%       (feature 20261120-140123-lrsrun-without-redund), 2026-11-20.
%     - lrsSpecifyRows no longer runs sed: minimal PATH lrs and which (feature
%       20261120-144501-lrsspecifyrows-without-sed), 2026-11-20.

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

%% redund = 0: the name takes _noR, and lrs removes the redundant facets

% vertex enumeration only renames: q6_noR.ine -> q6_noR.ext
writeText('q6_noR.ine', quadrantIne);
fileNameOut = lrsRun('q6', struct('redund', 0, 'facetEnumeration', 0));
assert(strcmp(fileNameOut, 'q6_noR.ext') && isequal(sortrows(readLrsRows(fileNameOut)), quadrantVertices));
% facet enumeration: lrs writes q7_noR.ine; lrs, run again on a temporary copy that carries
% its option redund 0 0, writes q7_noR_noR.ine without the trivial row 1 >= 0
writeText('q7_noR.ext', quadrantExt);
filesBefore = fileNames(pwd, '*');
temporaryInesBefore = fileNames(tempdir, '*.ine');
fileNameOut = lrsRun('q7', struct('redund', 0, 'facetEnumeration', 1));
assert(strcmp(fileNameOut, 'q7_noR_noR.ine'));
assert(isequal(sortrows(readLrsRows('q7_noR.ine')), quadrantFacets));
assert(isequal(sortrows(readLrsRows(fileNameOut)), quadrantFacetsNoRedundancy));
% lrs's facet output stays as lrs wrote it (no option line added to it), the folder gains only
% the two output files, and the temporary input of the redundancy step is removed
assert(~contains(fileread('q7_noR.ine'), 'redund'));
assert(isequal(setdiff(fileNames(pwd, '*'), filesBefore), {'q7_noR.ine'; 'q7_noR_noR.ine'}));
assert(isempty(setdiff(fileNames(tempdir, '*.ine'), temporaryInesBefore)));
% a name with extension keeps it: q8.ext -> q8.ine -> q8_noR.ine
writeText('q8.ext', quadrantExt);
fileNameOut = lrsRun('q8.ext', struct('redund', 0));
assert(strcmp(fileNameOut, 'q8_noR.ine') && isequal(sortrows(readLrsRows(fileNameOut)), quadrantFacetsNoRedundancy));

%% redund = 0 on a machine with lrs but without the program redund

% only lrs and which (both run by lrsRun) are on the PATH, as on a machine with COBRA's lrs for
% Linux, which ships no redund: a call of redund would fail with exit status 127; the facets
% are the same
writeText('q9_noR.ext', quadrantExt);
fileNameOut = runWithOnlyPrograms({'lrs', 'which'}, 'q9', struct('redund', 0, 'facetEnumeration', 1));
assert(strcmp(fileNameOut, 'q9_noR_noR.ine'));
assert(isequal(sortrows(readLrsRows(fileNameOut)), quadrantFacetsNoRedundancy));

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
% lrs failing in the redundancy step only (the stand-in runs the real lrs unless its input
% carries the option redund 0 0): the error names the command, and the temporary input is
% removed all the same
[~, realLrs] = system('command -v lrs');
writeText('f3_noR.ext', quadrantExt);
temporaryInesBefore = fileNames(tempdir, '*.ine');
message = runWithStandIn('lrs', sprintf(['#!/bin/sh\nif grep -q "redund 0 0" "$1"; then\n' ...
    '    echo stand-in failure\n    exit 5\nfi\nexec %s "$@"\n'], strtrim(realLrs)), ...
    'f3', struct('redund', 0, 'facetEnumeration', 1));
assert(contains(message, 'failed with exit status 5') && contains(message, 'f3_noR_noR.ine'));
assert(isempty(setdiff(fileNames(tempdir, '*.ine'), temporaryInesBefore)));
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

function names = fileNames(folder, pattern)
% names of the files in folder that match pattern, as a sorted column
listing = dir(fullfile(folder, pattern));
names = sort({listing(~[listing.isdir]).name})';
end

function fileNameOut = runWithOnlyPrograms(programNames, modelName, param)
% runs lrsRun with a PATH that holds only links to the named programs; the PATH and the links
% are restored and removed on return, also when lrsRun fails
programDir = tempname;
mkdir(programDir);
removeProgramDir = onCleanup(@() rmdir(programDir, 's'));
for i = 1:numel(programNames)
    [status, programPath] = system(['command -v ' programNames{i}]);
    assert(status == 0, 'program %s not found', programNames{i});
    system(['ln -s ' strtrim(programPath) ' ' fullfile(programDir, programNames{i})]);
end
previousPath = getenv('PATH');
restorePath = onCleanup(@() setenv('PATH', previousPath));
setenv('PATH', programDir);
fileNameOut = lrsRun(modelName, param);
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
