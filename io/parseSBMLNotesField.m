function [genes, rule, subSystem, grRule, formula, confidenceScore, ...
        citation, comment, ecNumber, charge, rxnGeneMat] = ...
        parseSBMLNotesField(notesField)
   
    % parseSBMLNotesField Parse the notes field of an SBML file to extract
    % information about reactions and metabolites
    %
    % notesField    Input string or cell array of SBML notes fields
    % 
    % subSystem     subSystem assignment for each reaction
    % formula       elemental formula for each metabolite
    % confidenceScore     Confidence score for each reaction
    %               0 = not evaluated
    %               1 = modeling data
    %               2 = sequence or physiological data
    %               3 = genetic data
    %               4 = biochemical data
    % citation      cell array of reference information
    % comment       cell array of comments
    % ecNumber      cell array of E.C. numbers for each reaction
    % charge        cell array of metabolite charge values
    % grRule        cell array of gene-protein-reaction strings
    % genes         cell array of all genes in the model
    % rule          cell array of boolean rules defining gene-reaction 
    %                relationships
    % rxnGeneMat    sparse binary matrix with rows corresponding to 
    %                reactions, and columns corresponding to genes
    
    % NOTE:    
    % This function is maintained to support reading of legacy models. It
    % will be depreciated soon, as the SBML <annotation> field is a more
    % standards-appropriate place for this information. Please do not add
    % new information to the SBML notes field or modify this function to do
    % things that aren't described in the COBRA or reconstruction protocol
    % papers! (DOI: 10.1038/nprot.2009.203 and DOI: 10.1038/nprot.2007.99
    % and DOI: 10.1038/nprot.2011.308 ).

    % Markus Herrgard 8/7/06
    %
    % Ines Thiele 1/27/10 - Added new fields
    %
    % Ben Heavner 1 July 2013 - add cell array functionality, rxnGeneMat,
    %   and bossy note

    subSystem = '';
    formula = '';
    confidenceScore = '';
    citation = '';
    comment = '';
    ecNumber = '';
    charge = [];
    grRule = '';
    genes = {};
    rule = '';
    rxnGeneMat = [];
    Comment = 0;
        
    if ischar(notesField) %if a string, use MH's code
        
        if isempty(regexp(notesField,'html:p', 'once'))
            tag = 'p';
        else
            tag = 'html:p';
        end
    
        [~,fieldList] = regexp(notesField,['<' tag '>.*?</' tag '>'], ...
            'tokens', 'match');

        for i = 1:length(fieldList)
            fieldTmp = regexp(fieldList{i},['<' tag '>(.*)</' tag '>'], ...
                'tokens');
            fieldStr = fieldTmp{1}{1};
            if (regexp(fieldStr,'GENE_ASSOCIATION'))
                gprStr = regexprep(strrep(fieldStr, ...
                    'GENE_ASSOCIATION:',''), '^(\s)+','');
                grRule = gprStr;
                [genes,rule] = parseBoolean(gprStr);
            elseif (regexp(fieldStr,'GENE ASSOCIATION'))
                gprStr = regexprep(strrep(fieldStr, ...
                    'GENE ASSOCIATION:',''), '^(\s)+','');
                grRule = gprStr;
                [genes,rule] = parseBoolean(gprStr);
            elseif (regexp(fieldStr,'SUBSYSTEM'))
                subSystem = regexprep(strrep(fieldStr,'SUBSYSTEM:',''), ...
                    '^(\s)+','');
                subSystem = strrep(subSystem,'S_','');
                subSystem = regexprep(subSystem,'_+',' ');
                if (isempty(subSystem))
                    subSystem = 'Exchange';
                end
            elseif (regexp(fieldStr,'EC Number'))
                ecNumber = regexprep(strrep(fieldStr,'EC Number:',''), ...
                    '^(\s)+','');
            elseif (regexp(fieldStr,'FORMULA'))
                formula = regexprep(strrep(fieldStr,'FORMULA:',''), ...
                    '^(\s)+','');
            elseif (regexp(fieldStr,'CHARGE'))
                charge = str2num(regexprep(strrep(fieldStr, ...
                    'CHARGE:',''), '^(\s)+',''));
            elseif (regexp(fieldStr,'AUTHORS'))
                if isempty(citation)
                    citation = strcat(...
                        regexprep(strrep(fieldStr,'AUTHORS:',''), ...
                        '^(\s)+',''));
                else
                    citation = strcat(...
                        citation, ';', ...
                        regexprep(strrep(fieldStr,'AUTHORS:',''), ...
                        '^(\s)+',''));
                end
            elseif Comment == 1 && isempty(regexp(fieldStr,'genes:', ...
                    'once'))
                Comment = 0;
                comment = fieldStr;
            elseif (regexp(fieldStr,'Confidence'))
                confidenceScore = regexprep(strrep(fieldStr, ...
                    'Confidence Level:', ''), '^(\s)+', '');
                Comment = 1;
            end
        end

    elseif iscell(notesField) % if a cell array, use BH code
        
        if sum(cellfun('isempty', regexp(notesField,'html:p', 'once')))
            tag = 'p';
        else
            tag = 'html:p';
        end
        
        NotesKeys = { ...
            'GENE_ASSOCIATION' ...  % for rxns
            'GENE ASSOCIATION' ...  % for rxns
            'SUBSYSTEM' ...         % for rxns
            'EC Number' ...         % for rxns
            'AUTHORS' ...           % for rxns
            'Confidence Level' ...  % for rxns
            'FORMULA' ...           % for mets
            'CHARGE' ...            % for mets
            }; 
        
        grRule = regexp(notesField, ...
            ['<' tag '>' NotesKeys{1} ':.*?</' tag '>'], 'match');
        key = NotesKeys{1};

        if sum(cellfun('isempty',grRule))
            grRule = regexp(notesField, ...
                ['<' tag '>' NotesKeys{2} ':.*?</' tag '>'], 'match');
            key = NotesKeys{2};
        end

        % strip HTML open tag and key text        
        grRule = cellfun(@(x) regexprep(x, ['<' tag '>' key ':'], ...
            ''), grRule, 'UniformOutput', 0);
        
        % strip leading space if it exists
        grRule = cellfun(@(x) regexprep(x, '^\s', ''), grRule, ...
            'UniformOutput', 0);
        
        % strip tag close tags
        grRule = cellfun(@(x) regexprep(x, ['</\' tag '>'], ''), ...
            grRule, 'UniformOutput', 0); 
        
        grRule = [grRule{:}]'; % unnest cell

        [genes, rule, rxnGeneMat] = parseBoolean(grRule);
        
        subSystem = regexp(notesField, ...
            ['<' tag '>' NotesKeys{3} ':.*?</' tag '>'], 'match');
        
        % strip HTML open tag and key text
        subSystem = cellfun(@(x) ...
            regexprep(x, ['<' tag '>' NotesKeys{3} ':'], ''), ...
            subSystem, 'UniformOutput', 0);

        % strip leading space if it exists
        subSystem = cellfun(@(x) regexprep(x, '^\s', ''), subSystem, ...
            'UniformOutput', 0);
        
        % strip tag close tags
        subSystem = cellfun(@(x) regexprep(x, ['</\' tag '>'],''), ...
           subSystem, 'UniformOutput', 0);
        
        % added to support some legacy subsystem encoding?
        subSystem = cellfun(@(x) strrep(x,'S_',''), subSystem, ...
            'UniformOutput', 0);
        subSystem = cellfun(@(x) regexprep(x,'_+',' '), subSystem, ...
            'UniformOutput', 0);
         
         % I think the intent of the string-based code was to default to
         % 'exchange' if there wasn't an entry for Subsystem. However, it
         % didn't do that, and instead returned an empty cell if there
         % wasn't a subsystem defined. I've kept the behavior, and
         % commented out what I understand to be the intent:
         
 %        subSystem(cellfun('isempty',subSystem)) = {{'Exchange'}};

        subSystem(cellfun('isempty',subSystem)) = {{''}};
        subSystem = [subSystem{:}]'; % unnest cell
         
        ecNumber = regexp(notesField, ...
            ['<' tag '>' NotesKeys{4} ':.*?</' tag '>'] , 'match');
         
        % strip HTML open tag and key text
        ecNumber = cellfun(@(x) regexprep(x, ...
            ['<' tag '>' NotesKeys{4} ':'], ''), ecNumber, ...
            'UniformOutput', 0);
         
        % strip leading space if it exists
        ecNumber = cellfun(@(x) regexprep(x, '^\s', ''), ecNumber, ...
            'UniformOutput', 0);
        
        % strip tag close tags
        ecNumber = cellfun(@(x) regexprep(x, ['</\' tag '>'], ''), ...
            ecNumber, 'UniformOutput', 0); 
        ecNumber(cellfun('isempty',ecNumber)) = {{''}}; % pad blanks
        ecNumber = [ecNumber{:}]'; % unnest cell

        citation = regexp(notesField, ...
            ['<' tag '>' NotesKeys{5} ':.*?</' tag '>'] , 'match');
        
        % strip HTML open tag and key text
        citation = cellfun(@(x) regexprep(x, ...
            ['<' tag '>' NotesKeys{5} ':'], ''), citation, ...
            'UniformOutput', 0);
        
        % strip leading space if it exists
        citation = cellfun(@(x) regexprep(x, '^\s', ''), citation, ...
            'UniformOutput', 0);
        
        % strip tag close tags
        citation = cellfun(@(x) regexprep(x, ['</\' tag '>'],''), ...
            citation, 'UniformOutput', 0); 
        citation(cellfun('isempty',citation)) = {{''}}; % pad blanks
        citation = [citation{:}]'; % unnest cell

        confidenceScore = regexp(notesField, ...
            ['<' tag '>' NotesKeys{6} ':.*?</' tag '>'] , 'match');
        
        % strip HTML open tag and key text
        confidenceScore = cellfun(@(x) regexprep(x, ...
            ['<' tag '>' NotesKeys{6} ':'], ''), confidenceScore, ...
            'UniformOutput', 0);
        
        % strip leading space if it exists
        confidenceScore = cellfun(@(x) regexprep(x, '^\s', ''), ...
            confidenceScore, 'UniformOutput', 0);
        
        % strip tag close tags
        confidenceScore = cellfun(@(x) regexprep(x, ...
            ['</\' tag '>'], ''), confidenceScore, 'UniformOutput', 0); 
        confidenceScore(cellfun('isempty',confidenceScore)) = ...
            {{''}}; % pad blanks
        confidenceScore = [confidenceScore{:}]'; % unnest cell
                
        formula = regexp(notesField, ...
            ['<' tag '>' NotesKeys{7} ':.*?</' tag '>'] , 'match');
        
        % strip HTML open tag and key text
        formula = cellfun(@(x) regexprep(x, ...
            ['<' tag '>' NotesKeys{7} ':'], ''), formula, ...
            'UniformOutput', 0);
        
        % strip leading space if it exists
        formula = cellfun(@(x) regexprep(x, '^\s', ''), formula, ...
            'UniformOutput', 0);
        
        % strip tag close tags
        formula = cellfun(@(x) regexprep(x, ['</\' tag '>'], ''), ...
            formula, 'UniformOutput', 0); 
        formula(cellfun('isempty',formula)) = {{''}}; % pad blanks
        formula = [formula{:}]'; % unnest cell
        
        charge = regexp(notesField, ...
            ['<' tag '>' NotesKeys{8} ':.*?</' tag '>'] , 'match');
        
        % strip HTML open tag and key text
        charge = cellfun(@(x) regexprep(x, ...
            ['<' tag '>' NotesKeys{8} ':'], ''), charge, ...
            'UniformOutput', 0);
        
        % strip leading space if it exists
        charge = cellfun(@(x) regexprep(x, '^\s', ''), charge, ...
            'UniformOutput', 0);
        
        % strip tag close tags
        charge = cellfun(@(x) regexprep(x, ['</\' tag '>'], ''), ...
            charge, 'UniformOutput', 0);
        charge(cellfun('isempty',charge)) = {{''}}; % pad blanks
        charge = [charge{:}]'; % unnest cell
        
        comment = notesField;
    else
        errorstr = [...
            'The str variable passed to parseBoolean must be a string ' ...
            'or cell array.'];
        error(errorstr)
    end

end