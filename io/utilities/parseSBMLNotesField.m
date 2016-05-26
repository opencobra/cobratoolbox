function [genes,rule,subSystem,grRule,formula,confidenceScore,citation,comment,ecNumber,charge] = parseSBMLNotesField(notesField)
%parseSBMLNotesField Parse the notes field of an SBML file to extract
%gene-rxn associations
%
% [genes,rule] = parseSBMLNotesField(notesField)
%
% Markus Herrgard 8/7/06
% Ines Thiele 1/27/10 Added new fields
% Handle different notes fields
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
    fieldStr = fieldTmp{1}{1};
    if (regexp(fieldStr,'GENE_ASSOCIATION'))
        gprStr = regexprep(strrep(fieldStr,'GENE_ASSOCIATION:',''),'^(\s)+','');
        grRule = gprStr;
        [genes,rule] = parseBoolean(gprStr);
    elseif (regexp(fieldStr,'GENE ASSOCIATION'))
        gprStr = regexprep(strrep(fieldStr,'GENE ASSOCIATION:',''),'^(\s)+','');
        grRule = gprStr;
        [genes,rule] = parseBoolean(gprStr);
    elseif (regexp(fieldStr,'SUBSYSTEM'))
        subSystem = regexprep(strrep(fieldStr,'SUBSYSTEM:',''),'^(\s)+','');
        subSystem = strrep(subSystem,'S_','');
        subSystem = regexprep(subSystem,'_+',' ');
        
        
%%%% The following commented three lines of codes assigns the SubSystem
%%%% 'Exchange' to any reaction that has SUBSYSTEM showing up in its notes
%%%% field but with no subsystem assigne

%         if (isempty(subSystem))
%             subSystem = 'Exchange';
%         end
    elseif (regexp(fieldStr,'EC Number'))
        ecNumber = regexprep(strrep(fieldStr,'EC Number:',''),'^(\s)+','');
    elseif (regexp(fieldStr,'FORMULA'))
        formula = regexprep(strrep(fieldStr,'FORMULA:',''),'^(\s)+','');
    elseif (regexp(fieldStr,'CHARGE'))
        charge = str2num(regexprep(strrep(fieldStr,'CHARGE:',''),'^(\s)+',''));
    elseif (regexp(fieldStr,'AUTHORS'))
        if isempty(citation)
            citation = strcat(regexprep(strrep(fieldStr,'AUTHORS:',''),'^(\s)+',''));
        else
            citation = strcat(citation,';',regexprep(strrep(fieldStr,'AUTHORS:',''),'^(\s)+',''));
        end
    elseif Comment == 1 && isempty(regexp(fieldStr,'genes:', 'once'))
        Comment = 0;
        comment = fieldStr;
    elseif (regexp(fieldStr,'Confidence'))
        confidenceScore = regexprep(strrep(fieldStr,'Confidence Level:',''),'^(\s)+','');
        Comment = 1;
    end
end