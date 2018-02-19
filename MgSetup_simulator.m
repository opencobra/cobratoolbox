%This script is called from the MgPipe pipeline. Its purpose is to apply 
%different diets (according to the user’s input) to the microbiota models 
%and run simulations computing FVAs on exchanges reactions of the microbiota 
%models. The output is saved in multiple .mat objects. Intermediate saving 
%checkpoints are present. 

% Federico Baldini, 2017-2018

%Creating list of all unique Exchanges to diet/fecal compartment  

allex=setup.rxns(strmatch('EX',setup.rxns));
ID = regexprep(allex,'\[d\]','\[fe\]');
ID=unique(ID,'stable');
ID=setdiff(ID,'EX_biomass[fe]','stable');

%Cell array to store results
FVAct=cell(3,patnumb);
NSct=cell(3,patnumb); 

%Auto load for crashed simulations 
resPathc=resPath(1:(length(resPath)-1));
cd(resPathc);
fnames = dir('*.mat');
numfids = length(fnames);
vals = cell(1,numfids);
for K = 1:numfids
    vals{K} = fnames(K).name;
end
vals=vals';

mapP = strmatch('intRes.mat', vals, 'exact');
if isempty(mapP)
    startIter=2
else
    s= 'simulation checkpoint file found: recovering crashed simulation';
    disp(s)
    load(strcat(resPath,'intRes.mat'))
    
%Detecting when execution halted  
    for o=1:length(FVAct(2,:))
        if isempty(FVAct{2,o})==0
            t=o 
        end
    end
    startIter=t+2
end
%End of Auto load for crashed simulations 


