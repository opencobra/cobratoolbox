% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
%Compair reactions for equality
%react is new reaction
%rxns are similar reactions
%matched is abbreviation name for exact reaction match
%Stefan G. Thorleifsson 2010.
function matched = ReactionEq(react,rxns)

matched = ''; % if empty then no match, otherwise reaction abbreviation


[a0 b0 c0] = parseRxnFormula(react);
k = size(a0,2);
%match = 0; Now this should work
for i = 1:size(rxns,1)
    match = 0;
    [a1 b1 c1 ] = parseRxnFormula(rxns{i,3});
    
    if size(a0,2) == size(a1,2) && c1 == c0 %same size and reversibility equal
        %Line up
        
        for j = 1:k
            for n = 1:k
                if strcmp(a0(j),a1(n)) && b0(j) == b1(n) %same
                    match = match + 1;
                    
                    break
                end
            end
        end
        
        if match == k  % Full match
            matched = rxns{i,1};
            break
        end
    end
end

