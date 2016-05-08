function [metCHEBI,metHMDB,metKEGG,metPubChem,metInChI] = parseSBMLAnnotationField(annotationField)
%parseSBMLAnnotationField Parse the annotation field of an SBML file to extract
%metabolite information associations
%
% [genes,rule] = parseSBMLAnnotationField(annotationField)
%
% Ines Thiele 1/27/10 Added new fields
% Handle different notes fields
%
% Longfei Mao 29/02/16 added more fields
%

metPubChem = '';
metCHEBI = '';
metKEGG = '';
metPubChem = '';
metInChI='';
metHMDB='';


[tmp,fieldList] = regexp(annotationField,'<rdf:li rdf:resource="urn:miriam:(\w+).*?"/>','tokens','match');

%fieldTmp = regexp(fieldList{i},['<' tag '>(.*)</' tag '>'],'tokens');
for i = 1:length(fieldList)
    fieldTmp = regexp(fieldList{i},['<rdf:li rdf:resource="urn:miriam:(.*)"/>'],'tokens');
    fieldStr = fieldTmp{1}{1};
    if (regexp(fieldStr,'obo.chebi'))
        metCHEBI = strrep(fieldStr,'obo.chebi:CHEBI%','');
    elseif (regexp(fieldStr,'kegg.compound'))
        metKEGG = strrep(fieldStr,'kegg.compound:','');
    elseif (regexp(fieldStr,'pubchem.substance'))
        metPubChem = strrep(fieldStr,'pubchem.substance:','');
    end
end

% get InChI string
fieldTmp = regexp(annotationField,'<in:inchi xmlns:in="http://biomodels.net/inchi" metaid="(.*?)">(.*?)</in:inchi>','tokens');
if ~isempty(fieldTmp)
    fieldStr = fieldTmp{1}{2};
    if (regexp(fieldStr,'InChI'))
        metInChI = strrep(fieldStr,'InChI=','');
    end
end

%%%  new code
if isempty(fieldList) % if the keywords do not exist anymore
    [tmp,fieldList] = regexp(annotationField,'<rdf:li rdf:resource="http://identifiers.org/(\w+).*?"/>','tokens','match');
    % temp contains: %{'chebi','hmdb','pubchem','kegg','inchi'}
    %fieldTmp = regexp(fieldList{i},['<' tag '>(.*)</' tag '>'],'tokens');
    % % for i = 1:length(fieldList)
    % %     fieldTmp = regexp(fieldList{i},['<rdf:li rdf:resource="urn:miriam:(.*)"/>'],'tokens');
    % %     fieldStr = fieldTmp{1}{1};
    % %     if (regexp(fieldStr,'obo.chebi'))
    % %         metCHEBI = strrep(fieldStr,'obo.chebi:CHEBI%','');
    % %     elseif (regexp(fieldStr,'kegg.compound'))
    % %         metKEGG = strrep(fieldStr,'kegg.compound:','');
    % %     elseif (regexp(fieldStr,'pubchem.substance'))
    % %         metPubChem = strrep(fieldStr,'pubchem.substance:','');
    % %     end
    % % end
    
    for i = 1:length(fieldList)
        fieldTmp = regexp(fieldList{i},['<rdf:li rdf:resource="http://identifiers.org/(.*)"/>'],'tokens');
        fieldStr = fieldTmp{1}{1};    % 'chebi/CHEBI:'
        if (regexp(fieldStr,'chebi/CHEBI:'))
            metCHEBI = strrep(fieldStr,'chebi/CHEBI:','');
       % elseif (regexp(fieldStr,'biocyc/'))
            
        elseif (regexp(fieldStr,'chebi/'))
            metCHEBI = strrep(fieldStr,'chebi/','');
            
%         elseif (regexp(fieldStr,'3dmet/'))
%             
%         elseif (regexp(fieldStr,'biocyc/'))

        elseif (regexp(fieldStr,'hmdb/'))
            metHMDB = strrep(fieldStr,'hmdb/','');
        elseif (regexp(fieldStr,'pubchem.substance/'))
            metPubChem = strrep(fieldStr,'pubchem.substance/','');
            
        elseif (regexp(fieldStr,'pubchem.compound/'))
            metPubChem = strrep(fieldStr,'pubchem.compound/','');
            
        elseif (regexp(fieldStr,'kegg.compound/'))
            metKEGG = strrep(fieldStr,'kegg.compound/','');
        elseif (regexp(fieldStr,'inchi/'))
            metInChI = strrep(fieldStr,'inchi/','');
        end
        
%         otherAnnotation.(tmp{1})=fieldStr
    end
    
end



