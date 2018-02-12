%REQUIRED INPUT VARIABLES
modPath='Y:\Federico\Eldermet\191017\models\'; %path to microbiota models
infoPath='Y:\Federico\HMP\Run_Almut_17_03_31_with10_new_strains\'; %path to the aboundance files
resPath='Y:\Federico\HMP\Run_Almut_17_03_31_with10_new_strains\'; %path to results directory 
patnumb = 149; %number of individuals to process (<=total individuals in the study) 
nwok = 3; %number of cores dedicated for parallelisation 
compmod = 0; % if outputs in open formats should be produced for each section (1=T)
patstat = 0; %if documentations on patient health status is provided (0 not 1 yes)
autofix=1 %autofix for names mismatch
figform = '-depsc' %the output is vectorised picture, change to '-dpng' for .png
objre={'EX_biomass(e)'}; %name of objective function of organism
rdiet=0 %to enable rich simulations also 
sdiet='EUAverageDiet'
cobrajl=0
%END OF REQUIRED INPUT VARIABLES

%Start warning section
if compmod == 1
    warning('compatibility mode activated. Output will also be saved in .csv / .sbml format. Time of computations will be affected.')    
else
    warning('pipeline output will be saved in .mat format. Please enable compomod option if you wish to activate compatibility mode.')
end

if nwok<2
   warning('apparently you disabled parallel mode to enable sequential one. Computations might become very slow. Please modify nwok option.')
end
if patstat==0
    disp('Individuals health status not declared. Analysis will ignore that.')
end
%end of warning section

fprintf('Well done! Pipeline successfully activated and ready to run!')
%%
%PIPELINE LAUNCHER -> Please don't modify this section !
parpool(nwok)
MgPipe
%%
%Don't change inputs 
newFVA = 0;

%Decide what to do with these inputs 
dietpath='Y:\Federico\PD\'; %path from where to read the diet 
hostnam='Recon3'; %name that the host cell will have
dietnam = 'Diet4pipe'; %name of the diet (csv file name without extension)
dietcomp = '[d]'; %name of the diet compartment
fwok = 1; %number of cores dedicated of paralellisation of fastFVA 
comobj={'EX_microbeBiomass[fe]'}; % comunity objective function
reid = '[fe]'; % identifier for set of reactions of which to run FVA (default fecal Exchanges)
modbuild = 1; %if part 2.1 (pan model construction)needs to be excecuted (=1) or not (=0)  (default = 0) 
storvec = 0 % if to save files separately (0) or in one big vector (1)
setspec=1
changeCobraSolver('tomlab_cplex','LP');
setuptype = 2 % 1 = comp + host ; 2 = comp no host ; 3 = no comp harvey compatible

pdiet=0 %if personalised diet is available (disabled for default)
cobrajl=0
dietT='Rich'
fileNameDiets='Rugby-fluxes.xlsx'

fprintf('Well done! Pipeline successfully activated and ready to run!')
%%
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
extrastrains=strtok(vals(:,1),'.');
mapP = strmatch('mapInfo.mat', vals, 'exact');

 %[PART 1] 
%Genomic Analysis Section -> processing mapping information
if isempty(mapP)
autostat=0;
%Reading names of samples 
filename=strcat(infoPath,{'normCoverage.csv'});
filename=cell2mat(filename);
[sampname]=readtable(filename,'ReadVariableNames',false);
s=size(sampname);
s=s(1,2);
sampname=sampname(1,3:s);
sampname=table2cell(sampname);
sampname=sampname'

%Reading models names
filename=strcat(infoPath,{'normCoverage.csv'});
filename=cell2mat(filename);
[strains]=readtable(filename);
strains=strains(:,2);
strains=table2cell(strains);

%Loading names matching with agora strains 

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
    a=strcat(modPath,strains(i,1),{'.mat'});%complete path from which to read the model  
    b=char(a);%conversion of the path in character
    prova=load(b);
    prova=prova.model;
    %creating array with models as required as imput from the later functions 
    models(i,1)={prova};
