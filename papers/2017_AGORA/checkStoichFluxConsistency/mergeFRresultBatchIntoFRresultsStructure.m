%merge a batch of FRresult_model_name.mat in a directory into a FRresults
%each FRresult_model_name.mat should contain one FRresult structure for one
%model

if 1
    finalFolder='/AGORA773';
else
    finalFolder='/Seed773';
end
%finalFolder='/AGORA_5test';

FRresultDirectory=['~/work' finalFolder];
FRresultsDirectory=['~/work/ownCloud/programReconstruction/projects/AGORA/results' finalFolder];
if ~exist(FRresultsDirectory,'dir')
    mkdir(FRresultsDirectory)
end
resultsFileName=[FRresultsDirectory finalFolder '_FRresults_' datestr(now,30) '.mat'];

%find the names of each FRresult .mat file
FRmatFiles=dir(FRresultDirectory);
FRmatFiles.name;
%get rid of entries that do not have a .mat suffix
bool=false(length(FRmatFiles),1);
for k=3:length(FRmatFiles)
    if strcmp(FRmatFiles(k).name(end-3:end),'.mat')
        bool(k)=1;
    end
end
FRmatFiles=FRmatFiles(bool);

%FR results structure
FRresults=struct();
for k=1:length(FRmatFiles)
    load([FRresultDirectory filesep FRmatFiles(k).name])
    tmp=strrep(FRmatFiles(k).name,'FRresult_','');
    fprintf('%u\t%s\n',k,tmp(1:end-4))
    FRresults(k).matFile=FRresult.matFile;
    FRresults(k).modelFilename=FRresult.modelFilename;
    FRresults(k).modelID=FRresults(k).modelFilename(1:end-4);%take off .mat
    FRresults(k).rankFR=FRresult.rankFR;
    FRresults(k).rankFRV=FRresult.rankFRV;
    FRresults(k).rankS=FRresult.rankS;
    FRresults(k).model=FRresult.model;
    FRresults(k).rankFRvanilla=FRresult.rankFRvanilla;
    FRresults(k).rankFRVvanilla=FRresult.rankFRVvanilla;
    FRresults(k).maxSij=FRresult.maxSij;
    FRresults(k).minSij=FRresult.minSij;
end

%save(resultsFileName,'FRresults');%faster but drops data
%save(resultsFileName,'FRresults','-v7.3');%slow but may not drop data?
fprintf('%s\n',['checkRankFRdriver complete. FRresults saved to ' resultsFileName]);
