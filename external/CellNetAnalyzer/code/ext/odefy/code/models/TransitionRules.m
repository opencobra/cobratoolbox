% TRANSITIONRULES
%
%   RESULT=TRANSITIONRULES(MAT,NOTMAT,ENABLED) generates transition rules
%   from CellNetAnalyzer matrices. Optionally  takes a vector of enabled
%   reactions.
%
%   Parameters: mat and NOTflags from the CNA network MATLAB structure
%
%   Returns a cell array of rules, each rule contains a 1 for positive
%   literals and a -1 for negative literals
%  
%   This is an Odefy helper function which should not be called directly.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function result = TransitionRules(mat, notmat, enabled)

numspecies = size(mat,1);

% initialize result cell array
result{numspecies} = [];

% set enabled reactions to 1 if not given
if (nargin == 2)
    enabled = ones(size(mat,2),1);
end

% iterate over all reactions
for i=1:size(mat,2)
    % only enabled reactions
    if (enabled(i))
        % determine the output species
        spec = find(mat(:,i) > 0);
        % only proceed if there is an output node
        if (size(spec) ~= 0)
            % get vector
            vec = -mat(:,i); % minus to turn the -1 input values to +1
            if (vec(spec) == -2)
                  vec(spec) = 1;
            else
                  vec(spec) = 0;
            end
          
            
            % negate those which are marked as negatives in the NOT matrix
            nots = find(notmat(:,i) == 0);
            for j=1:size(nots)
                vec(nots(j)) = -vec(nots(j));
            end
            % add to result
            if (size(result{spec},1) == 0)
                result{spec} = vec;
            else
                result{spec}(:,size(result{spec},2)+1) = vec;
            end
        end
    end
end

function v = bin2vec(binnum, n)

v = zeros(n,1);

for i=n-1:-1:0
    pow2 = 2^i;
    if binnum >= pow2
        v(i+1) = 1;
        binnum = binnum - pow2;
    end
end