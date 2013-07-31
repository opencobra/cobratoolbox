% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted.
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2012

function model = fixExchangeRxns(model)
% fixedModel = fixExchangeRxns(model)
% 
% INPUT
%   model - cobra reconstruction model
% OUTPUT
%   model - reconstruction model with faulty exchange reactions fixed
%    
%   Formula:
%       A[a] <=>        Correct
%       <=> A[a]        Wrong
% 
%   Script changes model.S entries +1 to -1. Nonreversible reactions are
%   skipped. 

for i = 1:size(model.S,2)
    if size(find(full(model.S(:,i))),1) == 1 && model.rev(i) == 1  
        if  model.S(find(model.S(:,i)),i) == 1
            model.S(find(model.S(:,i),i),i) = -1;
        end
    end
end

