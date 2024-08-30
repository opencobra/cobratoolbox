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
    assert(all((Q - Q2)==0,'all'))
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
    assert(all((Q - Q2)==0,'all'))
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
