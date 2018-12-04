function writeCoverage(coverageData, outputFile)
% Write the coverage data stored in the coverageData Struct into a json
% file. 
% USAGE:
%    writeCoverage(coverageData)
%
% INPUT:
%    coverageData:      A Data struct with the coverage data having the
%                       following fields
%                        * .fileName - the file name
%                        * .coverage - a n x 2 double array with n being the number of relevant lines in the file, while the first column indicates the line number and the second column indicates the number of executions
%                        * .lineCount - the number of lines in the file.
%
%    outputFile:        The name of the outputfile (e.g. 'coverage.json')
%
%
% AUTHOR:       Thomas Pfau 2018

global CBTDIR

jsonFile = fopen(outputFile,'w');
fprintf(jsonFile,'{\n"service_job_id": "none",\n"service_name": "none",\n"source_files": [\n');

for i = 1:numel(coverageData)
    if i > 1
        fprintf(jsonFile,',');
    end
    fprintf(jsonFile,'{ "name": "%s",\n',strrep(coverageData(i).fileName,[CBTDIR filesep],''));
    [md5] = getMD5Checksum(coverageData(i).fileName);
    fprintf(jsonFile,'"source_digest": "%s",\n',md5);
    coverage = repmat({'null'},coverageData(i).lineCount,1);
    coverage(coverageData(i).relevantLines(:,1)) = arrayfun(@num2str, coverageData(i).relevantLines(:,2),'Uniform',0);
    fprintf(jsonFile,'"coverage": [%s]\n }\n',strjoin(coverage,','));
    
end

fprintf(jsonFile,']\n}\n');

fclose(jsonFile);

end

