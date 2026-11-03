% The COBRAToolbox: testLrsInterface.m
%
% Purpose:
%     - tests the functionality of lsr interface.
%
% Authors:
%     - Ronan Fleming October 2021
%
% Test vertex enumeration problem from
%     Extreme Pathway Lengths and Reaction Participation in Genome-Scale Metabolic Networks
%     Jason A. Papin, Nathan D. Price and Bernhard Ø. Palsson

% save the current path
currentDir = pwd;

solverPkgs = prepareTest('requiredSoftwares',{'lrs'});

% set the model name
modelName = 'test';

%set the parameters
param.positivity = 0;
param.inequality = 0;
param.shellScript = 0;

% initialize the test
fileDir = fileparts(which('testLrsInterface'));
cd(fileDir);

S = [-1,  0,  0,  0,  0,  0, 1,  0,  0;
      1, -2, -2,  0,  0,  0, 0,  0,  0;
      0,  1,  0,  0, -1, -1, 0,  0,  0;
      0,  0,  1, -1,  1,  0, 0,  0,  0;
      0,  0,  0,  1,  0,  1, 0, -1,  0;
      0,  1,  1,  0,  0,  0, 0,  0, -1;
      0,  0, -1,  1, -1,  0, 0,  0,  0];

% no linear objective
f = [];

%fileNameOut = lrsWriteHalfspace(A, b, csense, modelName, param)
fileNameOut = lrsWriteHalfspace(S, [], [], modelName, param);
system(['cp ' fileNameOut ' ' strrep(fileNameOut,'test.ine','test_manual.ine')])  
%run lrs
param.facetEnumeration  = 0;%vertex enumeration
fileNameOut = lrsRun(modelName, param);
%read in vertex representation
[Q, vertexBool, fileNameOut] = lrsReadRay(modelName,param);
system(['cp ' fileNameOut ' ' strrep(fileNameOut,'test.ext','test_lrs.ext')])  


%write out vertex representation
[fileNameOut, extension] = lrsWriteRay(Q,modelName,vertexBool,param);
system(['cp ' fileNameOut ' ' strrep(fileNameOut,'test.ext','test_manual.ext')])  
%run lrs
param.facetEnumeration  = 1;
fileNameOut = lrsRun(modelName, param);
%read in halfspace representation
[A,b,csense] = lrsReadHalfspace(modelName,param);
if param.inequality == 1
    %only every second row required
    A = A(1:2:end,1);
    b = b(1:2:end);
end
if 0
    %implicit representation of a polytope is not uniquely defined from vertex representation
    assert(all((S - A)==0,'all'))
end

%write out halfspace representation
fileNameOut = lrsWriteHalfspace(A, b, csense, [modelName '2'], param);
%run lrs
param.facetEnumeration  = 0;%vertex enumeration
fileNameOut = lrsRun([modelName '2'], param);
%read in vertex representation
[Q2, vertexBool, fileNameOut] = lrsReadRay([modelName '2'],param);
if 1
    Qsorted = sortrows(full(Q));
    Q2sorted = sortrows(full(Q2));
    assert(isequal(Qsorted, Q2sorted), ...
        ['LrsInterface vertex mismatch (positivity=0).\nSize(Q)=%s, Size(Q2)=%s\n' ...
         'Q:\n%s\nQ2:\n%s\nSorted(Q):\n%s\nSorted(Q2):\n%s'], ...
        mat2str(size(Q)), mat2str(size(Q2)), mat2str(Q), mat2str(Q2), ...
        mat2str(Qsorted), mat2str(Q2sorted))
end


param.positivity = 1;
%fileNameOut = lrsWriteHalfspace(A, b, csense, modelName, param)
fileNameOut = lrsWriteHalfspace(S, [], [], modelName, param);
system(['cp ' fileNameOut ' ' strrep(fileNameOut,'test.ine','test_manual.ine')])  
%run lrs
param.facetEnumeration  = 0;%vertex enumeration
fileNameOut = lrsRun(modelName, param);
%read in vertex representation
[Q, vertexBool, fileNameOut] = lrsReadRay(modelName,param);
system(['cp ' fileNameOut ' ' strrep(fileNameOut,'test.ext','test_lrs.ext')])  
%write out vertex representation
[fileNameOut, extension] = lrsWriteRay(Q,modelName,vertexBool,param);
system(['cp ' fileNameOut ' ' strrep(fileNameOut,'test.ext','test_manual.ext')])  
%run lrs
param.facetEnumeration  = 1;
fileNameOut = lrsRun(modelName, param);
%read in halfspace representation
[A,b,csense] = lrsReadHalfspace(modelName,param);
if any(csense~='E') && param.inequality == 1
    %only every second row required
    %TODO encode this properly 
    A = A(1:2:end,1);
    b = b(1:2:end);
    csense = csense(1:2:end);
