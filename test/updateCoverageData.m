function coverageData = updateCoverageData(coverageData, profilerStats )
% Updates the coverage data according to the data provided in the profile
% Status (from profile('info')
% USAGE:
%    coverageData = updateCoverageData(coverageData, profilerStats )
% INPUTS:
%    coverageStruct:    A struct array with the following fields:
%                        * .fileName - the file name
%                        * .coverage - a n x 2 double array with n being the number of relevant lines in the file, while the first column indicates the line number and the second column indicates the number of executions
%    profilerStats:     a Structure array obtained from the command
%                       `profilerStats = profile('info')
%
% OUTPUT:
%    coverageStruct:    A struct array with the following fields:
%                        * .fileName - the file name
%                        * .coverage - a n x 2 double array with n being the number of relevant lines in the file, while the first column indicates the line number and the second column indicates the number of executions
%                        * .totalLines - the total number of lines in the file
%                        * .md5sum - The md5sum hash of the file.

functionTable = profilerStats.FunctionTable;
profiledFiles = {functionTable.FileName};
[FilePres,FilePos] = ismember(profiledFiles,{coverageData.fileName});
updateInfo = find(FilePres);
for i = 1:numel(updateInfo)
    cProfilePos = updateInfo(i);
    cCovPos = FilePos(updateInfo(i));
    ExecutedLines = functionTable(cProfilePos).ExecutedLines;    
    [linePres,linePos] = ismember(ExecutedLines(:,1),coverageData(cCovPos).relevantLines(:,1));
    coverageData(cCovPos).relevantLines(linePos(linePres),2) = coverageData(cCovPos).relevantLines(linePos(linePres),2) + ExecutedLines(linePres,2);
end

