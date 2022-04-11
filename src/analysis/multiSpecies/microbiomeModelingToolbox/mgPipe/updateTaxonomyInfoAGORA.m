function updateTaxonomyInfoAGORA
% This function retrieves the newest taxonomy information for each AGORA
% strain from NCBI Taxonomy to facilitate mapping taxonomic assignments
% from metagenomic sequencing data to AGORA. An updated version of the
% AGORA information table is saved in spreadsheet format.
%
% .. Author: Almut Heinken, 04/2022

% AGORA information table
infoFile = readInputTableForPipeline('AGORA_infoFile.xlsx');

ncbiCol = find(strcmp(infoFile(1,:),'NCBI Taxonomy ID'));
strainCol = find(strcmp(infoFile(1,:),'Strain'));
speciesCol = find(strcmp(infoFile(1,:),'Species'));
genusCol = find(strcmp(infoFile(1,:),'Genus'));
familyCol = find(strcmp(infoFile(1,:),'Family'));
orderCol = find(strcmp(infoFile(1,:),'Order'));
classCol = find(strcmp(infoFile(1,:),'Class'));
phylumCol = find(strcmp(infoFile(1,:),'Phylum'));
kingdomCol = find(strcmp(infoFile(1,:),'Kingdom'));

taxa = {
    strainCol 'strain'
    speciesCol 'species'
    genusCol 'genus'
    familyCol 'family'
    orderCol 'order'
    classCol 'class'
    phylumCol 'phylum'
    kingdomCol 'superkingdom'
    };

for i=2:size(infoFile,1)
    i
    taxonomy = parseNCBItaxonomy(infoFile{i,ncbiCol});
    for j=1:size(taxa,1)
        if isfield(taxonomy,taxa{j,2})
            if j==1
                if ~strcmp(taxonomy.('strain'),'root')
                    if isfield(taxonomy,'species')
                        if ~strcmp(taxonomy.('strain'),taxonomy.('species'))
                            if ~isempty(taxonomy.(taxa{j,2}))
                                infoFile{i,taxa{j,1}} = taxonomy.(taxa{j,2});
                            end
                        end
                    end
                end
            else
                if ~isempty(taxonomy.(taxa{j,2}))
                    infoFile{i,taxa{j,1}} = taxonomy.(taxa{j,2});
                end
            end
        end
    end
end
writetable(cell2table(infoFile),'AGORA_infoFile.xlsx','FileType','spreadsheet','writeVariableNames',false);

% AGORA2 information table
infoFile = readInputTableForPipeline('AGORA2_infoFile.xlsx');

ncbiCol = find(strcmp(infoFile(1,:),'NCBI Taxonomy ID'));
strainCol = find(strcmp(infoFile(1,:),'Strain'));
speciesCol = find(strcmp(infoFile(1,:),'Species'));
genusCol = find(strcmp(infoFile(1,:),'Genus'));
familyCol = find(strcmp(infoFile(1,:),'Family'));
orderCol = find(strcmp(infoFile(1,:),'Order'));
classCol = find(strcmp(infoFile(1,:),'Class'));
phylumCol = find(strcmp(infoFile(1,:),'Phylum'));
kingdomCol = find(strcmp(infoFile(1,:),'Kingdom'));

taxa = {
    strainCol 'strain'
    speciesCol 'species'
    genusCol 'genus'
    familyCol 'family'
    orderCol 'order'
    classCol 'class'
    phylumCol 'phylum'
    kingdomCol 'superkingdom'
    };

for i=2:size(infoFile,1)
    i
    taxonomy = parseNCBItaxonomy(infoFile{i,ncbiCol});
    for j=1:size(taxa,1)
        if isfield(taxonomy,taxa{j,2})
            if j==1
                if ~strcmp(taxonomy.('strain'),'root')
                    if isfield(taxonomy,'species')
                        if ~strcmp(taxonomy.('strain'),taxonomy.('species'))
                            if ~isempty(taxonomy.(taxa{j,2}))
                                infoFile{i,taxa{j,1}} = taxonomy.(taxa{j,2});
                            end
                        end
                    end
                end
            else
                if ~isempty(taxonomy.(taxa{j,2}))
                    infoFile{i,taxa{j,1}} = taxonomy.(taxa{j,2});
                end
            end
        end
    end
end
writetable(cell2table(infoFile),'AGORA2_infoFile.xlsx','FileType','spreadsheet','writeVariableNames',false );

end
