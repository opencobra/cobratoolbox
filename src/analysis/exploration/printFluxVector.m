function printFluxVector(model, fluxData, nonZeroFlag, excFlag, sortCol, fileName, headerRow, formulaFlag, gprFlag)
% Prints a flux vector with reaction labels
%
% USAGE:
%    printFluxVector(model, fluxData, nonZeroFlag, excFlag, sortCol, fileName, headerRow, formulaFlag, gprFlag)
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
%    gprFlag:        Print reaction GPR (Default = false)
%

% .. Authors:
%       - Markus Herrgard, Ronan Fleming

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
if nargin < 9
    gprFlag = false;
end

if excFlag
    bool = findExcRxns(model, true, false);
else
    bool = true(size(model.S,2),1);
    labels = model.rxns;
end

if length(nonZeroFlag)==size(model.S,2)
    bool = bool & nonZeroFlag;
    nonZeroFlag = 1;
else
    if nonZeroFlag
        bool = bool & fluxData(:,1)~=0;
    end
end
  

% Add reaction formulas
if formulaFlag
    if nonZeroFlag
        labels = [model.rxns,model.rxns];
        %only generate the formulas for the nonzero entries
        formulas = printRxnFormula(model, labels(bool), false, false);
        labels(bool,2) = formulas;
    else
        formulas = printRxnFormula(model, labels, false, false);
        labels = [labels, formulas];
    end
end

% Add GPR
if gprFlag
    if nonZeroFlag
        %only generate the gprs for the nonzero entries
        labels(bool,end+1) = model.grRules(bool);
    else
        labels = [labels, model.grRules];
    end
end

%only print the nonzeros
if nonZeroFlag
    labels = labels(bool,:);
    fluxData = fluxData(bool,:);
end

labels(:,2) = pad(labels(:,2));

%print the labeled data
printLabeledData(labels, fluxData, 0, sortCol, fileName, headerRow)
