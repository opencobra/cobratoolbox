function [metaboliteList,stoichCoeffList,revFlag] = parseRxnFormula(formula)
%parseRxnFormula Parse reaction formula into a list of metabolites and a
%list of S coefficients
%
% [metaboliteList,stoichCoeffList,revFlag] = parseRxnFormula(formula)
%
%INPUT
% formula           Reaction formula, may contain symbols '+', '->', '<=>' in
%                   addition to stoichiometric coefficients and metabolite names
%                   examples: 
%                   '0.01 cdpdag-SC[m] + 0.01 pg-SC[m]  -> 0.01 clpn-SC[m] + cmp[m] + h[m]' (irreversible reaction)
%                   'cit[c] + icit[x]  <=> cit[x] + icit[c] ' (reversible reaction)
%                   If no stoichiometric coefficient is provided, it is assumed
%                   to be = 1
%                   Reaction formula should be a string, not a cell array
%
%OUTPUTS
% metaboliteList    Cell array with metabolite names
% stoichCoeffList   List of S coefficients
% revFlag           Indicates whether the reaction is reversible (true) or
%                   not (false)
%
% Example:
%
%  formula = '0.01 cdpdag-SC[m] + 0.01 pg-SC[m]  -> 0.01 clpn-SC[m] + cmp[m] + h[m]'
%
%  [metaboliteList,stoichCoeffList,revFlag] = parseRxnFormula(formula)
%
%  metaboliteList = 
%   'cdpdag-SC[m]'    'pg-SC[m]'    'clpn-SC[m]'    'cmp[m]'    'h[m]'
%  stoichCoeffList = 
%   -0.01 -0.01 0.01 1 1
%  revFlag =
%   false
%
% Markus Herrgard 6/1/07
%
% Richard Que 1/25/10 Modified to handle '-->' and '<==>' as arrows 
% as well as reactionsformatted as '[compartment] : A --> C'. 
% IT May 2012 Modified to handle '=>'

tokens = splitString(formula);

stoichCoeffList = [];
metaboliteList = {};
revFlag = true;

% Marks the start of a new stoichiometry + metabolite block
newMetFlag = true;
% Designates products vs reactants
productFlag = false;
compartment = '';
for i = 1:length(tokens)
    t = tokens{i};
    if strcmp(t(1),'[')
        %set compartment
        compartment = t;
    elseif strcmp(t,':')
        %Do nothing
    elseif strcmp(t,'+')
        % Do nothing
        newMetFlag = true;
    elseif strcmp(t,'->') || strcmp(t,'-->') || strcmp(t,'=>')
        % Irreversible
        revFlag = false;
        productFlag = true;
        newMetFlag = true;
    elseif strcmp(t,'<=>') || strcmp(t,'<==>')
        % Reversible
        revFlag = true;
        productFlag = true;
        newMetFlag = true;
    else
        sCoeff = str2double(t);
        if (~isnan(sCoeff))
            % Stoich coefficient
            if ~productFlag
                sCoeff = -sCoeff;
            end
            stoichCoeffList(end+1) = sCoeff;
            newMetFlag = false;
        else
            % Metabolite name
            metaboliteList{end+1} = strcat(t,compartment);
            if newMetFlag
                if ~productFlag
                    stoichCoeffList(end+1) = -1;
                else
                    stoichCoeffList(end+1) = 1;
                end
                newMetFlag = true;
            end
        end
    end
end
        
