function [inchiString] = getInchiStringFromHMDB(HMDBID)
% Retrieve the InChIString from HMDB (online) for a given HMDB ID. Returns an
% empty array if the retrieval fails.
%
% USAGE:
%
%    [inchiString] = getInchiStringFromHMDB(HMDBID)
%
% INPUT:
%    HMDBID:         Human metabolome database (HMDB) ID
%
% OUTPUT:
%    inchiString:    retrieved InChIString
%
% .. Author: - Ines Thiele, 09/2021

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
