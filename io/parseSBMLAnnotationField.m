function [metCHEBI,metKEGG,metPubChem,metInChI] = ...
        parseSBMLAnnotationField(annotationField)
    % parseSBMLAnnotationField Parse the annotation field of an SBML file
    % to extract metabolite information associations
    %
    % [genes,rule] = parseSBMLAnnotationField(annotationField)

    % Ines Thiele 1/27/10 Added new fields
    % Ben Heavner 7/8/2013 Added cell array functionality and
    % identifiers.org URL support
    
    % TODO: generalize for reaction annotation info too. Hopefully modify
    % for SBML FBC package support soon.

    metPubChem = '';
    metCHEBI = '';
    metKEGG = '';
    metInChI='';
    
    if ischar(annotationField) %if a string, use older code
        
        [~,fieldList] = regexp(annotationField, ...
            '<rdf:li rdf:resource="urn:miriam:(\w+).*?"/>', 'tokens', ...
            'match');

        if isempty(fieldList) % look for identifiers.org URL if no miriam
            string = ['<rdf:li rdf:resource="http://identifiers.org/' ...
                '(\w+).*?"/>'];
            [~,fieldList] = regexp(annotationField, string, 'tokens', ...
                'match');
        end

        %fieldTmp = regexp(fieldList{i},['<' tag '>(.*)</' tag '>'], ...
        %    'tokens');
        for i = 1:length(fieldList)
            fieldTmp = regexp(fieldList{i}, ...
                ['<rdf:li rdf:resource="urn:miriam:(.*)"/>'], 'tokens');
            
            if isempty(fieldTmp)% look for identifiers.org URL if no miriam
                string = ['<rdf:li rdf:resource="http://identifiers' ...
                    '.org/(.*)"/>'];
                fieldTmp = regexp(fieldList{i}, string, 'tokens');
            end

            fieldStr = fieldTmp{1}{1};
            if (regexp(fieldStr, 'obo.chebi'))
                metCHEBI = strrep(fieldStr, 'obo.chebi:CHEBI%', '');
            elseif (regexp(fieldStr, 'chebi/'))
                metCHEBI = strrep(fieldStr, 'chebi/CHEBI:', '');            
            elseif (regexp(fieldStr, 'kegg.compound:'))
                metKEGG = strrep(fieldStr, 'kegg.compound:', '');
            elseif (regexp(fieldStr, 'kegg.compound/'))
                metKEGG = strrep(fieldStr, 'kegg.compound/', '');
            elseif (regexp(fieldStr, 'pubchem.substance'))
                metPubChem = strrep(fieldStr, 'pubchem.substance:', '');
            elseif (regexp(fieldStr, 'pubchem.compound:'))
                metPubChem = strrep(fieldStr, 'pubchem.compound:', '');
            elseif (regexp(fieldStr, 'pubchem.compound/'))
                metPubChem = strrep(fieldStr, 'pubchem.compound/', '');
            end
        end

        % get InChI string - this is in notes for recon and yeast models,
        % so not changed
        string = ['<in:inchi xmlns:in="http://biomodels.net/inchi" ' ...
            'metaid="(.*?)">(.*?)</in:inchi>'];
        fieldTmp = regexp(annotationField, string, 'tokens');
        
        if ~isempty(fieldTmp)
            fieldStr = fieldTmp{1}{2};
            if (regexp(fieldStr, 'InChI'))
                metInChI = strrep(fieldStr, 'InChI=', '');
            end
        end
    
    elseif iscell(annotationField) % if a cell array, use BH code
        [~,fieldList] = regexp(annotationField, ...
            '<rdf:li rdf:resource="urn:miriam:(\w+).*?"/>', 'tokens', ...
            'match');
        
        % look for identifiers.org URL if no miriam
        if isempty(find(~cellfun('isempty',fieldList))) 
            string = ['<rdf:li rdf:resource="http://identifiers.org/' ...
                '(\w+).*?"/>'];
            [~,fieldList] = regexp(annotationField, string, 'tokens', ...
                'match');
        end
        
        unannotated = (cellfun('isempty',fieldList)); % needed?
        
        metCHEBI(unannotated) = {{''}};
        metKEGG(unannotated) = {{''}};
        metPubChem(unannotated) = {{''}};
        metInChI(unannotated) = {{''}};
        
        % I AM HERE -- STARTING TO BUILD 
        
        string = 'obo.chebi:CHEBI%';
        string = 'chebi/';
        metCHEBI = cellfun(@(x) regexp(x, string, 'tokens'), fieldList, ...
            'UniformOutput', 0); 
        % want something like 
        % [~, b] = regexp(fieldList{10}, string, 'tokens', 'match')
        
        for i = 1:length(fieldList)
            fieldTmp = regexp(fieldList{i}, ...
                ['<rdf:li rdf:resource="urn:miriam:(.*)"/>'], 'tokens');
            if isempty(fieldTmp)% look for identifiers.org URL if no miriam
                string = ['<rdf:li rdf:resource="http://identifiers' ...
                    '.org/(.*)"/>'];
                fieldTmp = regexp(fieldList{i}, string, 'tokens');
            end

            fieldStr = fieldTmp{1}{1};
            if (regexp(fieldStr, 'obo.chebi'))
                metCHEBI = strrep(fieldStr, 'obo.chebi:CHEBI%', '');
            elseif (regexp(fieldStr, 'chebi/'))
                metCHEBI = strrep(fieldStr, 'chebi/CHEBI:', '');            
            elseif (regexp(fieldStr, 'kegg.compound:'))
                metKEGG = strrep(fieldStr, 'kegg.compound:', '');
            elseif (regexp(fieldStr, 'kegg.compound/'))
                metKEGG = strrep(fieldStr, 'kegg.compound/', '');
            elseif (regexp(fieldStr, 'pubchem.substance'))
                metPubChem = strrep(fieldStr, 'pubchem.substance:', '');
            elseif (regexp(fieldStr, 'pubchem.compound:'))
                metPubChem = strrep(fieldStr, 'pubchem.compound:', '');
            elseif (regexp(fieldStr, 'pubchem.compound/'))
                metPubChem = strrep(fieldStr, 'pubchem.compound/', '');
            end
        end

        % get InChI string - this is in notes for recon and yeast models,
        % so not changed
        string = ['<in:inchi xmlns:in="http://biomodels.net/inchi" ' ...
            'metaid="(.*?)">(.*?)</in:inchi>'];
        fieldTmp = regexp(annotationField, string, 'tokens');
        if ~isempty(fieldTmp)
            fieldStr = fieldTmp{1}{2};
            if (regexp(fieldStr, 'InChI'))
                metInChI = strrep(fieldStr, 'InChI=', '');
            end
        end
    end
end