function model = removeFieldEntriesForType(model, indicesToRemove, type, fieldSize, varargin)
% Remove field entries at the specified indices from all fields associated
% with the given type
% USAGE:
%    model = removeFieldEntriesForType(model, indicesToRemove, type, varargin)
%
% INPUTS:
%
%    model:              the model to update
%    indicesToRemove:    indices which should eb removed (either a logical array or double indices)
%    type:               the Type of field to update one of 
%                        ('rxns','mets','comps','genes')
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

PossibleTypes = {'rxns','mets','comps','genes'};


parser = inputParser();
parser.addRequired('model',@(x) isfield(x,type));
parser.addRequired('indicesToRemove',@(x) islogical(x) || isnumeric(x));
parser.addRequired('type',@(x) any(ismember(PossibleTypes,x)));
parser.addRequired('fieldSize',@isnumeric);

parser.addParameter('excludeFields',{},@iscell);

parser.parse(model,indicesToRemove,type,fieldSize,varargin{:});


fieldSize = parser.Results.fieldSize;
excludeFields = parser.Results.excludeFields;


if isnumeric(indicesToRemove)
    res = false(fieldSize,1);
    res(indicesToRemove) = 1;
    indicesToRemove = res;
end




fields = getModelFieldsForType(model, type, fieldSize);

fields = setdiff(fields,excludeFields);

for i = 1:numel(fields)
    %Lets assume, that we only have 2 dimensional fields.
    if size(model.(fields{i}),1) == fieldSize
        model.(fields{i}) = model.(fields{i})(~indicesToRemove,:);
    end
    if size(model.(fields{i}),2) == fieldSize
        model.(fields{i}) = model.(fields{i})(:,~indicesToRemove);
    end
end


%We need a special treatment for genes, i.e. if we remove genes, we need to
%update all rules/gprRules
if strcmp(type,'genes')    
    genePos = find(indicesToRemove);    
    %update the rules fields.
    if isfield(model,'rules')       
        %First, eliminate all removed indices
        for i = 1:numel(genePos)
            %Replace either a trailing &, or a leading &
            rules = regexp(model.rules,['(?<pre>[\|&]?) *x\(' num2str(genePos(i)) '\) *(?<post>[\|&]?)'],'names');
            matchingrules = find(~cellfun(@isempty, rules));
            for elem = 1:numel(matchingrules)
                cres = rules{matchingrules(elem)};
                for pos = 1:numel(cres)
                    if isequal(cres(pos).pre,'&')
                        model.rules(matchingrules(elem)) = regexprep(model.rules(matchingrules(elem)),[' *& *x\(' num2str(genePos(i)) '\) *([ \)])'],'$1');
                    elseif isequal(cres(pos).post,'&')
                        model.rules(matchingrules(elem)) = regexprep(model.rules(matchingrules(elem)),['[ \(] *x\(' num2str(genePos(i)) '\) *& *'],'$1');
                    elseif isequal(cres(pos).post,'|')
                        %Make sure its not preceded by a &
                        model.rules(matchingrules(elem)) = regexprep(model.rules(matchingrules(elem)),['([^&]) *x\(' num2str(genePos(i)) '\) *\| *'],'$1 ');
                    elseif isequal(cres(pos).pre,'|')
                        %Make sure its not followed by a &
                        model.rules(matchingrules(elem)) = regexprep(model.rules(matchingrules(elem)),[' *\| *x\(' num2str(genePos(i)) '\) *([^&])'],' $1');
                    else
                        %This should only ever happen if there is only one gene.
                        model.rules(matchingrules(elem)) = regexprep(model.rules(matchingrules(elem)),['[\( ]*x\(' num2str(genePos(i)) '\)[\( ]*'],'');
                    end
                end
            end
        end
        %Now, replace all remaining indices.
        oldIndices = find(~indicesToRemove);
        for i = 1:numel(model.genes)       
            if i ~= oldIndices(i)
                %replace by new with an indicator that this is new.
                model.rules = strrep(model.rules,['x(' num2str(oldIndices(i)) ')'],['x(' num2str(i) '$)']);
            end
        end
        %remove the indicator.
        model.rules = strrep(model.rules,'$','');
    end
end
        
        