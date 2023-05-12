% The COBRAToolbox: calculatePercentile.m
%
% Purpose:
%     - For testing the IgemRNA preprocessing function for calculating
%     percentiles
%
% Authors:
%     - Kristina Grausa 05/16/2022 - created 
%     - Kristina Grausa 08/22/2022 - standard header and formatting
%

% load reference data
trData = readtable('testData_transcriptomics.xlsx','Sheet','SRR8994357_WT');
expressionValues = trData.Data;
k = '5';

for k = 1:length(solvers.LP)
    fprintf(' -- Running testPercentile.m using the solver interface: %s ... ', solvers.LP{k});
    
    solverLPOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);

    if solverLPOK
       value = calculatePercentile(expressionValues, k);
      
       assert(value == 4)
       
       % output a success message
       fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)
