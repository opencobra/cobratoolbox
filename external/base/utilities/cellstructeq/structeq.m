function [result, why] = structeq(structA, structB, funh2string, ignorenan)
% STRUCTEQ performs an equality comparison between two structures by
% recursively comparing the elements of the struct array, their fields and
% subfields. This function requires companion function CELLEQ to compare
% two cell arrays.
%
% USAGE:
%
% structeq(struct1, struct2)
%       Performs a comparison and returns true if all the subfields and
%       properties of the structures are identical. It will fail if
%       subfields include function handles or other objects which don't
%       have a defined eq method.
%
% [iseq, info] = structeq(struct1, struct2)
%       This syntax returns a logical iseq and a second output info which
%       is a structure that contains a field "Reason" which gives you a
%       text stack of why the difference occurred as well as a field
%       "Where" which contains the indices and subfields of the structure
%       where the comparison failed. If iseq is true, info contains empty
%       strings in its fields.
%
% [...] = structeq(struct1, struct2, funh2string, ignorenan)
%       Illustrates an alternate syntax for the function with additional
%       input arguments. See the help for CELLEQ for more information on the
%       meaning of the arguments
%
% METHOD:
% 1. Compare sizes of struct arrays
% 2. Compare numbers of fields
% 3. Compare field names of the arrays
% 4. For every element of the struct arrays, convert the field values into
% a cell array and do a cell array comparison recursively (this can result
% in multiple recursive calls to CELLEQ and STRUCTEQ)
%
% EXAMPLE:
% % Compare two handle graphics hierarchies
% figure;
% g = surf(peaks(50));
% rotate3d
% hg1 = handle2struct(gcf);
% set(g,'XDataMode', 'manual');
% hg2 = handle2struct(gcf);
%
% structeq(hg1, hg2)
% [iseq, info] = structeq(hg1, hg2)
% [iseq, info] = structeq(hg1, hg2, true)


if nargin < 3
    funh2string = false;
end
if nargin < 4
    ignorenan = false;
end

result = true;

why = struct('Reason','','Where','','A','','B','');

if any(size(structA) ~= size(structB))
    result = false;
    why = struct('Reason','Sizes are different',Where,'');
    return
end

fieldsA = fieldnames(structA);
fieldsB = fieldnames(structB);

nDifferences=0;

if 0
    % Check field lengths
    if length(fieldsA) ~= length(fieldsB)
        result = false;
        why = struct('Reason','Number of fields are different','Where','');
        return
    end
else
    % cleaner that joins with a newline instead of a comma
    % newline is a built-in MATLAB function for \n
    stacker = @(x) string(strjoin(string(x), newline));

    % Find unique fields for each struct
    uniqueToA = sort(setdiff(fieldsA, fieldsB));
    uniqueToB = sort(setdiff(fieldsB, fieldsA));
    % If there is any mismatch in the field names
    if ~isempty(uniqueToA) || ~isempty(uniqueToB)

        for j=1:max(length(uniqueToA))
            nDifferences = nDifferences + 1;
            result = false;
            why(nDifferences).Reason = 'Field names are different';
            why(nDifferences).Where  = uniqueToA{j};
            % Attempt to convert string back to a number
            numVal = str2double(structA(1).(uniqueToA{j}));
            if isnan(numVal)
                why(nDifferences).A = structA(1).(uniqueToA{j});
                why(nDifferences).B = '';
            else
                why(nDifferences).A = numVal;
                why(nDifferences).B = NaN;
            end
        end

        for j=1:max(length(uniqueToB))
            nDifferences = nDifferences + 1;
            result = false;
            why(nDifferences).Reason = 'Field names are different';
            why(nDifferences).Where  = uniqueToB{j};
            % Attempt to convert string back to a number
            numVal = str2double(structB(1).(uniqueToB{j}));
            if isnan(numVal)
                why(nDifferences).B = structB(1).(uniqueToB{j});
                why(nDifferences).A = '';
            else
                why(nDifferences).B = numVal;
                why(nDifferences).A = NaN;
            end

        end
    end
end

% Find fields that exist in both structures
commonFields = intersect(fieldsA, fieldsB);

for i = 1:numel(structA)
    if numel(structA)==1
        for j=1:length(commonFields)
            if isstruct(structA(i).(commonFields{j}))
                props1 = struct2cell(structA(i).(commonFields{j}));
                props2 = struct2cell(structB(i).(commonFields{j}));
            else
                props1 = {structA(i).(commonFields{j})};
                props2 = {structB(i).(commonFields{j})};
            end
            [resultn, subwhy] = celleq(props1,props2,funh2string,ignorenan);
            resultn = all(resultn);
            if ~resultn
                nDifferences = nDifferences + 1;
                result = resultn;
                %str2double(regexp(subwhy.Where,'{([0-9]+)}','tokens','once'));
                % why = struct('Reason',sprintf('Properties are different <- %s',subwhy.Reason),'Where',where);
                why(nDifferences).Reason = sprintf('Properties are different <- %s',subwhy.Reason);
                why(nDifferences).Where = commonFields{j}; %sprintf('(%d).%s%s',i,fields1{fieldidx},subwhy.Where(2:end));
                try
                    props1 = string(props1);
                    % Attempt to convert string back to a number
                    numVal = str2double(props1);
                    if 1 || isnan(numVal)
                        why(nDifferences).A = props1;
                    else
                        why(nDifferences).A = numVal;
                    end

                    props2 = string(props2);
                    % Attempt to convert string back to a number
                    numVal = str2double(props2);
                    if 1 || isnan(numVal)
                        why(nDifferences).B = props2;
                    else
                        why(nDifferences).B = numVal;
                    end
                catch
                    why(nDifferences).A = props1;
                    why(nDifferences).B = props2;
                end
            end
        end
    else
        props1 = struct2cell(structA(i));
        props2 = struct2cell(structB(i));
        [result, subwhy] = celleq(props1,props2,funh2string,ignorenan);
        result = all(result);
        if ~result
            [fieldidx, subwhy.Where] = strtok(subwhy.Where, '}');
            fieldidx = str2double(fieldidx(2:end));
            %str2double(regexp(subwhy.Where,'{([0-9]+)}','tokens','once'));
            where = sprintf('(%d).%s%s',i,fieldsA{fieldidx},subwhy.Where(2:end));
            why = struct('Reason',sprintf('Properties are different <- %s',subwhy.Reason),'Where',where);
            return
        end
    end

end

end

function s = any2str(x)

    if isstring(x)
        s = x;

    elseif ischar(x)
        s = string(x);

    elseif isnumeric(x) || islogical(x)
        if isscalar(x)
            s = string(x);
        else
            s = string(mat2str(x));
        end

    elseif istable(x)
        s = string(formattedDisplayText(x));

    elseif isstruct(x)
        s = string(jsonencode(x,'PrettyPrint',true));

    elseif iscell(x)
        try
            s = string(formattedDisplayText(x));
        catch
            s = string(evalc("disp(x)"));
        end

    elseif isa(x,'datetime') || isa(x,'duration')
        s = string(x);

    else
        % fallback for arbitrary classes / objects
        try
            s = string(x);
        catch
            s = string(evalc("disp(x)"));
        end
    end
end
