function model = changeCOBRAConstraints(model, constraintID, varargin)
% Modify an existing COBRA constraint by providing new settings for the
% constraint to update existing settings.
% USAGE:
%    model = changeCOBRAConstraints(model, constraintID, varargin)
%
% INPUTS:
%    model:             model structure
%    constraintID:      The ID of the constraint (or the index in the
%                       ctrs field) 
% 
% OPTIONAL INPUTS:
%    varargin:      all elements (name, d, dsense and c can be modified as indicated below.  
%                   * idList:           cell array of ids either from either the rxns, or the evars vectors. Can also be a a double vector of indices (in which case indices in evars have to be set off by numel(rxns).
%                   * c:                the elements of the C matrix. If idList is empty, this has to be a vector of length #rxns + #evars
%                   * dsense:           the constraint sense ('L': <= ,'G': >=, 'E': =), or a vector for multiple constraints
%                   * d:                The right hand side of the C*v <= d constraint (or a vector, for multiple simultaneous addition)
%                   * name:             The new, descriptive name of the constraint.
%                   
% OUTPUT:
%    model:         constrained model
%
% EXAMPLE:
%    Modify the constraint 'A_and_B_Lower_10' to read A + B + C <= 10
%    model = addCOBRAConstraints(model, 'A_and_B_Lower_10', 'idList', {'A','B','C'}, 'c', [1,1,1]);
%
% NOTE:
%    If c is provided, the whole constraint coefficients will be reset and
%    existing coefficients will be removed!
%
% Author: Thomas Pfau, Oct 2018


parser = inputParser();
parser.addRequired('model',@isstruct);
parser.addRequired('constraintID',@(x) ischar(x) && any(ismember(model.ctrs,x)));
parser.addParameter('d',[],@isnumeric);
parser.addParameter('c',[],@(x) isnumeric(x));
parser.addParameter('dsense','', @ischar );
parser.addParameter('idList',{},@(x) iscell(x) );
parser.addParameter('name',[],@(x) ischar(x) );
parser.parse(model,constraintID,varargin{:});

coefs = columnVector(parser.Results.c)';
d = parser.Results.d;
dsense = parser.Results.dsense;
idList = parser.Results.idList;
name = parser.Results.name;
c = parser.Results.c;

% get some model properties
[~,nRxns] = size(model.S);
if isfield(model,'evars')
    [nCtrs,nVars] = size(model.D);
else
    nVars = 0;
end

if ischar(constraintID)
    constraintID = find(ismember(model.ctrs,constraintID));
end

% check idList to determine new C/D values.
if ~isempty(c)
    if isempty(idList)
        if size(coefs,2) ~= nVars + nRxns
            error('If no idList is provided, the c vector has to contain one element for each reaction and each variable in the model');
        end
        newC = c(1:nRxns);
        newD = c((nRxns+1):end);
    else
        if size(c,2) ~= numel(idList)
            error('If idList is provided, the c vector has to contain one element for each element in idList');
        end
        % get the positions of the provided ids in rxns/evars
        [pos,pres] = getIDPositions(model,idList,'rxns');
        if any(~pres)
            missingreactions = idList(~pres);
            error('The following ids were not found in the model:\n%s\nNo Constraint was added',strjoin(missingreactions,', '));
        end
        % create the respective rows.
        newC = sparse(1,nRxns);
        newD = sparse(1,nVars);
        % get the positions of the variables
        vars = pos > nRxns;
        varPos = pos(vars) - nRxns;
        varCoefs = c(vars);
        rxns = pos <= nRxns;
        rxnPos = pos(rxns);
        rxnCoefs = c(rxns);
        newC(rxnPos) = rxnCoefs;
        newD(varPos) =varCoefs;        
    end
    
    % set the rows if applicable
    model.C(constraintID,:) = newC;
    if isfield(model, 'D')
        model.D(constraintID,:) = newD;
    end
end

% update d
if ~isempty(d)
    model.d(constraintID) = d;
end

% update dsense
if ~isempty(dsense)
    model.dsense(constraintID) = dsense;
end

% update name:
if ~isempty(name)
    if ~isfield(model,'ctrNames')
        model = createEmptyFields(model,'ctrNames');
    end
    model.ctrNames{constraintID} = name;
end