function infoFile = createInfoFileDEMETER(taxIDs,strainNames)
% Creates a taxonomy table that can be used as input for DEMETER from a
% list of NCBI Taxonomy IDs. The taxonomy IDs can be on any taxonomical
% level but should be on the strain level to generate a unique model ID.
% If this is not the case, a list of unique and custom gene names each
% corresponding to each taxonomy ID can be provided to serve as strain
% identifiers.
%
% USAGE:
%   createInfoFileDEMETER(taxIDs)
%
% REQUIRED INPUT
% taxIDs         Vector or cell array of numerics that represent valid NCBI
%                Taxonomy IDs.
%
% OPTIONAL INPUT
% % strainNames  List of custom gene names to be used a model IDs
%
% OUTPUT
% infoFile       Table with taxonomic information, gram staining, and
%                oxygen requirement for each strain
%
% .. Author:
%       - Almut Heinken, 06/2025

if ~isnumeric(taxIDs) && ~isnumeric(cell2mat(taxIDs))
    error('Input for taxIDs is not valid!')
end

if nargin >1
    if length(taxIDs) ~= length(strainNames)
        error('Numbers of taxonomy IDs and gene names do not match!')
    end
end

global CBTDIR
% find the folder with information that was collected for DEMETER
demeterInputFolder = [CBTDIR filesep 'papers' filesep '2021_demeter' filesep 'input'];
% Get taxonomy information on AGORA2 that will serve to inform new
% organisms
agoraInfoFile = readInputTableForPipeline([demeterInputFolder filesep 'AGORA2_infoFile.xlsx']);

% start creation of the table
infoFile = {'Model_ID','Strain','Species','Genus','Family','Order','Class','Phylum','Kingdom','NCBI Taxonomy ID','Gram Staining','Oxygen Requirement'};

%% fill out the table with taxonomic information
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

infoFile(2:length(taxIDs)+1,taxCol) = taxIDs;
if nargin >1
    % use provided gene names as strain identifiers
    infoFile(2:length(strainNames)+1,strain) = strainNames;
end

for i=2:size(infoFile,1)
    taxonomy = parseNCBItaxonomy(infoFile{i,taxCol});
    for j=1:length(taxa)
        if isfield(taxonomy,taxa{j})
            % do not overwrite gene names if already present
            if isempty(infoFile{i,cols(j)})
                infoFile{i,cols(j)} = taxonomy.(taxa{j});
            end
        end
    end
    % create model ID
    infoFile{i,1} = adaptDraftModelID(infoFile{i,cols(1)});
end

%% propagate gram staining information
gramCol=find(strcmp(infoFile(1,:),'Gram Staining'));
if isempty(gramCol)
    infoFile{1,size(infoFile,2)+1}='Gram Staining';
    gramCol=find(strcmp(infoFile(1,:),'Gram Staining'));
end
taxa={'Species','Genus','Family','Order','Class','Phylum'};

agoraGramCol=find(strcmp(agoraInfoFile(1,:),'Gram Staining'));

for i=2:size(infoFile,1)
    for j=1:length(taxa)
        if ~isempty(find(strcmp(infoFile(1,:),taxa{j})))
            taxon=infoFile{i,find(strcmp(infoFile(1,:),taxa{j}))};
            
            taxCol=find(strcmp(agoraInfoFile(1,:),taxa{j}));
            taxRow=find(strcmp(agoraInfoFile(:,taxCol),taxon));
            if ~isempty(taxRow)
                infoFile{i,gramCol}=agoraInfoFile{taxRow,agoraGramCol};
                break
            end
        end
    end
end

%% propagate oxygen requirement
o2Col=find(strcmp(infoFile(1,:),'Oxygen Requirement'));
if isempty(o2Col)
    infoFile{1,size(infoFile,2)+1}='Oxygen Requirement';
    o2Col=find(strcmp(infoFile(1,:),'Oxygen Requirement'));
end
taxa={'Species','Genus','Family','Order','Class','Phylum'};

agoraO2Col=find(strcmp(agoraInfoFile(1,:),'Oxygen Requirement'));

for i=2:size(infoFile,1)
    for j=1:length(taxa)
        if ~isempty(find(strcmp(infoFile(1,:),taxa{j})))
            taxon=infoFile{i,find(strcmp(infoFile(1,:),taxa{j}))};
            
            taxCol=find(strcmp(agoraInfoFile(1,:),taxa{j}));
            taxRow=find(strcmp(agoraInfoFile(:,taxCol),taxon));
            if ~isempty(taxRow)
                infoFile{i,o2Col}=agoraInfoFile{taxRow,agoraO2Col};
                break
            end
        end
    end
end

% add genome links to the info file and get assemblies
websave('assembly_summary_refseq.txt','https://ftp.ncbi.nlm.nih.gov/genomes/refseq/assembly_summary_refseq.txt')

refseq_db = readInputTableForPipeline('assembly_summary_refseq.txt');
taxCol = find(strcmp(refseq_db(1,:),'taxid'));
linkCol = find(strcmp(refseq_db(1,:),'ftp_path'));

% retrieve corresponding genomes
infoFile{1,13} = 'NCBI_Genome_Link';
for i=2:size(refseq_db,1)
    refseq_db{i,taxCol} = num2str(refseq_db{i,taxCol});
end
sp_col = find(strcmp(refseq_db(1,:),'organism_name'));
strain_col = find(strcmp(refseq_db(1,:),'infraspecific_name'));
for i=2:size(infoFile,1)
    % find the taxon in RefSeq database
    findTax = find(strcmp(refseq_db(:,taxCol),num2str(infoFile{i,10})));
    % exclude unknown strains
    findTax(strcmp(refseq_db(findTax,strain_col),'na'))=[];
    if ~isempty(findTax)
        % retrieve strain identifier
        if ~contains(refseq_db{findTax(1),sp_col},strrep(refseq_db{findTax(1),strain_col},'strain=',''))
            strain = [refseq_db{findTax(1),sp_col} ' ' strrep(refseq_db{findTax(1),strain_col},'strain=','')];
            infoFile{i,cols(1)} = strain;
        else
            infoFile{i,cols(1)} = refseq_db{findTax(1),sp_col};
        end
        % construct the download link for the genome
        ftp_link = refseq_db{findTax(1),linkCol};
        gl = strsplit(ftp_link,'/GCF_');
        dl = [gl{1} '/GCF_' gl{2} '/GCF_' gl{2} '_genomic.fna.gz'];
        infoFile{i,13} = dl;
        % recreate model IDs
        infoFile{i,1} = adaptDraftModelID(infoFile{i,cols(1)});
        % rename genome to strain name for simplicity
        websave(['GCF_' gl{2} '_genomic.fna.gz'],dl)
        movefile(['GCF_' gl{2} '_genomic.fna.gz'],[infoFile{i,1} '.fna.gz'])
        % extract genome
        gunzip([infoFile{i,1} '.fna.gz'])
        delete([infoFile{i,1} '.fna.gz'])
    end
end

% export the created table
writetable(cell2table(infoFile),'DEMETER_infoFile.xlsx','WriteVariableNames',false);

end