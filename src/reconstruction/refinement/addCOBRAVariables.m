function model = addCOBRAVariables(model, idList, varargin)
% Add a Variable to the COBRA model provided. These variables can be
% referred to by additional constraints added via addCOBRAConstraint. Their
% IDs have to be mutually exclusive with the IDs in model.rxns
% USAGE:
%    model = addCOBRAVariables(model, idList, varargin)
%
% INPUTS:
%    model:         model structure
%    idList:        cell array of ids 
%
%    varargin:
%                   * lb:               The lower bounds of the variables
%                                       Has to be of the same size as
%                                       idlist
%                                       (default: -1000)
%                   * ub:               The upper bounds of the variables.
%                                       Has to be of the same size as
%                                       idlist
%                                       (default: 1000)
%                   * c:                The objective coefficient of the variables
%                                       Has to be of the same size as idlist                                      
%                                       (default: 0)
%                   * Names:            Descriptive names of the variables.
%                                       (default: idList)
% OUTPUT:
%    model:  constrained model
%
% Author: Thomas Pfau, Oct 2018

if ischar(idList) 
    %This is an individual element.
    idList = {idList};
end

p = inputParser();
p.CaseSensitive = false;
p.addRequired('model',@isstruct);
p.addRequired('idList',@iscell);
p.addParameter('lb',columnVector(-1000*ones(size(idList))),@(x) isnumeric(x) && numel(x) == numel(idList));
p.addParameter('ub',columnVector(1000*ones(size(idList))),@(x) isnumeric(x) && numel(x) == numel(idList));
p.addParameter('c',columnVector(zeros(size(idList))),@(x) isnumeric(x) && numel(x) == numel(idList));
p.addParameter('Names',idList, @(x) (iscell(x) && numel(x) == numel(idList)) || ischar(x) && numel(idList == 1));
p.parse(model,idList,varargin{:});

if any(ismember(model.rxns,idList))
    duplicateIDs = unique(model.rxns(ismember(model.rxns,idList)));    
    error('The following IDs are already IDs of reactions:\n%s\n',strjoin(duplicateIDs,'\n'));    
end

% no variables exist yet, so we need to build the fields.
if ~isfield(model,'evars')
    % we need to create new fields
    if ~isfield(model,'ctrs')
        fieldsToCreate = {'E','evars','evarlb','evarub','evarc'};
    else
        fieldsToCreate = {'E','evars','evarlb','evarub','evarc','D'};
    end    
    model = createEmptyFields(model,fieldsToCreate);
else
    % check, that the IDs are valid.
    if any(ismember(model.evars,idList))
        duplicateIDs = unique(model.evars(ismember(model.evars,idList)));
        error('The following IDs are already IDs of variables:\n%s\n',strjoin(duplicateIDs,'\n'));
    end
end

if ~isfield(model,'evarNames') && ~any(strcmp(p.UsingDefaults,'Names'))
    % if the field does not yet exist, and we got actual names, we need to
    % create the field.
    model = createEmptyFields(model,{'evarNames'});
end


% this is all checks done, now lets get to work.
[~,nVars] = size(model.E);


% extend the IDs.
model.evars = [model.evars; columnVector(idList)];
model.evarlb = [model.evarlb; columnVector(p.Results.lb)];
model.evarub = [model.evarub; columnVector(p.Results.ub)];
model.evarc = [model.evarc; columnVector(p.Results.c)];

if isfield(model,'evarNames')
    model.evarNames = [model.evarNames; columnVector(p.Results.Names)];
end

% extend other fields as necessary.
model = extendModelFieldsForType(model,'evars','originalSize',nVars);