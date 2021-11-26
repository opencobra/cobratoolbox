function [metabolite_structure,IDsAdded,IDsSuggested] = parseMetaNetXWebpage(metabolite_structure,startSearch,endSearch)

%% function [metabolite_structure,IDsAdded,IDsSuggested] = parseMetaNetXWebpage(metabolite_structure)
% This function first retrieves MetaNetX IDs based on existing IDs in the
% metabolite_structure (defined in queryFields).  MetaNetX IDs will only be
% added to the metabolite_structure if the  MetaNetX inchiKey and the metabolite_structure inchiKey
% agree (and added to IDsAdded(, otw it will be added to IDsSuggested.
% The function then takes all the MetaNetX IDs can retrieves further IDs to
% be added to the metabolite_structure. Therefore, we first verify the MetaNetX ID in the metabolite_structure by
% comparing the inchiKey in the metabolite_structure with the one from the MetaNetX ID
% if they do not agree the MetaNetX ID, the function tries to find the right ID based on the inchiKey in the metabolite structure. If unsuccesfull,
% the MetaNetX ID is removed from the metabolite_structure and added
% to the IDsSuggested list. Further ID's are only retrieved for verified MetaNetX IDs.
%
% INPUT
% metabolite_structure  metabolite structure
% startSearch           specify where the search should start in the
%                       metabolite structure. Must be numeric (optional, default: all metabolites
%                       in the structure will be search for)
% endSearch             specify where the search should end in the
%                       metabolite structure. Must be numeric (optional, default: all metabolites
%                       in the structure will be search for)
%
% OUTPUT
% metabolite_structure  updated metabolite structure
% IDsAdded              list of addded IDs
% IDsSuggested          list of suggested IDs
%
% Ines Thiele 2020/2021

annotationSource = 'MetaNetX website';
annotationType = 'automatic';
verificationType0 = 'not verified';
verificationType1 = 'verified by inchiKey comparison';

Mets = fieldnames(metabolite_structure);

if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(Mets);
end


queryFields = {'keggId';'seed';'biggId';'cheBIId';'inchiKey'}; %gets all fieldnames for metabolites
mapping ={
    'cheBIId' 'https://www.ebi.ac.uk/chebi/'
    'keggId'    'https://www.kegg.jp/entry'
    'seed'  'https://modelseed.org/biochem/compounds/'
    'biocyc'   'https://metacyc.org/compound?org'
    'inchiKey'  'InChIKey'
    'inchiString'   '\>InChI\>'
    'lipidmaps' 'https://www.lipidmaps.org/data/'
    'biggId'    'http://bigg.ucsd.edu/universal/metabolites/'
    'hmdb'     'https://hmdb.ca/metabolites/'
    'swisslipids'   'https://www.swisslipids.org/#/entity/'
    };

a = 1;
IDsAdded = '';
IDsSuggested = ''; b= 1;

%% first I search MetaNetX for more IDs based on the ID's that I have


for i = startSearch : endSearch
    %if ~isempty(metabolite_structure.(Mets{i}).VMHId) && isempty(find(isnan(metabolite_structure.(Mets{i}).VMHId),1))
    % no MetaNetX ID
    if isempty(metabolite_structure.(Mets{i}).metanetx) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).metanetx),1))
        for j = 1 : length(queryFields)
            if ~isempty(metabolite_structure.(Mets{i}).(queryFields{j})) && isempty(find(isnan(metabolite_structure.(Mets{i}).(queryFields{j})),1))
                %  search for exact term
                try
                    url = strcat('https://www.metanetx.org/cgi-bin/mnxweb/search?query=+',metabolite_structure.(Mets{i}).(queryFields{j}));
                    syst = urlread(url);
                    % parse output
                    if ~contains(syst,'No result found</strong></div><br><h1>Reactions</h1>')
                        
                        startvalue=strfind(syst,'href="/chem_info/');
                        string = syst(startvalue(1):startvalue(1)+100);
                        [tok,rem]=strtok(string,' ');
                        idM = regexprep(tok,'href="/chem_info/','');
                        idM = regexprep(idM,'\W$','');
                        % check that the metaNetX ID has the same
                        % inchiKey as metabolite_structure
                        url = strcat('https://www.metanetx.org/chem_info/',idM);
                        syst = urlread(url);
                        
                        r =  contains(mapping(:,1),'inchiKey');
                        mapping_InchiKey = mapping(r,:);
                        [metabolite_structure,idNew] = getData(metabolite_structure,syst,Mets{i}, mapping_InchiKey);
                        % compare idNew (MetaNetX inchiKey) with
                        % metabolite_structure
                        if ~isempty(metabolite_structure.(Mets{i}).inchiKey)|| ~isempty(find(isnan(metabolite_structure.(Mets{i}).inchiKey),1)) % no inchiKey for metabolite
                            if strcmp(metabolite_structure.(Mets{i}).inchiKey,idNew)
                                metabolite_structure.(Mets{i}).metanetx = idM;
                                metabolite_structure.(Mets{i}).metanetx_source = [annotationSource,':',annotationType,':', verificationType1,':',datestr(now)];
                                IDsAdded{a,1} = Mets{i};
                                IDsAdded{a,2} = 'metanetx';
                                IDsAdded{a,3} = char(idM);
                                IDsAdded{a,4} = 'added based on matching inchiKey';
                                a = a+1;
                            else
                                IDsSuggested{b,1} = Mets{i};
                                IDsSuggested{b,2} =  metabolite_structure.(Mets{i}).inchiKey;
                                IDsSuggested{b,3} = ['metanetx: ' idM];
                                IDsSuggested{b,4} = char(idNew);
                                IDsSuggested{b,5} = ['suggested based on matching ',queryFields{j},' :',metabolite_structure.(Mets{i}).(queryFields{j}), 'but inchiKey mismatch'];
                                b = b + 1;
                            end
                        else
                            IDsSuggested{b,1} = Mets{i};
                            IDsSuggested{b,2} =  metabolite_structure.(Mets{i}).inchiKey;
                            IDsSuggested{b,3} = ['metanetx: ' idM];
                            IDsSuggested{b,4} = char(idNew);
                            IDsSuggested{b,5} =  ['suggested based on matching ',queryFields{j},' ID, but inchiKey missing in metabolite_structure'];
                            b = b + 1;
                        end
                    end
                end
            end
        end
        %   end
    end
