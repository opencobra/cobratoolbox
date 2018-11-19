function model = convertOldStyleModel(model, printLevel)
% Converts several old fields to their replacement.
%
% USAGE:
%
%    model = convertOldStyleModel(model)
%    model = convertOldStyleModel(model, printLevel)
%
% INPUT:
%    model:         a COBRA Model (potentially with old field names)
%
% OPTIONAL INPUT:
%    printLevel:    indicates whether warnings and messages are given (default, 1).
%
% OUTPUT:
%    model:         a COBRA model with old field names replaced by new ones and
%                   duplicated fields merged.
%
% NOTE: 
%    There are multiple fields which were used inconsistently in the course
%    of the COBRA toolbox. This function provides a simple way to get these
%    model fields converted to the current names. In addition, some fields
%    were commonly not present in older models and are now checked in many
%    newer models. These fields are initialized by this function, with
%    default values, which do not alter any previous behaviour.
%    The model fields changed are as follows:
%    'confidenceScores' 	 -> 	 'rxnConfidenceScores'
%    'metCharge' 	 -> 	 'metCharges' 
%    'ecNumbers' 	 -> 	 'rxnECNumbers' 
%    'KEGGID' 	 -> 	 'metKEGGID' 
%    'metKeggID' 	 -> 	 'metKEGGID' 
%    'rxnKeggID' 	 -> 	 'rxnKEGGID' 
%    'metInchiString' 	 -> 	 'metInChIString' 
%    'metSmile' 	 -> 	 'metSmiles' 
%    'metHMDB' 	 -> 	 'metHMDBID' 
%    If both an old and a new field is present, data from old fields is
%    merged into new fields, with the data of new fields taking precedence
%    (i.e. if not data is present in the new field at any position, the old
%    field data replaces it, otherwise the new field data is kept.
%    Furthermore, fields deemed to be required for Flux Balance analysis are generated if not present:
%    osenseStr: Objective Sense.
%            By default this field is initialized as 'max'. If osense is
%            present, a -1 will be translates as 'max' and a 1 will be
%            translated as 'min'
%    csense: Constraint sense.
%            This field indicates the sense of the b matrix, i.e. if b
%            stands for lower than ('L') or greater than ('G') or equality constraints ('E'). It
%            is initialized as a char vector of 'E' with the same size as
%            model.mets.
%    genes:  A Field for genes present in the model.
%    rules:  The rules field is a logical representation of the GPR rules,
%            and used in multiple functions. If the grRules field is
%            present, this field will be initialized according to grRules,
%            otherwise it will be initialized as a cell array of the ame size as model.rxns 
%            with empty strings in each cell.
%    rev:    This field was deprecated and is therefore removed, for
%            reversibility determination the toolbox relies on the lower
%            bounds of the reactions.
%    The following fields might be altered to adhere to the definitions in
%    the COBRAModelFields documentation:
%    rxnConfidenceScores:  This field is defined as a number betwen 0 and 4
%                          indicating the confidence of a reaction. It is
%                          therefore assumed to be a double vector in COBRA
%                          functions. Some old models provide this as
%                          Strings, or a numeric cell array. Those fields
%                          are converted to double vectors, with the data
%                          retained.
%    Fields with Cell arrays:  Some older models have defined cell array fields
%                              which have individual cells which are
%                              numeric (i.e. empty []). These empty cells
%                              are replaced by '' for those fields, which
%                              are defined in the COBRAModelFields file as
%                              having cell arrays with chars.
%       
% .. Author: - Thomas Pfau May 2017
warnstate = warning;
if ~exist('printLevel','var')
    printLevel = 1;
end

if(printLevel > 0)
    warning('on');
else
    warning('off');
end

cellmerge = 'model.$NEW$(cellfun(@isempty, model.$NEW$)) = model.$OLD$(cellfun(@isempty, model.$NEW$));';
maxmerge = 'model.$NEW$ = max(model.$NEW$,model.$OLD$);';
nanmerge = 'model.$NEW$(isnan(model.$NEW$)) = model.$OLD$(isnan(model.$NEW$));';


oldFields = {'confidenceScores','metCharge','ecNumbers',...
		  'KEGGID','metKeggID','rxnKeggID',...
		  'metInchiString', 'metSmile', 'metHMDB'};

newFields = {'rxnConfidenceScores', 'metCharges','rxnECNumbers',...
		'metKEGGID','metKEGGID','rxnKEGGID',...
		'metInChIString', 'metSmiles','metHMDBID'};

mergefunction = {maxmerge, nanmerge,cellmerge,...
		cellmerge,cellmerge,cellmerge,...
		cellmerge,cellmerge,cellmerge};    

% get the defined field properties.    
definedFields = getDefinedFieldProperties();
    
    
if isfield(model,'A') && isfield(model,'S')
    if printLevel >=1
        warning('The inserted Model contains an old style coupling matrix (A). The MAtrix will be converted into a Coupling Matrix (C) and fields will be adapted.')
    end
    nMets = size(model.S,1);
    % get the Constraint data
    C = model.A(nMets+1:end,:);     
    ctrs = columnVector(model.mets(nMets+1:end));    
    dsense =  columnVector(model.csense(nMets+1:end));
    d = columnVector(model.b(nMets+1:end));
    % set the constraint data
    model.C = C;
    model.ctrs = ctrs;
    model.dsense = dsense;
    model.d = d;
    % now, we assume, that those are the only modified fields, if not,
    % something is seriously broken.    
    model.mets = columnVector(model.mets(1:nMets));
    model.b = columnVector(model.b(1:nMets));
    model.csense = columnVector(model.csense(1:nMets));
    model = rmfield(model,'A');
    
end
    

% convert old fields to current fields. 
for i = 1:numel(oldFields)
    % if it is a model field
    if (isfield(model,oldFields{i}))        
        fieldRef = [newFields{i}(1:3) 's'];
        expectedSize = numel(model.(fieldRef));
        if numel(model.(oldFields{i})) == expectedSize
            % check, that the expected size is correct. If not, skip.
            if ~isfield(model,newFields{i})
                model.(newFields{i})= model.(oldFields{i});
            else
                % if, for whatever reason, this model has both fields
                % (happens, and not a good idea....), we will correct both of those fields (which might have empty entries)                
                if iscell(model.(oldFields{i})) 
                    if strcmp(mergefunction{i}, cellmerge)
                        %fix [] present instead of '' in
                        emptyPos = cellfun(@(x) isnumeric(x) && isempty(x), model.(oldFields{i}));
                        model.(oldFields{i})(emptyPos) = {''};
                    else
                        % this indicates, that we even have the wrong type
                        % of structure...
                        numericPos = cellfun(@(x) isnumeric(x), model.(oldFields{i}));
                        emptyPos = cellfun(@(x) isempty(x), model.(oldFields{i}));
                        % now, if these are reaction confidence scores,
                        % they might be provided as strings representing
                        % numbers....                        
                        if any(~numericPos)
                            model.(oldFields{i})(~numericPos) = cellfun(@(x) str2num(x),model.(oldFields{i})(~numericPos),'Uniform',0);
                        end                                                
                        model.(oldFields{i})(emptyPos) = {0};                        
                        model.(oldFields{i}) = cell2mat(model.(oldFields{i}));
                    end
                end                
                if iscell(model.(newFields{i})) 
                    if strcmp(mergefunction{i}, cellmerge)
                        %fix [] present instead of '' in
                        emptyPos = cellfun(@(x) isnumeric(x) && isempty(x), model.(newFields{i}));
                        model.(newFields{i})(emptyPos) = {''};
                    else
                        % this indicates, that we even have the wrong type
                        % of structure...
                        emptyPos = cellfun(@(x) isnumeric(x) && isempty(x), model.(newFields{i}));
                        model.(newFields{i})(emptyPos) = {NaN};
                        model.(newFields{i}) = cell2mat(model.(newFields{i}));
                    end
                end                
                
                if numel(model.(newFields{i})) == expectedSize
                    merger = strrep(mergefunction{i},'$OLD$',oldFields{i});
                    merger = strrep(merger,'$NEW$',newFields{i});
                    eval(merger);
                    
                else
                    warning('Size of %s does not fit to %s. Old field %s exists, but cannot be merged',newFields{i},fieldRef,oldFields{i});
                    continue
                end
            end
       else
           warning('Old field %s exists, but does not fit to size of %s, not converting it',oldFields{i},fieldRef);
           continue;
       end
       model = rmfield(model,oldFields{i});
    end
end

if isfield(model,'osense')
   if ~isfield(model,'osenseStr')       
        if model.osense == -1
            model.osenseStr = 'max';
        end
        if model.osense == 1
            model.osenseStr = 'min';
        end
   end
   model = rmfield(model,'osense');    
else
    if ~isfield(model,'osenseStr')
        model.osenseStr = 'max';
    end
end

if ~isfield(model,'csense')
    model.csense = repmat('E',numel(model.mets),1);
else
    model.csense = columnVector(model.csense);
end

if ~isfield(model, 'genes')
    model.genes = cell(0,1);
end

if ~isfield(model,'c')
    model.c = zeros(size(model.rxns));
end

if ~isfield(model, 'rules') 
    if isfield(model, 'grRules')
        model = generateRules(model);
    else
       model.rules = cell(size(model.rxns));
       model.rules(:) = {''};
    end
end

if isfield(model,'rev')
    model = rmfield(model,'rev');
end

%Handle wrong rxnConfidenceScores.
if isfield(model,'rxnConfidenceScores')
    if iscell(model.rxnConfidenceScores)
        %We want a double array.
        emptyCells = cellfun(@isempty, model.rxnConfidenceScores);
        try

            setValues = cell2mat(model.rxnConfidenceScores(~emptyCells));
            if ~isnumeric(setValues)
                tmpValues = model.rxnConfidenceScores(~emptyCells);
                setValues = cellfun(@str2num,tmpValues);
            end
            model.rxnConfidenceScores = zeros(size(model.rxnConfidenceScores));
            model.rxnConfidenceScores(~emptyCells) = setValues;
        catch
            warning('Cannot Convert Reaction Confidence Scores, setting to 0')
            model.rxnConfidenceScores = zeros(size(model.rxns));
%         if ~isnumeric(tempScores)
%             emptyConf = cellfun(@isempty, model.rxnConfidenceScores);
%             tempScores = zeros(numel(model.rxnConfidenceScores),1);
%             tempScores(~emptyConf) = cellfun(@str2num , model.rxnConfidenceScores(~emptyConf));
        end
%        model.rxnConfidenceScores = tempScores;
    end
end

%Check whether those are defined Cell fields
%And whether they are assumed to be all chars.
definedCharCells = definedFields(~cellfun(@isempty, regexp(definedFields(:,4),'iscell\(x\)')) & ~cellfun(@isempty, regexp(definedFields(:,4),'all\(cellfun\(@\(.\) *ischar')),1);
modelfields = fieldnames(model);
modelfields = intersect(modelfields,definedCharCells);
%Some Cell array fields (which all should have '' as default use []
%instead. we need to fix this, i.e. we will simply replace all non char
%entries by '' in all cell array fields.

for i = 1: numel(modelfields)
    if iscell(model.(modelfields{i}))
        numericpos = cellfun(@(x) isnumeric(x) && isempty(x), model.(modelfields{i}));
        model.(modelfields{i})(numericpos) = {''};
    end
end

if isfield(model,'subSystems')        
    done = false;
    charPos = cellfun(@(x) ischar(x), model.subSystems);
    if all(charPos)
        model.subSystems = cellfun(@(x) {x}, model.subSystems,'UniformOutput',0);            
        done = true;
    elseif any(charPos)
        model.subSystems(charPos) = cellfun(@(x) {x}, model.subSystems(charPos),'UniformOutput',0);                        
    end    
    if ~done
        numericPos = cellfun(@(x) isnumeric(x), model.subSystems);                
        model.subSystems(numericPos) = {{''}};
    end
end
%reset warnings
for i = 1:numel(warnstate)
    warning(warnstate(i).state,warnstate(i).identifier)
end

%check rxnGeneMat. If there are no genes set rxnGeneMat to the correct
%dimensions.
if isfield(model,'rxnGeneMat') && isfield(model,'genes')
    if size(model.rxnGeneMat,2) ~= size(model.genes,1) && size(model.genes,1) == 0
        model.rxnGeneMat = false(size(model.rxns,1),0);
    end
end

%Create b field if missing
if isfield(model,'S') && isfield(model,'mets') && ~isfield(model,'b')
    model.b = zeros(size(model.mets));
end

%Also, comps could currently be a char array if it is, convert it
if isfield(model,'comps') && ischar(model.comps)
    model.comps = columnVector(arrayfun(@(x) {x},model.comps));
end

if isfield(model,'metChEBIID')
    %some provide the chebi IDs as numbers, while the rest is string..
    numericIDs = cellfun(@isnumeric, model.metChEBIID);
    if any(numericIDs)
        model.metChEBIID(numericIDs) = cellfun(@num2str, model.metChEBIID(numericIDs),'Uniform',0);
    end
end

% adjust a genes field which is 0x0 (should be 0x1)
if size(model.genes,1) == 0 && size(model.genes,2) == 0 
    model.genes = cell(0,1);
end

    