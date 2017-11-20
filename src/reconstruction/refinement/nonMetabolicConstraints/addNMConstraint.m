function model = addNMConstraint(model, rxnList, varargin)
% Add a non Metabolic Constraint as defined by:
% sum(c(i)*v(rxn(i)) dsense d
% USAGE:
%    model = addNMConstraint(model, rxnList, varargin)
%
% INPUTS:
%    model:         model structure
%    rxnList:       cell array of reaction names, or double vector of
%                   reaction Positions 
%                   * c:                the coefficients to use with one entry per
%                                       reaction of a constraint (default: 1 for each element in rxnList)
%                   * d:                The right hand side of the C*v <= rhs constraint
%                                       (default: 0)
%                   * dsense:           the constraint sense ('L': <= , 'G': >=, 'E': =)
%                                       (default: ('L'))
%                   * ConstraintID:     the Name of the constraint. by
%                                       (default: 'ConstraintXYZ' with XYZ being the initial 
%                                       position in the mets vector
%                   * checkDuplicates:  check whether the constraint already
%                                       exists, and if it does, don't add it (default: false)
%
% OUTPUT:
%    modelConstrained:  constrained model
%
% EXAMPLE:
%    Add a constraint that leads to EX_glc and EX_fru not carrying a
%    combined flux higher than 5
%    model = addNMConstraint(model, {'EX_glc','EX_fru'}, 'c', [1 1], 'd', 5, 'dsense', 'L')
%    Assume Reaction 4 to be 2 A -> D and reaction 5 being A -> F. Create a
%    constraint that requires that the two reactions remove at least 4 units of A:
%    model = addNMConstraint(model, model.rxns(4:5), 'c', [2 1], 'd', 4, 'dsense', 'G')
%

if ischar(rxnList)
    rxnList = {rxnList};
end

if iscell(rxnList)
    [pres,pos] = ismember(rxnList,model.rxns);        
    if ~isempty(setdiff(rxnList,model.rxns))
        missingreactions = setdiff(rxnList,model.rxns);
        error('The following reactions were not found in the model:\n%s\nNo Constraint was added',strjoin(missingreactions,', '));        
    end
    rxnList = pos(pres);        
end

if ~(length(rxnList) == length(unique(rxnList)))
    error('There were duplicate reaction IDs or positions provided. No Constraint will be added.');        
end
defaultcoefficients = ones(sum(rxnList));
defaultrhs = 0;
defaultcsense = 'L';
defaultConstraintName = getConstraintName(model);

parser = inputParser();
parser.addRequired('model',@isstruct);
parser.addRequired('rxnList',@(x) isnumeric(x));
parser.addParameter('c',defaultcoefficients,@(x) isnumeric(x) && length(x) == length(rxnList));
parser.addParameter('d',defaultrhs,@isnumeric);
parser.addParameter('dsense',defaultcsense, @ischar );
parser.addParameter('ConstraintID',defaultConstraintName,@(x) ischar(x) );
parser.addParameter('checkDuplicates',false,@(x) islogical(x) || isnumeric(x) );
parser.parse(model,rxnList,varargin{:});


c = parser.Results.c;
d = parser.Results.d;
dsense = parser.Results.dsense;
ctrID = parser.Results.ConstraintID;
checkDuplicate = parser.Results.checkDuplicates;

ConstraintFields = {'C','d','dsense','ctrs'};
fieldsPresent = ismember(ConstraintFields,fieldnames(model));
if ~all(fieldsPresent)
    if any(fieldsPresent)        
        for i = 1:numel(ConstraintFields)
            if ~isfield(model,ConstraintFields{i})
                model = createEmptyField(model,ConstraintFields{i});
            else
                if ~isempty(model.(ConstraintFields{i}))
                    error('Inconsistent Field sizes detected. Expected an empty field but %s was non empty',ConstraintFields{i})            
                else
                    model = createEmptyField(model,ConstraintFields{i}); %Replace the existing to make sure the dimensions are correct.
                end
            end
        end
    else
        model = createEmptyFields(model,ConstraintFields);
    end    
end

%Now, we have all fields.
%Check for duplicates:
if any(ismember(model.ctrs,ctrID))
    error('A Constraint with this ID already exists.')
end

%Also check for duplicates in the C Matrix.
constRow = zeros(1,size(model.C,2));
constRow(rxnList) = c;

dupRows = all(model.C == constRow(ones(size(model.C,1),1),:),2);

duplicate = any(dupRows) && (model.dsense(dupRows) == dsense) && (model.d(dupRows) == d);
if duplicate && checkDuplicate
    warning('Constraint not added, because it already exists with ID: %s',strjoin(model.ctrs(dupRows)));
    return
end
model.C(end+1,:) = constRow;
model.d(end+1,1) = d;
model.dsense(end+1,1) = dsense;
model.ctrs{end+1,1} = ctrID;

end
    


function name = getConstraintName(model)
%Get a unique, not yet used constraint name.
if ~isfield(model,'ctrs')
    name = 'Constraint1';
    return
else
    i = size(model.C,1) + 1;
    name = ['Constraint' num2str(i)];
    while any(ismember(model.ctrs,name))
        i = i + 1;
        name = ['Constraint' num2str(i)];
    end
end
end