end

%% now I search based on all MetaNetX IDs for more
% The function now takes all the MetaNetX IDs can retrieves further IDs to
% be added to the metabolite_structure. Therefore, we first verify the MetaNetX ID in the metabolite_structure by
% comparing the inchiKey in the metabolite_structure with the one from the MetaNetX ID
% if they do not agree the MetaNetX ID, the function tries to find the right ID based on the inchiKey in the metabolite structure. If unsuccesfull,
% the MetaNetX ID is removed from the metabolite_structure and added
% to the IDsSuggested list. Further ID's are only retrieved for verified MetaNetX IDs.
for i = startSearch : endSearch
    %    if ~isempty(metabolite_structure.(Mets{i}).VMHId) && isempty(find(isnan(metabolite_structure.(Mets{i}).VMHId),1))
    
    if(~isempty(metabolite_structure.(Mets{i}).metanetx) && isempty(find(isnan(metabolite_structure.(Mets{i}).metanetx),1)))
        
        try
            url = strcat('https://www.metanetx.org/chem_info/',metabolite_structure.(Mets{i}).metanetx);
            syst = urlread(url);
            % try to verify MetaNetX ID
            r =  contains(mapping(:,1),'inchiKey');
            mapping_InchiKey = mapping(r,:);
            [metabolite_structure,idNew] = getData(metabolite_structure,syst,Mets{i}, mapping_InchiKey);
            if ~isempty(metabolite_structure.(Mets{i}).inchiKey)|| ~isempty(find(isnan(metabolite_structure.(Mets{i}).inchiKey),1)) %  inchiKey for metabolite
                if strcmp(metabolite_structure.(Mets{i}).inchiKey,idNew) % match
                    metabolite_structure.(Mets{i}).metanetx_source = [annotationSource,':',annotationType,':', verificationType1,':',datestr(now)];
                    % get further IDs
                    
                    for k = 1 : size(mapping,1)
                        [metabolite_structure,idNew] = getData(metabolite_structure,syst,Mets{i}, mapping(k,:));
                        if ~isempty(idNew) && isempty(find(isnan(idNew),1))
                            if isempty(metabolite_structure.(Mets{i}).(mapping{k,1})) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).(mapping{k,1})),1))
                                metabolite_structure.(Mets{i}).(mapping{k,1}) = (idNew);
                                metabolite_structure.(Mets{i}).(strcat(mapping{k,1},'_source')) = [annotationSource,':',annotationType,':',verificationType0,':',datestr(now)];
                                IDsAdded{a,1} = Mets{i};
                                IDsAdded{a,2} = mapping{k,1};
                                IDsAdded{a,3} = char(idNew);
                                a = a+1;
                            end
                        end
                    end
                else % mismatch
                    % try to use inchiKey to get new MetaNetX ID
                    
                    if ~isempty(metabolite_structure.(Mets{i}).inchiKey)|| ~isempty(find(isnan(metabolite_structure.(Mets{i}).inchiKey),1)) % no inchiKey for metabolite
                        url = strcat('https://www.metanetx.org/cgi-bin/mnxweb/search?query=+',metabolite_structure.(Mets{i}).inchiKey);
                        syst = urlread(url);
                        % parse output
                        if ~contains(syst,'No result found</strong></div><br><h1>Reactions</h1>')
                            
                            startvalue=strfind(syst,'href="/chem_info/');
                            string = syst(startvalue(1):startvalue(1)+100);
                            [tok,rem]=strtok(string,' ');
                            idM = regexprep(tok,'href="/chem_info/','');
                            idM = regexprep(idM,'\W$','');
                            metabolite_structure.(Mets{i}).metanetx = idM;
                            metabolite_structure.(Mets{i}).metanetx_source = [annotationSource,':',annotationType,':', verificationType1,':',datestr(now)];
                            IDsAdded{a,1} = Mets{i};
                            IDsAdded{a,2} = 'metanetx';
                            IDsAdded{a,3} = char(idM);
                            IDsAdded{a,4} = 'added based on matching inchiKey - old MetaNetX ID was removed';
                            a = a+1;
                        end
                    else
                        
                        IDsSuggested{b,1} = Mets{i};
                        IDsSuggested{b,2} = metabolite_structure.(Mets{i}).inchiKey;
                        IDsSuggested{b,3} = ['metanetx: ',  metabolite_structure.(Mets{i}).metanetx] ;
                        IDsSuggested{b,4} = char(idNew);
                        IDsSuggested{b,5} = ['suggested based on matching ','MetaNetX',' ID, but inchiKey mismatch'];
                        b = b + 1;
                        
                        metabolite_structure.(Mets{i}).metanetx = '';
                        metabolite_structure.(Mets{i}).metanetx_source = '';
                    end
                end
                
            end
        end
        %  end
    end
