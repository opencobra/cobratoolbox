function infoFile = updateAGORATaxonomyFile(version)
% Retrieved up to date taxonomic information for AGORA strains from NCBI
% and saves an updated table with the most recent taxonomic assignments.
%
% USAGE:
%   updateAGORATaxonomyFile(version)
%
% REQUIRED INPUT
% version          Version of AGORA for which the information table should
%                  be updated (allowed inputs: 'AGORA','AGORA2')
%
% OUTPUT
% infoFile       Updated table with up to date taxonomic information
%
% .. Author:
%       - Almut Heinken, 06/2025


if strcmp(version,'AGORA')
    infoFile = readInputTableForPipeline('AGORA_infoFile.xlsx');
elseif strcmp(version,'AGORA2')
    infoFile = readInputTableForPipeline('AGORA2_infoFile.xlsx');
else
    error('Not a valid version of AGORA!')
end

taxCol = find(strcmp(infoFile(1,:),'NCBI Taxonomy ID'));
strain =  find(strcmp(infoFile(1,:),'Strain'));
species =  find(strcmp(infoFile(1,:),'Species'));
genus =  find(strcmp(infoFile(1,:),'Genus'));
family =  find(strcmp(infoFile(1,:),'Family'));
order =  find(strcmp(infoFile(1,:),'Order'));
class =  find(strcmp(infoFile(1,:),'Class'));
phylum =  find(strcmp(infoFile(1,:),'Phylum'));
kingdom =  find(strcmp(infoFile(1,:),'Kingdom'));
taxa = {'strain','species','genus','family','order','class','phylum','kingdom','superkingdom'};
cols = [strain,species,genus,family,order,class,phylum,kingdom,kingdom];

for i=2:size(infoFile,1)
    taxonomy = parseNCBItaxonomy(infoFile{i,taxCol});
    for j=1:length(taxa)
        if isfield(taxonomy,taxa{j})
            infoFile{i,cols(j)} = taxonomy.(taxa{j});
        end
    end
end

% export the updated table
if strcmp(version,'AGORA')
    writetable(cell2table(infoFile),'AGORA_infoFile.xlsx','WriteVariableNames',false);
elseif strcmp(version,'AGORA2')
    writetable(cell2table(infoFile),'AGORA2_infoFile.xlsx','WriteVariableNames',false);
end

end

