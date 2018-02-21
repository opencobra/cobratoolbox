function [Y]=plotMappingInfo(resPath,patOrg,reacPat,reacTab,reacNumber,patStat,figForm)
% This function computes and automatically plots in a specified format 
% information coming from the mapping data as metabolic diversity and 
% classical multidimensional scaling of individuals' reactions repertoire 
%
% INPUTS: 
%   resPath:            char with path of directory where results are saved              
%   reac:               nx1 cell array with all the unique set of reactions 
%                       contained in the models
%   micRea:             binary matrix assessing presence of set of unique 
%                       reactions for each of the microbes 
%   BinOrg:             binary matrix assessing presence of specific strains in 
%                       different individuals
%   reacPat:            matrix with number of reactions per individual 
%                      (organism resolved) 
%   reacSet:            matrix with names of reactions of each individual
%   reacTab:            char with names of individuals in the study 
%   reacAbun:           binary matrix with presence/absence of reaction per 
%                       individual: to compare different individuals
%   reacNumber:         number of unique reactions of each individual
%   patStat:            logical indicating if documentation on health status 
%                       is available  
%   figForm:            format to use for saving figures
%
% OUTPUTS:
%   Y:                 classical multidimensional scaling of individuals' 
%                      reactions repertoire 
%
% ..Author: - Federico Baldini, 2017-2018

imagesc(reacPat);
colorbar
xlabel('Individuals'); % x-axis label
ylabel('Organisms'); % y-axis label
title('Heatmap individuals | organisms reactions')
print(strcat(resPath,'Heatmap'),figForm)

if patStat == 0
%Plot:metabolic diversity
scatter(patOrg,reacNumber,60,jet(length(patOrg)),'filled')   
xlabel('Microbiota Size') % x-axis label
ylabel('Number of unique reactions') % y-axis label
title('Metabolic Diversity') 
print(strcat(resPath,'Metabolic Diversity'),figForm)
else
%Plot: number of species | number of reactions  disease resolved
%Patients status: cellarray of same lenght of number of patients 0 means patient with disease 1 means helthy
patTab=readtable(strcat(infoPath,'Patients_status.csv'))
patients=table2array(patTab(2,:))
patients=patients(1:length(patOrg))
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


scatter(patOrg,reacNumber,24* ones(length(reacNumber), 1), colorMap, 'filled');
xlabel('Microbiota Size') % x-axis label
ylabel('Number of unique reactions') % y-axis label
title('Metabolic Diversity | health resolved')
print(strcat(resPath,'Metabolic Diversity | health resolved'),figForm)
end

% PCoA -> different reactions per individual
D = pdist(reacTab','jaccard');
[Y,eigvals] = cmdscale(D);
P = [eigvals eigvals/max(abs(eigvals))];
plot(Y(:,1),Y(:,2),'bx')
P = [eigvals eigvals/sum(eigvals)]
plot(Y(:,1),Y(:,2),'bx')
%build numbers of patients
%lab = 1:length(Y(:,1)) ;
%lab = strread(num2str(a),'%s');
%labels = lab';
%text(Y(:,1),Y(:,2),labels,'HorizontalAlignment','left');%to insert numbers
title('PCoA of reaction presence');
print(strcat(resPath,'PCoA reactions'),figForm)

%Plot Eigen number value: diasbled by default
%plot(1:length(eigvals),eigvals,'bo-');
%line([1,length(eigvals)],[0 0],'LineStyle',':','XLimInclude','off',...
   %  'Color',[.7 .7 .7])
%axis([1,length(eigvals),min(eigvals),max(eigvals)*1.1]);
%xlabel('Eigenvalue number');
%ylabel('Eigenvalue');
%print(strcat(resPath,'Eigen number value'),figform)

%3D PCoA plot
scatter3(Y(:,1),Y(:,2),Y(:,3))
print(strcat(resPath,'3D PCoA reactions'),figForm)
%text(Y(:,1),Y(:,2),Y(:,3),labels,'HorizontalAlignment','left');%to insert numbers

end
