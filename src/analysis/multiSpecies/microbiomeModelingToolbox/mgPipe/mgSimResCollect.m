function [netSecretionFluxes, netUptakeFluxes, Y] = mgSimResCollect(resPath, sampNames, exchanges, rDiet, pDiet, infoFilePath, netProduction, netUptake, figForm)
% This function is called from the MgPipe pipeline. Its purpose is to compute
% NMPCs from simulations with different diet on multiple microbiota models.
% Results are outputted as .csv and a PCoA on NMPCs to group microbiota
% models of individuals for similar metabolic profile is also
% computed and outputted.
%
% USAGE:
%
%    [fSp, Y]= mgSimResCollect(resPath, sampNames, sampNames, rDiet, pDiet, infoFilePath, netProduction, figForm)
%
% INPUTS:
%    resPath:            char with path of directory where results are saved
%    sampNames:          nx1 cell array cell array with names of individuals in the study
%    exchanges:          cell array with list of all unique exchanges to diet/
%                        fecal compartment that were interrogated in simulations      
%    rDiet:              number (double) indicating if to simulate a rich diet
%    pDiet:              number (double) indicating if a personalized diet
%                        is available and should be simulated
%    infoFilePath:       char indicating, if stratification criteria are available,
%                        full path and name to related documentation(default: no)
%                        is available
%    netProduction:      cell array containing FVA values for maximal uptake
%    figForm:            char indicating the format of figures
%
% OUTPUTS:
%    netSecretionFluxes: cell array with computed NMPCs
%    netUptakeFluxes:    cell array with computed uptake potential
%    Y:                  classical multexchangesimensional scaling
%
% .. Author: Federico Baldini, 2017-2018
%            Almut Heinken, 03/2021: simplified inputs

if ~exist('infoFilePath', 'var')||~exist(infoFilePath, 'file')
    patStat = 0;
else
    patStat = 1;
end

tol = 1e-07;

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
    for k = 1:length(sampNames)
        if isempty(netProduction{fl,k}) == 1
            disp('Jumping not feasible model')
            warning('NAN rows in fluxes matrix, no PCoA will be plotted')
            sp = NaN(length(exchanges), 1);
            up = NaN(length(exchanges), 1);
            fSp(:,k) = sp;
            uSp(:,k) = up;
            noPcoa = 1;
        else
            sp = zeros(length(exchanges), 1);  % consider to remove preallocation
            for i = 1:length(exchanges)
                x = netProduction{j,k}{i, 3};
                
                % cut off very small values below solver sensitivity
                if abs(x) < tol
                    netProduction{j,k}{i, 3}=0;
                end
                
                e = isempty(x);
                
                if e == 0
                    sp(i,1) = abs(netProduction{j, k}{i,3} + netProduction{j,k}{i, 2});
                end
                if e == 0
                    up(i,1) = abs(netUptake{j, k}{i,3} + netUptake{j,k}{i, 2});
                end
            end
            fSp(:,k) = sp;
            uSp(:,k) = up;
        end
    end
    
    fSpOld=fSp;
    convRes=num2cell(fSp);
    fSp=[exchanges';convRes'];
    ext=['Net secretion';sampNames];
    netSecretionFluxes=[ext';fSp'];
    writetable(cell2table(netSecretionFluxes),[resPath names{1, j} '_net_secretion_fluxes.csv'],'WriteVariableNames',false);
    convRes=num2cell(uSp);
    uSp=[exchanges';convRes'];
    ext=['Net uptake';sampNames];
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
                figure
                plot(Y(:, 1), Y(:, 2), 'bx')
                xlabel(strcat('PCoA1: ',num2str(round(expr(1)*100,2)),'% of explained variance'));
                ylabel(strcat('PCoA2: ',num2str(round(expr(2)*100,2)),'% of explained variance'));
                if length(sampNames)<30
                    h=text(Y(:,1),Y(:,2),sampNames,'HorizontalAlignment','left');%to insert numbers
                    set(h, 'Interpreter', 'none')
                else
                    warning('Plot annotation with individuals names disabled because of their big number');
                end
                print(strcat(resPath, 'PCoA_individuals_fluxes_', names{1, j}), figForm)
                title('PCoA of net secretion profiles');
            end
        else
            infoFile = readInputTableForPipeline(infoFilePath);
            
            % remove individuals not in simulations
            [C,IA] = setdiff(infoFile(:,1),sampNames);
            infoFile(IA,:)=[];
            
            % get the number of conditions
            cond=unique(infoFile(:,2));
            
            % assign a random color to each condition
            
            for i=1:length(cond)
                cols(i,:)=[rand rand rand];
            end
            
            colorMap = zeros(size(infoFile,1),3);
            
            for i = 1: size(infoFile(:,1))
                % get the color corresponding to the condition
                findCol=find(strcmp(cond,infoFile{i,2}));
                colorMap(i, :) = cols(findCol,:);
            end
            
            % catch if there are too few individuals to plot
            if ~isempty(Y)
                
                figure
                scatter(Y(:, 1), Y(:, 2), 30 * ones(size(Y,1), 1), colorMap, 'filled');
                
                xlabel(strcat('PCoA1: ',num2str(round(expr(1)*100,2)),'% of explained variance'));
                ylabel(strcat('PCoA2: ',num2str(round(expr(2)*100,2)),'% of explained variance'));
                
                for i=1:length(cond)
                    h=text(max(Y(:, 1)),max(Y(:, 2)-20*i),cond{i},'HorizontalAlignment','left','Color', cols(i,:));
                    set(h, 'Interpreter', 'none')
                    hold on
                end

                if length(sampNames)<30
                    h=text(Y(:,1),Y(:,2),sampNames,'HorizontalAlignment','left');%to insert numbers
                    set(h, 'Interpreter', 'none')
                else
                    warning('Plot annotation with individuals names disabled because of their big number');
                end
                print(strcat(resPath, 'PCoA_individuals_fluxes_', names{1, j}), figForm)
                title('PCoA of net secretion profiles');
                
            end
        end
    end
end

% delete files that are no longer needed
delete([resPath filesep 'exchanges.csv'])
delete([resPath filesep 'intRes.mat'])

end