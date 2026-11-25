function elements = readGAMSSet(fileName)
% Reads the elements of a GAMS set from an include file. Elements are read
% from quoted identifiers (e.g. `'R00004'`) or, if a line has no quotes, from
% a single bare identifier (e.g. `R00004`). GAMS comments are ignored: lines
% starting with `*`, inline comments `/* ... */` and the set delimiters `/`.
%
% USAGE:
%
%    elements = readGAMSSet(fileName)
%
% INPUT:
%    fileName:     (string) path to the GAMS include file
%
% OUTPUT:
%    elements:     (cell array) column cell array with the set elements, in
%                  the order they appear in the file (duplicates removed)
%
% EXAMPLE:
%
%    rxns = readGAMSSet('data/reactions_modified.txt');
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation of the data reading of optStoic-GAMS

if nargin < 1 || ~(ischar(fileName) || isstring(fileName))
    error('fileName must be a string.');
end
fileName = char(fileName);
if ~exist(fileName, 'file')
    error('File %s not found.', fileName);
end
txt = fileread(fileName);
% remove inline comments
txt = regexprep(txt, '/\*.*?\*/', '');
lines = regexp(txt, '\r?\n', 'split');
elements = {};
for i = 1:numel(lines)
    line = strtrim(lines{i});
    if isempty(line) || line(1) == '*'
        continue
    end
    quoted = regexp(line, '''([^'']+)''', 'tokens');
    if ~isempty(quoted)
        elements = [elements, cellfun(@(x) strtrim(x{1}), quoted, 'UniformOutput', false)]; %#ok<AGROW>
    else
        line = strtrim(strrep(line, '/', ''));
        bare = regexp(line, '^[A-Za-z0-9_+\-]+$', 'match', 'once');
        if ~isempty(bare)
            elements{end + 1} = bare; %#ok<AGROW>
        end
    end
end
[~, firstIdx] = unique(elements, 'stable');
elements = elements(sort(firstIdx));
elements = elements(:);
end
