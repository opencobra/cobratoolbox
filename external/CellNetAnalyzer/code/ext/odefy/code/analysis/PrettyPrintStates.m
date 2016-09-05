% PRETTYPRINTSTATES Print steady states in human-readable format.
%
%   PRETTYPRINTSTATES(MODEL,STATES) prints a table of STATES with respect
%   to the MODEL, where each column represents a state and each row a 
%   species. Active states are marked as '+' and inactive states as '-'.
%
%   Please refer to 'help BooleanStates' for more information on the 
%   numerical representation of Boolean states.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function PrettyPrintStates(model, states)

n = numel(model.species);
s = numel(states);

statevecs = zeros(n,s);
for j=1:s
    statevecs(:,j) = num2bin(states(j), n);
end

for i=1:n
    fprintf('%s\t', model.species{i});
    for j=1:s
        c = '';
        if statevecs(i,j)
            c = '1';
        else
            c = '0';
        end
        fprintf('%s ', c);
    end
    fprintf('\n');
    % fprintf('%s %s\n', model.species{i}, c);
end