end


function [metabolite_structure,idNew] = getData(metabolite_structure,syst,met, map)
% this function parses the MetaNetX website and retrieves the respective
% IDs
idNew = '';
try
    startvalue=strfind(syst,map{1,2});
    string = syst(startvalue(1):startvalue(1)+200);
    if (contains(string,'secondary/obsolete') || contains(string,'VMH_'))  && length(string)>1
        string = syst(startvalue(2):startvalue(2)+200);
    end
    if contains(map{1,1},'cheBIId')
        [tok,rem] = strtok(string,' ');
        [tok2,rem2] = strtok(tok,'=');
        idNew = regexprep(rem2,'=','');
        idNew = regexprep(idNew,'\W$','');
    elseif contains(map{1,1},'seed')
        [tok,rem] = strtok(string,'>');
        rem = regexprep(rem,'><','');
        [tok2,rem2] = strtok(rem,'>');
        [tok3,rem3] = strtok(rem2,'<');
        idNew = regexprep(tok3,'>seedM:','');
    elseif contains(map{1,1},'keggId')
        [tok,rem] = strtok(string,'>');
        rem = regexprep(rem,'><','');
        [tok2,rem2] = strtok(rem,'>');
        [tok3,rem3] = strtok(rem2,'<');
        idNew = regexprep(tok3,'>keggC:','');
    elseif contains(map{1,1},'biocyc')
        [tok,rem] = strtok(string,' ');
        [tok2,rem2] = strtok(tok,'=');
        [tok3,rem3] = strtok(rem2,'=');
        idNew = regexprep(rem3,'=','');
        idNew = regexprep(idNew,'\W$','');
        
    elseif contains(map{1,1},'inchiKey')
        string = regexprep(string,'InChIKey</td><td class="inchi">','');
        [tok,rem] = strtok(string,'<');
        idNew = tok;
    elseif contains(map{1,1},'inchiString')
        [tok,rem] = strtok(string,'=');
        [tok,rem] = strtok(rem,'=');
        rem = regexprep(rem,'="inchi">InChI</td><td class="inchi">','');
        idNew = regexprep(rem,'</t','');
    elseif contains(map{1,1},'lipidmaps')
        [tok,rem] = strtok(string,'=');
        [tok,rem] = strtok(rem,' ');
        rem = regexprep(tok,'=','');
        idNew = regexprep(rem,'\W$','');
          elseif contains(map{1,1},'biggId')
        [tok,rem] = strtok(string,' ');
        tok = regexprep(tok,'http://bigg.ucsd.edu/universal/metabolites/','');
        idNew = regexprep(tok,'\W$','');
          elseif contains(map{1,1},'hmdb')
        [tok,rem] = strtok(string,' ');
        tok = regexprep(tok,'https://hmdb.ca/metabolites/','');
        idNew = regexprep(tok,'\W$','');
                elseif contains(map{1,1},'swiss')
        [tok,rem] = strtok(string,' ');
        tok = regexprep(tok,'https://www.swisslipids.org/#/entity/slm:','');
        idNew = regexprep(tok,'/\W$','');
    end
    
end