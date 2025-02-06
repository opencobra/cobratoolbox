function [P, vertexBool, N] = extremePools(model, param)
% Calculates the extreme pools of a stoichiometric model using the vertex / facet enumeration package
% such that 
%
% INPUT:
%    model.S  - `m x (n + k)` Stoichiometric matrix
% OPTIONAL INPUTS:
%    model.SConsistentRxnBool: n x 1  boolean indicating  stoichiometrically consistent metabolites
%    model.SIntRxnBool - Boolean of reactions heuristically though to be mass balanced.
%    model.SIntMetBool - Boolean of metabolites heuristically though to be involved in mass balanced reactions.
%
%    positivity:           {0, (1)} if `positivity == 1`, then positive orthant base
%    inequality:           {(0), 1} if `inequality == 1`, then use two inequalities rather than a single equaltiy
%
% OUTPUT:
%   P: p x m matrix of non-negative entries such that P*N = 0. 
%   vertexBool         n x 1 Boolean vector indicating which columns of P are vertices
%   N: m x n stoichiometric matrix used such that P*N.
%
% Author(s) Ronan Fleming


[nMet, nRxn] = size(model.S);

if isfield(model,'SConsistentRxnBool')
    N = model.S(:, model.SConsistentRxnBool)';
else
    %heuristically identify exchange reactions and metabolites exclusively
    %involved in exchange reactions
    if ~isfield(model,'SIntRxnBool')  || ~isfield(model,'SIntMetBool')
        if isfield(model,'mets')
            %attempts to finds the reactions in the model which export/import from the model
            %boundary i.e. mass unbalanced reactions
            %e.g. Exchange reactions
            %     Demand reactions
            %     Sink reactions
            model = findSExRxnInd(model,[],printLevel-1);
        else
            model.SIntMetBool=true(size(model.S,1),1);
            model.SIntRxnBool=true(size(model.S,2),1);
        end
    else
        if length(model.SIntMetBool)~=size(model.S,1) || length(model.SIntRxnBool)~=size(model.S,2)
            model = findSExRxnInd(model,[],printLevel-1);
        end
    end
    if isfield(model, 'SIntRxnBool')
        N = model.S(:, model.SIntRxnBool)';
    else
        N = model.S';
    end
end

if nnz(N - round(N))
    figure
    spy(N - round(N))
    title('S-round(S)')
    error('Stoichiometric coefficients must be all integers')
end

try
    % [rankA, p, q] = getRankLUSOL(N, 1);
    % N=N(:,q(1:rankA));
    [rankN, rowPerm, colPerm] = getRankLUSOL(N, 1);
    N = N(rowPerm(1:rankN), :);  % <-- Removing only rows instead of columns
    disp('extremePools: row reduction with getRankLUSOL worked.')
catch
    disp('extremePools: row reduction with getRankLUSOL did not work, check installation of LUSOL. Proceeding without it.')
end

if 0
    a = zeros(size(N, 1),1);

    if isfield(model, 'description')
        filename = model.description;
    else
        filename = 'model';
    end

    if exist('positivity', 'var')
        positivity = 1;
    end
    if ~exist('inequality', 'var')
        inequality = 0;
    end
    suffix = '';
    if positivity
        suffix = [suffix 'pos_'];
    else
        suffix = [suffix 'neg_'];
    end
    if inequality
        suffix = [suffix 'ineq'];
    else
        suffix = [suffix 'eq'];
    end

    % no inequalities
    D = [];
    d = [];

    % no linear objective
    f = [];

    % no shell script
    sh = 0;

    % INPUT
    % A          matrix of linear equalities A*x=(a)
    % D          matrix of linear inequalities D*x>=(d)
    % filename   base name of output file
    %
    % OPTIONAL INPUT
    % positivity {0,(1)} if positivity==1, then positive orthant base
    % inequality {0,(1)} if inequality==1, then use two inequalities rather than a single equaltiy
    % a          boundry values for matrix of linear equalities A*x=a
    % d          boundry values for matrix of linear inequalities D*x>=d
    % f          linear objective for a linear optimization problem in rational arithmetic
    %            minimise     f'*x
    %            subject to   A*x=(a)
    %                         D*x>=(d)
    lrsInputHalfspace(N, D, filename, positivity, inequality, a, d, f, sh);

    % pause(eps)
    [status, result] = system('which lrs');
    if ~isempty(result)
        % call lrs and wait until extreme pathways have been calculated
        systemCallText = ['lrs ' pwd filesep filename '_' suffix '.ine > ' pwd filesep filename '_' suffix '.ext'];
        [status, result] = system(systemCallText);
    else
        error('lrs not installed or not in path')
    end

    %old interface
    [P, V] = lrsOutputReadRay([filename '_' suffix '.ext']);
    P = P';
    N = N';
    if any(any(P * N ~= 0))
        warning('extreme pool not in nullspace of stoichiometric matrix')
    end

    % Q = [P, V];
    % vertexBool = false(size(Q,2),1);
    % vertexBool(size(P,2)+1:end,1)=1;

else
    if ~exist('param','var')
        param = struct();
    end
    if ~isfield(param,'positivity')
        param.positivity  = 1;
    end
    if ~isfield(param,'inequality')
        param.inequality  = 0;
    end
    if ~isfield(param,'debug')
        param.debug  = 0;
    end
    if isfield(model, 'description')
        modelName = model.description;
    else
        modelName = 'model';
    end

    % Set up the zero right-hand side for N*x = 0 (all constraints are equalities)
    b = zeros(size(N, 1),1);
    csense(1:size(N, 1),1)='E';

    % Output a file for lrs to convert an H-representation (half-space) of a
    % polyhedron to a V-representation (vertex / ray) via vertex enumeration
    % Write the half-space (H-representation) to file for LRS
    % Here, N is an (n x m) matrix representing the transposed stoichiometry (S^T).
    % The LRS tool will enumerate all nonnegative solutions x s.t. N*x = 0.
    fileNameOut = lrsWriteHalfspace(N, b, csense, modelName, param);

    %run lrs
    param.facetEnumeration  = 0;%vertex enumeration
    fileNameOut = lrsRun(modelName, param);

    %read in vertex representation
    [Q, vertexBool, fileNameOut] = lrsReadRay(modelName,param);

    %first vertices then rays
    V = Q(:,vertexBool);
    P = Q(:,~vertexBool)';%extreme rays

    % After LRS enumeration, we check that each extreme pool vector P indeed satisfies P*N' = 0,
    % ensuring it lies in the left null space of the original stoichiometric matrix (S).
    if any(any(P*N' ~= 0))
        warning('extreme pool not in left nullspace of stoichiometric matrix')
    end
end

if ~param.debug
    % delete generated files
    delete('*.ine');
    delete('*.ext');
    delete('*.sh');
    delete('*.time');
end
