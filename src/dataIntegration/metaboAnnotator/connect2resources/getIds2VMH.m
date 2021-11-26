function [metabolite_structure,IDsAdded] = getIds2VMH(metabolite_structure)


% map Seed metabolites
% file obtained from https://www.pnas.org/highwire/filestream/616377/field_highwire_adjunct_files/0/pnas.1401329111.sd01.xlsx
% for PMID 24927599
% when getting the biggId's the script is checking whether the id's are
% still valid by testing the weblink. Only valid bigg id's will be added

[NUM,TXT,RAW]=xlsread('pnas.1401329111.sd01.xlsx','Compounds');
annotationSource = 'Based on PMID 24927599 mapping';
annotationType = 'automatic';

% 1. seed to kegg
Mets = fieldnames(metabolite_structure);

matching = {
    % id    col in input file
    'seed'  '3'
    'keggId'    '5'
    'biocyc'    '6'
    'biggId'    '18'
    };

a = 1;
IDsAdded = '';

for i = 1 : length(Mets)
    % has seed id
    
    for j = 1 :size(matching,1)
        if ~isempty(metabolite_structure.(Mets{i}).(matching{j,1})) && isempty(find(isnan(metabolite_structure.(Mets{i}).(matching{j,1}))))
            i
            try
                match = strmatch(metabolite_structure.(Mets{i}).(matching{j,1}),RAW(:,str2num(matching{j,2})),'exact');
                if ~isempty(match)
                    match = match(1); % use only first match
                    for k = 1 :size(matching,1)
                        if j~=k % don't look up same id
                            % if a kegg Id exists in input data - 5th col
                            if ~isempty(RAW(match,str2num(matching{k,2}))) && isempty(find(isnan(RAW{match,str2num(matching{k,2})}),1))
                                % now assign Kegg id if not present in structure
                                if isempty(metabolite_structure.(Mets{i}).(matching{k,1})) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).(matching{k,1})),1))
                                    %if multiple ID's then only take the first one
                                    if contains(RAW(match,str2num(matching{k,2})),',')
                                        string = strtok(RAW{match,str2num(matching{k,2})},',');
                                    else
                                        string = RAW{match,str2num(matching{k,2})};
                                    end
                                    if contains(matching{k,1},'biggId')
                                        % these are old bigg id's
                                        % so check whether biggId is still working
                                        url = strcat('http://bigg.ucsd.edu/models/universal/metabolites/',string);
                                        [syst,success] = urlread(url);
                                        if ~success
                                            % replaced - with _
                                            if contains(string,'-')
                                                tmp = regexprep(string,'-','_');
                                                % it is not clear in which cases bigg has
                                                url = strcat('http://bigg.ucsd.edu/models/universal/metabolites/',tmp);
                                                [syst,success] = urlread(url);
                                                if success
                                                    string = regexprep(string,'-','_');
                                                else
                                                    %try __
                                                    tmp = regexprep(string,'-','__');
                                                    % it is not clear in which cases bigg has
                                                    url = strcat('http://bigg.ucsd.edu/models/universal/metabolites/',tmp);
                                                    [syst,success] = urlread(url);
                                                    if success
                                                        string = regexprep(string,'-','__');
                                                    else
                                                        string = '';
                                                    end
                                                end
                                            else
                                                % remove entry
                                                string = '';
                                                
                                            end
                                        end
                                        
                                    end
                                    if ~isempty(string)
                                        metabolite_structure.(Mets{i}).(matching{k,1}) = string;
                                        metabolite_structure.(Mets{i}).([matching{k,1},'_source']) = [annotationSource,':',annotationType,':',datestr(now)];
                                        IDsAdded{a,1} = Mets{i};
                                        IDsAdded{a,2} = (matching{k,1});
                                        IDsAdded{a,3} =  metabolite_structure.(Mets{i}).(matching{k,1});
                                        a = a + 1;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
