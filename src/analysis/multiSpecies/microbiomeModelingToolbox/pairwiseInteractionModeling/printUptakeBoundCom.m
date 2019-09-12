function [printMatrix, printMet] = printUptakeBoundCom(model, SpFlag, metFlag)
% Prints the uptake bounds of the whole community and individual species for a community COBRA model
%
% USAGE:
%
%    rxnIDs = printUptakeBoundCom(model, SpFlag, metFlag)
%
% INPUT:
%    model:    the community model with field `.infoCom` or `.indCom` indicating the indicies of
%              community exchange reactions/metabolites. Can be obtained from `getMultiSpeciesModelId.m`
%
% OPTIONAL INPUTS:
%    SpFlag:   true to show individual uptake rates though community uptake is not allowed (default false)
%    metFlag:  true to print with `model.metNames` (default false) 
%
% OUTPUTS:
%    printMatrix: matrix of the uptake bounds being printed
%    printMet:    column of metabolites whose uptake bounds are printed

if nargin < 2 || isempty(SpFlag)
    SpFlag = false;
end
if nargin < 3 || isempty(metFlag)
    metFlag = false;
end
if ~isfield(model, 'indCom')
    if ~isfield(model, 'infoCom')
        error('model.indCom or model.infoCom must exist for printing bounds');
    end
    indCom = infoCom2indCom(model);
else
    indCom = model.indCom;
end
nSp = size(indCom.EXsp, 2);  % number of organisms
% organisms' abbreviations
if isfield(model, 'infoCom')
    spAbbr = model.infoCom.spAbbr;
else
    spAbbr = strcat('Org', strtrim(cellstr(num2str((1:nSp)'))));
end
comMet = find(indCom.metSps == 0);  % community metabolites
if metFlag  % print with .metNames
    printMet = model.metNames(comMet);
    for j = 1:numel(printMet)
        if iscell(printMet{j})
            printMet{j} = printMet{j}{1};
        end
    end
else  % print with .mets. Get rid of the compartment name
    printMet = cellfun(@(x) regexprep(model.mets{x}, '\[u\]$', ''), num2cell(comMet), 'UniformOutput', false);
end
% prepend the index of the met among all mets in [u]
printMet = strcat('(', num2str((1:size(printMet, 1))'),repmat({') '}, size(printMet, 1), 1), printMet);
show = false(numel(comMet), 1);  % to decide showing a met in [u] or not
if size(model.infoCom.EXcom, 2) == 1
    % if the model has a single community exchange reaction for each met[u]
    compareSign = @(x) x < 0;
    bd = 'lb';
elseif size(model.infoCom.EXcom, 2) == 2
    % if the model has separate community uptake and export reactions for each met[u]
    compareSign = @(x) x > 0;
    bd = 'ub';
else
    error('infoCom.EXcom or indCom.EXcom should have at most two columns.')
end
id = indCom.EXcom(:, 1) > 0;
% show the row if the community uptake rate is non-zero
show(id) = show(id) | compareSign(model.(bd)(indCom.EXcom(id, 1)));
if SpFlag
    % show the row if the any organism-specific uptake rate is non-zero
    for jSp = 1:nSp
        id = indCom.EXsp(:, jSp) > 0;
        show(id) = show(id) | model.lb(indCom.EXsp(id, jSp)) < 0;
    end
end
hostExist = isfield(indCom, 'EXhost') && ~isempty(indCom.EXhost);
if hostExist
    id = indCom.EXhost > 0;
    show(id) = show(id) | model.lb(indCom.EXhost(id)) < 0;
end
len = cellfun(@(x) length(x), printMet);  % number of characters for each met[u] to be displayed
maxLen = min(30, max(len(show)));
fp = sprintf(['%%' num2str(maxLen) 's\t']);  % number of character spaces needed
printMet = printMet(show);
printMatrix = zeros(sum(show), nSp + 1);
printMatrix(indCom.EXcom(show, 1) > 0, 1) = model.(bd)(indCom.EXcom(show & indCom.EXcom(:, 1) > 0, 1));
for jSp = 1:nSp
    printMatrix(indCom.EXsp(show, jSp) > 0, jSp + 1) = model.lb(indCom.EXsp(show & indCom.EXsp(:, jSp) > 0, jSp));
end
if ~hostExist
    fprintf([fp '%-10s' repmat('%-10s', 1, nSp) '\n'],'Mets', 'Comm.', spAbbr{:});
    for j = 1:size(printMatrix, 1)
        if length(printMet{j}) <= maxLen
            fprintf([fp repmat('%-10.3g', 1, nSp + 1) '\n'], printMet{j}, printMatrix(j, :));
        else
            fprintf([fp repmat('%-10.3g', 1, nSp + 1) '\n'], printMet{j}(1:maxLen), printMatrix(j, :));
            curLen = maxLen;
            while curLen < length(printMet{j})
                fprintf(['%' num2str(maxLen) 's\n'], printMet{j}((curLen + 1):min(curLen + maxLen, length(printMet{j}))))
                curLen = curLen + maxLen;
            end     
        end
    end
else
    printMatrix(indCom.EXhost(show) > 0, end + 1) = model.lb(indCom.EXhost(show & indCom.EXhost > 0));
    fprintf([fp '%-10s' repmat('%-10s', 1, nSp + 1) '\n'],'Mets', 'Comm.', spAbbr{:}, [spAbbr{end} ' (host [b])']);
    for j = 1:size(printMatrix, 1)
        if length(printMet{j}) <= maxLen
            fprintf([fp repmat('%-10.3g', 1, nSp + 2) '\n'], printMet{j}, printMatrix(j, :));
        else
            fprintf([fp repmat('%-10.3g', 1, nSp + 2) '\n'], printMet{j}(1:maxLen), printMatrix(j, :));
            curLen = maxLen;
            while curLen < length(printMet{j})
                fprintf(['%%' num2str(maxLen) 's\n'], printMet{j}((curLen + 1):min(curLen + maxLen, length(printMet{j}))))
                curLen = curLen + maxLen;
            end     
        end
    end
end


end