end
if 0
    %implicit representation of a polytope is not unique
    assert(all((S - A)==0,'all'))
end
%write out halfspace representation
fileNameOut = lrsWriteHalfspace(A, b, csense, [modelName '2'], param);
%run lrs
param.facetEnumeration  = 0;%vertex enumeration
fileNameOut = lrsRun([modelName '2'], param);
%read in vertex representation
[Q2, vertexBool, fileNameOut] = lrsReadRay([modelName '2'],param);
if 1
    Qsorted = sortrows(full(Q));
    Q2sorted = sortrows(full(Q2));
    assert(isequal(Qsorted, Q2sorted), ...
        ['LrsInterface vertex mismatch (positivity=1).\nSize(Q)=%s, Size(Q2)=%s\n' ...
         'Q:\n%s\nQ2:\n%s\nSorted(Q):\n%s\nSorted(Q2):\n%s'], ...
        mat2str(size(Q)), mat2str(size(Q2)), mat2str(Q), mat2str(Q2), ...
        mat2str(Qsorted), mat2str(Q2sorted))
end

% lrsRun must stop with an error naming the command and its exit status when lrs cannot
% run, for vertex and for facet enumeration. Each case reads its own copy of test.ine or
% test.ext, because the failed run overwrites the file it redirects into.
if isunix
    standInInput = {'standInVertex.ine', 'standInFacet.ext'};
    copyfile([modelName '.ine'], standInInput{1});
    copyfile([modelName '.ext'], standInInput{2});
    for facetEnumeration = 0:1
        param.facetEnumeration = facetEnumeration;
        message = lrsRunErrorMessageWithStandIn(standInInput{facetEnumeration + 1}(1:end - 4), param);
        assert(contains(message, 'exit status 127'), ...
            'lrsRun did not report exit status 127 (facetEnumeration = %d): %s', facetEnumeration, message);
    end
end

% shell-script mode: exit status 0 returns the output file name, non-zero is an error
param.shellScript = 1;
param.facetEnumeration = 0;
shellFid = fopen([modelName '.sh'], 'w');
fprintf(shellFid, '#!/bin/sh\nexit 0\n');
fclose(shellFid);
fileNameOut = lrsRun(modelName, param);
assert(strcmp(fileNameOut, [modelName '.ext']), 'lrsRun shell-script mode returned %s', fileNameOut);
shellFid = fopen([modelName '.sh'], 'w');
fprintf(shellFid, '#!/bin/sh\nexit 3\n');
fclose(shellFid);
message = lrsRunErrorMessage(modelName, param);
assert(contains(message, 'exit status 3'), 'lrsRun shell-script failure not reported: %s', message);
param.shellScript = 0;

if 1
% delete generated files
delete('*.ine');
delete('*.ext');
delete('*.sh');
delete('*.time');
end

% change the directory
cd(currentDir)

function message = lrsRunErrorMessageWithStandIn(modelName, param)
% runs lrsRun with a stand-in lrs that exits 127 first on the PATH; the PATH and the
% stand-in are restored on return, also when an assertion fails
standInDir = tempname;
mkdir(standInDir);
removeStandIn = onCleanup(@() rmdir(standInDir, 's'));
standInFid = fopen(fullfile(standInDir, 'lrs'), 'w');
fprintf(standInFid, '#!/bin/sh\necho stand-in lrs failure\nexit 127\n');
fclose(standInFid);
system(['chmod +x ' fullfile(standInDir, 'lrs')]);
previousPath = getenv('PATH');
restorePath = onCleanup(@() setenv('PATH', previousPath));
setenv('PATH', [standInDir pathsep previousPath]);
message = lrsRunErrorMessage(modelName, param);
end

function message = lrsRunErrorMessage(modelName, param)
% runs lrsRun, asserts that it raises lrsRun:commandFailed, and returns the message
try
    lrsRun(modelName, param);
catch ME
    assert(strcmp(ME.identifier, 'lrsRun:commandFailed'), ...
        'lrsRun raised %s instead of lrsRun:commandFailed: %s (%s line %d)', ...
        ME.identifier, ME.message, ME.stack(1).file, ME.stack(1).line);
    message = ME.message;
    return
end
error('lrsRun did not raise an error.');
end
