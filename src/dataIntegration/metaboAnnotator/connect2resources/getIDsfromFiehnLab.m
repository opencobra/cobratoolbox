function [metabolite_structure,IDsAdded] = getIDsfromFiehnLab(metabolite_structure, sourceId,targetId,startSearch,endSearch)


% connect to Fiehn lab (associated paper:
% https://academic.oup.com/bioinformatics/article/26/20/2647/194184_
% url *from* / *to* / query term
% e.g., http://cts.fiehnlab.ucdavis.edu/service/convert/kegg/inchikey/C00234


    mets = fieldnames(metabolite_structure);

if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(Mets);
end

annotationSource = 'Fiehn lab';
annotationType = 'automatic';

% translation key between metabolite field name and Fiehnlab naming

translation = {'keggId' 'kegg'
    'inchiKey'  'inchikey'
    'bindingdb' 'bindingdb'
    'drugbank'  'drugbank'
    'biocyc'    'biocyc'
    'chemspider'    'chemspider'
    'casRegistry'   'cas'
    'pubChemId' 'PubChem%20CID'
    'hmdb'  'Human%20Metabolome%20Database'
    'cheBIId'   'chebi'
    'inchiString'   'inchi%20code'
    'lipidmaps' 'lipidmaps'
    'epa_id'    'epa%20dsstox'
    };


a = 1;
IDsAdded = '';
for i = startSearch : endSearch
    fieldIn = strmatch(sourceId,translation(:,1),'exact');
    lookUpTerm = metabolite_structure.(mets{i}).(sourceId);
    fieldOut = strmatch(targetId,translation(:,1),'exact');
    if ~isfield(metabolite_structure.(mets{i}),targetId)
        metabolite_structure.(mets{i}).(targetId) = NaN;
    end
    
    if isempty(find(isnan(metabolite_structure.(mets{i}).(sourceId)))) && ~isempty(metabolite_structure.(mets{i}).(sourceId))
        if ~isempty(find(isnan(metabolite_structure.(mets{i}).(targetId)))) || isempty(metabolite_structure.(mets{i}).(targetId))
            try
                if strcmp(translation{fieldIn,1},'hmdb')
                    if isempty(strfind('HMDB0',lookUpTerm))
                        lookUpTerm = regexprep(lookUpTerm,'HMDB','HMDB00');
                    elseif isempty(strfind('HMDB000',lookUpTerm))
                        lookUpTerm = regexprep(lookUpTerm,'HMDB0','HMDB000');
                    end
                end
                    url = strcat('http://cts.fiehnlab.ucdavis.edu/service/convert/',translation{fieldIn,2},'/',translation{fieldOut,2},'/',lookUpTerm);
                    syst = urlread(url);
                    result=split(syst,'"');
                    if length(result)>16
                        output = result(16);
                        metabolite_structure.(mets{i}).(targetId) = char(output);
                        metabolite_structure.(mets{i}).([targetId '_source']) = [annotationSource,':',annotationType,':',datestr(now)];
                        
                        IDsAdded{a,1} = mets{i};
                        IDsAdded{a,2} = targetId;
                        IDsAdded{a,3} = char(output);
                        
                        a = a + 1;
                    end
                end
            end
    end
end