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


[fieldTmp,fieldList] = regexp(notesField,['<' tag '>(.*?)</' tag '>'],'tokens','match');

for i = 1:length(fieldList)
    fieldStr = strtrim(fieldTmp{i}{1});
    strfields = strsplit(fieldStr,':');
    %Remove leading and trailing whitespace , and join the remaining string again with the : separator
    valueStr = strtrim(strjoin(strfields(2:end), ':'));
    %We have several
    if strcmpi(strfields{1}, 'GENE_ASSOCIATION') || strcmp(strfields{1}, 'GENE ASSOCIATION') || strcmp(strfields{1}, 'GPR_ASSOCIATION')
        grRule = valueStr;
    elseif strcmpi(strfields{1},'SUBSYSTEM')
        subSystem = valueStr;
        subSystem = strrep(subSystem,'S_','');
        subSystem = strsplit(regexprep(subSystem,'_+',' '),';');

    elseif strcmpi(strfields{1},'EC Number') || strcmpi(strfields{1},'EC_Number')
        ecNumber = valueStr;
    elseif strcmpi(strfields{1},'FORMULA')
        formula = valueStr;
    elseif strcmpi(strfields{1},'CHARGE')
        charge = str2num(valueStr);
    elseif strcmpi(strfields{1},'AUTHORS')
        if isempty(citation)
            citation = valueStr;
        else
            citation = strcat(citation,';',valueStr);
        end
    elseif strcmpi(strfields{1},'Confidence Level') || strcmpi(strfields{1},'Confidence_Level')
        confidenceScore = str2double(valueStr);
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
