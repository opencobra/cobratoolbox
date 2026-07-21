function [term, ng, nt, nr, nko, reactionKO, reactionKO2term] = readGeneRules(model)
% readGeneRules is a submodule of gDel_minRN that reads the
% gene-protein-reaction (GPR) relations and produces the information needed
% to formulate the mixed-integer linear program (MILP).
%
% USAGE:
%
%    [term, ng, nt, nr, nko, reactionKO, reactionKO2term] = readGeneRules(model)
%
% INPUT:
%    model:    COBRA model structure with the fields:
%
%                * .rxns - reaction identifiers (n x 1 cell array)
%                * .genes - gene identifiers (g x 1 cell array)
%                * .grRules - gene-protein-reaction association rules (n x 1 cell array)
%
% OUTPUTS:
%    term:               struct array of Boolean-function terms extracted from
%                        the GPR rules, with the fields:
%
%                          * .output - output variable name of the term
%                          * .function - Boolean operator ('and', 'or', 'equal')
%                          * .input - input variable name(s) of the term
%
%    ng:                 number of genes
%    nt:                 number of internal terms
%    nr:                 number of reactions
%    nko:                number of repressible reactions
%    reactionKO:         number of reaction-repression (knockout) terms identified
%    reactionKO2term:    map from a reaction index to the index of its
%                        corresponding term in term
%
% .. Author:    - Takeyuki Tamura, Mar 06, 2025
%

x = 1; y = 1; reactionKO = 0; qq = 0; ww = 0;
for i=1:numel(model.grRules)
    GRrelation = model.grRules{i};
    empty = 0;
    if isempty(GRrelation) == 0
        if (isempty(strfind(GRrelation, 'or'))==0) || (isempty(strfind(GRrelation, 'and')) == 0)
            GRrelation=strcat('(', GRrelation, ')');
        else
            GRrelation = strtrim(GRrelation);
            term(x).output = sprintf('reactionKO_%d', i);
            term(x).function = 'equal';
            term(x).input{1, 1} = GRrelation;
            reactionKO2term(i, 1) = x;
            x = x+1;
            reactionKO = reactionKO + 1;
            qq = qq+1;
        end
    else
        empty = 1;
    end
    flag = 1;
    while isempty(strfind(GRrelation, ')')) == 0
        size(GRrelation, 2);
        p_tail_list = strfind(GRrelation, ')');
        p_tail = p_tail_list(1);
        j = p_tail;
        flag = 1;
        while flag == 1
            j = j-1;
            if  GRrelation(j) == '('
                p_head = j;
                flag = 0;
            end
        end
        extract = GRrelation(p_head+1:p_tail-1);
        extract2 = strtrim(extract);
        term(x).output = sprintf('term_%d', y);
        term(x).output;
        y = y+1;
        unit = strsplit(extract2);
        for k=1:floor(size(unit, 2)/2)
            if strcmp(unit(2), unit(2*k)) == 0
                save('readGeneRules.mat');
                error('Boolean functions are inappropriate.')
            end
        end
        
        term(x).function = unit(2);
        for k=1:ceil(size(unit,2)/2)
            term(x).input{k,1} = unit(2*k-1);
        end
        str = sprintf('(%s)', extract);
        GRrelation = strrep(GRrelation, str, term(x).output);
        x = x+1;
    end
    if (empty == 0 && strcmp(term(x-1).function, 'equal') == 0)
        term(x-1).output = sprintf('reactionKO_%d', i);
        reactionKO2term(i, 1) = x-1;
        reactionKO = reactionKO + 1;
        ww = ww + 1;
    end
end
ng = size(model.genes, 1);
nr = size(model.rxns, 1);
nko = ww + qq;
nt = y - ww - 1;
j = 1;
for i=1:nt+nko
    if contains(term(i).output, 'term') == 1
        term2(j) = term(i);
        j = j + 1;
    end
end
for i=1:nt+nko
    if contains(term(i).output, 'reaction') == 1
        term2(j) = term(i);
        j = j + 1;
    end
end
term = term2;

end

