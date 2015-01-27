function [A,modelFlipped,V] = fastcc(model,epsilon,printLevel)
% [A,V] = fastcc(model,epsilon,printLevel)
%
% The FASTCC algorithm for testing the consistency of a stoichiometric model
% Output A is the consistent part of the model
%
% INPUT
% model         cobra model structure containing the fields
%   S           m x n stoichiometric matrix    
%   lb          n x 1 flux lower bound
%   ub          n x 1 flux upper bound
%   rxns        n x 1 cell array of reaction abbreviations
% epsilon       flux threshold       
% printLevel    0 = silent, 1 = summary, 2 = debug
%
% OUTPUT
% A             n x 1 boolean vector indicating the flux consistent
%               reactions
% modelFlipped  modified input cobra model for which the sign of the
%               several reverse reactions was changed so that the flux is 
%               carried in the forward direction. 
% V             n x k matrix such that S(:,A)*V(:,A)=0 and |V(:,A)|'*1>0
% 
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg
% 
% Fast Reconstruction of Compact Context-Specific Metabolic Network Models
% ( Vlassis et al. 2014)   10.1371/journal.pcbi.1003424
%
% Ronan Fleming      17/10/14 Commenting of inputs/outputs/code

tic

origModel=model;

% Number of reactions
N = (1:size(model.S,2));

% Reactions annotated to be irreversible (forward direction only)
I = find(model.rev==0);

A = [];

% J is the set of reactions for which card(v) is maximized
J = intersect( N, I );
if printLevel>1
    fprintf('|J|=%d  ', numel(J));
end

% V is the n x k matrix of maximum cardinality vectors
V=[];

% v is the flux vector that approximately maximizes the cardinality of v
% for the set of reactions J
v = LP7( J, model, epsilon );

% A is the set of reactions in v with absolute value greater than epsilon
Supp = find( abs(v) >= 0.99*epsilon );
A = Supp;
if printLevel>1
    fprintf('|A|=%d\n', numel(A));
end

if ~isempty(A)
    % save the first v
    V=[V,v];
end

% incI is the set of irreversible reactions that are flux inconsistent
incI = setdiff( J, A );
if ~isempty( incI )
    if printLevel>0
        fprintf('\n(flux inconsistent subset of I detected)\n');
    end
end

% J is the set of reactions with absolute value less than epsilon in V
J = setdiff( setdiff( N, A ), incI);
if printLevel>1
    fprintf('|J|=%d  ', numel(J));
end

% Reversible reactions have to be tried for flux consistency in both
% directions
flipped = false;
singleton = false;
JiRev=[];
orientation=ones(size(model.S,2),1);
while ~isempty( J )
    if singleton
        Ji = J(1);
        v = LP3( Ji, model ) ;
    else
        Ji = J;
        v = LP7( Ji, model, epsilon ) ;
    end
    % Supp is the set of reactions in v with absolute value greater than epsilon
    Supp = find( abs(v) >= 0.99*epsilon );
    % A is the set of reactions in V with absolute value greater than epsilon
    nA1=length(A);
    A = union( A, Supp);
    nA2=length(A);
    
    % Save v if new flux consistent reaction found
    if nA2>nA1
        if ~isempty(JiRev)
            % Make sure the sign of the flux is consistent with the sign of
            % the original S matrix if any reactions have been flipped
            vf=v;
            vf=diag(orientation)*v;
            V=[V,vf];
            
            % Sanity check
            if norm(origModel.S*vf)>1e-7
                pause(eps)
                fprintf('%s\t%g\n','should be zero :',norm(model.S*v)) % should be zero
                fprintf('%s\t%g\n','should be zero :',norm(origModel.S*vf)) % should be zero
                fprintf('%s\t%g\n','may not be zero:',norm(model.S*vf)) % may not be zero
                fprintf('%s\t%g\n','may not be zero:',norm(origModel.S*v)) % may not be zero 
                error('Flipped flux consistency step failed.')
            end
        else
            V=[V,v];
        end
    end
        
    if printLevel>1
        fprintf('|A|=%d\n', numel(A));
    end
    % If the set of reactions in V with absolute value less than epsilon has
    % no reactions in common with the set of reactions in V with absolute value
    % greater than epsilon, then flip the sign of the reactions with absolute
    % value less than epsilon because perhaps they are flux consistent in
    % the reverse direction
    if ~isempty( intersect( J, A ))
        % J is the set of reactions with absolute value less than epsilon in V
        J = setdiff( J, A );
        if printLevel>1
            fprintf('|J|=%d  ', numel(J));
        end
        flipped = false;
    else
        % Do not flip the direction of exclusively forward reactions
        JiRev = setdiff( Ji, I );
        
        if flipped || isempty( JiRev )
            % If reactions flipped, confirm if first reaction without flux
            % can not carry flux.
            % If only forward reactions are candidates suggested to be
            % flipped, then report reaction as flux inconsistent
            flipped = false;
            if singleton
                J = setdiff( J, Ji );
                if printLevel>1
                    fprintf('%s','Flux inconsistent reversible reaction detected:');
                end
                if printLevel>1
                    fprintf('%s\n',model.rxns{Ji});
                    if printLevel>1
                        save A A;
                    end
                end
            else
                singleton = true;
            end
        else
            % Flipping the orientation of reactions
            model.S(:,JiRev) = -model.S(:,JiRev);
            tmp = model.ub(JiRev);
            model.ub(JiRev) = -model.lb(JiRev);
            model.lb(JiRev) = -tmp;
            flipped = true;
            % Need to keep track of the orientation of model.S compared with
            % origModel.S
            orientation(JiRev)=orientation(JiRev)*-1;
            if printLevel>1
                fprintf('%s\n',['Flipped ' num2str(length(JiRev)) ' reaction.']);
            end
        end
    end
end

modelFlipped=model;

% Sanity check
if norm(origModel.S*V,inf)>epsilon
    norm(origModel.S*V,inf)
    error('Flux consistency check failed')
else
    fprintf('%s\n','Flux consistency check finished...')
    fprintf('%10u%s\n',sum(any(V,2)),' = Number of flux consistent columns.')
    fprintf('%10f%s\n\n',norm(origModel.S*V,inf),' = ||S*V||.')
end


if numel(A) == numel(N)
    if printLevel>0
        fprintf('\nThe input model is consistent.\n');
    end
end
if printLevel>1
    toc
end