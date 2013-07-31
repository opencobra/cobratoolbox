% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson

function matched = ReactionEq(reaction,rxns,Abbreviation,bar)
% matched = ReactionEq(reaction,rxns,Abbreviation,bar)
% Compare reaction formulas
% 
% INPUT: 
%   reaction - Reaction formula being checked
%   rxns - Compare reactions, rBioNet format
%   if Abbreviation is false rxns input can be only formulas
%
% INPUT OPTIONAL
%   Abbreviation - default true
%   bar - default false
%   
% OUTPUT:
%   matched - empty if reaction douesn't exists, else rxn Abbreviation.
%   If Abbreviation is false, then return formula number

matched = ''; % if empty then no match, otherwise reaction abbreviation

if nargin < 3
    Abbreviation = true;
end

if nargin < 4
    bar = false;
end

if ~Abbreviation && size(rxns,2) == 1
    formulas = rxns;
else
    formulas = rxns(:,3);
end

[a0 b0 c0] = parseRxnFormula(reaction);
% a  Cell array with metabolite names
% b  List of S coefficients
% c  reversible (true) or (false)
k = size(a0,2);
%match = 0; Now this should work
Sdata = size(rxns,1);

if bar 
    h = waitbar(0/Sdata,'Checking reactions...');
end

for i = 1:size(rxns,1)
    if bar == 1
        waitbar(i/Sdata);
    end
    
    match = 0;
    
    [a1 b1 c1 ] = parseRxnFormula(formulas{i});
    
    if size(a0,2) == size(a1,2) && c1 == c0 %same size and reversibility equal
        %Line up
        
        for j = 1:k
            for n = 1:k
                if strcmp(a0(j),a1(n)) && b0(j) == b1(n) %same
                    match = match + 1;
                    break;
                end
            end
        end
        
        if match == k  % Full match
            if Abbreviation
                matched = rxns{i,1};
            else
                matched = i;
            end
            
            break;
        end
    end
end

if bar
    close(h)
end

