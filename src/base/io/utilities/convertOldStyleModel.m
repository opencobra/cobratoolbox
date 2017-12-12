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
%    osense: Objective Sense.
%            By default this field is initialized as -1 (maximisation)
%            If the osenseStr field is present, that field will be
%            interpreted and if it is 'min' osense will be initialized to 1
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
    
for i = 1:numel(oldFields)
    if (isfield(model,oldFields{i}))
        fieldRef = [newFields{i}(1:3) 's'];
        expectedSize = numel(model.(fieldRef));
        if numel(model.(oldFields{i})) == expectedSize
            if ~isfield(model,newFields{i})
                model.(newFields{i})= model.(oldFields{i});
            else
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

if ~isfield(model,'osense')
    if isfield(model,'osenseStr')
        if strcmpi(model.osenseStr,'min')
            model.osense = 1;
        else
            model.osense = -1;
        end
    else
        model.osense = -1;
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

definedFields = getDefinedFieldProperties();
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
    %Convert subSystems to Cell Arrays of Cell Arrays.
    if ischar([model.subSystems{:}])
        model.subSystems = cellfun(@(x) {x}, model.subSystems,'UniformOutput',0);
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

%Further, if there is a C matrix, check, whether csense contains both
%dsense and csense and replace accordingly.
if isfield(model,'C') % we assume, that d is present.
    %Crete the ctrs field.
    if ~isfield(model,'ctrs')
        model = createEmptyFields(model,'ctrs',{'ctrs','d',1,'iscell(x)','[''Constraint'' num2str(i)]',0,'cell'});
    end
    if isfield(model,'csense')
        if length(model.csense) == size(model.S,1) + size(model.C,1)
            model.dsense = model.csense(size(model.S,1)+1:end);
            model.csense = model.csense(1:size(model.S,1));
        elseif length(model.csense) == size(model.S,1)
            %This is odd. 
            %lets create the dsense vector.
            model = createEmptyFields(model,'dsense');            
        end
    else
        %create csense and dsense
        model = createEmptyFields(model,'csense');
        model = createEmptyFields(model,'dsense');
    end
end