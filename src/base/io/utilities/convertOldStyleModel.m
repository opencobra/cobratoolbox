function model = convertOldStyleModel(model, printLevel)
%CONVERTOLDSTYLEMODEL converts several old fields to their replacement.
%
% USAGE:
%
%    model = convertOldStyleModel(model)
%    model = convertOldStyleModel(model, printLevel)
%
% INPUT: 
%    model:     a COBRA Model (potentially with old field names)
%
% OPTIONAL INPUT:
%    printLevel:    indicates whether warnings and messages are given (default, 1).
%
% OUPUT:
%    model:      a COBRA model with old field names replaced by new ones and
%                duplicated fields merged.
% .. Authors:
%       - Thomas Pfaz May 2017
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

%reset warnings
for i = 1:numel(warnstate)
    warning(warnstate(i).state,warnstate(i).identifier)
end