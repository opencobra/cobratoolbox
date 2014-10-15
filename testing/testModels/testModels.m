%test a set of models

testDifferentLPSolvers


%batch of mat files models in a directory
directory=which('testModels');
directory=[directory(1:end-12) 'models/'];
matFiles=dir(directory);
matFiles.name

%name
resultsFileName=['modelTestResults_' date '.mat'];


cd(directory)
results=struct();
%save(['~/Dropbox/graphStoich/results/FRresults/' resultsFileName],'results');
for k=3:length(matFiles)
    disp(k)
    disp(matFiles(k).name)
    whosFile=whos('-file',matFiles(k).name);
    if ~strcmp(matFiles(k).name,'clone1.log')
        load(matFiles(k).name);
        model=eval(whosFile.name);
        printLevel=1;
        disp(k)
        
        testDifferentLPSolvers(model)
        
        
%         model=findSExRxnInd(model);
%         if isfield(model,'metFormulas')
%             [massImbalance,imBalancedMass,imBalancedCharge,imBalancedRxnBool,Elements,missingFormulaeBool,balancedMetBool]...
%                 = checkMassChargeBalance(model,model.SIntRxnBool,printLevel);
%             model.balancedRxnBool=~imBalancedRxnBool;
%             model.balancedMetBool=balancedMetBool;
%             model.Elements=Elements;
%             model.missingFormulaeBool=missingFormulaeBool;
%             
%             %assumes that all mass imbalanced reations are exchange reactions
%             model.SIntRxnBool = model.SIntRxnBool & model.balancedRxnBool;
%             model.SIntMetBool = model.SIntMetBool & model.balancedMetBool;
%         end
%         [inform,m,model]=checkStoichiometricConsistency(model,printLevel);
%         [rankFR,rankFRV,rankFRvanilla,rankFRVvanilla,model] = checkRankFR(model,printLevel);
%         [rankS,p,q]= getRankLUSOL(model.S);
%         
%         load(['~/Dropbox/graphStoich/results/FRresults/' resultsFileName])
%         results(k-2).modelFilename=matFiles(k).name;
%         results(k-2).rankFR=rankFR;
%         results(k-2).rankFRV=rankFRV;
%         results(k-2).rankS=rankS;
%         results(k-2).model=model;
%         results(k-2).rankFRvanilla=rankFRvanilla;
%         results(k-2).rankFRVvanilla=rankFRVvanilla;
%         save(['~/Dropbox/graphStoich/results/FRresults/' resultsFileName],'results');
%         clear results model;
        
    end
end