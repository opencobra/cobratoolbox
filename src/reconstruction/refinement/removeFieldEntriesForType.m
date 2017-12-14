function model = removeFieldEntriesForType(model, indicesToRemove, type, fieldSize, varargin)
% Remove field entries at the specified indices from all fields associated
% with the given type
% USAGE:
%    model = removeFieldEntriesForType(model, indicesToRemove, type, varargin)
%
% INPUTS:
%
%    model:              the model to update
%    indicesToRemove:    indices which should be removed (either a logical array or double indices)
%    type:               the Type of field to update. one of 
%                        ('rxns','mets','comps','genes','ctrs')
%    fieldSize:          The size of the original field before
%                        modification. This is necessary to identify fields
%                        from which entries have to be removed.
% OPTIONAL INPUTS:
%    varargin:        Additional Options as 'ParameterName', Value pairs. Options are:
%                     - 'excludeFields', fields which should not be
%                       adjusted but kkept how they are.
%
% OUTPUT:
%
%    modelNew:         the model in which all fields associated with the
%                      given type have the entries indicated removed. The
%                      initial check is for the size of the field, if
%                      multiple base fields have the same size, it is
%                      assumed, that fields named e.g. rxnXYZ are
%                      associated with rxns, and only those fields are
%                      adapted along with fields which are specified in the
%                      Model FieldDefinitions.
%
% .. Authors: 
%                   - Thomas Pfau June 2017, adapted to merge all fields.

PossibleTypes = {'rxns','mets','comps','genes','ctrs'};


parser = inputParser();
parser.addRequired('model',@(x) isfield(x,type));
parser.addRequired('indicesToRemove',@(x) islogical(x) || isnumeric(x));
parser.addRequired('type',@(x) any(ismember(PossibleTypes,x)));
parser.addRequired('fieldSize',@isnumeric);

parser.addParamValue('excludeFields',{},@iscell);

parser.parse(model,indicesToRemove,type,fieldSize,varargin{:});


fieldSize = parser.Results.fieldSize;
excludeFields = parser.Results.excludeFields;



if isnumeric(indicesToRemove)
    res = false(fieldSize,1);
    res(indicesToRemove) = 1;
    indicesToRemove = res;
end

%If there is nothing to remove, we remove nothing...
if ~any(indicesToRemove)
    return
end

