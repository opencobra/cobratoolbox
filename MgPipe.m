%MgPipe is a MATLAB based pipeline to integrate microbial abundances 
%(coming from metagenomic data) with constraint based modeling, creating 
%individuals' personalized models.
%The pipeline is divided in 3 parts:
%[PART 1] Analysis on individuals' specific microbes abundances are computed.
%[PART 2]: 1 Constructing a global metabolic model (setup) containing all the 
%microbes listed in the study. 2 Building individuals' specific models 
%integrating abundance data retrieved from metagenomics. For each organism,
%reactions are coupled to objective function.
%[PART 3] Simulations under different diet regimes.
%MgPipe was created (and tested) for AGORA 1.0 please first download AGORA 
%version 1.0 from https://vmh.uni.lu/#downloadview and place the mat files 
%into a folder.

% Federico Baldini, 2017-2018

%Automatic detection of number of samples in the study 

[patnumb,sampname,strains]=getIndividualSizeName(infoPath,modPath,'normCoverage.csv');

%Auto load for PART1 -> if PART1 was already computed and is alreday
%present in results folder its execution is skipped else its execution starts

resPathc=resPath(1:(length(resPath)-1));
cd(resPathc);
fnames = dir('*.mat');
numfids = length(fnames);
vals = cell(1,numfids);
   for K = 1:numfids
       vals{K} = fnames(K).name;
   end
vals=vals';
mapP = strmatch('mapInfo.mat', vals, 'exact');

 %[PART 1] 
%Genomic Analysis Section -> processing mapping information
if isempty(mapP)
autostat=0;

%Loading names of models not present in the study but in folder: the vector
%containing the name is called extrastrains

modPathc=modPath(1:(length(modPath)-1));
cd(modPathc)
fnames = dir('*.mat');
numfids = length(fnames);
vals = cell(1,numfids);
for K = 1:numfids
   vals{K} = fnames(K).name;
end
vals=vals';
extrastrains=strtok(vals(:,1),'.'); 

%Loading all the models and putting them into a vector

models={[]}; %empty cell array to be filled with models 
 for i = 1:length(strains)
    %reading the models   
    pn=strcat(modPath,strains(i,1),{'.mat'});%complete path from which to read the model  
    cpn=char(pn);%conversion of the path in character
    ldm=load(cpn);
    ldm=ldm.model;
    %creating array with models as required as input from the later functions 
    models(i,1)={ldm};
 end


[reac,MicRea,BinOrg,patOrg,ReacPat,reacNumb,ReacSet,ReacTab,ReacAbun,reacnumber]=getMappingInfo(models,infoPath,'normCoverage.csv',patnumb)
writetable(cell2table(ReacAbun),strcat(resPath,'reactions.csv'))

% Genomic Analysis section ->  Plotting section
[PCoA]=plotMappingInfo(resPath,patOrg,ReacPat,ReacTab,reacnumber,patstat,figform) 

if compmod==1
   mkdir(strcat(resPath,'compfile'))
   csvwrite(strcat(resPath,'compfile/reacTab.csv'),ReacTab)
   writetable(cell2table(ReacSet),strcat(resPath,'compfile/reacset.csv'))
   csvwrite(strcat(resPath,'compfile/reacNumb.csv'),reacNumb)
   csvwrite(strcat(resPath,'compfile/ReacPat.csv'),ReacPat)
   csvwrite(strcat(resPath,'compfile/PCoA_tab.csv'),Y)
end

%Save all the created variables
save(strcat(resPath,'mapInfo.mat'))
else
    s= 'mapping file found: loading from resPath and skipping [PART1] analysis';
    disp(s)
    load(strcat(resPath,'mapInfo.mat'))
end
%end of trigger for Autoload
%% %% [PART 2.1]


%Importing names of models from reformatted coverages files
orglist=strains;

%Autofix part 
%Checking consistence of inputs: if autofix == 0 halts execution with error 
%msg if inconsistences are detected, otherwise it really tries hard to fix 
%the problem and continues execution when possible. 

if autofix == 0

    for i=1:length(orglist)
    check=strmatch(orglist(i,1),orglist);
        if length(check) > 1
        vecErr=orglist(check)
        msg = 'Nomenclature error: one or more organisms have ambiguous ID. Ambiguity indexes stored in check vector';
        error(msg)
        end
    end
else
    for i=1:length(orglist)
    check=strmatch(orglist(i,1),orglist);
        if length(check) > 1
        vecErr=orglist(check)
        %Autodebug, suffix '_extended' is added to solve ambiguity: 
        orglist(i)
        fixVec(i)=orglist(i)
        fixNam= strcat(orglist(i),'_extended')
        orglist(i)=fixNam
        autostat=1
        end
    end
        
%Second cycle: checking multiple times is always better idea 
    for i=1:length(orglist)
    check=strmatch(orglist(i,1),orglist);
        if length(check) > 1
        vecErr=orglist(check)
        msg = 'Nomenclature error: one or more organisms have ambiguous ID. Ambiguity indexes stored in check vector';
        error(msg)
        end
    end
end
%end of Autofix part

%Auto load for PART2.1 -> if PART2.1 was already computed and is alreday
%present in results folder its execution is skipped else its execution starts
resPathc=resPath(1:(length(resPath)-1));
cd(resPathc);
fnames = dir('*.mat');
numfids = length(fnames);
vals = cell(1,numfids);
    for K = 1:numfids
        vals{K} = fnames(K).name;
    end
