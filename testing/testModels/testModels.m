%test a set of models
clear

printLevel=1;

if 0
%batch of mat files models the testModels directory
directory=which('testModels');
directory=[directory(1:end-12) 'mat/'];
cd(directory)

if exist('clone1.log','file')
    rm('clone1.log');
end

matFiles=dir(directory);

%name
resultsFileName=['modelTestResults_' date '.mat'];

nModels=length(matFiles)-2;
results=cell(nModels,4);
for k=3:length(matFiles)
    
    if printLevel>0
        disp(k)
        disp(matFiles(k).name)
    end
    
    %name of the model from the filename
    whosFile=whos('-file',matFiles(k).name);
    results{k-2,1}=matFiles(k).name(1:end-4);
    
    load(matFiles(k).name);
    model=eval(whosFile.name);
   
    %
    solvers={'gurobi5','quadMinos'};
    [out,solutions{k-2}]=testDifferentLPSolvers(model,solvers,printLevel);
    
    results{k-2,2}=solutions{k-2}{1}.obj;
    results{k-2,3}=solutions{k-2}{2}.obj;
    results{k-2,4}=results{k-2,2}-results{k-2,3};
end
else
load all_models.mat
%list of models in order
modelNames={
'LLACTIS';
'S_coilicolor';
'T_Maritima';
'mus_musculus';
'Natronomonas_pharaonis';
'AORYZAE_COBRA';
'AraGEM';
'iAC560'; 
'iAF1260'; 
'iAF692';
'iAI549'; 
'iBsu1103'; 
'iCA1273';
'iCB925';
'iFF708'; 
'iIN800'; 
'iIT341'; 
'iJO1366';
'iJP815';
'iJR904'; 
'iKF1028'; 
'iMA871';
'iMB745';
'iMM904'; 
'iND750'; 
'iNJ661'; 
'iNJ661m'; 
'iPS189';
'iRC1080';
'iRS1563';
'iRsp1095';
'iSB619';
'iSR432'; 
'iTH366';
'iYL1228'; 
'SpoMBEL1693';
'STM_v1';
'textbook';
'VvuMBEL943';};

modelsFound=true(length(modelNames),1);
j=1;
for k=1:length(modelNames)
    %name of the model from the cell
if exist(modelNames{k})
    if printLevel>0
        fprintf('%s%s\n','    Model found: ',modelNames{k})
    end

    model=eval(modelNames{k});

    %select solvers to try
    solvers={'gurobi5','quadMinos'};

    [out,solutions{k}]=testDifferentLPSolvers(model,solvers,printLevel);
    
    results{k,1}=modelNames{k};
    results{k,2}=solutions{k}{1}.obj;
    results{k,3}=solutions{k}{2}.obj;
    results{k,4}=results{k,2}-results{k,3};
    j=j+1;
else
    if printLevel>0
        fprintf('%s%s\n','Model not found: ',modelNames{k})
    end
    modelsFound(k)=0;
end
   

end
fprintf('\n')
fprintf('%s%s%s%s\n','        \solver','          gurobi','       quadMinos',...
'      difference')
fprintf('%s%s%s%s\n','model\precision','          double','       quadruple',...
'      difference')
for k=1:length(modelNames)
if modelsFound(k)
fprintf('%15s\t%15d\t%15d\t%15d\n',results{k,1},results{k,2},results{k,3},results{k,4})
end
end

end

