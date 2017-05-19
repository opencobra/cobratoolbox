function model = convertOldStyleModel(model)
%CONVERTOLDSTYLEMODEL converts several old fields to their replacement.
%INPUT 
% model     a COBRA Model (potentially with old field names)
%OUPUT
% model     a COBRA model with old field names replaced by new ones and
%           duplicated fields merged.
warnstate = warning;
warning('on');

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

warning(warnstate.state)