vals=vals';
extrastrains=strtok(vals(:,1),'.');
mapP = strmatch('Setup_allbacs.mat', vals, 'exact');
if isempty(mapP)
    modbuild = 1;
else
    modbuild = 0;
    s= 'global setup file found: loading from resPath and skipping [PART2.1] analysis';
    disp(s)
end
%end of trigger for Autoload

if modbuild == 1
%Preparing models (removing constrains) and inserting models in an array
   models={[]}; %empty cell array to be filled with models 
   parfor i = 1:length(strains)
       %reading the models   
       pn=strcat(modPath,strains(i,1),{'.mat'});%complete path from which to read the models  
       cpn=char(pn);%conversion of the path in character
       ldm=load(cpn);
       ldm=ldm.model;
       %removing possible constraints of the bacs
       [selExc,selUpt] = findExcRxns(ldm);
       Reactions2 = ldm.rxns(find(selExc));
       allex=Reactions2(strmatch('EX',Reactions2));
       biomass=allex(strmatch(objre,allex));
       finrex=setdiff(allex,biomass);
       ldm = changeRxnBounds(ldm, finrex, -1000,'l');
       %creating array with models as required as input from the following functions 
       models(i,1)={ldm};
   end

   %Creating global model -> setup creator will be called
   setup=FastSetupCreator(models, orglist, {})
   setup.name='Global reconstruction with lumen / fecal compartments no host'
   setup.recon=0
   save(strcat(resPath,'Setup_allbacs.mat'), 'setup')
end

if modbuild==0
load(strcat(resPath,'Setup_allbacs.mat')) 
end
%% [PART 2.2]

%Create microbiota models -> Integrate metagenomic data to create individualized models 
allmod={[]};

parfor k = 2:(patnumb+1)
    mgmodel=setup
    filename=strcat(infoPath,{'normCoverage.csv'});
    filename=cell2mat(filename);
    [abundance]=readtable(filename);
    abundance = table2array(abundance(:,k+1));
    %retrieving current model ID
    id=sampname((k-1),1);
    mId=strcat('microbiota_model_samp_',id,'.mat');
    
    %Autoload for already created models 
    resPathc=resPath(1:(length(resPath)-1));
    cd(resPathc);
    fnames = dir('*.mat');
    numfids = length(fnames);
    vals = cell(1,numfids);
    for K = 1:numfids
        vals{K} = fnames(K).name;
    end
    vals=vals';

    mapP = strmatch(mId, vals, 'exact');
    if isempty(mapP)
       %end of trigger
       idInfo=cell2mat(sampname((k-1),1))
       %parsave(sprintf(strcat(idInfo,'%d.mat')),id)
       %code lines to find which  bacteria has abundance of 0
       noab={};
       abcel=num2cell(abundance);
       abtab=[orglist,abcel];
       cnt=1;
       for i = 1:length(orglist)
            celabtab=cell2mat(abtab(i,2));
            if celabtab == 0
               noab(cnt)=abtab(i,1);
               cnt=cnt+1;
            end
       end
       noab=noab';
       %Setting to 0 the Exchange reactions of a bacteria whose abundance is 0 in
       %the individual and in the biomass
       for i = 1:length(noab)
           IndRxns=strmatch(noab(i,1),mgmodel.rxns);%finding indixes of specific reactions
           RmRxns=mgmodel.rxns(IndRxns);
           mgmodel=removeRxns(mgmodel,RmRxns); 
       end
      %Preparing vectors with abundances and bacteria in a way to eliminate the
      %ones not present (abundance =0)
      presBac=setdiff(orglist,noab,'stable');
      abval={};
      index=1;
      for i = 1:length(abundance)
          if ~abundance(i)== 0
            abval(index) = num2cell(abundance(i));
            index=index+1;
          end
      end
     abval=abval';
     abval=cell2mat(abval);
     mgmodel=addMicrobeCommunityBiomass(mgmodel,presBac,abval);
  
    %Coupling constraints for bacteria 
    for i = 1:length(presBac)
        IndRxns=strmatch(presBac(i,1),mgmodel.rxns);%finding indixes of specific reactions 
        mgmodel=coupleRxnList2Rxn(mgmodel,mgmodel.rxns(IndRxns(1:length(mgmodel.rxns(IndRxns(:,1)))-1,1)),strcat(presBac(i,1),{'_biomass0'}),400,0.01); %couple the specific reactions 
    end
    %finam.name=sampname((k-1),1); 
    %allmod(k,1)={finam};
    microbiota_model=mgmodel;
    microbiota_model.name=sampname((k-1),1);
    idInfo=cell2mat(sampname((k-1),1));
    lw=length(resPath);
    sresPath=resPath(1:(length(resPath)-1));
    cd(sresPath) 
    parsave(sprintf(strcat('microbiota_model_samp_',idInfo,'%d.mat')),microbiota_model)
    
else
   s= 'microbiota model file found: skipping model creation for this sample';
   disp(s)  
end
end

%Section to export models in .xml. This part is not implemented yet.
% if compmod == 1
% parfor k = 2:(patnumb+1)
% modelrm = allmod(k,1)
% modelrm.description=[];
% modelrm.description=strcat('setup_model_patient',k-1);
% writeCbToSBML(modelrm, strcat(resPath,'Setup_',k-1,'.xml'));
% end
% end  

%%
%[PART 3]
disp('Framework for fecal diet compartments microbiota models in use')
MgSetup_simulator


