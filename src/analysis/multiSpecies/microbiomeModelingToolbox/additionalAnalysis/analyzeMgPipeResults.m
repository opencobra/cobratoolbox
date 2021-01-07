function analyzeMgPipeResults(infoFilePath,resPath,statPath,sampleGroupHeaders)

% infoFilePath         Path to text file or spreadsheet with information on analyzed samples including
%                      group classification with sample IDs as rows

% Read in the file with sample information

infoFile = readtable(infoFilePath, 'ReadVariableNames', false);
infoFile = table2cell(infoFile);

% get all spreadsheet files in results folder
dInfo = dir(resPath);
fileList={dInfo.name};
fileList=fileList';
delInd=find(~(contains(fileList(:,1),{'csv'})));
fileList(delInd,:)=[];

% analyze data in spreadsheets
for i=1:length(fileList)
    sampleData = readtable([resPath filesep fileList{i}], 'ReadVariableNames', false);
    sampleData = table2cell(sampleData);
    
    % remove entries not in data
    [C,IA]=intersect(infoFile,sampleData(1,2:end));
    if length(C)<length(sampleData(1,2:end))
        error('Some sample IDs are not found in the file with sample information!')
    end
    
    for j=1:length(sampleGroupHeaders)
        [Statistics,significantFeatures] = performStatisticalAnalysis(sampleData',infoFile,sampleGroupHeaders{j});
        
        % Print the results as a text file
        writetable(cell2table(Statistics),[statPath filesep strrep(fileList,'.csv','') '_' sampleGroupHeaders{j} '_Statistics'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
        writetable(cell2table(significantFeatures),[statPath filesep strrep(fileList,'.csv','') '_' sampleGroupHeaders{j} '_SignificantFeatures'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
    end
end

end