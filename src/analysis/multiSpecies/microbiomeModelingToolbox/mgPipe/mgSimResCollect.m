function [netSecretionFluxes, netUptakeFluxes, Y] = mgSimResCollect(resPath, ID, sampName, rDiet, pDiet, patNumb, indInfoFilePath, fvaCt, nsCt, figForm)
% This function is called from the MgPipe pipeline. Its purpose is to compute
% NMPCs from simulations with different diet on multiple microbiota models.
% Results are outputted as .csv and a PCoA on NMPCs to group microbiota
% models of individuals for similar metabolic profile is also
% computed and outputted.
%
% USAGE:
%
%    [fSp, Y]= mgSimResCollect(resPath, sampName, ID, sampName, rDiet, pDiet, patNumb, indInfoFilePath, fvaCt, figForm)
%
% INPUTS:
%    resPath:            char with path of directory where results are saved
%    ID:                 cell array with list of all unique Exchanges to diet/
%                        fecal compartment
%    sampName:           nx1 cell array cell array with names of individuals in the study
%    rDiet:              number (double) indicating if to simulate a rich diet
%    pDiet:              number (double) indicating if a personalized diet
%                        is available and should be simulated
%    patNumb:            number (double) of individuals in the study
%    indInfoFilePath:    char indicating, if stratification criteria are available, 
%                        full path and name to related documentation(default: no)
%                        is available
%    fvaCt:              cell array containing FVA values for maximal uptake
%    figForm:            char indicating the format of figures
%
% OUTPUTS:
%    netSecretionFluxes: cell array with computed NMPCs
%    netUptakeFluxes:    cell array with computed uptake potential
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
if ~exist('indInfoFilePath', 'var')||~exist(indInfoFilePath, 'file')
    patStat = 0;
else
    patStat = 1;
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

names = {'rich', 'inputDiet', 'personalized'};

for j = init:fl
    noPcoa = 0;
    fSp=[];
    uSp=[];
    for k = 2:patNumb + 1
        if isempty(fvaCt{fl, (k - 1)}) == 1
            disp('Jumping not feasible model')
            warning('NAN rows in fluxes matrix, no PCoA will be plotted')
            sp = NaN(length(ID), 1);
            up = NaN(length(ID), 1);
            fSp(:, k - 1) = sp;
            uSp(:, k - 1) = up;
            noPcoa = 1;
        else
            sp = NaN(length(ID), 1);  % consider to remove preallocation
            for i = 1:length(ID)
                x = fvaCt{j, (k - 1)}{i, 3};
                e = isempty(x);
                if e == 0
                    sp(i, 1) = abs(fvaCt{j, (k - 1)}{i, 3} + fvaCt{j, (k - 1)}{i, 2});
                end
                if e == 0
                    up(i, 1) = abs(nsCt{j, (k - 1)}{i, 3} + nsCt{j, (k - 1)}{i, 2});
                end
            end
            fSp(:, k - 1) = sp;
            uSp(:, k - 1) = up;
        end
    end
    
    fSpOld=fSp;
    convRes=num2cell(fSp);
    fSp=[ID';convRes'];
    ext=['NMPCs';sampName];
    netSecretionFluxes=[ext';fSp'];
    writetable(cell2table(netSecretionFluxes),[resPath names{1, j} '_net_secretion_fluxes.csv'],'WriteVariableNames',false);
    convRes=num2cell(uSp);
    uSp=[ID';convRes'];
    ext=['Net uptake';sampName];
    netUptakeFluxes=[ext';uSp'];
    writetable(cell2table(netUptakeFluxes),[resPath names{1, j} '_net_uptake_fluxes.csv'],'WriteVariableNames',false);
    if noPcoa == 1
        Y=[];
        disp('Jump plotting')
    else
        JD = pdist(fSpOld','euclidean');
        [Y, eigvals] = cmdscale(JD);
        P = [eigvals eigvals / max(abs(eigvals))];
        expr = [eigvals/sum(eigvals)];
        if patStat == 0
            % catch if there are too few individuals to plot
            if ~isempty(Y)
                plot(Y(:, 1), Y(:, 2), 'bx')
                xlabel(strcat('PCoA1: ',num2str(round(expr(1)*100,2)),'% of explained variance'));
                ylabel(strcat('PCoA2: ',num2str(round(expr(2)*100,2)),'% of explained variance'));
                if length(sampName)<30
                    text(Y(:,1),Y(:,2),sampName,'HorizontalAlignment','left');%to insert numbers
                else
                    warning('Plot annotation with individuals names disabled because of their big number');
                end
                print(strcat(resPath, 'PCoA_individuals_fluxes_', names{1, j}), figForm)
                title('PCoA of NMPCs');
            end
        else
            infoFile = readtable(indInfoFilePath);
            infoFile=table2cell(infoFile);
            
            % remove entries not in data
            [C,IA]=intersect(infoFile,sampName);
            if length(C)<length(sampName)
                error('Some sample IDs are not found in the file with sample information!')
            end
            infoFile=infoFile(IA,:);
            groups=unique(infoFile(1:end,2));
            % define a random color for each group
            cols = zeros(length(groups), 3);
            for k=1:length(groups)
                cols(k,:)=[rand rand rand];
            end
            colorMap = zeros(size(infoFile,1), 3);
            for k = size(infoFile,1)
                gInd=find(strcmp(groups,infoFile{k,2}));
                colorMap(k, :) = cols(gInd,:);
            end
            % catch if there are too few individuals to plot
            if ~isempty(Y)
                scatter(Y(:, 1), Y(:, 2), 24 * ones(size(Y,1), 1), colorMap, 'filled');
                for k=1:length(groups)
                text(max(Y(:, 1)),max(Y(:, 3-k)),groups{k},'HorizontalAlignment','left','Color', cols(k,:));%to insert numbers
                end
                xlabel(strcat('PCoA1: ',num2str(round(expr(1)*100,2)),'% of explained variance'));
                ylabel(strcat('PCoA2: ',num2str(round(expr(2)*100,2)),'% of explained variance'));
                title('PCoA of NMPCs');
            end
        end
    end
end

% delete files that are no longer needed
delete([resPath filesep 'ID.csv'])
delete([resPath filesep 'intRes.mat'])

end