end
    
%find the unique se of all the reactions contained in the models
    
 reac={}; %array with unique set of all the reactions present in the models
for i = 1:(length(models)-1)
    prova=models{i,1};
    allreac=prova.rxns;
    i=i+1;
    prova=models{i,1};
    allreac1=prova.rxns;
    reaclist=unique(union(allreac,allreac1));
    reac=union(reac,reaclist);
end

%Code to detect reaction presence in each model

MicRea = zeros(length(models),length(reac));
for i = 1:length(models)
    model=models{i,1};
    for j = 1:length(reac)
        if ismember(reac(j),model.rxns)
        MicRea(i,j)= 1;
        end
    end
end

%creating binary table for abundances

filename=strcat(infoPath,{'normCoverage.csv'});
filename=cell2mat(filename);
[binary]=readtable(filename);
s=size(binary);
s=s(1,2);
binary=binary(:,3:s);
binar=table2cell(binary);

for i=1:length(binar(:,1))
    for j=1:length(binar(1,:))
        if table2array(binary(i,j))~=0
           binary{i,j}=1;
        end
    end
end

cleantab=binary;

%Compute number of reactions per individual (species resolved)

ReacPat=zeros(length(table2cell(cleantab(:,1))),length(table2cell(cleantab(1,:))));
cleantabc=table2cell(cleantab);
for j = 1:length(table2cell(cleantab(1,:)))
    for i = 1:length(table2cell(cleantab(:,1)))
        b=cell2mat(cleantabc(i,j));
        if b == 1 
            ReacPat(i,j)=sum(MicRea(i,:));
        end
    end
end

%Computing overall number of reactions per individual

totReac=[];
for i = 1:length(ReacPat(1,:))
    totReac(i,1)= sum(ReacPat(:,i));
end

%Computing number of reactions per bacteria species

reacNumb=[];
for i = 1:length(MicRea(:,1))
%sum(MicRea(2,:))
    reacNumb(i,1)=sum(MicRea(i,:));
end

%Computing number of species per individual

patNumb=[];
for i = 1:length(cleantabc(1,:))
    patNumb(i,1) = sum(table2array(cleantab(:,i)));
end
patNumb=patNumb';

%number and names of UNIQUE reactions patient
filename=strcat(infoPath,{'normCoverage.csv'});
filename=cell2mat(filename);
[abundance]=readtable(filename);
reacset={};
reacnumber=[];

for j = 1 : length(table2cell(cleantab(1,:)))
    abunvec=[];
    reacvec=[];
    for i = 1 : length(table2cell(cleantab(:,1)))
        if (cell2mat(table2cell(cleantab(i,j)))) == 1
            model=models{i,1};
            reacvec= vertcat(reacvec,model.rxns);
            abunvec((length(abunvec)+1) : ((length(abunvec))+ length(model.rxns)))=  table2array(abundance(i,j+2));
        end
    end
    
    completeset(1:length(reacvec),j)=  reacvec; %to get lists of reactions per each individual
    completeabunorm(1:length(reacvec),j) = abunvec';%matrix with abundance coefficients for normalization 
    reacset(1:length(unique(reacvec)),j)= unique(reacvec); %to get lists of reactions per each individual
    reacnumber(j)= length(unique(reacvec));
end

till=length(reac);

parfor j=1:patnumb
    for i=1:till
        x = find(strncmp(reac(i,1), completeset(:,j), length(char(reac(i,1)))));
        numbtab(i,j)=sum(completeabunorm(x));
    end
end

out = [reac,num2cell(numbtab)];
writetable(cell2table(out),strcat(resPath,'reactions.csv'))

%presence/absence of reaction per patient: to compare different patients
%with pCoA
reacTab = zeros(length(reac),length(ReacPat(1,:)));


