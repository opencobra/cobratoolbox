function A = fastcc_cvx( model, epsilon ) 

tic
N = (1:numel(model.rxns));
I = find(model.lb==0);

A = [];

% start with I
J = intersect( N, I ); fprintf('|J|=%d  ', numel(J));
V = LP7cvx( J, model, epsilon ); 
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
        V = LP3cvx( Ji, model ) ; 
    else
        Ji = J;
        V = LP7cvx( Ji, model, epsilon ) ; 
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
                disp(model.rxns(Ji));
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
