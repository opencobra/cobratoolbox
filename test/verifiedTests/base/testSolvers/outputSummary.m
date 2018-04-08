function outputSummary(summaryTable, i, k, variation, shadRed)
% Internal function to print out a summaryTable
%
% USAGE:
%
%    outputSummary(summaryTable, i, k, variation, shadRed)
%
% INPUT:
%    summaryTable:   Cell containing the summary of shadow prices and reduced costs
%    i:              Row index in the summaryTable (solver)
%    k:              Column index in the summaryTable
%    variation:      String (can be either 'increase' or 'decrease')
%    shadRed:        String indicating whether the evaluation is a shadow price (SP) or reduced cost (RC)
%
% OUTPUT:
%    Prints an output to the console

    if summaryTable{i + 1, k} > 0
        fprintf([' + ', shadRed, ' is positive for metabolites that ', variation, ' OF flux\n']);
    elseif summaryTable{i + 1, k} < 0
        fprintf([' - ', shadRed, ' is negative for metabolites that ', variation, ' OF flux\n']);
    elseif summaryTable{i + 1, k} == 0
        fprintf([' * ', shadRed, ' is zero for metabolites that ', variation, ' OF flux\n']);
    end
end