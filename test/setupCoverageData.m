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
    prevLines = [{''},lines(1:end-1)];
    codeLines = columnVector(find(cellfun(@(x,y) isCodeLine(x,y),lines,prevLines)));
    relevantLines = zeros(numel(codeLines),2);
    relevantLines(:,1) = codeLines;
    relevantLines(:,2) = zeros(size(codeLines));
    coverageStruct(i).fileName = cFileName;
    coverageStruct(i).relevantLines = relevantLines;
    coverageStruct(i).lineCount = numel(lines);
end

profile on

end