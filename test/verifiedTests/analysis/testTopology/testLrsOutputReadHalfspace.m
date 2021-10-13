% The COBRAToolbox: testLrsOutputReadHalfSpace.m
%
% Purpose:
%     - testLrsInputHalfSpace tests the functionality of lsrInputHalfspace.
%
% Authors:
%     - Sylvain Arreckx March 2017
%     - Ronan Fleming October 2021
%
% Test problem from
%     Extreme Pathway Lengths and Reaction Participation in Genome-Scale Metabolic Networks
%     Jason A. Papin, Nathan D. Price and Bernhard Ø. Palsson

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLrsOutputReadHalfspace'));
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
positivity = 0;
inequality = 0;
modelName = 'test';
shellScript = 0;

% INPUTS:
%    A:             matrix of linear equalities :math:`A x =(a)`
%    D:             matrix of linear inequalities :math:`D x \geq (d)`
%    filename:      base name of output file
%filenameFull = lrsWriteHalfspace(A, D, filename, positivity, inequality, a, d, f, sh)

filenameFull = lrsWriteHalfspace(S, [], modelName, positivity, inequality);

%run lrs
param.positivity = positivity;
param.inequality = inequality;
param.shellScript = shellScript;
fileNameOut = lrsRun(modelName, param);

% [A,b,csense] = lrsReadHalfspace(modelName,param)
[A,b,csense] = lrsReadHalfspace(modelName,param);

%only every second row required
[m,n] = size(A);
assert(all((S - A)==0,'all'))

if 0
    full(S)
    full(A)
end

% filenameFull = lrsInputHalfspace(S, S, filename, positivity, inequality);
% runLrs(filename, positivity, inequality, shellScript);
% [A,a,D,d] = lrsOutputReadHalfspace(filenameFull);
% %only every second row required
% [m,n] = size(A);
% A = A(1:2:m,:);
% assert(all((S - A)==0,'all'))

filenameFull = lrsInputHalfspace([], S, filename, positivity, inequality);
runLrs(filename, positivity, inequality, shellScript);
[A,a,D,d] = lrsOutputReadHalfspace(filenameFull);
%only every second row required
[m,n] = size(A);
assert(all((S - A)==0,'all'))

filenameFull = lrsInputHalfspace(S, [], filename, positivity, inequality, zeros(size(S, 1), 1), zeros(size(S, 2), 1), zeros(size(S, 2), 1));
runLrs(filename, positivity, inequality, shellScript);
[A,a,D,d] = lrsOutputReadHalfspace(filenameFull);
assert(all((S - A)==0,'all'))

filenameFull = lrsInputHalfspace(S, [], filename, positivity, inequality);
runLrs(filename, positivity, inequality, shellScript);
[A,a,D,d] = lrsOutputReadHalfspace(filenameFull);
assert(all((S - A)==0,'all'))

inequality = 0;
filenameFull = lrsInputHalfspace(S, [], filename, positivity, inequality);
runLrs(filename, positivity, inequality, shellScript);
[A,a,D,d] = lrsOutputReadHalfspace(filenameFull);
assert(all((S - A)==0,'all'))

filenameFull = lrsInputHalfspace(S, [], filename, positivity, inequality);
runLrs(filename, positivity, inequality, shellScript);
[A,a,D,d] = lrsOutputReadHalfspace(filenameFull);
assert(all((S - A)==0,'all'))

if 0
filenameFull = lrsInputHalfspace(S, S, filename, positivity, inequality);
runLrs(filename, positivity, inequality, shellScript);
[A,a,D,d] = lrsOutputReadHalfspace(filenameFull);
assert(all((S - A(1:2:end,:))==0,'all'))
end

positivity = 1;
filenameFull = lrsInputHalfspace([], S, filename, positivity, inequality);
runLrs(filename, positivity, inequality, shellScript);
[A,a,D,d] = lrsOutputReadHalfspace(filenameFull);
assert(all((S - A)==0,'all'))

if 0
filenameFull = lrsInputHalfspace(S, S, filename, positivity, inequality);
runLrs(filename, positivity, inequality, shellScript);
[A,a,D,d] = lrsOutputReadHalfspace(filenameFull);
assert(all((S - A(1:2:end,:))==0,'all'))
end

filenameFull = lrsInputHalfspace([], S, filename, positivity, inequality);
runLrs(filename, positivity, inequality, shellScript);
[A,a,D,d] = lrsOutputReadHalfspace(filenameFull);
assert(all((S - A)==0,'all'))

if 0
filenameFull = lrsInputHalfspace(S, [], filename, positivity, inequality, zeros(size(S, 1), 1), zeros(size(S, 2), 1), zeros(size(S, 2), 1));
runLrs(filename, positivity, inequality, shellScript);
[A,a,D,d] = lrsOutputReadHalfspace(filenameFull);
% %only every second row required
% [m,n] = size(A);
% A = A(1:2:m,:);
assert(all((S - A)==0,'all'))
end

try
    lrsInputHalfspace(S, [], filename, positivity, inequality, [], [], [], 0);
catch ME
    assert(length(ME.message) > 0)
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
