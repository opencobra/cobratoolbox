% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
% Small script that links to major databases.
% In case of changes of these websites I keep this script.
% Stefan G. Thorleifsson March 2011

function webDatabases(db,str,type)
%db - wich database, see options at switch db
%str - ID of metabolite/reaction
%type(optional) - 1 if reaction, 0 for metabolite (only used for the KEGG database. 

if nargin < 3
    type = 0; %metabolite, 1 if reaction
end
%No id

if isempty(str)
    msgbox(['There is no ' db ' ID available for this metabolite / reaction.'],'Help','help');
    return;
end

switch db
    case 'kegg'
        if type == 0
            web(['http://www.genome.jp/dbget-bin/www_bget?cpd:' str],'-browser');%met
        else
            web(['http://www.genome.jp/dbget-bin/www_bget?rn:' str],'-browser');%rxn
        end
    case 'ec'
        str = regexpi(str,'\.','split');
        web(['http://www.chem.qmul.ac.uk/iubmb/enzyme/EC' str{1} '/' str{2} '/' str{3} '/' str{4} '.html'],'-browser');
    case 'pubchem'
        web(['http://pubchem.ncbi.nlm.nih.gov/summary/summary.cgi?sid=' str],'-browser');
    case 'chebi'
        
        if isa(str,'numeric')
            str = num2str(str);
        end
        web(['http://www.ebi.ac.uk/chebi/searchId.do?chebiId=CHEBI:' str],'-browser');
    case 'hmdb'
        web(['http://www.hmdb.ca/metabolites/HMDB' str],'-browser');
    otherwise
     msgbox('unknown source');   
end
