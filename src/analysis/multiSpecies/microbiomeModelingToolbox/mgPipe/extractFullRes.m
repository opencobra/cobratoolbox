function [finRes] = extractFullRes(resPath, ID, dietType, sampName, fvaCt, nsCt)
% This function is called from the MgPipe pipeline. Its purpose is to retrieve 
% and export, in a comprehensive way, all the results (fluxes) computed during 
% the simulations for a specified diet. Since FVA is computed on diet and fecal 
% exchanges, every metabolite will have four different values for each individual, 
% values corresponding min and max of uptake and secretion. 
%
% USAGE:
%
%    [finRes]= extractFullRes(resPath, ID, dietType, sampName, fvaCt, nsCt)
%
% INPUTS:
%    resPath:            char with path of directory where results are saved
%    ID:                 cell array with list of all unique Exchanges to diet/
%                        fecal compartment
%    dietType:           char indicating under which diet to extract results: 
%                        rDiet (rich diet), sDiet(previously specified diet)
%                        set by default, and pDiet(personalized)if available        
%    sampName:           nx1 cell array cell array with names of individuals in the study
%    fvaCt:              cell array containing FVA values for maximal uptake
%    nsCt:               cell array containing FVA values for minimal uptake
%                        and secretion for setup lumen / diet exchanges
%
% OUTPUTS:
%    finRes:             cell array with min and max value of uptake and 
%                        secretion for each metabolite
%
% .. Author: Federico Baldini 2018
if (~exist('ID'))
    warning('Automatically retrieving reactions list from global setup')
    allex = setup.rxns(strmatch('EX', setup.rxns));  % Creating list of all unique Exchanges to diet/fecal compartment
    ID = regexprep(allex, '\[d\]', '\[fe\]');
    ID = unique(ID, 'stable');
    ID = setdiff(ID, 'EX_biomass[fe]', 'stable');
end

if (exist('dietType'))
    disp(strcat('Extracting results for_',dietType,'_diet'))
else
  dietType='sDiet'
  disp('Diet set to standard as by default')
end

if (strcmp(dietType,'rDiet'))
    lInd=1;
end

if (strcmp(dietType,'sDiet'))
    lInd=2;
end

if (strcmp(dietType,'pDiet'))
    lInd=3;
end

valStor={};
startLoop=0;
for k=1:length(sampName)
    if isempty(fvaCt{lInd, k}) == 1
        disp('Jumping not feasible model')
    else
        for i =1:length(ID) %i iters for the length of ID
            allRes(i,startLoop + 1)=fvaCt{lInd, k}{i, 2}; %min upt
            allRes(i,startLoop+2)=nsCt{lInd, k}{i, 2};  %max upt
            allRes(i,startLoop+3)=nsCt{lInd, k}{i, 3}; %min secr
            allRes(i,startLoop+4)=fvaCt{lInd, k}{i, 3};  %max secr
        end
        convRes=num2cell(allRes);
        finRes=[ID';convRes']';
        if k==1
            valNames=({'Rxn';strcat('minUpt_',sampName{k});strcat('maxUpt_',sampName{k});strcat('minScr_',sampName{k});strcat('maxScr_',sampName{k})})';
        else
            valNames=({strcat('minUpt_',sampName{k});strcat('maxUpt_',sampName{k});strcat('minScr_',sampName{k});strcat('maxScr_',sampName{k})})';
        end
        valStor=[valStor';valNames']';
        finRes=[valStor;finRes];
        autoDimDect=size(finRes);
        autoDimDect=autoDimDect(2);
        startLoop=autoDimDect-1;
    end
end
if (exist('finRes'))
    writetable(cell2table(finRes),strcat(resPath,dietType,'_allFlux.csv'));
else
    finRes=0;
end
end
