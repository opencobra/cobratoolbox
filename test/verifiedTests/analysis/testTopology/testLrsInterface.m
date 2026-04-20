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

if 1
% delete generated files
delete('*.ine');
delete('*.ext');
delete('*.sh');
delete('*.time');
end

% change the directory
cd(currentDir)
