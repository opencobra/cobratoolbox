function [A,modelFlipped,V] = fastcc(model,epsilon,printLevel, orig)
% [A,modelflipped,V] = fastcc(model,epsilon,printLevel,orig)
%
% The FASTCC algorithm for testing the consistency of a stoichiometric model
% Output A is the consistent part of the model
%
% INPUT
% model         cobra model structure containing the fields
%   S           m x n stoichiometric matrix    
%   lb          n x 1 flux lower bound
%   ub          n x 1 flux uppper bound
%   rxns        n x 1 cell array of reaction abbreviations
% 
% epsilon       
% printLevel    0 = silent, 1 = summary, 2 = debug
%
%OPTIONAL INPUT
% orig 	    Indicator whether the original code or COBRA adjusted code 
%           should be used. If original code is requested, CPLEX needs 
%           to be installed (default 0)
%
% OUTPUT
% A             n x 1 boolean vector indicating the flux consistent
%               reactions
% modelFlipped  the model with all flipped reactions necessitated during the consistency check
% V             n x k matrix such that S(:,A)*V(:,A)=0 and |V(:,A)|'*1>0
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg
%
% Ronan Fleming      17/10/14 Commenting of inputs/outputs/code
% Maria Pires Pacheco  27/01/15 Added a switch to select between COBRA code and the original code
tic 
if nargin < 4
   orig = 0;
end

origModel=model;

%number of reactions
N = (1:size(model.S,2));

%reactions assumed to be irreversible in forward direction
I = find(model.lb==0);

A = [];

% J is the set of irreversible reactions
J = intersect( N, I );
if printLevel>1
    fprintf('|J|=%d  ', numel(J));
end

%V is the n x k matrix of maximum cardinality vectors
V=[];

%v is the flux vector that approximately maximizes the cardinality 
%of the set of irreversible reactions v(J)
v = LP7( J, model, epsilon, orig );

%A is the set of reactions in v with absoulte value greater than epsilon
Supp = find( abs(v) >= 0.99*epsilon );
A = Supp;
if printLevel>1
    fprintf('|A|=%d\n', numel(A));
end

if length(A)>0
    %save the first v
    V=[V,v];
end

%incI is the set of irreversible reactions that are flux inconsistent
incI = setdiff( J, A );
if ~isempty( incI )
    if printLevel>0
        fprintf('\n(flux inconsistent subset of I detected)\n');
    end
end

%J is the set of reactions with absolute value less than epsilon in V
J = setdiff( setdiff( N, A ), incI);
if printLevel>1
    fprintf('|J|=%d  ', numel(J));
end

% reversible reactions have to be tried for flux consistency in both
% directions
flipped = false;
singleton = false;
JiRev=[];
orientation=ones(size(model.S,2),1);
while ~isempty( J )
    if singleton
        Ji = J(1);
        v = LP3( Ji, model, orig ) ;
    else
        Ji = J;
        v = LP7( Ji, model, epsilon, orig );
    end
    %Supp is the set of reactions in v with absoulte value greater than epsilon
    Supp = find( abs(v) >= 0.99*epsilon );
    %A is the set of reactions in V with absoulte value greater than epsilon
    nA1=length(A);
    A = union( A, Supp);
    nA2=length(A);
    
    %save v if new flux consistent reaction found
    if nA2>nA1
        if ~isempty(JiRev)
            %make sure the sign of the flux is consistent with the sign of
            %the original S matrix if any reactions have been flipped
            vf=v;
            vf=diag(orientation)*v;
            V=[V,vf];
            
            %sanity check
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
    %if the set of reactions in V with absolute value less than epsilon has
    %no reactions in common with the set of reactions in V with absolute value
    %greater than epsilon, then flip the sign of the reactions with absolute
    %value less than epsilon because perhaps they are flux consistent in
    %the reverse direction
    if ~isempty( intersect( J, A ))
        %J is the set of reactions with absolute value less than epsilon in V
        J = setdiff( J, A );
        if printLevel>1
            fprintf('|J|=%d  ', numel(J));
        end
        flipped = false;
    else
        %do not flip the direction of exclusively forward reactions
        JiRev = setdiff( Ji, I );
        
        if flipped || isempty( JiRev )
            %if reactions flipped, check if first reaction without flux
            %can really not carry flux
            %if only forward reactions are candidates suggested to be flipped
            %then report reaction as flux inconsistent
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
            %flipping the orientation of reactions
            model.S(:,JiRev) = -model.S(:,JiRev);
            tmp = model.ub(JiRev);
            model.ub(JiRev) = -model.lb(JiRev);
            model.lb(JiRev) = -tmp;
            flipped = true;
            %need to keep track of the orientation of model.S compared with
            %origModel.S
            orientation(JiRev)=orientation(JiRev)*-1;
            if printLevel>1
                fprintf('%s\n',['Flipped ' num2str(length(JiRev)) ' reaction.']);
            end
        end
    end
end

modelFlipped=model;

%sanity check
if norm(origModel.S*V,inf)>1e-6
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











