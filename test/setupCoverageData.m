function coverageStruct = setupCoverageData()
% set up the Coverage data, i.e. scan through all files in src and extract
% their relevant lines.
% USAGE:
%    coverageStruct = setupCoverageData()
%
% OUTPUT:
%    coverageStruct:    A struct array with the following fields:
%                        * .fileName - the file name
%                        * .coverage - a n x 2 double array with n being the number of relevant lines in the file, while the first column indicates the line number and the second column indicates the number of executions
%                        * .totalLines - the total number of lines in the file
%                        * .md5sum - The md5sum hash of the file.
% ..Author
%    - Thomas Pfau

global CBTDIR
coverageStruct = struct('fileName','fileName','relevantLines',1);
files = getFilesInDir('dirToList',[CBTDIR filesep 'src'],'type', 'tracked', 'restrictToPattern', '^.*\.m$', 'checkSubFolders', true);
coverageStruct(numel(files)).fileName = 'end';
for i = 1:length(files)
    cFileName = files{i};
    text = fileread(cFileName);
    lines = strsplit(text,'\n','CollapseDelimiters',false);
    codeLines = columnVector(find(cellfun(@(x) iscodeLine(strtrim(x)),lines)));
    relevantLines = zeros(numel(codeLines),2);
    relevantLines(:,1) = codeLines;
    relevantLines(:,2) = zeros(size(codeLines));
    coverageStruct(i).fileName = cFileName;
    coverageStruct(i).relevantLines = relevantLines;
    coverageStruct(i).totalLines = numel(lines);
    coverageStruct(i).md5sum = GetMD5(cFileName,'file');
end


end

function tf = iscodeLine(lineOfFile)
if length(lineOfFile) > 0 && ... %There is something in the line
        length(strfind(lineOfFile(1), '%')) ~= 1  && ... %The line is not commented
        length(strfind(lineOfFile, 'end')) ~= 1 && ... %Its not an 'end'
        length(strfind(lineOfFile, 'otherwise')) ~= 1 && ... %'its not an otherwise from a switch statement
        length(strfind(lineOfFile, 'else')) ~= 1  && ... %its not an else from an if
        length(strfind(lineOfFile, 'case')) ~= 1 && ... %its not a individual case from aswitch statement
        length(strfind(lineOfFile, 'function')) ~= 1 % its not the function header
    tf = true;
else
    tf = false;
end
end