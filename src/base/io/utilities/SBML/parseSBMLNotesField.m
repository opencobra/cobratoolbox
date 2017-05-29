function [subSystem,grRule,formula,confidenceScore,citation,comment,ecNumber,charge] = parseSBMLNotesField(notesField)
%parseSBMLNotesField Parse the notes field of an SBML file to extract
%gene-rxn associations
%
% [genes,rule] = parseSBMLNotesField(notesField)
%
% Markus Herrgard 8/7/06
% Ines Thiele 1/27/10 Added new fields
% Handle different notes fields
% Thomas Pfau 1/10/17 Make distinction between Matlab versions

subSystem = '';
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
MatlabVer = version('-release');
[A,B] = regexp(MatlabVer,'[\d]+');
MatlabYear = str2num(MatlabVer(A:B));
%if we are prior to 2013 use the old version
if MatlabYear < 2013
    [subSystem,grRule,formula,confidenceScore,citation,comment,ecNumber,charge] = parseSBMLNotesField2012(notesField);
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
    strfields = strsplit(fieldStr,':');
    %We have several
    if strcmp(strfields{1}, 'GENE_ASSOCIATION') || strcmp(strfields{1}, 'GENE ASSOCIATION')
        %Remove leading and trailing whitespace, and join the remaining strin again with the : separator
        grRule = strtrim(strjoin(strfields(2:end),':'));
    elseif strcmp(strfields{1},'SUBSYSTEM')
        subSystem = strtrim(strjoin(strfields(2:end),':'));
        subSystem = strrep(subSystem,'S_','');
        subSystem = regexprep(subSystem,'_+',' ');
        
    elseif strcmp(strfields{1},'EC Number') || strcmp(strfields{1},'EC_Number') || strcmp(strfields{1},'EC_NUMBER') || strcmp(strfields{1},'EC NUMBER')
        ecNumber = strtrim(strjoin(strfields(2:end),':'));
    elseif strcmp(strfields{1},'FORMULA') || strcmp(strfields{1},'Formula')
        formula = strtrim(strjoin(strfields(2:end),':'));
    elseif strcmp(strfields{1},'CHARGE') || strcmp(strfields{1},'Charge')
        charge = str2num(strtrim(strjoin(strfields(2:end),':')));
    elseif strcmp(strfields{1},'AUTHORS')
        if isempty(citation)
            citation = strtrim(strjoin(strfields(2:end),':'));
        else
            citation = strcat(citation,';',strtrim(strjoin(strfields(2:end),':')));
        end
    elseif strcmp(strfields{1},'Confidence Level')
        confidenceScore = str2num(strtrim(strjoin(strfields(2:end),':')));
    elseif strcmp(strfields{1},'NOTES')
        if isempty(notes)
            notes = regexprep(fieldStr,'[\n\r]+',' ');
        else
            if ~isempty(strjoin(strfields(2:end),':'))
                notes = regexprep(strcat(notes,';',strjoin(strfields(2:end),':')),'[\n\r]+',' ');
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
