function [ model ] = initFBAFields( model, printLevel )
% This function initializes all fields in a model that are required for
% downstream FBA analysis. It does so if and only if a Stoichiometric
% matrix S is provided. 
%
% USAGE:
%    model = convertOldStyleModel(model, printLevel)
%
% INPUT:
%    model:         a COBRA Model structure with at least the model.S field.
%                   All fields already present are retained and absent
%                   fields are initialized with their defaults.
%
% OPTIONAL INPUT:
%    printLevel:    indicates whether warnings and messages are given (default, 1).
%
% OUTPUT:
%    model:         a COBRA model struct with the following fields:
%                   .S (same as input)
%                   .rxns (default: a vector of strings R1 .. R size(S,2)
%                   .mets (default: a vector of strings M1 .. M size(S,1)
%                   .lb   (default: -1000 * ones(size(S,2),1) );
%                   .ub   (default: 1000 * ones(size(S,2),1) );
%                   .genes   (default: cell(0,1));
%                   .rules   (default: repmat({''},size(S,2),1))
%                   .osense (default: -1)
%                   .csense (default: a char vector of 'E' of the size size(S,1) x 1)
%                   
% .. Author: - Thomas Pfau Nov 2017

if ~isfield(model,'S')
    error('Cannot create FBA fields without stoichiometric matrix');
else
    %Init basic sizes
    rxns = size(model.S,2);
    mets = size(model.S,1);
    genes = 0;
end

structfields = fieldnames(model);
optionalFields = getDefinedFieldProperties();
fluxConsistencyFields = optionalFields(cellfun(@(x) x, optionalFields(:,6)),:);
    
for field = 1:size(fluxConsistencyFields,1)
    cfieldName = fluxConsistencyFields{field,1};
    if ~any(ismember(structfields,cfieldName))
        
        csize1 = fluxConsistencyFields{field,2};
        if ischar(csize1)
            eval(['csize1 = ' fluxConsistencyFields{field,2} ';']);
        end
        csize2 = fluxConsistencyFields{field,3};
        if ischar(csize2)
            eval(['csize2 = ' fluxConsistencyFields{field,3} ';']);
        end

        i = 0;
        defaultVal = fluxConsistencyFields{field,5};
        isCellEntry = false;
        if ischar(defaultVal)
            if strfind('iscell',fluxConsistencyFields(field,4))
                eval(['defaultVal = ' fluxConsistencyFields{field,5} ';']);
            else
                defaultVal = fluxConsistencyFields{field,5};
            end
            isCellEntry = true;
        end
        if ~isCellEntry
            cfield = zeros(csize1,csize2);
            for i = 1:csize1
                cfield(i) = fluxConsistencyFields{field,5};
            end
            model.(cfieldName) = cfield;
        else
            %Lets also check for this being a char.
            if isequal(fluxConsistencyFields{field,4},'ischar(x)')
                cfield = repmat(defaultVal,csize1,csize2);
                model.(cfieldName) = cfield;    
            else
                
                cfield = cell(csize1,csize2);
                for i = 1:csize1
                    eval(['cfield{i} = ' fluxConsistencyFields{field,5} ';']);
                end
                model.(cfieldName) = cfield;
            end
        end
    end
end

