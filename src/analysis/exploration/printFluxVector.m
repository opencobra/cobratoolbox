function printFluxVector(model, fluxData, nonZeroFlag, excFlag, sortCol, fileName, headerRow, formulaFlag)
% Prints a flux vector with reaction labels
%
% USAGE:
%    printFluxVector(model, fluxData, nonZeroFlag, excFlag, sortCol, fileName, headerRow, formulaFlag)
%
% INPUTS:
%    model:          COBRA model structure
%    fluxData:       Data matrix/vector (for example, solution.v)
%
% OPTIONAL INPUTS:
%    nonZeroFlag:    Only print nonzero rows (Default = false)
%    excFlag:        Only print exchange fluxes (Default = false)
%    sortCol:        Column used for sorting (-1, none; 0, labels; >0, data
%                    columns;) (Default = -1)
%    fileName:       Name of output file (Default = [])
%    headerRow:      Header (Default = [])
%    formulaFlag:    Print reaction formulas (Default = false)
%
% .. Authors:
%       - Markus Herrgard 6/9/06

if isempty(fluxData)
    return
end
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
    if nonZeroFlag
        bool=fluxData~=0;
        formulas = printRxnFormula(model, labels(bool), false, false);
        labels = [labels(bool), formulas];
        printLabeledData(labels, fluxData(bool), 0, sortCol, fileName, headerRow)
    else
        formulas = printRxnFormula(model, labels, false, false);
        labels = [labels, formulas];
        printLabeledData(labels, fluxData(bool), nonZeroFlag, sortCol, fileName, headerRow)
    end
else
    printLabeledData(labels, fluxData, nonZeroFlag, sortCol, fileName, headerRow)
end
