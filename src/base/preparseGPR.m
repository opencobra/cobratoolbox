function preParsedGrRules = preparseGPR(grRule)

    preParsedGrRules = regexprep(grRule, '[\]\}]',')'); %replace other brackets by parenthesis.
    preParsedGrRules = regexprep(preParsedGrRules, '[\[\{]','('); %replace other brackets by parenthesis.
    preParsedGrRules = regexprep(preParsedGrRules,'([\(])\s*','$1'); %replace all spaces after opening parenthesis
    preParsedGrRules = regexprep(preParsedGrRules,'\s*([\)])','$1'); %replace all spaces before closing paranthesis.
    preParsedGrRules = regexprep(preParsedGrRules, '([\)]\s?|\s)\s*(?i)(and)\s*?(\s?[\(]|\s)\s*', '$1&$3'); %Replace all ands
    preParsedGrRules = regexprep(preParsedGrRules, '([\)]\s?|\s)\s*(?i)(or)\s*?(\s?[\(]|\s)\s*', '$1|$3'); %replace all ors

end