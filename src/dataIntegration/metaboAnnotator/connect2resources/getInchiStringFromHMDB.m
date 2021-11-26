function [inchiString] = getInchiStringFromHMDB(HMDBID)
% This function retrieves the inchiString from HMDB (online) for a given
% HMDB ID.
%
% INPUT
% HMDBID    Human metabolome database (HMDB) ID
%
% OUTPUT
% inchiString   Retrieved inchiString
%
% Ines Thiele, 09/2021
%

% get inchi from HMDB
try
    url=strcat('https://hmdb.ca/metabolites/',HMDBID);
    syst = urlread(url);
    [tok] = split(syst,'InChI=1S');
    tok2= split(tok{2},'INCHI_KEY');
    tok3 = regexprep(tok2{1},'\n\n\&gt; \&lt;','');
    inchiString = ['InChI=1S' tok3];
catch
    inchiString =[];
end
