function s = cobraTdfread(fileName, delimiter, varargin)
% Reads a delimited text file with a header row into a structure without the
% Statistics and Machine Learning Toolbox
%
% USAGE:
%
%    s = cobraTdfread(fileName)
%    s = cobraTdfread(fileName, delimiter)
%
% INPUT:
%    fileName:    name of the file (character vector or string scalar), in
%                 the current folder, on the MATLAB path, or a full or
%                 relative path; the first non-blank line holds the variable
%                 names
%
% OPTIONAL INPUT:
%    delimiter:   '\t' or 'tab' (default), ' ' or 'space', ',' or 'comma',
%                 ';' or 'semi', '|' or 'bar'
%
% OUTPUT:
%    s:           structure with one field per column, in column order:
%
%                 * a double column vector if every non-empty field of the
%                   column (below the header) is a number and at least one
%                   is; empty fields are NaN
%                 * otherwise a char matrix with one row per data line,
%                   padded with blanks to the longest entry
%
% NOTE:
%    Plain-MATLAB replacement for tdfread (Statistics and Machine Learning
%    Toolbox); supported syntaxes are those listed under USAGE (the
%    file-dialog syntax without a file name, and creating workspace
%    variables when no output is requested, are not supported); any other
%    input raises an error naming it; semantics: mathworks-semantics.md §14
%    (feature 20261103-120403-toolbox-free-replacements).
%
%    * Lines end with LF, CRLF or CR. Empty lines are skipped, and lines
%      of spaces when the delimiter is not a space; a line made of
%      delimiters is a data row of empty fields. (So in a one-column file an
%      empty entry is an empty line and is skipped.) Every line must have as
%      many fields as the header, otherwise error
%      `cobraTdfread:badFileFormat` (as tdfread).
%    * A field is a number when, after removing leading and trailing
%      blanks, it is a decimal number with an optional sign and exponent,
%      or Inf/NaN (any case, optional sign); it is converted with
%      `str2double`, never evaluated. tdfread (R14) evaluated the column with
%      `str2num`, so text such as `pi` or `1+2` made a column numeric there
%      but not here.
%    * Empty fields of a numeric column are NaN. This follows the call site
%      readInputTableForPipeline, which removes 'NaN' text produced by
%      tdfread; the current MathWorks rule is UNCONFIRMED (R14 could drop or
%      misalign them). A column whose fields are all empty is a blank char
%      matrix.
%    * Field contents are kept verbatim (quotes and inner blanks included;
%      R14 collapsed runs of spaces and stripped blanks next to delimiters,
%      current behaviour UNCONFIRMED; `cellstr` of a row removes trailing
%      blanks either way).
%    * Field names are `genvarname` of the trimmed header entries, as in
%      tdfread of about R2012 (MathWorks Answers 65244): valid and unique,
%      e.g. 'my value' -> 'myValue', 'a-b' -> 'a0x2Db', a repeated 'A' ->
%      'A1'. Whether current releases still use genvarname is UNCONFIRMED
%      (R14 replaced spaces with `_`). A leading UTF-8 byte-order mark is
%      removed.
%    * The file is read with the default character encoding of `fopen`.
%
% EXAMPLE:
%
%    vmhReactions = cobraTdfread('VMH_Reactions.tsv');
%    cellstr(vmhReactions.abbreviation(1, :))
%
% .. Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

if ~isempty(varargin)
    extraName = class(varargin{1});
    if ischar(varargin{1}) || isstring(varargin{1})
        extraName = char(varargin{1});
    end
    error('cobraTdfread:unsupportedOption', 'cobraTdfread: unsupported option ''%s'' (only a file name and a delimiter are supported).', extraName);
end
if ~exist('fileName', 'var') || isempty(fileName)
    error('cobraTdfread:noFileName', 'cobraTdfread: a file name is required (the file selection dialog is not supported).');
end
if ~(ischar(fileName) || (isstring(fileName) && isscalar(fileName)))
    error('cobraTdfread:invalidFileName', 'cobraTdfread: the file name must be a character vector or string scalar.');
end
if ~exist('delimiter', 'var') || isempty(delimiter)
    delimiter = '\t';
end
delimiterChar = parseDelimiter(delimiter);

fileId = fopen(char(fileName), 'r');
if fileId < 0
    error('cobraTdfread:fileNotFound', 'cobraTdfread: cannot open the file ''%s''.', char(fileName));
end
text = fread(fileId, Inf, '*char')';
fclose(fileId);
if ~isempty(text) && text(1) == char(65279)
    text = text(2:end);
end

lines = regexp(text, '\r\n|\n|\r', 'split');
% skip empty lines, and lines of blanks unless the delimiter is a blank; a
% line made of delimiters is a data line with empty fields
if strcmp(delimiterChar, ' ')
    isBlankLine = cellfun(@isempty, lines);
else
    isBlankLine = cellfun(@(line) all(line == ' '), lines);
end
lines = lines(~isBlankLine);
if isempty(lines)
    error('cobraTdfread:emptyFile', 'cobraTdfread: the file ''%s'' has no header line.', char(fileName));
end
fields = regexp(lines, regexptranslate('escape', delimiterChar), 'split');
nFields = cellfun(@numel, fields);
nColumns = nFields(1);
badLine = find(nFields ~= nColumns, 1);
if ~isempty(badLine)
    error('cobraTdfread:badFileFormat', 'cobraTdfread: line %d has %d fields but the header has %d.', badLine, nFields(badLine), nColumns);
end
header = fields{1};
data = vertcat(fields{2:end});
if isempty(data)
    data = cell(0, nColumns);
end
names = genvarname(strtrim(header));

numberPattern = '^[+-]?((\d+\.?\d*|\.\d+)([eE][+-]?\d+)?|inf|nan)$';
s = struct();
for j = 1:nColumns
    column = data(:, j);
    trimmed = strtrim(column);
    isEmptyField = cellfun(@isempty, trimmed);
    isNumber = ~cellfun(@isempty, regexpi(trimmed, numberPattern, 'once'));
    if any(isNumber) && all(isNumber | isEmptyField)
        s.(names{j}) = str2double(trimmed);
    else
        s.(names{j}) = char(column);
    end
end
end

function delimiterChar = parseDelimiter(delimiter)
% Maps the tdfread delimiter names to the delimiter character
if ~(ischar(delimiter) || (isstring(delimiter) && isscalar(delimiter)))
    error('cobraTdfread:unsupportedDelimiter', 'cobraTdfread: unsupported delimiter of class ''%s''.', class(delimiter));
end
delimiter = char(delimiter);
switch lower(delimiter)
    case {'\t', 'tab', char(9)}
        delimiterChar = char(9);
    case {' ', 'space'}
        delimiterChar = ' ';
    case {',', 'comma'}
        delimiterChar = ',';
    case {';', 'semi'}
        delimiterChar = ';';
    case {'|', 'bar'}
        delimiterChar = '|';
    otherwise
        error('cobraTdfread:unsupportedDelimiter', 'cobraTdfread: unsupported delimiter ''%s'' (supported: ''\\t''/''tab'', '' ''/''space'', '',''/''comma'', '';''/''semi'', ''|''/''bar'').', delimiter);
end
end
