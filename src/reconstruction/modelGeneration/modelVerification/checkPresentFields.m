function results = checkPresentFields(fieldProperties,model, results)
% Check the model fields for consistency with the given fieldProperties and
% update the results struct.
% The desired properties of each field are described here:
% https://github.com/opencobra/cobratoolbox/blob/master/docs/source/notes/COBRAModelFields.md
%
% USAGE:
%
%    results = checkPresentFields(fieldProperties,model, results)
%
% INPUT:
%    fieldProperties:  field properties as obtained by
%                      getDefinedFieldProperties
%    model:            a structure that represents the COBRA model.
%    results:          the results structure for this test
%
% OUTPUT:
%
%    results:          The updated results struct.
%
% .. Authors:
%       - Thomas Pfau, May 2017

presentFields = find(ismember(fieldProperties(:,1),fieldnames(model)));

%Check all Field Sizes
for i = 1:numel(presentFields)
    testedField = fieldProperties{presentFields(i),1};
    [x_size,y_size] = size(model.(testedField));
    xFieldMatch = fieldProperties{presentFields(i),2};
    yFieldMatch = fieldProperties{presentFields(i),3};
    
    checkX = ~isnan(xFieldMatch);
    checkY = ~isnan(yFieldMatch);
    if checkX
        if ischar(xFieldMatch)
            if ~isfield(model,xFieldMatch)
                x_pres = 0;
                if ~isfield(results.Errors,'missingFields')
                    results.Errors.missingFields = {};
                end
                results.Errors.missingFields(end+1) = {xFieldMatch};
            else
                x_pres = numel(model.(xFieldMatch));
            end
            errorMessage = sprintf('%s: Size of %s does not match elements in %s', xFieldMatch,testedField,xFieldMatch);
        elseif isnumeric(xFieldMatch)
            errorMessage = sprintf('X Size of %s was %i. Expected %i',testedField, x_size,x_pres);
            x_pres = xFieldMatch;
        end
        if x_pres ~= x_size
            if ~isfield(results.Errors,'inconsistentFields')
                results.Errors.inconsistentFields = struct();
            end
            results.Errors.inconsistentFields.(testedField) = errorMessage;
        end
    end
    if checkY
        if ischar(yFieldMatch)
            if ~isfield(model,yFieldMatch)
                y_pres = 0;
                if ~isfield(results.Errors,'missingFields')
                    results.Errors.missingFields = {};
                end
                results.Errors.missingFields(end+1) = {yFieldMatch};
            else
                y_pres = numel(model.(yFieldMatch));
            end
            errorMessage = sprintf('%s: Size of %s does not match elements in %s', yFieldMatch,testedField,yFieldMatch);
        elseif isnumeric(yFieldMatch)
            y_pres = yFieldMatch;
            errorMessage = sprintf('Y Size of %s was %i. Expected %i',testedField, y_size,y_pres);
        end
        if y_pres ~= y_size
            if ~isfield(results.Errors,'inconsistentFields')
                results.Errors.inconsistentFields = struct();
            end
            results.Errors.inconsistentFields.(testedField) = errorMessage;
        end
    end
    %Test the field content properties
    %x is necessary here, since it is used for the eval below!
    x = model.(testedField);
    try
        propertiesMatched = eval(fieldProperties{presentFields(i),4});
    catch
        propertiesMatched = false;
    end
    if ~propertiesMatched
        if ~isfield(results.Errors,'propertiesNotMatched')
            results.Errors.propertiesNotMatched = struct();
        end
        %results.Errors.propertiesNotMatched.(testedField) = 'Field does not match the required properties.;
        results.Errors.propertiesNotMatched.(testedField) = ['Field does not match the required properties: model.' testedField ' is ' class(x) ' but must satisfy: ' fieldProperties{presentFields(i),4}];
    end
    
end
%disp('done')
end
