function [A,modelFlipped,V] = fastcc(model,epsilon,printLevel,modeFlag)
% [A,V] = fastcc(model,epsilon,printLevel)
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
% OPTIONAL INPUT
% modeFlag      {(0),1}; 1=return matrix of modes V
%
% OUTPUT
% A             n x 1 boolean vector indicating the flux consistent
%               reactions
% V             n x k matrix such that S(:,A)*V(:,A)=0 and |V(:,A)|'*1>0
 
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg
%
% Ronan Fleming      17/10/14 Commenting of inputs/outputs/code

if ~exist('printLevel','var')
    printLevel = 2;
end
if ~exist('modeFlag','var')
    modeFlag=0;
end

tic

%number of reactions
N = (1:size(model.S,2));

veryOrigModel=model;

%reactions irreversible in the reverse direction
Ir = find(model.ub<=0);
%flip direction of reactions irreversible in the reverse direction
model.S(:,Ir) = -model.S(:,Ir);
tmp = model.ub(Ir);
model.ub(Ir) = -model.lb(Ir);
model.lb(Ir) = -tmp;

%save the model with only the flips of the reverse reactions
origModel=model;

%all irreversible reactions should only be in the forward direction
I  = find(model.lb>=0);

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
[v, basis] = LP7( J, model, epsilon);

%A is the set of reactions in v with absoulte value greater than epsilon
Supp = find( abs(v) >= 0.99*epsilon );
A = Supp;
if printLevel>1
    fprintf('|A|=%d\n', numel(A));
end

if length(A)>0 && modeFlag
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
        [v, basis] = LP3( Ji, model, basis);
    else
        Ji = J;
        [v, basis] = LP7( Ji, model, epsilon, basis);
    end
    %Supp is the set of reactions in v with absoulte value greater than epsilon
    Supp = find( abs(v) >= 0.99*epsilon );
    %A is the set of reactions in V with absoulte value greater than epsilon
    nA1=length(A);
    A = union( A, Supp);
    nA2=length(A);
    
    %save v if new flux consistent reaction found
    if nA2>nA1 && modeFlag
        if ~isempty(JiRev)
            %make sure the sign of the flux is consistent with the sign of
            %the original S matrix if any reactions have been flipped
            len=length(orientation);
            vf=spdiags(orientation,0,len,len)*v;
            V=[V,vf];
            
            %sanity check
            if norm(origModel.S*vf)>epsilon/100
                fprintf('%g%s\n',epsilon/100, '= epsilon/100')
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

if modeFlag
    flippedReverseOrientation=ones(size(model.S,2),1);
    flippedReverseOrientation(Ir)=-1;
    %flip the direction of the returned fluxes
    V=spdiags(flippedReverseOrientation,0,size(model.S,2),size(model.S,2))*V;
    
    %sanity check
    if norm(veryOrigModel.S*V,inf)>epsilon/100
        fprintf('%g%s\n',epsilon/100, '= epsilon/100')
        fprintf('%g%s\n',norm(veryOrigModel.S*V,inf),' = ||S*V||.')
        if 0
            error('Flux consistency check failed')
        else
            warning('Flux consistency numerically challenged')
        end
    else
        if printLevel>0
            fprintf('%s\n','Flux consistency check finished...')
            fprintf('%10u%s\n',sum(any(V,2)),' = Number of flux consistent columns.')
            fprintf('%10f%s\n\n',norm(veryOrigModel.S*V,inf),' = ||S*V||.')
        end
    end
end
origModel=veryOrigModel;
if numel(A) == numel(N)
    if printLevel>0
        fprintf('\n fastcc.m: The input model is consistent.\n');
    end
end
if printLevel>1
    toc
end











