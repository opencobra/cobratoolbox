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
sourceFolder = [CBTDIR filesep 'src'];
coverageStruct = struct('fileName','fileName','relevantLines',1);
files = getFilesInDir('dirToList',sourceFolder,'type', 'tracked', 'restrictToPattern', '^.*\.m$', 'checkSubFolders', true);
coverageStruct(numel(files)).fileName = 'end';
[stat,res] = system(['find ' sourceFolder ' -type f -regex .*\.m -exec md5sum "{}" +']);
if stat == 0
    indFiles = strsplit(res,'\n');
    [md5s,fileNames] = cellfun(@(x) deal(x(1:32),x(35:end)),indFiles(1:end-1),'UniformOutput',0);    %The last line is an empty line.
    [fpres,fpos] = ismember(files,fileNames);
    md5s = md5s(fpos(fpres));
else
    md5s = cell(numel(files));
    for i = 1:numel(files)
        [~,md5] = getMD5Checksum(files{i});
        md5s{i} = getMD5Checksum(md5);
    end
end
    
        
    try
for i = 1:length(files)
    cFileName = files{i};
    text = fileread(cFileName);
    lines = strsplit(text,'\n','CollapseDelimiters',false);
    codeLines = cellfun(@(x) iscodeLine(x),lines);
    codeLineNumbers = columnVector(find(codeLines));
    relevantLines = zeros(numel(codeLineNumbers),2); 
    if size(codeLineNumbers > 0)
        relevantLines(:,1) = codeLineNumbers;
        relevantLines(:,2) = zeros(size(codeLineNumbers));
    end
    coverageStruct(i).fileName = cFileName;
    coverageStruct(i).relevantLines = relevantLines;
    coverageStruct(i).totalLines = numel(lines);
    coverageStruct(i).md5sum = md5s{i};
end
    catch
        keyboard
    end

end

function tf = iscodeLine(lineOfFile)
lineOfFile = strtrim(lineOfFile);
if (length(lineOfFile) > 0) && ... %There is something in the line
        (length(strfind(lineOfFile(1), '%')) ~= 1) %The line is not commented
    %Now, we have a line, which is not a commented line.
    
    if ~isempty(regexp(lineOfFile,'^end;?\s*(%.*)?$'))
        %Now, if it only contains 'end' or 'end;' or an end with a comment we can skip it.
        tf = false;
        return
    end
    if ~isempty(regexp(lineOfFile,'^otherwise;?\s*(%.*)?$'))
        %Now, if it only contains 'otherwise' or an 'otherwise followed by a comment or whitespace we can skip it.
        tf = false;
        return
    end
    if ~isempty(regexp(lineOfFile,'^else;?\s*(%.*)?$'))
        %Now, if it only contains 'else' or an 'else;' or an else followed by a comment or whitespace we can skip it.
        tf = false;
        return
    end
    if ~isempty(regexp(lineOfFile,'^case .*$|(%.*)'))
        %Now, if it only contains 'case' or an case followed by a comment or whitespace we can skip it.
        tf = false;
        return
    end
    if ~isempty(regexp(lineOfFile,'^function\s+.*$'))
        %If it contains the 'function' keyword at the start of the non
        %whitespace line followed by at least one whitespace (to make
        %sure it actually is the function keyword.
        tf = false;
        return
    end
    tf = true;
else
    tf = false;
end
end