function [EPproblem, nEvar] = prepareEnzymeConstrainedEP(EPproblem, model, m, n, nCoupling, enzymeEntropyWeight)
% Fold optional enzyme-constrained (GECKO) column variables into an assembled
% entropic problem, for entropicFluxBalanceAnalysis.
%
% USAGE:
%
%    [EPproblem, nEvar] = prepareEnzymeConstrainedEP(EPproblem, model, m, n, nCoupling, enzymeEntropyWeight)
%
% INPUTS:
%    EPproblem:              partially-assembled entropic problem with fields
%                            `.A` (rows ordered metabolite(m), internal-net(n),
%                            coupling(nCoupling), other), `.c`, `.lb`, `.ub`, `.d`
%    model:                  COBRA model carrying the optional column-variable
%                            fields `model.E` (enzyme columns in the metabolite
%                            rows), `model.D` (enzyme columns in the coupling
%                            rows), `model.evarlb`, `model.evarub`, `model.evarc`
%    m:                      number of metabolite (S) rows
%    n:                      number of internal (SConsistent) reactions
%    nCoupling:              number of coupling (`model.C`) rows (0 if none)
%
% OPTIONAL INPUTS:
%    enzymeEntropyWeight:    entropy weight applied to the enzyme-usage columns:
%                            0 or `[]` (default) => linear-only enzyme variables;
%                            a positive scalar or nEvar-vector => enzyme columns
%                            carry an entropy term (added to `EPproblem.d`)
%
% OUTPUTS:
%    EPproblem:              the problem with `nEvar` enzyme columns appended to
%                            `.A`/`.c`/`.lb`/`.ub`/`.d`
%    nEvar:                  number of enzyme-usage variables folded in
%
% NOTE:
%
%    The enzyme columns are appended AFTER all existing columns (matching the
%    `buildOptProblemFromModel` [S E; C D] ordering): `model.E` occupies the
%    metabolite rows, `model.D` the coupling rows, zeros elsewhere. When
%    `enzymeEntropyWeight` is 0/[] the enzyme variables are linear-only (their
%    `.d` entries are 0), so `nnz(.d)` and the exponential-cone count are
%    unchanged.
%
% .. Author:
%       - Generated for feature 010-gecko-entropic-fba, 2026-07-15.

if ~exist('enzymeEntropyWeight', 'var') || isempty(enzymeEntropyWeight)
    enzymeEntropyWeight = 0;
end

nEvar = size(model.E, 2);

% dimension validation (fail loud, with ME.stack via error)
if size(model.E, 1) ~= m
    error('COBRA:entropicFBA:enzymeDim', ...
        'prepareEnzymeConstrainedEP: model.E has %d rows but the stoichiometric matrix has %d metabolites.', ...
        size(model.E, 1), m);
end
if nCoupling > 0
    if size(model.D, 1) ~= nCoupling
        error('COBRA:entropicFBA:enzymeDim', ...
            'prepareEnzymeConstrainedEP: model.D has %d rows but there are %d coupling constraints.', ...
            size(model.D, 1), nCoupling);
    end
    if size(model.D, 2) ~= nEvar
        error('COBRA:entropicFBA:enzymeDim', ...
            'prepareEnzymeConstrainedEP: model.D has %d columns but model.E has %d.', ...
            size(model.D, 2), nEvar);
    end
elseif ~isempty(model.D) && any(model.D(:) ~= 0)
    error('COBRA:entropicFBA:enzymeDim', ...
        'prepareEnzymeConstrainedEP: model.D is nonempty but the model has no coupling (model.C) rows.');
end
if numel(model.evarlb) ~= nEvar || numel(model.evarub) ~= nEvar || numel(model.evarc) ~= nEvar
    error('COBRA:entropicFBA:enzymeDim', ...
        'prepareEnzymeConstrainedEP: evarlb/evarub/evarc must each have length nEvar (%d).', nEvar);
end
if any(model.evarlb(:) > model.evarub(:))
    error('COBRA:entropicFBA:enzymeBounds', ...
        'prepareEnzymeConstrainedEP: some model.evarlb exceed model.evarub.');
end

% build the enzyme column block with the correct row structure of EPproblem.A
nRows = size(EPproblem.A, 1);
enzymeCols = sparse(nRows, nEvar);
enzymeCols(1:m, :) = model.E;                          % metabolite rows
if nCoupling > 0
    enzymeCols(m + n + 1 : m + n + nCoupling, :) = model.D;   % coupling rows
end

% append columns and the matching entries
EPproblem.A = [EPproblem.A, enzymeCols];
EPproblem.c = [EPproblem.c; model.evarc(:)];
EPproblem.lb = [EPproblem.lb; model.evarlb(:)];
EPproblem.ub = [EPproblem.ub; model.evarub(:)];

% entropy weight on the enzyme columns (0 => linear-only)
if isscalar(enzymeEntropyWeight)
    dEnzyme = enzymeEntropyWeight * ones(nEvar, 1);
else
    dEnzyme = enzymeEntropyWeight(:);
end
EPproblem.d = [EPproblem.d; dEnzyme];
end
