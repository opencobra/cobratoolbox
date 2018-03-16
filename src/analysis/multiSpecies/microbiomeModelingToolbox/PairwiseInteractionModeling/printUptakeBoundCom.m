function printUptakeBoundCom(model, SpFlag, metFlag)
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
    comMetDisp = model.metNames(comMet);
    for j = 1:numel(comMetDisp)
        if iscell(comMetDisp{j})
            comMetDisp{j} = comMetDisp{j}{1};
        end
    end
else  % print with .mets. Get rid of the compartment name
    comMetDisp = cellfun(@(x) regexprep(model.mets{x}, '\[u\]$', ''), num2cell(comMet), 'UniformOutput', false);
end
% prepend the index of the met among all mets in [u]
comMetDisp = strcat('(', num2str((1:size(comMetDisp, 1))'),repmat({') '}, size(comMetDisp, 1), 1), comMetDisp);
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
for j = 1:numel(comMet)
    if SpFlag
        % show the row if the organism-specific uptake rate if lb < 0
        show(j) = show(j) | any(model.lb(indCom.EXsp(j, indCom.EXsp(j,:) > 0)) < 0);
    end
end
% show the row if the community uptake rate is non-zero
show = show | compareSign(model.(bd)(indCom.EXcom(:,1)));
hostExist = isfield(indCom, 'EXhost') && ~isempty(indCom.EXhost);
if hostExist
    show = show | model.lb(indCom.EXhost) < 0;
end
len = cellfun(@(x) length(x), comMetDisp);  % number of characters for each met[u] to be displayed
fp = sprintf(['%%' num2str(max(len(show))) 's\t']);  % number of character spaces needed
if ~hostExist
    fprintf([fp '%-10s' repmat('%-10s', 1, nSp) '\n'],'Mets', 'Comm.', spAbbr{:});
    for j = 1:numel(comMet)
        if show(j)
            lbSp = zeros(nSp,1);
            lbSp(indCom.rxnSps(indCom.EXsp(j,indCom.EXsp(j,:) > 0))) = model.lb(indCom.EXsp(j,indCom.EXsp(j,:) > 0));
            fprintf([fp repmat('%-10.3g', 1, nSp + 1) '\n'], comMetDisp{j}, ...
                abs(model.(bd)(findRxnIDs(model,model.infoCom.EXcom(j,1)))), lbSp(:));
        end
    end
else
    fprintf([fp '%-10s' repmat('%-10s', 1, nSp + 1) '\n'],'Mets', 'Comm.', spAbbr{:}, [spAbbr{end} ' (host [b])']);
    for j = 1:numel(comMet)
        if show(j)
            lbSp = zeros(nSp, 1);
            lbSp(indCom.rxnSps(indCom.EXsp(j,indCom.EXsp(j,:) > 0))) = model.lb(indCom.EXsp(j,indCom.EXsp(j,:) > 0));
            fprintf([fp repmat('%-10.3g', 1, nSp + 2) '\n'], comMetDisp{j}, ...
                abs(model.(bd)(findRxnIDs(model,model.infoCom.EXcom(j,1)))), lbSp(:), model.lb(indCom.EXhost(j)));
        end
    end
end


end
