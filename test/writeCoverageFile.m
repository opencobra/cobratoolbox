function [codeLines,coveredLines] = writeCoverageFile(coverage, fileName)
% Write the given coverageData to the given file in json format.
% USAGE:
%     writeCoverageFile(coverage, fileName)
%
% OUTPUT:
%    coverageStruct:    A struct array with the following fields:
%                        * .fileName - the file name
%                        * .coverage - a n x 2 double array with n being the number of relevant lines in the file, while the first column indicates the line number and the second column indicates the number of executions
%                        * .totalLines - the total number of lines in the file
% OPTIONAL INPUT:
%    fileName:          The fileName to write the coverage data to
%                       (default: [CBTDIR filesep 'coverage.json'])
%
% OUTPUTS:
%    codeLines:         Total number of lines of code in the covered files.
%    coveredLines:      Total number of lines tested in the covered files
% ..Author
%    - Thomas Pfau

global CBTDIR

if ~exist('fileName','var')
    fileName = [CBTDIR filesep 'coverage.json'];
end

f = fopen(fileName,'w');

%Opening statements
fprintf(f,'{\n"service_job_id": "none",\n"service_name": "none",\n"source_files": [\n');
coveredLines = 0;
codeLines = 0;
try
for i = 1:numel(coverage)-1
    currentFile = coverage(i);    
    filecoverage = cell(currentFile.totalLines,1);
    filecoverage(:) = {'null'};
    filecoverage(currentFile.relevantLines(:,1)) = cellfun(@num2str, num2cell(currentFile.relevantLines(:,2)),'Uniform',0);
    codeLines = codeLines + size(currentFile.relevantLines,1);
    coveredLines = coveredLines + sum(currentFile.relevantLines(:,2) ~= 0);
    fprintf(f,'{ ');
    fprintf(f,'"name": "%s",\n',strrep(currentFile.fileName,CBTDIR,''));
    fprintf(f,'"source_digest": "%s",\n',currentFile.md5sum);
    fprintf(f,'"coverage": [%s]',strjoin(filecoverage,','));
    fprintf(f,'},\n');
end
catch ME
    disp('blubb')
end
%the last file:
currentFile = coverage(end);
filecoverage = cell(currentFile.totalLines,1);
filecoverage(:) = {'null'};
filecoverage(currentFile.relevantLines(:,1)) = cellfun(@num2str, num2cell(currentFile.relevantLines(:,2)),'Uniform',0);
codeLines = codeLines + size(currentFile.relevantLines,1);
coveredLines = coveredLines + sum(currentFile.relevantLines(:,2) ~= 0);
fprintf(f,'{ ');
fprintf(f,'"name": "%s",\n',strrep(currentFile.fileName,CBTDIR,''));
fprintf(f,'"source_digest": "%s",\n',currentFile.md5sum);
fprintf(f,'"coverage": [%s]',strjoin(filecoverage,','));
fprintf(f,'}\n'); % no ',' in the end.



%closing statements
fprintf(f,'\n]\n}\n');
fclose(f);