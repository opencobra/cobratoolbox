% GRAPHTOODEFY  Convert normal graph to Odefy model using some
% generalized combination logic.
% 
%   MODEL=GRAPHTOODEFY(A,ACTLOGIC,COMBLOGIC,INHLOGIC) creates an Odefy 
%   MODEL from an adjacency matrix A. Positive values are interpreted as 
%   activating edges whereas negative values represent inhibition.
%   ACTLOGIC, COMBLOGIC and INHLOGIC determine how to combine multiple
%   input edges for a node into a Boolean equation (see below).
%
%   There is no unique mapping from the graph space to the space of 
%   Boolean update rules. Thus, we have to assume a general scheme of how 
%   to generate a Boolean model from a graph:
%
%   For a given set of activators A1,...,An and inhibitors I1,...,Im, the
%   Boolean formulas are of the form
%
%   (A1 ! A2 ! ... ! An) $ NOT (I1 % I2 % ... % Im)
%
%   where ! stands for the activator logic, $ stands for the combination
%   logic and % stands for the inhibitor logic.
%
%   Each logic can be either 1 (logical AND) or 2 (logical OR)
%
%
%   Example:
%
%   M = [-1 0 1 0;1 0 0 -1;1 0 1 1;-1 1 0 0];
%   model = GraphToOdefy(M, 2, 1, 2)
%
%   Resulting in "at least one activator but no inhibitors" rules of the 
%   form:
%   (A1 OR ... OR An) AND NOT (I1 OR ... OR Im)

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function model=GraphToOdefy(A, actLogic, combLogic, inhLogic)

if nargin==1
    actLogic = 2;
    combLogic = 1;
    inhLogic = 2;
elseif nargin~=4
    error('Function takes 1 or 4 parameters');
end

% verify arguments
specs = {};
for i=1:size(A,1)
    specs{i} = char(64+i);
end

% get logical string
lstr = {'&&','||'};

n = size(A,1);
eqs = cell(n,1);
for i=1:n
    inter=A(:,i);
    % find activators
    act = find(inter>0);
    nact = numel(act);
    % find inhibitors
    inh = find(inter<0);
    ninh = numel(inh);
    
    % assemble equation
    eq = [specs{i} '='];
    if nact > 0
        eq = [eq '('];
        for j=1:nact
            eq = [eq specs{act(j)}];    
            if j<nact 
                eq = [eq lstr{actLogic}];
            end
        end
        eq = [eq ')'];
    end
    if ninh > 0
        if nact > 0
            eq = [eq lstr{combLogic}];
        end
        eq = [eq '~('];
        for j=1:ninh
            eq = [eq specs{inh(j)}];
            if j<ninh
                eq = [eq lstr{inhLogic}];
            end
        end
        eq = [eq ')'];
    end
    if nact==0 && ninh==0
        eq = [eq 'false'];
    end
    eqs{i} = eq;
    
   % eq
end

model = ExpressionsToOdefy(eqs);