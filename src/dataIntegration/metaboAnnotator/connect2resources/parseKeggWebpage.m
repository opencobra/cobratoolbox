function [metabolite_structure,IDsAdded] = parseKeggWebpage(metabolite_structure,startSearch,endSearch)


annotationSource = 'Kegg website';
annotationType = 'automatic';


Mets = fieldnames(metabolite_structure);
a = 1;
IDsAdded = '';

if ~exist('endSearch','var')
    endSearch = length(Mets);
end

if ~exist('startSearch','var')
    startSearch = 1;
end

% I am not going to collect pubchemId's as kegg has deposited its own id's
% to pubchem in the past and I prefer the "real" pubchem id's
mapping ={
   'casRegistry'   '<nobr>CAS:'
   'cheBIId' 'https://www.ebi.ac.uk/chebi/'
  %  'pubchemId' 'https://pubchem.ncbi.nlm.nih.gov/'
    'chembl'    'https://www.ebi.ac.uk/chembldb'
   'knapsack'  'http://kanaya.naist.jp/knapsack_jsp'
    };

for i = startSearch : endSearch%size(Mets,1)
    
    if ~isempty(metabolite_structure.(Mets{i}).VMHId) && isempty(find(isnan(metabolite_structure.(Mets{i}).VMHId),1))
        
        if(~isempty(metabolite_structure.(Mets{i}).keggId) && isempty(find(isnan(metabolite_structure.(Mets{i}).keggId),1)))
       
            try
                
                url = strcat('https://www.genome.jp/dbget-bin/www_bget?',metabolite_structure.(Mets{i}).keggId);
                syst = urlread(url);
          
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
            catch
                continue;
            end
        end
    end
end


function [metabolite_structure,idNew] = getData(metabolite_structure,syst,met, map,IDsAdded)
a = size(IDsAdded,1)+1;
idNew = '';
try
    startSearchvalue=strfind(syst,map{1,2});
    string = syst(startSearchvalue(1):startSearchvalue(1)+200);
    
    if contains(map{1,1},'cas')
        string = regexprep(string,'<nobr>CAS:&nbsp;</nobr></td><td>','');
        [tok,rem] = strtok(string,'<');
        idNew = tok;
    elseif contains(map{1,1},'pubchemId')
        [tok,rem] = strtok(string,'=');
        [tok2,rem2] = strtok(rem,'>');
        idNew = regexprep(tok2,'=','');
        idNew = regexprep(idNew,'\W$','');
    elseif contains(map{1,1},'cheBIId')
        [tok,rem] = strtok(string,'=');
        [tok2,rem2] = strtok(rem,'>');
        idNew = regexprep(tok2,'=','');
        idNew = regexprep(idNew,'CHEBI:','');
        idNew = regexprep(idNew,'\W$','');
    elseif contains(map{1,1},'chembl') ||  contains(map{1,1},'knapsack')
        [tok,rem] = strtok(string,'>');
        [tok2,rem2] = strtok(rem,'<');
        idNew = regexprep(tok2,'>','');
        
    end
    
end