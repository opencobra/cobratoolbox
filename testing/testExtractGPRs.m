function [ParsedGPR,corrRxn] = testExtractGPRs(model)
% Extract GPR rules based on grRules field of a COBRA model. This code
% significantly reduces cpu-time comparing to the old code. 

% IMPROVEMENTS: Compare with two COBRA models Recon1 and iOJ1366 resulted
% in two following outputs:
% 1- CPU-time of the new algorithm for iOJ1366 = 1.835656 compared to the old
% one 43.800403 seconds,
% 2- CPU-time of the new algorithm for Recon1 = 3.454554 compared to the old
% one 247.569950 seconds,
% Results of two methods (ParsedGPR and corrRxn) are the same to each
% other.


% Oveis Jamialahmadi 12/21/2016


AllRules = model.grRules;
[AllGPR,corrRxn] = deal({});
for i = 1:numel(AllRules)
    if isempty(AllRules{i})
        continue
    end
    EachRule = AllRules{i};
    orFind = textscan(EachRule,'%s','delimiter','or'); orFind = orFind{1};
    orFind(cellfun('isempty',orFind)) = [];

    GPR_temp = regexp(orFind,'(\d*)[.](\d*)|(\d*)|(\w+)(\d*)[.](\d*)|(\w+)(\d+)','match');
    corrRxn = [corrRxn;repmat(model.rxns(i),numel(GPR_temp),1)];
    AllGPR = [AllGPR;GPR_temp];
end

maxSize = max(cellfun(@numel,AllGPR));  
FillerFunc = @(x) [x repmat({'Del'},1,maxSize-numel(x))]; 
ParsedGPR = cellfun(FillerFunc,AllGPR,'UniformOutput',false); 
ParsedGPR = vertcat(ParsedGPR{:});
ParsedGPR = strrep(ParsedGPR,'Del','');
