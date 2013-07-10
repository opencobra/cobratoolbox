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
        
        % first, check if the annotation uses miram URNs or identifiers.org
        % URLs by using a regexp to search for the string 'miriam'. If all
        % returned cells are empty, assign logical 0 to miriam variable.
        
        miriam = ~isempty... 
            (find ...
            (~cellfun('isempty', ...
            regexp(annotationField, 'miriam'))));
        
        % there is probably a more clever way to do this with named tokens
        % and cell arrays of structs, but it's beyond me at the moment.
        
        % get the ChEBI annotation
        if miriam
            p1 = ['<rdf:li rdf:resource="urn:miriam:obo.chebi:' ...
                'CHEBI%3A([^"]*)"/>'];
        else
            p1 = ['<rdf:li rdf:resource="http://identifiers.org/chebi/' ...
                'CHEBI:([^"]*)"/>'];
        end
        
        [temp, ~] = regexp(annotationField, p1, 'tokens', 'match');
        no_CHEBI = (cellfun('isempty',temp));
        emptycell={{' '}};
        [temp{no_CHEBI}] = deal(emptycell); 
        % temp is now a cell of cells (of cells of strings) Need to
        % unnest it a bit
        temp=[temp{:}]; 
        metCHEBI=[temp{:}];

        % next get the KEGG annotation
        if miriam
            p1 = ['<rdf:li rdf:resource="urn:miriam:kegg.compound:' ...
                '([^"]*)"/>'];
        else
            p1 = ['<rdf:li rdf:resource="http://identifiers.org/kegg.' ...
                'compound/([^"]*)"/>'];
        end
        
        [temp, ~] = regexp(annotationField, p1, 'tokens', 'match');
        no_KEGG = (cellfun('isempty',temp));
        emptycell={{' '}};
        [temp{no_KEGG}] = deal(emptycell); 
        % temp is now a cell of cells (of cells of strings) Need to
        % unnest it a bit
        temp=[temp{:}]; 
        metKEGG=[temp{:}];
        
        % next get the PubChem annotation
        if miriam
            p1 = ['<rdf:li rdf:resource="urn:miriam:pubchem.compound:' ...
                '([^"]*)"/>'];
        else
            p1 = ['<rdf:li rdf:resource="http://identifiers.org/' ...
                'pubchem.compound/([^"]*)"/>'];
        end
        
        [temp, ~] = regexp(annotationField, p1, 'tokens', 'match');
        no_PubChem = (cellfun('isempty',temp));
        emptycell={{' '}};
        [temp{no_PubChem}] = deal(emptycell); 
        % temp is now a cell of cells (of cells of strings) Need to
        % unnest it a bit
        temp=[temp{:}]; 
        metPubChem=[temp{:}];
        
        % and finally, InChI annotation (which I think is usually in notes
        % fields for legacy models, so expect to never have a match for
        % this regexp)
        p1 = ['<in:inchi xmlns:in="http://biomodels.net/inchi" ' ...
            'metaid="(.*?)">(.*?)</in:inchi>'];
        [temp, ~] = regexp(annotationField, p1, 'tokens', 'match');
        no_InChI = (cellfun('isempty',temp));
        emptycell={{' '}};
        [temp{no_InChI}] = deal(emptycell); 
        % temp is now a cell of cells (of cells of strings) Need to
        % unnest it a bit
        temp=[temp{:}]; 
        metInChI=[temp{:}]; 
        
        metCHEBI = metCHEBI';
        metKEGG = metKEGG';
        metPubChem = metPubChem';
        metInChI = metInChI';
    end
end