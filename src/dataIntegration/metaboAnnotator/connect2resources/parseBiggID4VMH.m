function [metabolite_structure,IDsAdded] = parseBiggID4VMH(metabolite_structure,startSearch,endSearch,grebMoreIDs)
% the problem is that by chance Bigg and VMH could have the same ID but for
% different metabolites -- I do not do any additional checks right now
% which is dangerous (hence I do not greb more ID's by default)


if ~exist('grebMoreIDs','var')
    grebMoreIDs = 0;
end

% try to guess bigg ID from VMH ID
Mets = fieldnames(metabolite_structure);
if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(Mets);
end



annotationSource = 'Bigg website (matching)';
annotationType = 'automatic';

a = 1;
IDsAdded = '';

mapping = {
    'inchiKey'     'https://identifiers.org/inchikey/'
    'hmdb'  'http://identifiers.org/hmdb'
    'metanetx'  'http://identifiers.org/metanetx.chemical'
    'keggId'    'http://identifiers.org/kegg.compound/'
    'biocyc'    'http://identifiers.org/biocyc/'
    'reactome'  'http://identifiers.org/reactome/' % for the moment I greb only the first entry
    'cheBIId'   'http://identifiers.org/chebi/'
    };
for i = startSearch : endSearch
    
    %get VMHId
    MetsID= metabolite_structure.(Mets{i}).VMHId;
    % try if a valid website exists
    try
        
        url = strcat('http://bigg.ucsd.edu/universal/metabolites/',MetsID);
        [syst,success] = urlread(url);
        if ~success %no entry found
            MetsID = regexprep(MetsID,'_','__');
            url  = strcat('http://bigg.ucsd.edu/universal/metabolites/',MetsID);
            [syst,success] = urlread(url);
        end
        
        if success
            metabolite_structure.(Mets{i}).biggId = MetsID;
            metabolite_structure.(Mets{i}).biggId_source = [annotationSource,':',annotationType,':',datestr(now)];
            if  grebMoreIDs == 1
                for k = 1 : size(mapping,1)
                    [metabolite_structure,idNew] = getData(metabolite_structure,syst,Mets{i}, mapping(k,:),IDsAdded);
                    if ~isempty(idNew) && isempty(find(isnan(idNew),1))
                        if isempty(metabolite_structure.(Mets{i}).(mapping{k,1})) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).(mapping{k,1})),1))
                            metabolite_structure.(Mets{i}).(mapping{k,1}) = (idNew);
                            metabolite_structure.(Mets{i}).(strcat(mapping{k,1},'_source')) = [annotationSource,':',annotationType,':',datestr(now)];
                            IDsAdded{a,1} = Mets{i};
                            IDsAdded{a,2} = mapping{k,1};
                            IDsAdded{a,3} = char(idNew);
                            a = a+1;
                        end
                    end
                end
            end
            
        end
    catch
        continue;
    end
end


function [metabolite_structure,idNew] = getData(metabolite_structure,syst,met, map,IDsAdded)
a = size(IDsAdded,1)+1;
idNew = '';
try
    startvalue=strfind(syst,map{1,2});
    string = syst(startvalue(1):startvalue(1)+200);
    [tok,rem] = strtok(string,'>');
    [tok2,rem2] = strtok(rem,'<');
    idNew = regexprep(tok2,'>','');
    if contains(idNew,'META:')
        idNew = regexprep(idNew,'META:','');
    end
    if contains(idNew,'CHEBI:')
        idNew = regexprep(idNew,'CHEBI:','');
    end
end