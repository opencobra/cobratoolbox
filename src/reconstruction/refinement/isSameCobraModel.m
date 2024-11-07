function [isSame, nDiff, commonFields] = isSameCobraModel(model1, model2, printLevel)
% Checks if two COBRA models are the same
%
% USAGE:
%
%    [isSame, nDiff, commonFields] = isSameCobraModel(model1, model2, printLevel)
%
% INPUTS:
%    model1:          COBRA model structure 1
%    model2:          COBRA model structure 2
%
% OPTIONAL INPUTS:
%    printLevel:      Whether to provide additional output (0 - no output (default), 1 - output).
%
% OUTPUTS:
%    isSame:          True if all common fields are identical, else false
%    nDiff:           Number of differences between the two models for each field
%    commonFields:    List of common fields
%
% .. Authors:
%     - Markus Herrgard 9/14/07
%     - CI integration: Laurent Heirendt
%     - Farid Zare 2024/08/12: New format of subSystems in the model
%
% Note: Notice that this function checks if two models are the same, two 
% same models does not necessary mean two same structures.
% use structeq.m to compare two structures

if ~exist('printLevel','var')
    printLevel = 0;
end

isSame = true;

fields1 = fieldnames(model1);
fields2 = fieldnames(model2);
onlyIn1 = setdiff(fields1, fields2);
onlyIn2 = setdiff(fields2, fields1);
if printLevel > 0
    if ~isempty(onlyIn1)
        fprintf('The following fields are only present in the first input model:\n');
        for i = 1:numel(onlyIn1)
            fprintf('%s\n',onlyIn1{i});
        end
    end
    if ~isempty(onlyIn2)
        fprintf('The following fields are only present in the second input model:\n');
        for i = 1:numel(onlyIn2)
            fprintf('%s\n',onlyIn2{i});
        end
    end
end

commonFields = intersect(fields1, fields2);
commonFields = commonFields(~strcmpi('description', commonFields));

if (~isempty(onlyIn1) || ~isempty(onlyIn2))
    isSame = false;
end

% Check if subSystems field is nested cells
if isfield(model1, 'subSystems') || isfield(model2, 'subSystems')
    [~, rxnSubSystemMat1, subSystemNames1, nestedCells1] = buildRxn2subSystem(model1);
    [~, rxnSubSystemMat2, subSystemNames2, nestedCells2] = buildRxn2subSystem(model2);
end

% initialize variables
nFields = length(commonFields);
nDiff = zeros(nFields,1);

% loop through all fields
for i = 1:nFields
    fieldName = commonFields{i};
    value1 = getfield(model1, fieldName);
    value2 = getfield(model2, fieldName);

    % Check if subSystems field is nested cells
    if strcmp(fieldName, 'subSystems') && (nestedCells1 || nestedCells2)
        % Compare subSystem names
        nDiffSubName = sum(~strcmp(subSystemNames1, subSystemNames2));
        % Compare rxnSubSystem matrix
        nDiffSubMat = ~isequal(rxnSubSystemMat1, rxnSubSystemMat2);

        if nDiffSubName > 0
            if printLevel > 0
                fprintf('Field %s differs in %d positions between the models\n',fieldName,nDiff(i));
            end
            nDiff(i) = nDiffSubName;
        elseif nDiffSubMat > 0
            if printLevel > 0
                fprintf('Nested cells in field subSystems: Shared lists, different contents per reaction.\n');
            end
            nDiff(i) = nDiffSubMat;
        end
    else

        if 0 %debugging code
            if strcmp(fieldName,'rxnConfidenceScores')
                pause(0.1);
            end
        end
        % replace all whitespaces
        if iscellstr(value1)
            value1 = regexprep(value1, '[^\w'']', '');
            value2 = regexprep(value2, '[^\w'']', '');
        end

        if isnumeric(value1)
            nDiff(i) = sum(sum(~((value1 == value2) | (isnan(value1) & isnan(value2))) ));
        elseif iscellstr(value1)
            if 0 %debugging code
                for i=1:length(value1)
                    if class(value1{i})~=class(value2{i})
                        pause(0.1)
                    end
                    if length(value1{i})~=length(value2{i})
                        pause(0.1)
                    end
                end
            end
            nDiff(i) = sum(~strcmp(value1, value2));
        elseif ischar(value1)
            nDiff(i) = ~strcmp(value1, value2);
        end

        if printLevel > 0
            if nDiff(i) > 0
                fprintf('Field %s differs in %d positions between the models\n',fieldName,nDiff(i));
            end
        end

    end

    if (nDiff(i) > 0)
        isSame = false;
    end
end
