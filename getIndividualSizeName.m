function [indNumb,sampName,organisms]=getIndividualSizeName(infoPath, fileName)
% This function automatically detects name and number of individuals present 
% in the study. 
%
% INPUTS: 
%   infoPath:            char with path of directory from where to retrieve information
%   fileName:            char with name of file from which to retreive information
%                     
% OUTPUTS:               
%   indNumb:             number of individuals in the study  
%   sampName:            nx1 cell array cell array with names of individuals in the study
%   organisms:           nx1 cell array cell array with names of organisms in the study
%
% ..Author: Federico Baldini 2017-2018

fileName=strcat(infoPath,{fileName});
fileName=cell2mat(fileName);
[sampName]=readtable(fileName,'ReadVariableNames',false);
s=size(sampName);
s=s(1,2);
sampName=sampName(1,3:s);
sampName=table2cell(sampName);
sampName=sampName'; 
indNumb=length(sampName);%number of individuals

%getting info on present strains
%Reading models names
[strains]=readtable(fileName);
strains=strains(:,2);
organisms=table2cell(strains); %extracted names of models 
end

