function[reac,micRea,binOrg,patOrg,reacPat,reacNumb,reacSet,reacTab,reacAbun,reacNumber]=getMappingInfo(models,infoPath,filename,patNumb)
% This function automatically extracts information from strain abundances in 
% different individuals and combines this information into different tables. 
%
% INPUTS: 
%   models:            nx1 cell array that contains n microbe models in
%                      COBRA model structure format
%   infoPath:          char with path of directory from where to retrieve information
%   filename:          char with name of file from which to retrieve information
%   patNumb:           number of individuals in the study
%                     
% OUTPUTS:               
%   reac:              cell array with all the unique set of reactions 
%                      contained in the models
%   micRea:            binary matrix assessing presence of set of unique 
%                      reactions for each of the microbes 
%   binOrg:            binary matrix assessing presence of specific strains in 
%                      different individuals
%   reacPat:           matrix with number of reactions per individual 
%                      (organism resolved) 
%   reacSet:           matrix with names of reactions of each individual
%   reacTab:           char with names of individuals in the study 
%   reacAbun:          binary matrix with presence/absence of reaction per 
%                      individual: to compare different individuals
%   reacNumber:        number of unique reactions of each individual 
%
% ..Author: Federico Baldini 2017-2018

 reac={}; %array with unique set of all the reactions present in the models
for i = 1:(length(models)-1)%find the unique set of all the reactions contained in the models
    smd=models{i,1};
    allreac=smd.rxns;
    i=i+1;
    smd=models{i,1};
    allreac1=smd.rxns;
    reaclist=unique(union(allreac,allreac1));
    reac=union(reac,reaclist);
end

%Code to detect reaction presence in each model and create inary matrix 
%assessing presence of set of unique reactions for each of the microbes

micRea = zeros(length(models),length(reac));

mdlt=length(models);
rclt=length(reac);
parfor i = 1:mdlt 
    model=models{i,1};
    for j = 1:rclt
        if ismember(reac(j),model.rxns)
        micRea(i,j)= 1;
        end
    end
end

%creating binary table for abundances

filename=strcat(infoPath,{filename});
filename=cell2mat(filename);
[binary]=readtable(filename);
s=size(binary);
s=s(1,2);
binary=binary(:,3:s); %removing model info and others 
binar=table2cell(binary);

lgi=length(binar(:,1));
lgj=length(binar(1,:));
parfor i=1:lgi
    for j=1:lgj
        if table2array(binary(i,j))~=0
           binary{i,j}=1;
        end
    end
end

binOrg=binary;

%Compute number of reactions per individual (species resolved)

reacPat=zeros(length(table2cell(binOrg(:,1))),length(table2cell(binOrg(1,:))));
cleantabc=table2cell(binOrg);
for j = 1:length(table2cell(binOrg(1,:)))
    for i = 1:length(table2cell(binOrg(:,1)))
        temp=cell2mat(cleantabc(i,j));
        if temp == 1 
            reacPat(i,j)=sum(micRea(i,:));
        end
    end
end

%Computing overall (non unique) number of reactions per individual

totReac=[];
for i = 1:length(reacPat(1,:))
    totReac(i,1)= sum(reacPat(:,i));
end

%Computing number of reactions per organism

reacNumb=[];
for i = 1:length(micRea(:,1))
    reacNumb(i,1)=sum(micRea(i,:));
end

%Computing number of organism per individual

patOrg=[];
for i = 1:length(cleantabc(1,:))
    patOrg(i,1) = sum(table2array(binOrg(:,i)));
end
patOrg=patOrg';

%number and names of UNIQUE reactions per patient

[abundance]=readtable(filename);
reacSet={};
reacNumber=[];

for j = 1 : length(table2cell(binOrg(1,:)))
    abunvec=[];
    reacvec=[];
    for i = 1 : length(table2cell(binOrg(:,1)))
        if (cell2mat(table2cell(binOrg(i,j)))) == 1
            model=models{i,1};
            reacvec= vertcat(reacvec,model.rxns);
            abunvec((length(abunvec)+1) : ((length(abunvec))+ length(model.rxns)))=  table2array(abundance(i,j+2));
        end
    end
    
    completeset(1:length(reacvec),j)=  reacvec; %to get lists of reactions per each individual
    completeabunorm(1:length(reacvec),j) = abunvec';%matrix with abundance coefficients for normalization 
    reacSet(1:length(unique(reacvec)),j)= unique(reacvec); %to get lists of reactions per each individual
    reacNumber(j)= length(unique(reacvec));
end

reacLng=length(reac);

parfor j=1:patNumb
    for i=1:reacLng
        indrxn = find(strncmp(reac(i,1), completeset(:,j), length(char(reac(i,1)))));
        numbtab(i,j)=sum(completeabunorm(indrxn));
    end
end

reacAbun = [reac,num2cell(numbtab)];


%presence/absence of reaction per patient: to compare different patients
%with pCoA
reacTab = zeros(length(reac),length(reacPat(1,:)));


parfor k = 1 : length(reacPat(1,:))
 match= []
    for i = 1 : length(reac)
        for j = 1 : length(reacSet(:,1))
            if strcmp(reac(i),reacSet(j,k)) == 1 %the 2 reactions are equal
               match(i) = 1;
            end
        end
    end
 reacTab(:,k)= match
end
end

