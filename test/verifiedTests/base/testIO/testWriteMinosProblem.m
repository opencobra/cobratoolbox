% The COBRAToolbox: testWriteMinosProblem.m
%
% Purpose:
%     - test the writeMinosProblem function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWriteMinosProblem'));
cd(fileDir);

% test variables
LPproblem.A = [1 1 0; -1 0 -1; 0 -1 1];             %LHS matrix
LPproblem.b = [5; -10; 7];                          %RHS vector
LPproblem.lb = [0; -1; 0];                          %Lower bound vector
LPproblem.ub = [4; 1; inf];                         %Upper bound vector
LPproblem.c = [1; 4; 9];                              %Objective coeff vector
LPproblem.csense = ['L'; 'L'; 'E'];                 %Constraint sense
LPproblem.osense = 1;                               %Minimize

LPproblem2 = rmfield(LPproblem, 'csense');          % function will add it automatically
LPproblem2 = rmfield(LPproblem2, 'osense');         % function will add it automatically
LPproblem2.S = ['L'; 'L'; 'E'];

% function outputs
[directory, fname] = writeMinosProblem(LPproblem);
[directory2, fname2] = writeMinosProblem(LPproblem2, 'single', 'FBA2', pwd, 1);

% test for the common part, the rest differs by precision
testFile = fopen('FBA.txt', 'r');
testVar = fscanf(testFile, '%c');
testVar = testVar(4:149);
fclose(testFile);
testFile_2 = fopen('FBA2.txt', 'r');
testVar_2 = fscanf(testFile_2, '%c');
testVar_2 = testVar_2(5:150);
fclose(testFile_2);

assert(isequal(testVar, testVar_2));

% delete the test files
delete FBA.txt
delete FBA2.txt

% change to old directory
cd(currentDir);
