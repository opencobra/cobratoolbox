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
    star=2
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
    star=t+2
end
%End of Auto load for crashed simulations 


%Starting personalized simulations 
for k=star:(patnumb+1) 
 pp=cell2mat(sampname((k-1),1))
 load(strcat('microbiota_model_samp_',pp,'.mat'))
 model=microbiota_model;
 for j=1:length(model.rxns)
    if strfind(model.rxns{j},'biomass')
       model.lb(j)=0;
    end
 end
    model=changeObjective(model,'EX_microbeBiomass[fe]');
    AllEx = model.rxns;
    result  = find(cellfun(@(x) ~isempty(strfind(x,'[d]')),AllEx));
    prova=model.rxns(result);
    prova= regexprep(prova,'EX_','Diet_EX_');
    model.rxns(result)=prova;
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
      AllEx = model.rxns;
      result2  = find(cellfun(@(x) ~isempty(strfind(x,'[fe]')),AllEx));
      result3  = find(cellfun(@(x) ~isempty(strfind(x,'[d]')),AllEx));
      Irec = AllEx(result2);
      Irec=setdiff(Irec,'EX_microbeBiomass[fe]','stable');
      Irec2 = AllEx(result3);
       if rdiet==1 %fede working on it 0218
       [minFlux,maxFlux]=guidedSim(model,newFVA,Irec); %to uncomment
       sma=maxFlux;
       sma2=minFlux %addded 2018 to save all results
       [minFlux,maxFlux]=guidedSim(model,newFVA,Irec2);
       smi=minFlux;
       smi2=maxFlux
       maxFlux=sma; %addded 2018 to save all results
       minFlux=smi;
      FVAct{1,(k-1)}=ID; 
      NSct{1,(k-1)}=ID; %addded 2018 to save all results
    for i =1:length(Irec)
        [truefalse, index] = ismember(Irec(i), ID);
        FVAct{1,(k-1)}{index,2}=minFlux(i,1);
        FVAct{1,(k-1)}{index,3}=maxFlux(i,1);
        NSct{1,(k-1)}{index,2}=smi2(i,1);%addded 2018 to save all results
        NSct{1,(k-1)}{index,3}=sma2(i,1);%addded 2018 to save all results
    end
       end
  else
       microbiota_model=model
       mkdir(strcat(resPath,'Rich'))
       save(strcat(resPath,'Rich\','microbiota_model_richD_',pp,'.mat'),'microbiota_model') 
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
       [minFlux,maxFlux]=guidedSim(model_sd,newFVA,Irec);
       sma=maxFlux;
       sma2=minFlux %addded 2018 to save all results
       [minFlux,maxFlux]=guidedSim(model_sd,newFVA,Irec2);
       smi=minFlux;
       smi2=maxFlux
       maxFlux=sma; %addded 2018 to save all results
       minFlux=smi;
       
       FVAct{2,(k-1)}=ID;
       NSct{2,(k-1)}=ID; %addded 2018 to save all results
        for i =1:length(Irec)
            [truefalse, index] = ismember(Irec(i), ID);
            FVAct{2,(k-1)}{index,2}=minFlux(i,1);
            FVAct{2,(k-1)}{index,3}=maxFlux(i,1);
            NSct{2,(k-1)}{index,2}=smi2(i,1);%addded 2018 to save all results
            NSct{2,(k-1)}{index,3}=sma2(i,1);%addded 2018 to save all results
        end
  else 
  microbiota_model=model_sd;
  mkdir(strcat(resPath,'Standard'))
  save(strcat(resPath,'Standard\','microbiota_model_standardD_',pp,'.mat'),'microbiota_model')
  end

if cobrajl==0
   save(strcat(resPath,'intRes.mat'),'FVAct')  
end  
  
  
%Using personalised diet not documented and bugchecked yet!!!!

if pdiet==1

model_pd=model;
[Numbers, Strings] = xlsread(strcat(abundancepath,fileNameDiets));
EldermetIDs = Strings(1,2:end)';
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
        [minFlux,maxFlux]=guidedSim(model_pd,newFVA,Irec);
       sma=maxFlux;
       [minFlux,maxFlux]=guidedSim(model_pd,newFVA,Irec2);
       smi=minFlux;
       maxFlux=sma;
       minFlux=smi;
      FVAct{3,(k-1)}=ID;
 for i =1:length(Irec)
 [truefalse, index] = ismember(Irec(i), ID);
 FVAct{3,(k-1)}{index,2}=minFlux(i,1);
 FVAct{3,(k-1)}{index,3}=maxFlux(i,1);
  end
  else 
  microbiota_model=model_pd  
    mkdir(strcat(resPath,'Personalized'))
    save(strcat(resPath,'Personalized\','microbiota_model_personalisedD_',pp,'.mat'),'microbiota_model')
  end


 end
    end
    end
    end
end

%Saving all output of simulations 
if cobrajl==0
  save(strcat(resPath,'simRes.mat'),'FVAct','Presol','InFesMat', 'NSct')  
end

