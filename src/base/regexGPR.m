function [tmp] = regexGPR(grRule)

    tmp = regexprep(grRule, '[\]\}]',')'); %replace other brackets by parenthesis.
    tmp = regexprep(tmp, '[\[\{]','('); %replace other brackets by parenthesis.
    tmp = regexprep(tmp,'([\(])\s*','$1'); %replace all spaces after opening parenthesis
    tmp = regexprep(tmp,'\s*([\)])','$1'); %replace all spaces before closing paranthesis.
    tmp = regexprep(tmp, '([\)]\s?|\s)\s*(?i)(and)\s*?(\s?[\(]|\s)\s*', '$1&$3'); %Replace all ands
    tmp = regexprep(tmp, '([\)]\s?|\s)\s*(?i)(or)\s*?(\s?[\(]|\s)\s*', '$1|$3'); %replace all ors

    %genes = regexp(tmp,'([^\(\)\|\&\s]+)','match');
end