parfor k = 1 : length(ReacPat(1,:))
 a= []
    for i = 1 : length(reac)
        for j = 1 : length(reacset(:,1))
            if strcmp(reac(i),reacset(j,k)) == 1 %the 2 reactions are equal
            a(i) = 1;
            end
        end
    end
    reacTab(:,k)= a
end

if compmod==1
  mkdir(strcat(resPath,'compfile'))
  csvwrite(strcat(resPath,'compfile/reacTab.csv'),reacTab)
  writetable(cell2table(reacset),strcat(resPath,'compfile/reacset.csv'))
  csvwrite(strcat(resPath,'compfile/reacNumb.csv'),reacNumb)
  csvwrite(strcat(resPath,'compfile/ReacPat.csv'),ReacPat)
end

%%
% Genomic Analysis section ->  Plotting section
% clustergram(ReacPat,'Standardize','none')
imagesc(ReacPat);
colorbar
% yax=[1:(length(ReacPat)-1)];
% xax=[1:(length(ReacPat(1,:))-1)];
% set(gca,'YTick',yax)
% set(gca,'XTick',xax)
xlabel('Individuals'); % x-axis label
ylabel('Organisms'); % y-axis label
title('Heatmap individuals | organisms reactions')
print(strcat(resPath,'Heatmap'),figform)

if patstat == 0
%Plot: number of species | number of reactions  patient resolved
scatter(patNumb,reacnumber,60,jet(length(patNumb)),'filled')   
xlabel('Microbiota Size') % x-axis label
ylabel('Number of unique reactions') % y-axis label
title('Metabolic Diversity') 
print(strcat(resPath,'Metabolic Diversity'),figform)
else
%Plot: number of species | number of reactions  disease resolved
%Patients status: cellarray of same lenght of number of patients 0 means patient with disease 1 means helthy
patTab=readtable(strcat(infoPath,'Patients_status.csv'))
patients=table2array(patTab(2,:))
patients=patients(1:length(patNumb))
N = length(patients(1,:))
colorMap = [zeros(N, 1), zeros(N, 1), ones(N,1)];
    for k = 1 : length(patients(1,:))
        if patients(1,k) == 1
           colorMap(k, :) = [1,0,0]; % Red
        end
        if patients(1,k) == 2
           colorMap(k, :) = [0,1,0]; % Green
        end
    end


scatter(patNumb,reacnumber,24* ones(length(reacnumber), 1), colorMap, 'filled');
xlabel('Microbiota Size') % x-axis label
ylabel('Number of unique reactions') % y-axis label
title('Metabolic Diversity | health resolved')
%text(patNumb,reacnumber,'HorizontalAlignment','left');%to insert numbers
%text(patNumb,reacnumber,labels,'HorizontalAlignment','left');%to insert numbers
%print('Patients  strains disease resolved','-dpng')
print(strcat(resPath,'Metabolic Diversity | health resolved'),figform)
end

