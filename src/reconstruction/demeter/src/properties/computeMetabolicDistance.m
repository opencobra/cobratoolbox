function computeMetabolicDistance(propertiesFolder,reconVersion)
% This function computes the Jaccard distance for each pairwise combination
% of analysed strains in terms of reaction presence and metabolite uptake
% and secretion potential. 
%
% USAGE
%   computeMetabolicDistance(propertiesFolder,reconVersion)
%
% INPUTS
% propertiesFolder      Folder where the reaction presences and uptake/secretion
%                       potentials to be analysed are stored
% reconVersion          Name assigned to the reconstruction resource
%
%   - AUTHOR
%   Almut Heinken, 07/2020

files={
    [propertiesFolder filesep 'UptakeSecretion' filesep 'UptakeSecretion_' reconVersion '.txt']
    [propertiesFolder filesep 'ReactionPresence' filesep 'ReactionPresence_' reconVersion '.txt']
        };

metabolicDistance={'Microbe_1','Microbe_2','Distance_ReactionPresence','Distance_UptakeSecretion'};

for i=1:length(files)
    data = readtable(files{i}, 'ReadVariableNames', false);
    data = table2cell(data);
    
    cnt=2;
    for j=2:size(data,1)-1
        j
        for k=j+1:size(data,1)
            metabolicDistance{cnt,1}=data{k,1};
            metabolicDistance{cnt,2}=data{j,1};
            cnt=cnt+1;
        end
    end
    comDist=pdist(str2double(data(2:end,2:end)),'jaccard');
    if i==1
        metabolicDistance(:,3)=comDist';
    elseif i==2
        metabolicDistance(:,4)=comDist';
    end
    writetable(cell2table(metabolicDistance),[propertiesFolder filesep 'MetabolicDistance_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
end
writetable(cell2table(metabolicDistance),[propertiesFolder filesep 'MetabolicDistance_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');

f=figure;
scatter(cell2mat(metabolicDistance(2:end,3)),cell2mat(metabolicDistance(2:end,4)),2,'k','filled')
set(gca, 'FontSize', 12)
xlabel('Metabolic distance for uptake/secretion potential')
ylabel('Metabolic distance for reaction presence')
title(['Metabolic distances in ' reconVersion], 'FontSize', 14, 'FontWeight', 'bold')
f.Renderer='painters';
print(['Metabolic_distances_' reconVersion],'-dpng','-r300')

end

