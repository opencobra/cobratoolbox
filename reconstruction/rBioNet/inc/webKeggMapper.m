% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
% Small script that links to kegg mapper.
% In case of changes of the website  I keep this script.
% Stefan G. Thorleifsson March 2011
function webKeggMapper(id,str)

%No id
if isempty(str)
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