% PCoA -> different reactions per individual
D = pdist(reacTab','jaccard');
[Y,eigvals] = cmdscale(D);
P = [eigvals eigvals/max(abs(eigvals))]
plot(Y(:,1),Y(:,2),'bx')
P = [eigvals eigvals/sum(eigvals)]
plot(Y(:,1),Y(:,2),'bx')
%build numbers of patients
a = 1:length(Y(:,1)) ;
b = strread(num2str(a),'%s');
labels = b';
%text(Y(:,1),Y(:,2),labels,'HorizontalAlignment','left');%to insert numbers
title('PCoA of reaction presence');
print(strcat(resPath,'PCoA reactions'),figform)

plot(1:length(eigvals),eigvals,'bo-');
line([1,length(eigvals)],[0 0],'LineStyle',':','XLimInclude','off',...
     'Color',[.7 .7 .7])
axis([1,length(eigvals),min(eigvals),max(eigvals)*1.1]);
xlabel('Eigenvalue number');
ylabel('Eigenvalue');
%print(strcat(resPath,'Eigen number value'),figform)
%3D PCoA plot
scatter3(Y(:,1),Y(:,2),Y(:,3))
print(strcat(resPath,'3D PCoA reactions'),figform)
%text(Y(:,1),Y(:,2),Y(:,3),labels,'HorizontalAlignment','left');%to insert numbers

if compmod ==1
csvwrite(strcat(resPath,'compfile/PCoA_tab.csv'),Y)
end

%%
%Save all the variables
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
%Preparing models (removing constrains, imposing a minimal growth) and inserting models in a array
models={[]}; %empty cell array to be filled with models 
   for i = 1:length(strains)
   %reading the models   
    a=strcat(modPath,strains(i,1),{'.mat'});%complete path from which to read the models  
    b=char(a);%conversion of the path in character
    prova=load(b);
    prova=prova.model;
    %removing possible constraints of the bacs
    [selExc,selUpt] = findExcRxns(prova);
    Reactions2 = prova.rxns(find(selExc));
    allex=Reactions2(strmatch('EX',Reactions2));
    biomass=allex(strmatch(objre,allex));
    finrex=setdiff(allex,biomass);
    prova = changeRxnBounds(prova, finrex, -1000,'l');
    %creating array with models as required as imput from the following functions 
    models(i,1)={prova};
   end

%Creating global model
setup=FatSetupCreator(models, orglist, {})
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
    finam=setup
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
    pp=cell2mat(sampname((k-1),1));
    %parsave(sprintf(strcat(pp,'%d.mat')),id)

    %code to find which  bacteria has aboundance of 0
    noab={};
    abne=num2cell(abundance);
    abtab=[orglist,abne];
    cnt=1;
    for i = 1:length(orglist)
        cane=cell2mat(abtab(i,2));
        if cane == 0
            noab(cnt)=abtab(i,1);
            cnt=cnt+1;
        end
    end
    noab=noab';
    %Setting to 0 the Exchange reactions of a bacteria whose aboundance is 0 in
    %the patient and the biomass
    for i = 1:length(noab)
        BTRxns=strmatch(noab(i,1),finam.rxns);%finding indixes of specific reactions
        old_ex=finam.rxns(BTRxns);
        finam=removeRxns(finam,old_ex); %compatible with new cobra
    end
   
    %Preparing vectors with aboundances and bacteria in a way to eliminte the
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
    finam=addMicrobeCommunityBiomass(finam,presBac,abval);
  
    %Coupling constraints for bacteria 
    for i = 1:length(presBac)
        BTRxns=strmatch(presBac(i,1),finam.rxns);%finding indixes of specific reactions 
        finam=coupleRxnList2Rxn(finam,finam.rxns(BTRxns(1:length(finam.rxns(BTRxns(:,1)))-1,1)),strcat(presBac(i,1),{'_biomass0'}),400,0.01); %couple the specific reactions 
    end
    finam.name=sampname((k-1),1); 
    allmod(k,1)={finam};
    microbiota_model=finam;
    microbiota_model.name=sampname((k-1),1) ;
    pp=cell2mat(sampname((k-1),1));
    lw=length(resPath);
    sresPath=resPath(1:(length(resPath)-1))
    cd(sresPath) 
    parsave(sprintf(strcat('microbiota_model_samp_',pp,'%d.mat')),microbiota_model)
    
else
   s= 'microbiota model file found: skipping model creation for this sample';
   disp(s)  
end
end

if compmod == 1
parfor k = 2:(patnumb+1)
modelrm = allmod(k,1)
modelrm.description=[];
modelrm.description=strcat('setup_model_patient',k-1);
writeCbToSBML(modelrm, strcat(resPath,'Setup_',k-1,'.xml'));
end
poolobj = gcp('nocreate');
delete(poolobj);
end  

%%
%[PART 3]
disp('Framework for fecal diet compartments microbiota models in use')
MgSetup_simulator

if cobrajl==0
    MgResCollect
end



