function [hmdb,multipleHits]  = retrievePotHitsHMDB(met)
% This function connects to HMDB can searches the metabolite name. The
% first 10 hits will be looked at and the metabolite name will be search
% for in traditional name, IUPAC name, synonyms, and common name. If one or
% more hits are found, the HMDB Ids will be returned.
%
% INPUT
% met   Metabolite name
%
% OUTPUT
% hmdb          One or more HMDB id's. If empty, no hmdb ID could be found.
% multipleHits  This variable indicates whether there are multiple hits.
%
% Ines Thiele, 09/2021

hmdb = '';
% make name fit for internet
met = regexprep(met,'"','');
metInt = ['%22' regexprep(met,' ','+') '%22'];

try
    % avoid that the script fails when the connection is down or times out
    url=strcat(['https://hmdb.ca/unearth/q?utf8=%E2%9C%93&query=' metInt '&searcher=metabolites&button=']);
    syst = urlread(url);
end

multipleHits = 0;

if exist('syst','var')
    syst = regexprep(syst,'\;','');
    syst = regexprep(syst,'&#39','');
    
    if ~contains(syst,'no results')
        
        [H,rem] = split(syst,'href="/metabolites/');
        if length(H) > 20 % only search through the first 10 entries - it could hang the function otw
            max = 20;
        else
            max = length(H);
        end
        for i = 2 : 2: max
            if contains(H{i},'HMDB')
                [tok2,rem] = split(H{i},'>');
                % potential HMDB ID
                potHMDB = regexprep(tok2{1},'"','');
                
                % there seems to be a problem those entries of the HMDB website
                failedhmdbids = {'HMDB0247409, HMDB0004062', 'HMDB0040446', 'HMDB0033968', 'HMDB0004231', 'HMDB004231', 'HMDB0011737', 'HMDB0004062', 'HMDB0012252'};

                if ~any(strcmp(failedhmdbids, potHMDB))
                    % now check whether it is a perfect match
                    clear syst
                    
                    url=strcat('https://hmdb.ca/metabolites/',potHMDB);
                    syst = urlread(url);
                    
                    if exist('syst','var')
                        syst = regexprep(syst,'\;','');
                        syst = regexprep(syst,'&#39','');
                        hit = 0;
                        if contains(lower(syst),lower(met))
                            % check that it is in name or synonym
                            % common name:
                            clear tok*
                            [tok,rem] = split(syst,'Common Name</th>');
                            % sometimes the ping did not work, just move on
                            % instead of dying
                            if length(tok)>1
                                [tok2,rem] = split(tok{2},'</td>');
                                commonName = regexprep(tok2{1},'<td><strong>','');
                                commonName = regexprep(commonName,'</strong>','');
                                commonName = regexprep(commonName,'&#39','');
                                % IUPAC Name
                                clear tok*
                                [tok,rem] = split(syst,'IUPAC Name</th><td>');
                                [tok2,rem] = split(tok{2},'</td>');
                                IUPAC =tok2{1};
                                IUPAC = regexprep(IUPAC,'&#39','');
                                % Synonyms
                                clear tok*
                                [tok,rem] = split(syst,'Synonyms</th>');
                                [tok2,rem]= split(tok{2},'</table>');
                                tmp = regexprep(tok2{1},'<td class="data-table-container"><table class="table-inner"><thead><tr><th class="head-large">Value','');
                                tmp = regexprep(tmp,'<\/th><th>Source<\/th><\/tr><\/thead><tbody><tr><td>','');
                                tmp2 = split(tmp,'</td>');
                                syn = tmp2(1:2:end-1);
                                % remove '
                                syn = regexprep(syn,'\;','');
                                syn = regexprep(syn,'&#39','');
                                syn = regexprep(syn,'<\/tr><tr><td>','');
                                % Traditional Name
                                clear tok*
                                [tok,rem] = split(syst,'Traditional Name</th><td>');
                                [tok2,rem]= split(tok{2},'</td>');
                                tradName = tok2{1};
                                if strcmp(lower(met),lower(commonName))||...
                                        strcmp(lower(met),lower(IUPAC))||...
                                        strcmp(lower(met),lower(tradName))||...
                                        length(find(ismember(lower(syn),lower(met))))
                                    
                                    % check now that synomyms is a full hit
                                    if isempty(hmdb)
                                        hmdb = potHMDB;
                                    else
                                        hmdb = [hmdb ';' potHMDB];
                                        multipleHits = 1;
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