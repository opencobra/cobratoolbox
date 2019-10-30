function [preParsedGrRules,genes] = preparseGPR(grRules)
% preparse model.grRules before parsing the remaining part
% and transforming model.grRules into model.rules
%
% USAGE:
%
%    preParsedGrRules = preparseGPR(grRules)
%
% INPUT:
%    grRules:           grRules cell or single grRule
%
% OUTPUT:
%    preParsedGrRules:  preparsed grRules cell or single grRule
%
% .. Author: -  Laurent Heirendt - December 2017

%using regexprep all cells must be char row vectors.
glt=size(grRules,1);
if glt>2
for g=1:glt
    if ~ischar(grRules{g})
        if iscell(grRules{g})
            tmp=grRules{g};
            grRules{g}=tmp{1};
        else
            error(['grRules ' int2str(g)  ' is not a character array'])
        end
    end
end
end
    preParsedGrRules = regexprep(grRules, '[\]\}]',')'); %replace other brackets by parenthesis.
    preParsedGrRules = regexprep(preParsedGrRules, '[\[\{]','('); %replace other brackets by parenthesis.
    preParsedGrRules = regexprep(preParsedGrRules,'([\(])\s*','$1'); %replace all spaces after opening parenthesis
    preParsedGrRules = regexprep(preParsedGrRules,'\s*([\)])','$1'); %replace all spaces before closing paranthesis.
    preParsedGrRules = regexprep(preParsedGrRules, '([\)]\s?|\s)\s*(?i)(and)\s*?(\s?[\(]|\s)\s*', '$1&$3'); %Replace all ands
    preParsedGrRules = regexprep(preParsedGrRules, '([\)]\s?|\s)\s*(?i)(or)\s*?(\s?[\(]|\s)\s*', '$1|$3'); %replace all ors
    preParsedGrRules = regexprep(preParsedGrRules, '[\s]?&[\s]?', ' & '); %introduce spaces around ands
    preParsedGrRules = regexprep(preParsedGrRules, '[\s]?\|[\s]?', ' | '); %introduce spaces around ors.    
    genes = cellfun(@unique,regexp(preParsedGrRules,'([^\(\)\|\&\s]+)','match'),'Uniform',0); %Get all genes for each reaction.       
end