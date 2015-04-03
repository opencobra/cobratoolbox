function Supp = findSparseMode( J, P, singleton, model, epsilon )
% Supp = findSparseMode( J, P, singleton, model, epsilon )
% Finds a mode that contains as many reactions from J and as few from P
% Returns its support, or [] if no reaction from J can have flux above epsilon
%
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg

Supp = [];
% J is the set of reactions for which card(v) is maximized
if isempty( J )
    return;
end
%Fastcore first tests the irreversible reactions then the reversible ones.
%If reversible reactions of set J have an absolute flux below epsilon,
%the sign of the reversible reactions in set J is flipped and
%eventually card(v) of the reamining reactions in J is maximized one by one
%in the singleton step.
if singleton
    %V is the flux vector that approximately maximizes card(v)
    %for the set of reactions in J
    V = LP7( J(1), model, epsilon ); %Maximises card(v) for the 1st
    %element in J
else
    V = LP7( J, model, epsilon ); %Maximises card(v) for all
    %elements in J
end
%K is the set of reactions having a flux above epsilon
K = intersect( J, find(V >= 0.99*epsilon) );

if isempty( K )
    return;
end

V = LP9( K, P, model, epsilon );%Minimizes the number of additional reactions
%from the set of penalized reactions P that are required for set
%K to carry a flux

Supp = find( abs(V) >= 0.99*epsilon );