%Starting personalized simulations 
for k=startIter:(patnumb+1) 
 idInfo=cell2mat(sampname((k-1),1))
 load(strcat('microbiota_model_samp_',idInfo,'.mat'))
 model=microbiota_model;
 for j=1:length(model.rxns)
    if strfind(model.rxns{j},'biomass')
       model.lb(j)=0;
    end
 end
    model=changeObjective(model,'EX_microbeBiomass[fe]');
    AllRxn = model.rxns;
    RxnInd  = find(cellfun(@(x) ~isempty(strfind(x,'[d]')),AllRxn));
    EXrxn=model.rxns(RxnInd);
    EXrxn= regexprep(EXrxn,'EX_','Diet_EX_');
    model.rxns(RxnInd)=EXrxn;
    model=changeRxnBounds(model,'EX_microbeBiomass[fe]',0.4,'l');
    model=changeRxnBounds(model,'EX_microbeBiomass[fe]',1,'u');
    solution_allOpen=solveCobraLPCPLEX(model,2,0,0,[],0); 
    if isnan(solution_allOpen.obj)
        warning('Presolve detected one or more infeasible models. Please check InFesMat object !')
        InFesMat{k,1}= model.name
    else
    Presol{k,1}=solution_allOpen.obj;
    model=changeRxnBounds(model,{'DUt_h2o','UFEt_h2o','EX_h2o[fe]'},1000000,'u');
  if cobrajl==0
      AllRxn = model.rxns;
      FecalInd  = find(cellfun(@(x) ~isempty(strfind(x,'[fe]')),AllRxn));
      DietInd  = find(cellfun(@(x) ~isempty(strfind(x,'[d]')),AllRxn));
      FecalRxn = AllRxn(FecalInd);
      FecalRxn=setdiff(FecalRxn,'EX_microbeBiomass[fe]','stable');
      DietRxn = AllRxn(DietInd);
       if rdiet==1 
          [minFlux,maxFlux]=guidedSim(model,FVAtype,FecalRxn); 
           sma=maxFlux;
           sma2=minFlux 
          [minFlux,maxFlux]=guidedSim(model,FVAtype,DietRxn);
          smi=minFlux;
          smi2=maxFlux
          maxFlux=sma; 
          minFlux=smi;
          FVAct{1,(k-1)}=ID; 
          NSct{1,(k-1)}=ID; 
          for i =1:length(FecalRxn)
            [truefalse, index] = ismember(FecalRxn(i), ID);
            FVAct{1,(k-1)}{index,2}=minFlux(i,1);
            FVAct{1,(k-1)}{index,3}=maxFlux(i,1);
            NSct{1,(k-1)}{index,2}=smi2(i,1);
            NSct{1,(k-1)}{index,3}=sma2(i,1);
          end
     end
  else
       microbiota_model=model
       mkdir(strcat(resPath,'Rich'))
       save(strcat(resPath,'Rich\','microbiota_model_richD_',idInfo,'.mat'),'microbiota_model') 
  end


%Using standard diet

model_sd=model;
model_sd = setDietConstraints(model_sd,sdiet);
    if exist('unfre') ==1 %option to directly add other essential nutrients 
       warning('Feasibility forced with addition of essential nutrients')
       model_sd=changeRxnBounds(model_sd, unfre,-0.1,'l')
    end
solution_sDiet=solveCobraLPCPLEX(model_sd,2,0,0,[],0);
Presol{k,2}=solution_sDiet.obj
 if isnan(solution_sDiet.obj) 
    warning('Presolve detected one or more infeasible models. Please check InFesMat object !')
    InFesMat{k,2}= model.name
 else

  if cobrajl==0
       [minFlux,maxFlux]=guidedSim(model_sd,FVAtype,FecalRxn);
       sma=maxFlux;
       sma2=minFlux 
       [minFlux,maxFlux]=guidedSim(model_sd,FVAtype,DietRxn);
       smi=minFlux;
       smi2=maxFlux
       maxFlux=sma; 
       minFlux=smi;
       
       FVAct{2,(k-1)}=ID;
       NSct{2,(k-1)}=ID; 
        for i =1:length(FecalRxn)
            [truefalse, index] = ismember(FecalRxn(i), ID);
            FVAct{2,(k-1)}{index,2}=minFlux(i,1);
            FVAct{2,(k-1)}{index,3}=maxFlux(i,1);
            NSct{2,(k-1)}{index,2}=smi2(i,1);
            NSct{2,(k-1)}{index,3}=sma2(i,1);
        end
  else 
  microbiota_model=model_sd;
  mkdir(strcat(resPath,'Standard'))
  save(strcat(resPath,'Standard\','microbiota_model_standardD_',idInfo,'.mat'),'microbiota_model')
  end

if cobrajl==0
   save(strcat(resPath,'intRes.mat'),'FVAct')  
end  
  
  
%Using personalized diet not documented in MgPipe and bug checked yet!!!!

if pdiet==1
  model_pd=model;
 [Numbers, Strings] = xlsread(strcat(abundancepath,fileNameDiets));
 usedIDs = Strings(1,2:end)';
 % diet exchange reactions
 DietNames = Strings(2:end,1);
% Diet exchanges for all individuals 
 Diets(:,k-1) = cellstr(num2str((Numbers(1:end,k-1))));
 DietID = {DietNames{:,1} ; Diets{:,k-1}}';
 DietID = regexprep(DietID,'EX_','Diet_EX_');
 DietID = regexprep(DietID,'\(e\)','\[d\]');
 model_pd = setDietConstraints(model_pd,DietID);
 solution_pdiet=solveCobraLPCPLEX(model_pd,2,0,0,[],0);
 Presol{k,3}=solution_pdiet.obj
 if isnan(solution_pdiet.obj)
    warning('Presolve detected one or more infeasible models. Please check InFesMat object !')
    InFesMat{k,3}= model.name
 else

  if cobrajl==0
        [minFlux,maxFlux]=guidedSim(model_pd,FVAtype,FecalRxn);
       sma=maxFlux;
       [minFlux,maxFlux]=guidedSim(model_pd,FVAtype,DietRxn);
       smi=minFlux;
       maxFlux=sma;
       minFlux=smi;
      FVAct{3,(k-1)}=ID;
 for i =1:length(FecalRxn)
 [truefalse, index] = ismember(FecalRxn(i), ID);
 FVAct{3,(k-1)}{index,2}=minFlux(i,1);
 FVAct{3,(k-1)}{index,3}=maxFlux(i,1);
  end
  else 
  microbiota_model=model_pd  
    mkdir(strcat(resPath,'Personalized'))
    save(strcat(resPath,'Personalized\','microbiota_model_personalizedD_',idInfo,'.mat'),'microbiota_model')
  end


 end
    end
    end
    end
end

%Saving all output of simulations 
if cobrajl==0
  save(strcat(resPath,'simRes.mat'),'FVAct','Presol','InFesMat', 'NSct')
  MgResCollect
end