%We need a special treatment for genes, i.e. if we remove genes, we need to
%update all rules/gprRules
if strcmp(type,'genes')    
    removeRulesField = false;
    genePos = find(indicesToRemove);    
    if ~ isfield(model,'rules') && isfield(model, 'grRules')% Only use grRules, if no rules field is present.        
        %lets make this easy. we will simply create the rules field and
        %Then work on the rules field (removing that field again in the
        %end.        
        model = generateRules(model);
        removeRulesField = true;
    end
    %update the rules fields.
    if isfield(model,'rules') %Rely on rules first  
        rulesFieldOk = verifyModel(model,'simpleCheck',true,'restrictToFields',{'rules'}, 'silentCheck', true);
        if ~rulesFieldOk
            includedLink = hyperlink('https://github.com/opencobra/cobratoolbox/blob/master/docs/source/notes/COBRAModelFields.md','here');
            errormessage = ['Rules field does not satisfy the field definitions. Please check that it satisfies the definitions given ' includedLink];
            error(errormessage);
        end
        %Store all modified rules
        modifiedRules = [];
        %However, we first normalize the rules.        
        model = normalizeRules(model);
        %First, eliminate all removed indices
        for i = 1:numel(genePos)
            %Replace either a trailing &, or a leading &            
            rules = regexp(model.rules,['(?<pre>[\|&]?) *x\(' num2str(genePos(i)) '\) *(?<post>[\|&]?)'],'names');
            matchingrules = find(~cellfun(@isempty, rules));
            modifiedRules = union(modifiedRules,matchingrules);
            for elem = 1:numel(matchingrules)
                cres = rules{matchingrules(elem)};                
                for pos = 1:numel(cres)
                    if isequal(cres(pos).pre,'&')
                        model.rules(matchingrules(elem)) = regexprep(model.rules(matchingrules(elem)),[' *& *x\(' num2str(genePos(i)) '\) *([ \)|$])'],'$1');
                    elseif isequal(cres(pos).post,'&')
                        model.rules(matchingrules(elem)) = regexprep(model.rules(matchingrules(elem)),['(^|[ \(]) *x\(' num2str(genePos(i)) '\) *& *'],'$1');
                    elseif isequal(cres(pos).post,'|')
                        %Make sure its not preceded by a &
                        model.rules(matchingrules(elem)) = regexprep(model.rules(matchingrules(elem)),['(^|[^&]) *x\(' num2str(genePos(i)) '\) *\| *'],'$1 ');
                    elseif isequal(cres(pos).pre,'|')
                        %Make sure its not followed by a &
                        model.rules(matchingrules(elem)) = regexprep(model.rules(matchingrules(elem)),[' *\| *x\(' num2str(genePos(i)) '\)([^&]|$)'],'$1');
                    else
                        %This should only ever happen if there is only one gene.
                        model.rules(matchingrules(elem)) = regexprep(model.rules(matchingrules(elem)),['^|[\( ]*x\(' num2str(genePos(i)) '\)[\) ]*|$'],'');
                    end
                    %Remove trailing or leading whitespaces
                    model.rules(matchingrules(elem)) = strtrim(model.rules(matchingrules(elem)));
                end
            end              
        end
        %Now, replace all remaining indices.
        oldIndices = find(~indicesToRemove);
        for i = 1:numel(oldIndices)
            if i ~= oldIndices(i)
                %replace by new with an indicator that this is new.
                model.rules = strrep(model.rules,['x(' num2str(oldIndices(i)) ')'],['x(' num2str(i) '$)']);
            end
        end
        %remove the indicator.
        model.rules = strrep(model.rules,'$','');
        %remove the indicator.

    end
    if removeRulesField
        model = rmfield(model,'rules');
    end
end


[fields,dimensions] = getModelFieldsForType(model, type, fieldSize);

for i = 1:numel(fields)
    if any(ismember(fields{i},excludeFields))
        continue
    end
    %Lets assume, that we only have 2 dimensional fields.
    model.(fields{i}) = removeIndicesInDimenion(model.(fields{i}),dimensions(i),~indicesToRemove);  
end

%Now, if this was a genes removal, we now have to update the grRules field.
%update the grRules is the field is present:
if isfield(model, 'grRules') && exist('modifiedRules','var')
    currentrules = strrep(model.rules(modifiedRules),'&','and');
    currentrules = strrep(currentrules,'|','or');
    getGeneName = @(pos) model.genes{str2num(pos)};
    currentrules = regexprep(currentrules,'x\(([0-9])\)','${getGeneName($1)}');
    model.grRules(modifiedRules) = currentrules;
end


function removed = removeIndicesInDimenion(input,dimension,indices)
% Remove the indices in a specified field in the given dimension
% USAGE:
%    removed = removeIndicesInDimenion(input, dimension, indices)
%
% INPUTS:
%
%    input:              The input matrix or array
%    dimension:          The dimension from which to remove the indices
%    indices:            The indices to remove
%
% OUTPUT:
%
%    removed:          The array/matrix with the given indices removed.
%
% .. Authors: 
%                   - Thomas Pfau Sept 2017, adapted to merge all fields.

inputDimensions = ndims(input);
S.subs = repmat({':'},1,inputDimensions);
S.subs{dimension} = indices;
S.type = '()';
removed = subsref(input,S);

        
function model = normalizeRules(model)
origrules = model.rules;
model.rules = regexprep(model.rules,'\( *(x\([0-9]+\)) *\)','$1');
while ~all(strcmp(origrules,model.rules))
    origrules = model.rules;
    model.rules = regexprep(model.rules,'\( *(x\([0-9]+\)) *\)','$1');
end

        
