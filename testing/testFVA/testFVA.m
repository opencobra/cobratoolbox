function x = testFVA()
%testFVA tests the functionality of flux variability analysis
%   basically performs FVA and checks solution against known solution.
%
%   Joseph Kang 04/27/09

oriFolder = pwd;

test_folder = what('testFVA');
cd(test_folder.path);

%tolerance
tol = 0.00000001;
x =1;
fprintf('\n*** Flux variability analysis ***\n\n');
load('Ec_iJR904.mat', 'model');
load('testFVAData.mat');

% [minFlux, maxFlux] = fluxVariability(model, 90);
[minFluxT, maxFluxT] = fluxVariability(model,90);

rxnNames = {'PGI','PFK','FBP','FBA','TPI','GAPD','PGK','PGM','ENO',...
'PYK','PPS','G6PDH2r','PGL','GND','RPI','RPE','TKT1','TKT2','TALA'};

rxnID = findRxnIDs(model,rxnNames);
% rxnIDT = findRxnIDs(test_model, rxnNames);

minTest =1;
maxTest =1;
maxMinusMinTest =1;
for i =1: size(rxnID)
    if(~((minFlux(rxnID)-tol <= minFluxT(rxnID)) & (minFluxT(rxnID)<= minFlux(rxnID)+tol)))
        minTest =0;
    end
    if(~((maxFlux(rxnID)-tol <= maxFluxT(rxnID)) & (maxFluxT(rxnID) <= maxFlux(rxnID)+tol)))
        maxTest =0;
    end
    maxMinusMin = maxFlux(rxnID)-minFlux(rxnID);
    maxTMinusMinT = maxFluxT(rxnID)-minFluxT(rxnID);
    if(~((maxMinusMin-tol <= maxTMinusMinT) & (maxTMinusMinT <= maxMinusMin+tol)))
        maxMinusMinTest =0;
    end
end

if(minTest==0)
    disp('Flux Variability test failed for minFlux');
    x=0;
else
    disp('Flux Variability test succeeded for minFlux');
end

if(maxTest==0)
    disp('Flux Variability test failed for maxFlux');
    x=0;
else
    disp('Flux Variability test succeeded for maxFlux');
end

if(maxMinusMinTest==0)
    disp('Flux Variability test failed for maxFlux minus minFlux');
    x=0;
else
    disp('Flux Variability test succeeded for maxFlux minus minFlux');
end
   
cd(oriFolder);    
        
    
% printLabeledData(model.rxns(rxnID),[minFlux(rxnID) maxFlux(rxnID) maxFlux(rxnID)-minFlux(rxnID)],true,3);
% printLabeledData(test_model.rxns(rxnIDT),[minFluxT(rxnIDT) maxFluxT(rxnIDT) maxFluxT(rxnIDT)-minFluxT(rxnIDT)],true,3);


end

