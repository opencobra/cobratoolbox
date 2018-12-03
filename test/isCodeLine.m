function tf = isCodeLine(lineOfFile, previousLine)
% test whether a given line is a code line or not.
% USAGE:
%    tf = isCodeLine(lineOfFile)
%
% INPUT:
%    lineOfFile:        The line of potential code to check.
%    previousLine:      the previous line (important for e.g. '...'
%                       continued lines.
%
% OUTPUT:
%    tf:                Whether it is a code line(true) or not);

% First trim the line
lineOfFile = strtrim(lineOfFile);
previousLine = strtrim(previousLine);
if ~isempty(regexp(previousLine,'\.\.\.(\s*%.*)?$','ONCE'))
    tf = false;
    return
end

if ~isempty(lineOfFile) && ... %There is something in the line
        length(strfind(lineOfFile(1), '%')) ~= 1  && ... %The line is not commented        
        isempty(regexp(lineOfFile,'^end[;$\s]*(%.*)?$','ONCE')) && ... %Its not an 'end'
        isempty(regexp(lineOfFile,'^otherwise[;$\s]*(%.*)?$','ONCE')) && ... %'its not an otherwise from a switch statement
        isempty(regexp(lineOfFile,'^else(if.*)?[;$\s]*(%.*)?$','ONCE'))  && ... %its not an else from an if        
        isempty(regexp(lineOfFile,'^case .*[;$\s]*(%.*)?$','ONCE')) && ... %its not a individual case from aswitch statement
        isempty(regexp(lineOfFile,'^function ','ONCE')) % its not the function header
    tf = true;
else
    tf = false;
end
end