% The COBRAToolbox: This is a test function for calculatePercentile.m
%
% Purpose:
%     - For testing the IgemRNA preprocessing function for calculating
%     percentiles
%
% Authors:
%     - Kristina Grausa 05/16/2022 - created 
%     - Kristina Grausa 08/22/2022 - standard header and formatting
%     - Farid Zare 27 Feb 2024, Standard formatting and name
%

global CBTDIR

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% require the specified toolboxes and solvers, along with a UNIX OS
solvers = prepareTest('needsLP', true);

% load reference data
trData = readtable('testData_transcriptomics.xlsx','Sheet','SRR8994357_WT');
expressionValues = trData.Data;

for k = 1:length(solvers.LP)
    fprintf(' -- Running testCalculatePercentile.m using the solver interface: %s ... ', solvers.LP{k});
    
    solverLPOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);

    if solverLPOK
       value = calculatePercentile(expressionValues, k);
       value = value + 1;
       assert(value == 4)
       
       % output a success message
       fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)
