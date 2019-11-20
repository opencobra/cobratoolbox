% The COBRAToolbox: testTranslateMetagenome2AGORAn.m
%
% Purpose:
%     - tests the basic functionality of translateMetagenome2AGORA
%
% Authors:
%     - Almut Heinken - March 2019
%
% Ensure that the organisms in the input file were correctly translated.
% This is the case if all organisms in the output file correspond to an
% AGORA strain model or AGORA pan-model.
% Note that this test cannot tell if the biological identity of the
% translated organisms is correct as this requires manual inspection.
% Moreover, input files with abundance data from other source may fail due
% to differences in formatting and nomenclature.

% Read in the info file with all AGORA strains and taxa
[~, infoFile, ~] = xlsread('AGORA_infoFile.xlsx');

% Download an example file with abundance data from EMBL-EBI
system('curl -O https://www.ebi.ac.uk/metagenomics/api/v1/studies/MGYS00001248/pipelines/3.0/file/SRP065497_taxonomy_abundances_v3.0.tsv')

% Test the output file on different taxonomical levels
% Note: On phylum and class level, some samples sum up to zero due to too
% few corresponding data points in the input file. Thus, these taxon levels
% cannot be tested.
taxLevels={
    'Species'
    'Genus'
    'Family'
    'Order'
    };

for t=1:size(taxLevels,1)
    % Define the taxon level of the input file
    orgList=unique(infoFile(2:end,find(strcmp(taxLevels{t,1},infoFile(1,:)))));
    orgList(strncmp('unclassified', orgList, 12)) = [];
    [translatedAbundances,normalizedAbundances,unmappedRows]=translateMetagenome2AGORA('SRP065497_taxonomy_abundances_v3.0.tsv',taxLevels{t,1});
    % Verify that the output file is not empty
    assert(size(translatedAbundances,1)>1)
    
    if size(translatedAbundances,1)>1
        translatedOrgs=translatedAbundances(2:end,1);
        translatedOrgs=strrep(translatedOrgs,'pan','');
        translatedOrgs=strrep(translatedOrgs,'_',' ');
        
        % Find the overlap between translated organisms and AGORA organisms
        C = intersect(translatedOrgs,orgList);
        
        % Verify that all output organisms overlap with AGORA organisms
        assert(length(translatedOrgs) == length(C))
    end
    
    % Verify that the relative abundances for each sample sum up to 1
    
    for i=2:size(normalizedAbundances,2)
        assert(sum(str2double(normalizedAbundances(2:end,i)))-1 < 0.0001)
    end
end

% output a success message
fprintf('Done.\n');