function model = addCOBRAVariables(model, idList, varargin)
% Add a Variable to the COBRA model provided. These variables can be
% referred to by additional constraints added via addCOBRAConstraint. Their
% IDs have to be mutually exclusive with the IDs in model.rxns
%
% USAGE:
%
%    model = addCOBRAVariables(model, idList, varargin)
%
% INPUTS:
%    model:         model structure with fields:
%
%                     * .rxns - `n x 1` reaction identifiers, checked so
%                       that new variable IDs do not clash with reaction IDs
%                     * .evars - `evars x 1` extra variable identifiers
%                       (created if absent, checked for duplicates otherwise)
%                     * .E - `m x evars` extra variable coefficient matrix,
%                       read to determine the current number of variables
%                     * .evarlb - `evars x 1` lower bounds of extra variables
%                     * .evarub - `evars x 1` upper bounds of extra variables
%                     * .evarc - `evars x 1` objective coefficients of extra variables
%                     * .evarNames - `evars x 1` extra variable names
%                       (created only if not already present and `Names`
%                       was supplied)
%    idList:        cell array of ids
%
% OPTIONAL INPUTS:
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
%
% OUTPUT:
%    model:         constrained model containing the new variables in the
%                   respective fields:
%
%                    * .E - The coefficient matrix for coefficients of metabolites for the variables
%                    * .evars - The variable IDs
%                    * .evarlb - The variable lower bounds
%                    * .evarub - The variable upper bounds
%                    * .evarc - The variable objective coefficient
%                    * .evarNames - The variable names (if provided or already present)
%
% NOTE:
%    This function will, if not present create the `E`, `evars`, `evarlb`, `evarub`, `evarc` and,
%    if additional Constraints (i.e. the `C` matrix) is present, the `D`
%    field as defined in the model field definitions. The `E` matrix containts
%    the Variable coefficients referring to metabolites, while the `D`
%    field contains the variable coefficients referring to additional
%    Constraints from `C`. `evars` contains the IDs of the additional
%    variables, with one entrey per column of `E`. `evarlb` and `evarub`
%    represent the lower and upper bounds of the variables respectively.
%    `evarc` are objective coefficients of the variables.
%
% .. Author: - Thomas Pfau, Oct 2018

if ischar(idList) 
    %This is an individual element.
    idList = {idList};
end

p = inputParser();
p.CaseSensitive = false;
p.addRequired('model',@isstruct);
p.addRequired('idList',@iscell);
p.addParameter('lb',columnVector(-1000*ones(size(idList))),@(x) isnumeric(x) && (numel(x) == numel(idList) || numel(x) == 1));
p.addParameter('ub',columnVector(1000*ones(size(idList))),@(x) isnumeric(x) && (numel(x) == numel(idList) || numel(x) == 1));
p.addParameter('c',columnVector(zeros(size(idList))),@(x) isnumeric(x) &&( numel(x) == numel(idList) || numel(x) == 1));
p.addParameter('Names',idList, @(x) (iscell(x) && numel(x) == numel(idList)) || ischar(x) && numel(idList == 1));
p.parse(model,idList,varargin{:});

lb = p.Results.lb;
if numel(lb) == 1
    lb = ones(numel(idList),1)*lb;
end

ub = p.Results.ub;
if numel(ub) == 1
    ub = ones(numel(idList),1)*ub;
end

c = p.Results.c;
if numel(c) == 1
    c = ones(numel(idList),1)*c;
end

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

% this is all checks done, now lets get to work.
[~,nVars] = size(model.E);

if ~isfield(model,'evarNames') && ~any(strcmp(p.UsingDefaults,'Names'))
    % if the field does not yet exist, and we got actual names, we need to
    % create the field.
    model = createEmptyFields(model,{'evarNames'});
end


% extend the IDs.
model.evars = [model.evars; columnVector(idList)];
model.evarlb = [model.evarlb; columnVector(lb)];
model.evarub = [model.evarub; columnVector(ub)];
model.evarc = [model.evarc; columnVector(c)];

if isfield(model,'evarNames')
    model.evarNames = [model.evarNames; columnVector(p.Results.Names)];
end

% extend other fields as necessary.
model = extendModelFieldsForType(model,'evars','originalSize',nVars);