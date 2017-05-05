function webKeggMapper(id,str)
% Small script that links to kegg mapper.
%
% USAGE:
%
%    webKeggMapper(id,str)
%
% INPUTS:
%    id:    Either 'ec' or 'kegg'
%    str:   ID of themetabolite / reaction
%
% .. Author: - Stefan G. Thorleifsson March 2011
% .. In case of changes of the website  I keep this script.
%
% .. rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% .. Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% .. reconstructing high-quality biochemical networks, Bioinformatics, Accepted.
% .. rbionet@systemsbiology.is

if isempty(str) %No id
    msgbox(['There is no ' id ' ID available for this metabolite/reaction.'],'Help','help');
    return;
end

switch id
    case 'ec'
        web(['http://www.genome.jp/kegg-bin/show_pathway?ec01100+' str],'-browser');
    case 'kegg'
        web(['http://www.genome.jp/kegg-bin/show_pathway?rn01100+' str],'-browser');
    otherwise
        msgbox('unknown source');
end
