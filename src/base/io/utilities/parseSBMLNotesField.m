function [subSystem, grRule, formula, confidenceScore, citation, comment, ecNumber, charge] = parseSBMLNotesField(notesField)
% Parses the notes field of an SBML file to extract `gene-rxn` associations
%
% USAGE:
%
%    [subSystem, grRule, formula, confidenceScore, citation, comment, ecNumber, charge] = parseSBMLNotesField(notesField)
%
% INPUT:
%    notesField:         notes field of SBML file
%
% OUTPUT:
%    subSystem:          subSystem assignment for each reaction
%    grRule:             a string representation of the GPR rules defined in a readable format
%    formula:            elementa formula
%    confidenceScore:    confidence scores for reaction presence
%    citation:           joins strings with authors
%    comment:            comments and notes
%    ecNumber:           E.C. number for each reaction
%    charge:             charge of the respective metabolite
%
% .. Authors:
%       - Markus Herrgard 8/7/06
%       - Ines Thiele 1/27/10 Added new fields
%       - Handle different notes fields


subSystem = {''};
grRule = '';
formula = '';
confidenceScore = NaN;
citation = '';
ecNumber = '';
charge = NaN;
comment = '';
notes = '';


if isempty(notesField)
    return
end

if isempty(regexp(notesField,'html:p', 'once'))
    tag = 'p';
else
    tag = 'html:p';
end


[tmp,fieldList] = regexp(notesField,['<' tag '>.*?</' tag '>'],'tokens','match');

for i = 1:length(fieldList)
    fieldTmp = regexp(fieldList{i},['<' tag '>(.*)</' tag '>'],'tokens');
    fieldStr = strtrim(fieldTmp{1}{1});
    % Join the remaining string again with the : separator
    strfields = strsplit(fieldStr,':');
    valueStr = strjoin(strfields(2:end), ':');
    %We have several
    if strcmpi(strfields{1}, 'GENE_ASSOCIATION') || strcmp(strfields{1}, 'GENE ASSOCIATION') || strcmp(strfields{1}, 'GPR_ASSOCIATION')
        %Remove leading and trailing whitespace 
        grRule = strtrim(valueStr);
    elseif strcmpi(strfields{1},'SUBSYSTEM')
        subSystem = strtrim(valueStr);
        subSystem = strrep(subSystem,'S_','');
        subSystem = strsplit(regexprep(subSystem,'_+',' '),';');
        
    elseif strcmpi(strfields{1},'EC Number') || strcmpi(strfields{1},'EC_Number')
        ecNumber = strtrim(valueStr);
    elseif strcmpi(strfields{1},'FORMULA')
        formula = strtrim(valueStr);
    elseif strcmpi(strfields{1},'CHARGE')
        charge = str2num(strtrim(valueStr));
    elseif strcmp(strfields{1},'AUTHORS')
        if isempty(citation)
            citation = strtrim(valueStr);
        else
            citation = strcat(citation,';',strtrim(valueStr));
        end
    elseif strcmpi(strfields{1},'Confidence Level') || strcmpi(strfields{1},'Confidence_Level')
        confidenceScore = str2double(strtrim(valueStr));
    elseif strcmpi(strfields{1},'NOTES')
        if isempty(notes)
            notes = regexprep(fieldStr,'[\n\r]+',' ');
        else
            if ~isempty(valueStr)
                notes = regexprep(strcat(notes,';',valueStr),'[\n\r]+',' ');
            end
        end
    else
        %Other Fields will be appended
        if~isempty(comment)
            comment = [comment sprintf('\n') regexprep(fieldStr,'[\n\r]+',' ')];
        else
            comment = regexprep(fieldStr,'[\n\r]+',' ');
        end
    end
end
if ~isempty(notes)
    if isempty(comment)
        comment = notes;
    else
        comment = [notes sprintf('\n') comment];
    end
    
end
end
