function model = addCOBRAConstraint(model, idList, d, varargin)
% Add a constraint to the model in the form c1 * v(id1) + c2 * v(id2) * ... cj * v(idj) dsense d
% where c is a vector with coefficients for each element in idList
% (default 1 for each reaction), dsense is one of lower than ('L', default), greater than
% ('G'), or equal ('E'), and d is a value. 
% USAGE:
%    model = addCOBRAConstraint(model, idList, d, varargin)
%
% INPUTS:
%    model:         model structure
%    idList:        cell array of ids either from either the rxns, or the
%                   evars vectors. Can also be a a double vector of indices (in which
%                   case indices in evars have to be set off by
%                   numel(rxns).
%    d:             The right hand side of the C*v <= d constraint (or a
%                   vector, for multiple simultaneous addition;
%
%    varargin:
%                   * c:                the coefficients to use with one entry per
%                                       reaction of a constraint for multiple constraints, a matrix
%                                       (default: 1 for each element indicated in idList)
%                   * dsense:           the constraint sense ('L': <= ,
%                                       'G': >=, 'E': =), or a vector for multiple constraints
%                                       (default: ('L'))
%                   * ConstraintID:     the Name of the constraint. by
%                                       (default: 'ConstraintXYZ' with XYZ being the initial 
%                                       position in the mets vector)
%                                       or a cell array of Strings for
%                                       multiple Constraints
%                   * checkDuplicates:  check whether the constraint already
%                                       exists, and if it does, don't add it (default: false)
%
% OUTPUT:
%    modelConstrained:  constrained model
%
% EXAMPLE:
%    Add a constraint that leads to EX_glc and EX_fru not carrying a
%    combined flux higher than 5
%    model = addNMConstraint(model, {'EX_glc','EX_fru'}, 5)
%    Assume Reaction 4 to be 2 A -> D and reaction 5 being A -> F. Create a
%    constraint that requires that the two reactions remove at least 4 units of A:
%    model = addNMConstraint(model, model.rxns(4:5), 4, 'c', [2 1], 'dsense', 'G')
%
% Author: Thomas Pfau, Nov 2017

if ischar(idList) %This is an individual element.
    idList = {idList};
end

if iscell(idList)
    [pos,pres] = getIDPositions(model,idList,'rxns');    
    if any(~pres)
        missingreactions = idList(~pres);
        error('The following ids were not found in the model:\n%s\nNo Constraint was added',strjoin(missingreactions,', '));        
    end
    idList = pos;        
end


multiAdd = false;
if ~all(size(idList) > 1) %if this is true, its multiple rows...    
    if (length(d) > 1) %This should be a multiAdd
        dim = length(d) == size(idList);
        multiAdd = true;
        if ~all(dim)
            %make sure this is the right orientation
             cdim = find(dim);
             if cdim ~= 1
                 idList = idList';
             end
        else
            error('d has to be either a single value or a vector of doubles');
        end                
    else
        %there is only one element in d and idList has a dimension of size
        %1. So we need to make sure, that idList is a row vector.
        if size(idList,1) > size(idList,2)
            idList = idList';
        end        
        if ~(length(idList) == length(unique(idList))) 
            error('There were duplicate reaction IDs or positions provided. No Constraint will be added.');        
        end
    end
else
    multiAdd = true;
end

defaultcoefficients = ones(size(idList));

defaultcsense = 'L';
if ~multiAdd
    defaultConstraintName = getConstraintName(model,1);
else
    defaultConstraintName = getConstraintName(model,length(d));
end


parser = inputParser();
parser.addRequired('model',@isstruct);
parser.addRequired('idList',@(x) isnumeric(x));
parser.addRequired('d',@isnumeric);
parser.addParamValue('c',defaultcoefficients,@(x) isnumeric(x) && (multiAdd || length(x) == length(idList)));
parser.addParamValue('dsense',defaultcsense, @ischar );
parser.addParamValue('ConstraintID',defaultConstraintName,@(x) ischar(x) || iscell(x) );
parser.addParamValue('checkDuplicates',false,@(x) islogical(x) || isnumeric(x) );

parser.parse(model,idList,d,varargin{:});


c = parser.Results.c;
d = columnVector(parser.Results.d);
dsense = columnVector(parser.Results.dsense);
ctrID = parser.Results.ConstraintID;
if ischar(ctrID)
    ctrID = {ctrID};
else
    ctrID = columnVector(ctrID);
end
checkDuplicate = parser.Results.checkDuplicates;

if ~isfield(model,'evars')
    varspresent = false;
    ConstraintFields = {'C','d','dsense','ctrs'};
else
    varspresent = true;
    ConstraintFields = {'C','D','d','dsense','ctrs'};
end
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
    error('Constraints with the following IDs already exist.\n%s\n', strjoin(model.ctrs(ismember(model.ctrs,ctrID)),', '));
end
%And if multiAdd also check for duplicates in the input
if multiAdd && numel(ctrID) > numel(unique(ctrID))
    [unq,~,orig] = unique(ctrID);
    dupreacs = hist(orig,numel(unq)) > 1;
    error('Input contained the following duplicated IDs:\n %s ', strjoin(unq(dupreacs),', '));
end

if checkDuplicate && multiAdd
    %If we check for duplicates, and don't want to add them, we will first
    %filter them from the input, but only if we add multiple things.
    [sorted,order] = sort(idList,2);    
    sortedC = c;
    sorted = repmat(sorted,size(c,1),1);
    for i = 1:size(idList,1)
        sortedC(i,:) = c(i,order(i,:));
    end
    %Now, concatenate all inputs (except names) 
    toCompare = [sorted,sortedC,dsense]; %This will convert the dsense into doubles which is fine to get uniques.
    [~,pos] = unique(toCompare,'rows');
    %Now lets remove anything thats duplicated.    
    d = d(pos,:);
    c = c(pos,:);
    dsense = dsense(pos,:);
    ctrID = ctrID(pos,:);    
end

%In case nothing is left.
if isempty(ctrID)
    return
end



%Also check for duplicates in the C Matrix.
if varspresent
    mixrows = zeros(size(c,1),size(model.E,2));
end
constRow = sparse(size(c,1),size(model.C,2));
duppedRows = false(size(idList,1),1);
nRxns = numel(model.rxns);
rxnpos = idList <= nRxns;     
varpos = idList > nRxns; 
    
for i = 1:size(c,1)     
    constRow(i,idList(rxnpos)) = c(i,rxnpos);         
    if varspresent
         mixrows(i,idList(varpos)-nRxns) = c(i,varpos);
    end
    cRow = constRow(i,:);    
    dupRows = all(model.C == cRow(ones(size(model.C,1),1),:),2);
    if varspresent
        cmRow = mixrows(i,:);
        vdupRows = all(model.E == cmRow(ones(size(model.E,1),1),:),2);
        dupRows = dupRows & vdupRows;
    end
    if checkDuplicate
        duppedRows(i) = any(dupRows) && (model.dsense(dupRows) == dsense(i)) && (model.d(dupRows) == d(i));
    end
end
    

if any(duppedRows) && checkDuplicate
    warning('Constraint(s) not added, because it already exists with ID: %s',strjoin(model.ctrs(dupRows)));    
    if ~multiAdd
        return
    else
        ctrID(duppedRows) = [];
        d(duppedRows) = [];
        constRow(duppedRows,:) = [];
        dsense(duppedRows) = [];
    end
end



model.C = [model.C;constRow];
model.d = [model.d;d];
model.dsense = [model.dsense;dsense];
model.ctrs = [model.ctrs;ctrID];
if varspresent
    model.E = [model.E;mixrows];
end
    
end

function name = getConstraintName(model, count)
%Get a unique, not yet used constraint name.
if ~isfield(model,'ctrs')
    name = strcat('Constraint',cellfun(@num2str,num2cell(1:count)','UniformOutput',false));
    return
else
    name = cell(count,1);
    name(:) = {''}; %Need to initialize, otherwise we get a mismatch during ismember.
    constraintsCreated = 0;
    i = size(model.C,1) + 1;
    cname = ['Constraint' num2str(i)];
    while constraintsCreated < count
        while any(ismember(model.ctrs,cname)) || any(ismember(name,cname))
            i = i + 1;
            cname = ['Constraint' num2str(i)];
        end
        constraintsCreated = constraintsCreated + 1;
        name{constraintsCreated} = cname;        
    end
end
end