function Supp = findSparseMode( J, P, singleton, model, epsilon )
%
% Supp = findSparseMode( J, P, singleton, model, epsilon )
%
% Finds a mode that contains as many reactions from J and as few from P
% Returns its support, or [] if no reaction from J can get flux above epsilon

% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg

Supp = [];
if isempty( J ) 
  return;
end

if singleton
  V = LP7( J(1), model, epsilon );
else
  V = LP7( J, model, epsilon );
end

K = intersect( J, find(V >= 0.99*epsilon) );   

if isempty( K ) 
  return;
end

V = LP9( K, P, model, epsilon );

Supp = find( abs(V) >= 0.99*epsilon );
