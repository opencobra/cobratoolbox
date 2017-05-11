function [P, V, A] = extremePools(model, positivity, inequality)
% calculate the extreme pools of a stoichiometric model using the vertex/facet enumeration package
% lrs by David Avis, McGill University
%
% INPUT:
%     model.S   m x n Stoichiometric matrix with integer coefficients. If no
%               other inputs are specified it is assumed that all reactions are
%               reversible and S.v = 0
%
% OPTIONAL INPUT:
%     model.SIntRxnBool  n x 1 boolean vector with 1 for internal reactions
%     model.description
%     positivity {0,(1)} if positivity==1, then positive orthant base
%     inequality {(0),1} if inequality==1, then use two inequalities rather than a single equaltiy

[nMet, nRxn] = size(model.S);

if isfield(model, 'SIntRxnBool')
    A = model.S(:, model.SIntRxnBool)';
else
    A = model.S';
end

if nnz(A - round(A))
    figure
    spy(A - round(A))
    title('S-round(S)')
    error('Stoichiometric coefficients must be all integers')
end

a = zeros(size(A, 1));

if isfield(model, 'description')
    filename = model.description;
else
    filename = 'model';
end

if ~exist('positivity', 'var')
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
lrsInputHalfspace(A, D, filename, positivity, inequality, a, d, f, sh);

% pause(eps)
if isunix
    [status, result] = system('which lrs');
    if ~isempty(result)
        % call lrs and wait until extreme pathways have been calculated
        systemCallText = ['lrs ' pwd filesep filename '_' suffix '.ine > ' pwd filesep filename '_' suffix '.ext'];
        [status, result] = system(systemCallText);
    else
        error('lrs not installed or not in path')
    end
else
    error('non unix machines not yet supported')
end

[P, V] = lrsOutputReadRay([filename '_' suffix '.ext']);
P = P';
A = A';
if any(any(P * A ~= 0))
    warning('extreme pool not in nullspace of stoichiometric matrix')
end
