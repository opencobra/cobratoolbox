function [metabolite_structure,IDsAdded] = parseFDAsisWebpage(metabolite_structure,startSearch,endSearch)
% uses unii IDs to parse

annotationSource = 'FDAsis website';
annotationType = 'automatic';


Mets = fieldnames(metabolite_structure);
if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(Mets);
end


a = 1;
IDsAdded = '';

mapping ={
    'pubchemId' 'https://pubchem.ncbi.nlm.nih.gov/compound'
    };

for i = startSearch : endSearch
    clear syst
    if ~isempty(metabolite_structure.(Mets{i}).VMHId) && isempty(find(isnan(metabolite_structure.(Mets{i}).VMHId),1))
        
        if(~isempty(metabolite_structure.(Mets{i}).unii) && isempty(find(isnan(metabolite_structure.(Mets{i}).unii),1)))
            try
                url = strcat('https://fdasis.nlm.nih.gov/srs/unii/',metabolite_structure.(Mets{i}).unii);
                syst = urlread(url);
            catch
                continue;
            end
            if exist(syst)
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
    elseif (~isempty(metabolite_structure.(Mets{i}).inchiKey) && isempty(find(isnan(metabolite_structure.(Mets{i}).inchiKey),1)))
        % https://fdasis.nlm.nih.gov/srs/auto/nmlmacjwhphkgr-ncoidobvsa-n
        try
            url = strcat('https://fdasis.nlm.nih.gov/srs/auto/',metabolite_structure.(Mets{i}).inchiKey);
            syst = urlread(url);
        catch
            continue;
        end
        if exist(syst)
            if contains(syst,'1 result for ')
                tok = split(syst,'<td class="label">UNII:</td>');
                tok2 = split(tok{2},'colspan="2">');
                tok3 = split(tok2{2},'</td>');
                unii = tok3{1}
                metabolite_structure.(Mets{i}).unii = unii;
                metabolite_structure.(Mets{i}).unii_source =[annotationSource,':',annotationType,':',datestr(now)];
                IDsAdded{a,1} = Mets{i};
                IDsAdded{a,2} = 'unii';
                IDsAdded{a,3} = unii;
                a = a+1;
            end
        end
    end
end



function [metabolite_structure,idNew] = getData(metabolite_structure,syst,met, map,IDsAdded)
a = size(IDsAdded,1)+1;
idNew = '';
try
    startvalue=strfind(syst,map{1,2});
    string = syst(startvalue(1):startvalue(1)+200);
    
    [tok,rem] = strtok(string,' ');
    idNew = regexprep(tok,'https://pubchem.ncbi.nlm.nih.gov/compound/','');
    idNew = regexprep(idNew,'\W$','');
    
end