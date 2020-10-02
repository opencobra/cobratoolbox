%requires https://uk.mathworks.com/matlabcentral/fileexchange/29774-stoichiometry-tools

%             TODO
%             Error using parse_formula>parse_formula_ (line 191)
%             Could not parse formula:
%             O5C5H3A2
%                   ^^

formula = 'O5C5H3A2';
hillformulaExample = hillformula(formula);
assert(strcmp(hillformulaExample,'C5H3A2O5'))