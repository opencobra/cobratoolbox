function [fSp, Y] = mgSimResCollect(resPath, ID, rDiet, pDiet, patNumb, patStat, fvaCt, figForm)
% This function is called from the MgPipe pipeline. Its purpose is to compute
% NMPCs from simulations with different diet on multiple microbiota models.
% Results are outputted as .csv and a PCoA on NMPCs to group microbiota
% models of individuals for similar metabolic profile is also
% computed and outputted.
%
% USAGE:
%
%    [fSp, Y]= mgSimResCollect(resPath, ID, rDiet, pDiet, patNumb, patStat, fvaCt, figForm)
%
% INPUTS:
%    resPath:            char with path of directory where results are saved
%    ID:                 cell array with list of all unique Exchanges to diet/
%                        fecal compartment
%    rDiet:              number (double) indicating if to simulate a rich diet
%    pDiet:              number (double) indicating if a personalized diet
%                        is available and should be simulated
%    patNumb:            number (double) of individuals in the study
%    patStat:            logical indicating if documentation on health status
%                        is available
%    fvaCt:              cell array containing FVA values for maximal uptake
%    figForm:            char indicating the format of figures
%
% OUTPUTS:
%    fSp:                cell array with computed NMPCs
%    Y:                  classical multidimensional scaling
%
% .. Author: Federico Baldini, 2017-2018

 fid = fopen('ID.csv', 'wt');  % Exporting set of simulated reactions
 if fid > 0
     for k = 1:size(ID, 1)
         fprintf(fid, '%s,%f\n', ID{k, :});
     end
     fclose(fid);
 end

% Extract results from fluxes matrix and analyze: NMPCs will be computed for
% rich (if enabled) and standard diet. NMPCs are computed under the assumption
% that the community maximizes its uptakes and secretions. NMPCs are computed
% and saved in .csv format and a PCoA which aims to group individuals for
% similarity in their metabolic profile is also computed.

% In this section NMPCs are automatically computed for all types of diets.
% Number of different diets are automatically computed from the dimensions of
% the simulation object.

if rDiet == 0
    init = 2;
else
    init = 1;
end

if pDiet == 0
    fl = 2;
else
    fl = 3;
end

names = {'rich', 'standard', 'personalized'};
for j = init:fl
noPcoa = 0;
for k = 2:patNumb + 1
if isempty(fvaCt{fl, (k - 1)}) == 1
    disp('Jumping not feasible model')
    warning('NAN rows in fluxes matrix, no PCoA will be plotted')
    sp = NaN(length(ID), 1);
    fSp(:, k - 1) = sp;
    noPcoa = 1;
else
    sp = NaN(length(ID), 1);  % consider to remove preallocation
    for i = 1:length(ID)
        x = fvaCt{j, (k - 1)}{i, 3};
        e = isempty(x);
        if e == 0;
            sp(i, 1) = abs(fvaCt{j, (k - 1)}{i, 3} + fvaCt{j, (k - 1)}{i, 2});
        end
    end
    fSp(:, k - 1) = sp;
end
end

csvwrite(strcat(resPath, names{1, j}, '.csv'), fSp)
if noPcoa == 1
    Y=[];
    disp('Jump plotting')
else
    JD = pdist(fSp','euclidean');
    [Y, eigvals] = cmdscale(JD);
    P = [eigvals eigvals / max(abs(eigvals))];
    if patStat == 0
        plot(Y(:, 1), Y(:, 2), 'bx')
        print(strcat(resPath, 'PCoA_individuals_fluxes_', names{1, j}), figForm)
        title('PCoA of NMPCs');
    else
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
       scatter(patOrg,reacNumber,24* ones(length(reacNumber), 1), colorMap, 'filled');
       title('PCoA of NMPCs');
    end
end
end
end
