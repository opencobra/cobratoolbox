function Y = plotMappingInfo(resPath, patOrg, reacPat, reacTab, reacNumber, patStat, figForm)
% This function computes and automatically plots information coming from
% the mapping data as metabolic diversity and classical multidimensional
% scaling of individuals' reactions repertoire
%
% USAGE:
%
%   Y =plotMappingInfo(resPath, patOrg, reacPat, reacTab, reacNumber, patStat, figForm)
%
% INPUTS:
%   resPath:            char with path of directory where results are saved
%   reac:               nx1 cell array with all the unique set of reactions
%                       contained in the models
%   micRea:             binary matrix assessing presence of set of unique
%                       reactions for each of the microbes
%   reacSet:            matrix with names of reactions of each individual
%   reacTab:            binary matrix with presence/absence of reaction per
%                       individual.
%   reacAbun:           matrix with abundance of reaction per individual
%   reacNumber:         number of unique reactions of each individual
%   patStat:            logical indicating if documentation on health status
%                       is available
%   figForm:            format to use for saving figures
%
% OUTPUTS:
%   Y:                  classical multidimensional scaling of individuals'
%                       reactions repertoire
%
% .. Author: - Federico Baldini, 2017-2018

figure(1)
imagesc(reacPat);
colorbar
xlabel('Individuals');  % x-axis label
ylabel('Organisms');  % y-axis label
title('Heatmap individuals | organisms reactions')
print(strcat(resPath, 'Heatmap'), figForm)


if patStat == 0
    % Plot:metabolic diversity
figure(2)
scatter(patOrg, reacNumber, 60, jet(length(patOrg)), 'filled')
xlabel('Microbiota Size')  % x-axis label
ylabel('Number of unique reactions')  % y-axis label
title('Metabolic Diversity')
print(strcat(resPath, 'Metabolic Diversity'), figForm)

% PCoA -> different reactions per individual
D = pdist(reacTab','jaccard');
[Y, eigvals] = cmdscale(D);
figure(3)
P = [eigvals eigvals / max(abs(eigvals))];
plot(Y(:, 1), Y(:, 2), 'bx')

% build numbers of patients
% lab = 1:length(Y(:,1)) ;
% lab = strread(num2str(a),'%s');
% labels = lab';
% text(Y(:,1),Y(:,2),labels,'HorizontalAlignment','left');%to insert numbers
title('PCoA of reaction presence');
print(strcat(resPath, 'PCoA reactions'), figForm)

else
    % Plot: number of species | number of reactions  disease resolved
    % Patients status: cellarray of same lenght of number of patients 0 means patient with disease 1 means helthy
patTab = readtable(strcat(toolboxPath, 'Resources\sampInfo.csv'));
patients = table2array(patTab(2, :));
patients = patients(1:length(patOrg));
N = length(patients(1, :));
colorMap = [zeros(N, 1), zeros(N, 1), ones(N, 1)];
    for k = 1: length(patients(1, :))
        if str2double(patients(1, k)) == 1
            colorMap(k, :) = [1, 0, 0];  % Red
        end
        if str2double(patients(1, k)) == 0
            colorMap(k, :) = [0, 1, 0];  % Green
        end
    end

figure(2)
scatter(patOrg, reacNumber, 24 * ones(length(reacNumber), 1), colorMap, 'filled');
xlabel('Microbiota Size')  % x-axis label
ylabel('Number of unique reactions')  % y-axis label
title('Metabolic Diversity | health resolved')
print(strcat(resPath, 'Metabolic Diversity | health resolved'), figForm)

% PCoA -> different reactions per individual
D = pdist(reacTab','jaccard');
[Y, eigvals] = cmdscale(D);
figure(3)
P = [eigvals eigvals / max(abs(eigvals))];
scatter(Y(:, 1), Y(:, 2), 24 * ones(length(reacNumber), 1), colorMap, 'filled')
title('PCoA of reaction presence');
print(strcat(resPath, 'PCoA reactions'), figForm)
end

% Plot Eigen number value: diasbled by default
% plot(1:length(eigvals),eigvals,'bo-');
% line([1,length(eigvals)],[0 0],'LineStyle',':','XLimInclude','off',...
%  'Color',[.7 .7 .7])
% axis([1,length(eigvals),min(eigvals),max(eigvals)*1.1]);
% xlabel('Eigenvalue number');
% ylabel('Eigenvalue');
% print(strcat(resPath,'Eigen number value'),figform)

% 3D PCoA plot
% scatter3(Y(:,1),Y(:,2),Y(:,3))
% print(strcat(resPath,'3D PCoA reactions'),figForm)
% text(Y(:,1),Y(:,2),Y(:,3),labels,'HorizontalAlignment','left');%to insert numbers

end
