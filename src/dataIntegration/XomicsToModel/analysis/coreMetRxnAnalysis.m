function [coreMetAbbrNew, coreRxnAbbrNew] = coreMetRxnAnalysis(oldModel, model, coreMetAbbr, coreRxnAbbr, deletedMets, deletedRxns, param)
% compares the set of core metabolites and reactions with the current model
% report the core metabolites and reactions removed
% reduce the set of core metabolites and reactions
%
% USAGE:
%   [coreMetAbbrNew, coreRxnAbbrNew] = coreMetRxnAnalysis(oldModel,model, coreMetAbbr, coreRxnAbbr, deletedMets, deletedRxns, param)
%
% INPUTS:
%  oldModel: model prior to adjustment, with the following fields
%  * .mets:
%  * .rxns:
%  * .metNames:
% model: new model after adjustments, with the following fields
%  * .mets:
%  * .rxns:
%
%  coreMetAbbr: core metabolite identifiers 
%  coreRxnAbbr: core reaction identifiers
%
% OPTIONAL INPUTS:
%  deletedMets: set of metabolites removed from oldModel. If empty, given by setdiff(oldModel.mets,model.mets);
%  deletedRxns: set of reactions removed from oldModel. If empty, setdiff(oldModel.rxns,model.rxns);
%
%  param.message:
%  param.printLevel:
%
% OUTPUTS:
%  coreMetAbbrNew: set of core metabolites in the new model
%  coreRxnAbbrNew: set of core reactions in the new model
%
% EXAMPLE:
%
% NOTE:
%
% Author(s):

if ~exist('deletedMets','var') || isempty(deletedMets)
    if isempty(oldModel)
        deletedMets = [];
    else
        deletedMets = setdiff(oldModel.mets,model.mets);
    end
end

if ~exist('deletedRxns','var')  || isempty(deletedRxns)
    if isempty(oldModel)
        deletedMets = [];
    else
        deletedRxns = setdiff(oldModel.rxns,model.rxns);
    end
end
if ~exist('param','var')
    param = struct();
end
if ~isfield(param,'printLevel')
    param.printLevel = 0;
end
if ~isfield(param,'message')
    param.message = 'deletion';
end

%% metabolites
if ~isempty(coreMetAbbr)
    if isempty(oldModel)
        %check in case the core metabolite list contains some metabolites not in the old model
        missingCoreMetAbbr = setdiff(coreMetAbbr,[deletedMets,model.mets]);
    else
        %check in case the core metabolite list contains some metabolites not in the old model
        missingCoreMetAbbr = setdiff(coreMetAbbr,oldModel.mets);
    end
    if ~isempty(missingCoreMetAbbr)
        disp('coreMetRxnAnalysis: Old model does not contain these core metabolites (now removed from core metabolite set):')
        disp(missingCoreMetAbbr)
        coreMetAbbr = setdiff(coreMetAbbr,missingCoreMetAbbr);
    end
end

% Find the set of deleted non-core metabolites
if isnumeric(coreMetAbbr)
coreMetAbbr = num2str(coreMetAbbr);
coreMetAbbr = cellstr(coreMetAbbr);
end

if ~isempty(deletedMets)
    deletedNonCoreMetAbbr = setdiff(deletedMets, coreMetAbbr);
else
    deletedNonCoreMetAbbr = [];
end

% Display the set of non-core metabolites corresponding to inactive genes
if param.printLevel > 0
    fprintf('%u%s\n',length(deletedNonCoreMetAbbr), [' deleted non-core metabolites,  corresponding to ' param.message '.'])
    if param.printLevel>2
        disp(deletedNonCoreMetAbbr)
    end
end

% Find the set of deleted core metabolites
if ~isempty(deletedMets)
    deletedCoreMetAbbr = intersect(deletedMets, coreMetAbbr);
else
    deletedCoreMetAbbr = [];
end

% Display the set of core metabolites that were deleted
if param.printLevel > 0
    fprintf('%u%s\n',length(deletedCoreMetAbbr), [' deleted core metabolites,  corresponding to ' param.message '.'])
    if isempty(oldModel)
        disp(deletedCoreMetAbbr)
    elseif ~isempty(deletedCoreMetAbbr)
        T = table(oldModel.mets(ismember(oldModel.mets, deletedCoreMetAbbr)), ...
            oldModel.metNames(ismember(oldModel.mets, deletedCoreMetAbbr)), ...
            'VariableNames', {'mets', 'metNames'});
        disp(T);
    end
end


% Check in case the core metabolite list still contains some metabolites not in the model
if ~isempty(coreMetAbbr) && ~isempty(coreMetAbbr{1})
    
    % Remove deleted core metabolties
    coreMetAbbrNew = setdiff(coreMetAbbr,deletedMets);
    
    missingCoreMetAbbr = setdiff(coreMetAbbrNew, model.mets);
    if ~isempty(missingCoreMetAbbr)
        warning('Current model does not contain these metabolites from the core metabolite set (now removed from core metabolite set):')
        disp(missingCoreMetAbbr)
        coreMetAbbrNew = setdiff(coreMetAbbrNew, missingCoreMetAbbr);
    end
else
    coreMetAbbrNew = [];
end

%% reactions
if isempty(oldModel)
    %check in case the core metabolite list contains some metabolites not in the old model
    missingCoreRxnAbbr = setdiff(coreRxnAbbr,[deletedRxns,model.rxns]);
else
    %check in case the core metabolite list contains some metabolites not in the old model
    missingCoreRxnAbbr = setdiff(coreRxnAbbr,oldModel.rxns);
end
if ~isempty(missingCoreRxnAbbr)
    disp('Old model does not contain these core reactions (now removed from core reaction set):')
    disp(missingCoreRxnAbbr)
    coreRxnAbbr = setdiff(coreRxnAbbr,missingCoreRxnAbbr);
end

% Find the set of deleted non-core metabolites
deletedNonCoreRxnAbbr = setdiff(deletedRxns, coreRxnAbbr);

% Display the set of non-core reactions that were deleted
if param.printLevel > 0
    fprintf('%u%s\n',length(deletedNonCoreRxnAbbr), [' deleted non-core reactions,  corresponding to ' param.message '.'])
end
if param.printLevel>2
    if isempty(oldModel)
        disp(deletedNonCoreRxnAbbr)
    else
        rxnBool = ismember(oldModel.rxns,deletedNonCoreRxnAbbr);
        printConstraints(oldModel, -inf, inf, rxnBool)
    end
end

% Display the set of core reactions that were deleted
deletedCoreRxnAbbr = intersect(deletedRxns,coreRxnAbbr);
if param.printLevel > 0
    fprintf('%u%s\n',length(deletedCoreRxnAbbr), [' deleted core reactions,  corresponding to ' param.message '.'])
    if param.printLevel>0
        if isempty(oldModel)
            disp(deletedCoreRxnAbbr)
        else
            rxnBool = ismember(oldModel.rxns,deletedCoreRxnAbbr);
            printConstraints(oldModel, -inf, inf, rxnBool)
        end
    end
end

% Remove deleted core reactions
coreRxnAbbrNew = setdiff(coreRxnAbbr, deletedCoreRxnAbbr);

%check in case the core reaction list still contains some reactions not in the model
missingCoreRxnAbbr = setdiff(coreRxnAbbrNew,model.rxns);
if ~isempty(missingCoreRxnAbbr)
    warning('Current model does not contain these reactions from the core reaction set (now removed from core reaction set):')
    disp(missingCoreRxnAbbr)
    coreRxnAbbrNew = setdiff(coreRxnAbbrNew,missingCoreRxnAbbr);
end


end

