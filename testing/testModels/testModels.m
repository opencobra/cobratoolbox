%test a set of models
clear

printLevel=0;

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

