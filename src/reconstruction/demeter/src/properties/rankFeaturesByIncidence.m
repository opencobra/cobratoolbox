function rankFeaturesByIncidence(propertiesFolder,reconVersion)
% This function counts the incidence of a number of features in the refined
% reconstruction resource and ranks them from most to least common.
%
% USAGE
%   rankFeaturesByIncidence(curatedFolder,propertiesFolder,reconVersion)
%
% INPUTS
% propertiesFolder      Folder where the analyzed features are stored and
%                       the results will be stored (default: current folder)
% reconVersion          Name assigned to the reconstruction resource
%
%   - AUTHOR
%   Almut Heinken, 07/2020

tol=0.0000001;
analyzedFiles={
    'Reaction presence' ['ReactionMetabolitePresence' filesep 'ReactionPresence_' reconVersion]
    'Metabolite presence' ['ReactionMetabolitePresence' filesep 'MetabolitePresence_' reconVersion]
    'Uptake and secretion potential' ['ComputedFluxes' filesep 'UptakeSecretion_' reconVersion]
    'Internal metabolite production' ['ComputedFluxes' filesep 'InternalProduction_' reconVersion]
    };

mkdir([propertiesFolder filesep 'Ranked_features'])

% load database
database=loadVMHDatabase;

for i=1:length(analyzedFiles)
    data = readInputTableForPipeline([propertiesFolder filesep analyzedFiles{i,2}]);
    
    % if there are enough models to compare
    if size(data,1)>20
        dataCounted={};
        for j=2:size(data,2)
            dataCounted{j-1,1}=data{1,j};
            if contains(version,'(R202') % for Matlab R2020a and newer
                dataCounted{j-1,2}=sum(abs(cell2mat(data(2:end,j)))>tol);
            else
                dataCounted{j-1,2}=sum(abs(str2double(data(2:end,j)))>tol);
            end
        end
        % sort from most to least common
        [B,I] = sort(abs(cell2mat(dataCounted(:,2))),'descend');
        % create a new ranked table with reaction information
        if i<4
            dataPrintout={'Feature','Description','Formula','Subsystem','Number of reconstructions','Percentage of reconstructions'};
            for j=1:length(B)
                dataPrintout{j+1,1}=dataCounted{I(j),1};
                if ~strncmp(dataCounted{I(j),1},'bio',3)
                    findRxnInd=find(strcmp(database.reactions(:,1),dataCounted{I(j),1}));
                    if ~isempty(findRxnInd)
                        dataPrintout{j+1,2}=database.reactions{findRxnInd,2};
                        dataPrintout{j+1,3}=database.reactions{findRxnInd,3};
                        dataPrintout{j+1,4}=database.reactions{findRxnInd,11};
                    end
                end
                dataPrintout{j+1,5}=num2str(B(j));
                dataPrintout{j+1,6}=num2str(B(j)/max(B));
            end
            
            % sort from leat to most common
            data=flip(str2double(dataPrintout(2:end,6)));
        else
            dataPrintout={'Feature','Description','Number of reconstructions','Percentage of reconstructions'};
            for j=1:length(B)
                dataPrintout{j+1,1}=dataCounted{I(j),1};
                if ~strncmp(dataCounted{I(j),1},'bio',3)
                    findMetInd=find(strcmp(database.metabolites(:,1),dataCounted{I(j),1}));
                    if ~isempty(findMetInd)
                        dataPrintout{j+1,2}=database.metabolites{findMetInd,2};
                    end
                end
                dataPrintout{j+1,3}=num2str(B(j));
                dataPrintout{j+1,4}=num2str(B(j)/max(B));
            end
            
            % sort from leat to most common
            data=flip(str2double(dataPrintout(2:end,4)));
        end
        
        figure
        plot(data,'Color', 'k')
        set(gca, 'FontSize', 12)
        h=title(analyzedFiles{i,1});
        set(h,'interpreter','none')
        if i<4
            xlabel('Reactions')
        else
            xlabel('Metabolites')
        end
        ylabel('Percentage')
        print([propertiesFolder filesep 'Ranked_features' filesep strrep(analyzedFiles{i,1},' ','_') '_ranked_' reconVersion],'-dpng','-r300')
        
        dataPrintout=cell2table(dataPrintout);
        writetable(dataPrintout,[propertiesFolder filesep 'Ranked_features' filesep strrep(analyzedFiles{i,1},' ','_') '_ranked_' reconVersion],'FileType','spreadsheet','WriteVariableNames',false);
    end
end

end