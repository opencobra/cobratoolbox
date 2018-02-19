function [indnumb,sampname,organisms]=getIndividualSizeName(infoPath,modPath, filename)
%This function automatically detects name and number of individuals present 
%in the study. 

%INPUT 
% path                char with path of directory from where to retreive information
% filename            char with name of file from which to to retreive information
%                     
%OUTPUT               
% indnumb             number of individuals in the study  
% sampname            char with names of individuals in the study 
%
% Federico Baldini 19/02/18
filename=strcat(infoPath,{filename});
filename=cell2mat(filename);
[sampname]=readtable(filename,'ReadVariableNames',false);
s=size(sampname);
s=s(1,2);
sampname=sampname(1,3:s);
sampname=table2cell(sampname);
sampname=sampname'; 
indnumb=length(sampname);%number of individuals

%getting info on present strains
%Reading models names
[strains]=readtable(filename);
strains=strains(:,2);
organisms=table2cell(strains); %extracted names of models 
end

