function [result, why] = structeq(structA, structB, funh2string, ignorenan)
% STRUCTEQ performs an equality comparison between two structures by
% recursively comparing the elements of the struct array, their fields and
% subfields. This function requires companion function CELLEQ to compare
% two cell arrays.
%
% Additional behaviour in this version:
% - records dimensions of differing fields in why.ASize and why.BSize
% - explicitly reports field-size mismatches before value comparisons

if nargin < 3
    funh2string = false;
end
if nargin < 4
    ignorenan = false;
end

result = true;

% Predefine output structure with consistent fields.
why = struct('Reason','','Where','','A',[],'B',[],'ASize',"",'BSize',"");

% -------------------------------------------------------------
% Compare sizes of the top-level struct arrays
% -------------------------------------------------------------
if any(size(structA) ~= size(structB))
    result = false;
    why = struct( ...
        'Reason','Sizes of the struct arrays are different', ...
        'Where','', ...
        'A',[], ...
        'B',[], ...
        'ASize', sizeVec2str(size(structA)), ...
        'BSize', sizeVec2str(size(structB)));
    return
end

fieldsA = fieldnames(structA);
fieldsB = fieldnames(structB);

nDifferences = 0;

% -------------------------------------------------------------
% Compare field name sets
% -------------------------------------------------------------
uniqueToA = sort(setdiff(fieldsA, fieldsB));
uniqueToB = sort(setdiff(fieldsB, fieldsA));

if ~isempty(uniqueToA) || ~isempty(uniqueToB)
    result = false;

    % Fields present only in structA
    for j = 1:numel(uniqueToA)
        fld = uniqueToA{j};

        nDifferences = nDifferences + 1;
        why(nDifferences).Reason = 'Field names are different';
        why(nDifferences).Where  = fld;
        why(nDifferences).A      = structA(1).(fld);
        why(nDifferences).B      = [];
        why(nDifferences).ASize  = valueSize2str(structA(1).(fld));
        why(nDifferences).BSize  = '';
    end

    % Fields present only in structB
    for j = 1:numel(uniqueToB)
        fld = uniqueToB{j};

        nDifferences = nDifferences + 1;
        why(nDifferences).Reason = 'Field names are different';
        why(nDifferences).Where  = fld;
        why(nDifferences).A      = [];
        why(nDifferences).B      = structB(1).(fld);
        why(nDifferences).ASize  = '';
        why(nDifferences).BSize  = valueSize2str(structB(1).(fld));
    end
end

% -------------------------------------------------------------
% Compare fields present in both structures
% -------------------------------------------------------------
commonFields = intersect(fieldsA, fieldsB);

for i = 1:numel(structA)
    if numel(structA) == 1
        % Compare field by field for scalar structs.
        for j = 1:numel(commonFields)
            fld = commonFields{j};

            valA = structA(i).(fld);
            valB = structB(i).(fld);

            % First explicitly report a size mismatch at this field.
            if ~isequal(size(valA), size(valB))
                nDifferences = nDifferences + 1;
                result = false;

                why(nDifferences).Reason = 'Field sizes are different';
                why(nDifferences).Where  = fld;
                why(nDifferences).A      = valA;
                why(nDifferences).B      = valB;
                why(nDifferences).ASize  = valueSize2str(valA);
                why(nDifferences).BSize  = valueSize2str(valB);

                % Skip deeper comparison for this field once the sizes
                % already differ.
                continue
            end

            % Use the existing recursive logic for equal-sized fields.
            if isstruct(valA)
                props1 = struct2cell(valA);
                props2 = struct2cell(valB);
            else
                props1 = {valA};
                props2 = {valB};
            end

            [resultn, subwhy] = celleq(props1, props2, funh2string, ignorenan);
            resultn = all(resultn);

            if ~resultn
                nDifferences = nDifferences + 1;
                result = false;

                why(nDifferences).Reason = sprintf('Properties are different <- %s', subwhy.Reason);
                why(nDifferences).Where  = fld;
                why(nDifferences).A      = valA;
                why(nDifferences).B      = valB;
                why(nDifferences).ASize  = valueSize2str(valA);
                why(nDifferences).BSize  = valueSize2str(valB);
            end
        end

    else
        % Compare each element of a nonscalar struct array.
        props1 = struct2cell(structA(i));
        props2 = struct2cell(structB(i));

        [resultn, subwhy] = celleq(props1, props2, funh2string, ignorenan);
        resultn = all(resultn);

        if ~resultn
            result = false;

            % Recover the field index from CELLEQ's report, if possible.
            try
                [fieldidx, restWhere] = strtok(subwhy.Where, '}');
                fieldidx = str2double(fieldidx(2:end));
                where = sprintf('(%d).%s%s', i, fieldsA{fieldidx}, restWhere(2:end));
                valA = structA(i).(fieldsA{fieldidx});
                valB = structB(i).(fieldsA{fieldidx});
            catch
                where = sprintf('(%d)', i);
                valA = structA(i);
                valB = structB(i);
            end

            nDifferences = nDifferences + 1;
            why(nDifferences).Reason = sprintf('Properties are different <- %s', subwhy.Reason);
            why(nDifferences).Where  = where;
            why(nDifferences).A      = valA;
            why(nDifferences).B      = valB;
            why(nDifferences).ASize  = valueSize2str(valA);
            why(nDifferences).BSize  = valueSize2str(valB);
        end
    end
end

% If no differences were accumulated, clear the placeholder entry.
if result
    why = struct('Reason','','Where','','A',[],'B',[],'ASize',"",'BSize',"");
end
end

function s = valueSize2str(x)
% Return size of a MATLAB value as a compact string like "5x7" or "1x1".

    s = sizeVec2str(size(x));
end

function s = sizeVec2str(sz)
% Convert a size vector into a compact string like "5x7x3".

    if isempty(sz)
        s = "";
        return
    end

    s = join(string(sz), "x");
    s = s(1);
end

function out = formatTableColumn(in)
% Convert a table column of arbitrary MATLAB values into a cell array of
% character vectors for readable display.

    if ~iscell(in)
        in = num2cell(in);
    end

    out = cell(size(in));
    for k = 1:numel(in)
        try
            out{k} = char(any2str(in{k}));
        catch
            out{k} = evalc('disp(in{k})');
            out{k} = strtrim(out{k});
        end
    end
end