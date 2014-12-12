function A = fastcc( model, epsilon ) 
%
% A = fastcc( model, epsilon )
%
% The FASTCC algorithm for testing the consistency of an input model
% Output A is the consistent part of the model
%
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg
% 
%Fast Reconstruction of Compact Context-Specific Metabolic Network Models
% ( Vlassis et al. 2014)   10.1371/journal.pcbi.1003424
%
%
%INPUT
%
%  C        Core reactions vector containing indexes of the reactions in the input model that are highly supported in the context of interest
%  model    COBRA model structure
%  epsilon  flux smaller in absolute value than this value will be considered to be zero
%
%
%OUTPUT
%
%  A        Active reactions vector containing indexes of reactions of the
%  input model that are not blocked 


tic

N = (1:numel(model.rxns));
I = find(model.rev==0);

A = [];

% start with I
J = intersect( N, I ); fprintf('|J|=%d  ', numel(J));
V = LP7( J, model, epsilon ); 
Supp = find( abs(V) >= 0.99*epsilon );  
A = Supp;  fprintf('|A|=%d\n', numel(A));
incI = setdiff( J, A );    
if ~isempty( incI )
    fprintf('\n(inconsistent subset of I detected)\n');
end
J = setdiff( setdiff( N, A ), incI);  fprintf('|J|=%d  ', numel(J));

% reversible reactions
flipped = false;
singleton = false;        
while ~isempty( J )
    if singleton
        Ji = J(1);
        V = LP3( Ji, model ) ; 
    else
        Ji = J;
        V = LP7( Ji, model, epsilon ) ; 
    end    
    Supp = find( abs(V) >= 0.99*epsilon );  
    A = union( A, Supp);  fprintf('|A|=%d\n', numel(A)); 
    if ~isempty( intersect( J, A ))
        J = setdiff( J, A );     fprintf('|J|=%d  ', numel(J));
        flipped = false;
    else
        JiRev = setdiff( Ji, I );
        if flipped || isempty( JiRev )
            flipped = false;
            if singleton
                J = setdiff( J, Ji );  
                fprintf('\n(inconsistent reversible reaction detected)\n');
            else
                singleton = true;
            end
        else
            model.S(:,JiRev) = -model.S(:,JiRev);
            tmp = model.ub(JiRev);
            model.ub(JiRev) = -model.lb(JiRev);
            model.lb(JiRev) = -tmp;
            flipped = true;  fprintf('(flip)  ');
        end
    end
end

if numel(A) == numel(N)
    fprintf('\nThe input model is consistent.\n'); 
end

toc
