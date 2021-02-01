function taxonomy = parseNCBItaxonomy(NCBI)
% Grabs taxonomic lineage from NCBI using the NCBI ID
%
% INPUT
% NCBI          NCBI ID (e.g., 511145)
%
% OUTPUT
% taxonomy      structure containing the taxonomic lineage
%
% Stefania Magnusdottir, Nov 2017

if iscell(NCBI)
    NCBI = NCBI{1};
end
if isnumeric(NCBI)
    NCBI = num2str(NCBI);
end

hmtlString = urlread(['https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=', NCBI]);
lineage = {
    'superkingdom'
    'phylum'
    'class'
    'order'
    'family'
    'genus'
    'species'};

% extract information from html string and fill in data (different parsing
% types)

% type 1
taxonomy = struct();
for i = 1:length(lineage)
    n = regexp(hmtlString, ['ALT="', lineage{i}, '">([^<]+)'], 'tokens');
    if ~isempty(n)
        n = [n{:}];
        if ~isempty(n{1, 1})
            taxonomy.(lineage{i}) = n{1, 1};
        else
            taxonomy.(lineage{i}) = '';
        end
    end
end

% type 2
taxFields = fieldnames(taxonomy);
if isempty(taxFields)
    taxonomy = struct();
    for i = 1:length(lineage)
        n = regexp(hmtlString, ['TITLE="', lineage{i}, '">([^<]+)'], 'tokens');
        if ~isempty(n)
            n = [n{:}];
            if ~isempty(n{1, 1})
                taxonomy.(lineage{i}) = n{1, 1};
            else
                taxonomy.(lineage{i}) = '';
            end
        end
    end
end

% extract strain from title
n = regexp(hmtlString, '<TITLE>Taxonomy browser (([^)]+)', 'tokens');
if isempty(n)  % try other type
    n = regexp(hmtlString, '<title>Taxonomy browser (([^)]+)', 'tokens');
end
if ~isempty(n)
    n = [n{:}];
    if ~isempty(n{1, 1})
        taxonomy.strain = n{1, 1};
    else
        taxonomy.strain = '';
    end
end
