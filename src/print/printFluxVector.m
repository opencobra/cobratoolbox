function printFluxVector(model, fluxData, nonZeroFlag, excFlag, sortCol, fileName, headerRow, formulaFlag)
% Prints a flux vector with reaction labels
%
% USAGE:
%    printFluxVector(model, fluxData, nonZeroFlag, excFlag, sortCol, fileName, headerRow, formulaFlag)
%
% INPUTS:
%    model:         COBRA model structure
%    fluxData:      Data matrix/vector (for example, solution.x)
%
% OPTIONAL INPUTS:
%    nonZeroFlag:   Only print nonzero rows (Default = false)
%    excFlag:       Only print exchange fluxes (Default = false)
%    sortCol:       Column used for sorting (-1, none; 0, labels; >0, data
%                   columns;) (Default = -1)
%    fileName:      Name of output file (Default = [])
%    headerRow:     Header (Default = [])
%    formulaFlag:   Print reaction formulas (Default = false)
%
% .. Authors:
%       - Markus Herrgard 6/9/06

if nargin < 3
    nonZeroFlag = false;
end
if nargin < 4
    excFlag = false;
end
if nargin < 5
    sortCol = -1;
end
if nargin < 6
    fileName = [];
end
if nargin < 7
    headerRow = [];
end
if nargin < 8
    formulaFlag = false;
end

if (excFlag)
    selExchange = findExcRxns(model, true, false);
    labels = model.rxns(selExchange);
    fluxData = fluxData(selExchange, :);
else
    labels = model.rxns;
end

% Add reaction formulas
if (formulaFlag)
    rxnNames = labels;
    formulas = printRxnFormula(model, labels, false, false);
    for i = 1:length(rxnNames)
        labels{i, 2} = formulas{i};
    end
end

printLabeledData(labels, fluxData, nonZeroFlag, sortCol, fileName, headerRow)
