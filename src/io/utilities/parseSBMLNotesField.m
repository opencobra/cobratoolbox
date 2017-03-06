function [genes,rule,subSystem,grRule,formula,confidenceScore,citation,comment,ecNumber,charge] = parseSBMLNotesField(notesField)
%parseSBMLNotesField Parse the notes field of an SBML file to extract
%gene-rxn associations
%
% [genes,rule] = parseSBMLNotesField(notesField)
%
% Markus Herrgard 8/7/06
% Ines Thiele 1/27/10 Added new fields
% Handle different notes fields
% Thomas Pfau 1/10/17 Make distinction between Matlab versions

MatlabVer = version('-release');
[A,B] = regexp(MatlabVer,'[\d]+');
MatlabYear = str2num(MatlabVer(A:B));
%if we are prior to 2013 use the old version
if MatlabYear < 2013
    [genes,rule,subSystem,grRule,formula,confidenceScore,citation,comment,ecNumber,charge] = parseSBMLNotesField2012(notesField)
    return
end



if isempty(regexp(notesField,'html:p', 'once'))
    tag = 'p';
else
    tag = 'html:p';
end

subSystem = '';
grRule = '';
genes = {};
rule = '';
formula = '';
confidenceScore = '';
citation = '';
ecNumber = '';
comment = '';
charge = [];
Comment = 0;

[tmp,fieldList] = regexp(notesField,['<' tag '>.*?</' tag '>'],'tokens','match');

for i = 1:length(fieldList)
    fieldTmp = regexp(fieldList{i},['<' tag '>(.*)</' tag '>'],'tokens');
    fieldStr = strtrim(fieldTmp{1}{1});
    strfields = strsplit(fieldStr,':');
    %We have several
    if strcmp(strfields{1}, 'GENE_ASSOCIATION') || strcmp(strfields{1}, 'GENE ASSOCIATION')
        %Remove leading and trailing whitespace, and join the remaining strin again with the : separator
        grRule = strtrim(strjoin(strfields(2:end),':'));
        [genes,rule] = parseBoolean(grRule);
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
        confidenceScore = strtrim(strjoin(strfields(2:end),':'));
    elseif strcmp(strfields{1},'NOTES')
        if isempty(comment)
            comment = strtrim(strjoin(strfields(2:end),':'));
        else
            if ~isempty(strjoin(strfields(2:end),':'))
                comment = strcat(comment,';',strjoin(strfields(2:end),':'));
            end
        end
    else
        if isempty(comment)
            comment = strtrim(strjoin(strfields(1:end),':'));
        else
            if ~isempty(strjoin(strfields(1:end),':'))
                comment = strcat(comment,';',strjoin(strfields(1:end),':'));
            end
        end
    end
end
