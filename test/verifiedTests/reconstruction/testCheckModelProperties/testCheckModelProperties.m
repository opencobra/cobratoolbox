% The COBRAToolbox: testCheckModelProperties.m
%
% Purpose:
%     - checkModelProperties computes generic properties of a model: the internal and exchange
%     reactions, the leak and siphon metabolites, the stoichiometrically, flux and thermodynamically
%     consistent subsets, the ranks of [F R], [F;R] and S and the extreme stoichiometric coefficients.
%       Characterization test that PINS the current behaviour (feature
%       20261029-120000-checkmodelproperties-scalability, Constitution Principle III characterization
%       mode); it must not change the function under test. It is the reference that the memory and
%       runtime enhancement of the function is checked against.
%
% Function under test:
%     src/reconstruction/modelGeneration/modelProperties/checkModelProperties.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - the smallest stored model (ecoli_core_model) and hand-built models, an LP solver.
%
% Coverage (measured with the MATLAB profiler on the unmodified function, 219 of 340 runnable lines):
%     The lines below are not executed. They are exempt under Constitution III-Coverage, the
%     first group because no argument of the function reaches them.
%     Unreachable, switched by a constant inside the function:
%       126-146   coefficient scaling cases ('minimumCoefficient', 'gmscal'); scaling = 'none' (line 120)
%       227-324   the whole 'checkTrivial' branch (checkTrivial = 0, line 116), including the
%                 dense row and column normalisations at lines 275 and 301
%       375-380   flux consistency bounds 'aThousand' and 'infinity'; the setting is 'reconstruction'
%       409, 426-427, 652-663   'if 0' debug branches
%       488-494   zero columns report, disabled by '&& 0'
%       574-609   rank-selection cases 'a' to 'd'; the setting is 'e'
%     Reachable only by a model state that the heuristic solvers did not produce on either model:
%       214       exchange reactions reported that were internal before the stoichiometric test
%       221-224   metabolites reported that occur only in exchange reactions
%       342       the warning that h[c] is stoichiometrically inconsistent
%       347       the error for a consistent exchange reaction (contradicts the construction in
%                 findStoichConsistentSubset)
%       477-480, 483   metabolites that are consistent in every test and still have a zero row
%
% Known defects documented (NOT tested, NOT fixed here):
%     DEFECT: minSij is zero for every model with a zero in S
%       SEVERITY: wrong-result
%       TRIGGER: any model with a sparse S (min(min(abs(S))) includes the structural zeros)
%       OBSERVED: model.minSij = 0, although the documentation says minimum NONZERO magnitude
%       EXPECTED: the smallest nonzero magnitude
%       LINES: 791
%     DEFECT: the sanity checks after the rank computation never fire
%       SEVERITY: wrong-result (silent)
%       TRIGGER: always
%       OBSERVED: error('') with an empty message is a no-op in MATLAB, so the checks at lines
%         706-711 test nothing
%       EXPECTED: an error when a row or column used for the rank analysis is not classified
%       LINES: 706-711
%     DEFECT: the thermodynamic consistency counts vary between runs
%       SEVERITY: cosmetic
%       TRIGGER: findThermoConsistentFluxSubset uses randomised passes
%       OBSERVED: the numbers of thermodynamically consistent reactions on a stored model may
%         differ by a few reactions; this test therefore pins only quantities that do not depend
%         on those counts (ranks of the whole matrix, the booleans of the small model)
%       EXPECTED: a deterministic result
%       LINES: 431
%
% Authors:
%     - Generated for feature 20261029-120000-checkmodelproperties-scalability, 2026-10-29.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckModelProperties'));
cd(fileDir);

% declare the requirements of this test: an LP solver
solverPkgs = prepareTest('requiredSolvers', {'gurobi'});

% the E. coli core model: 72 metabolites, 95 reactions
model = getDistributedModel('ecoli_core_model.mat');
[nMet, nRxn] = size(model.S);

%% ecoli core, default printLevel, nothing precomputed
txt = evalc('out = checkModelProperties(model);');
assert(~isempty(strfind(txt, 'findMassLeaksAndSiphons START')));
assert(isequal(size(out.S), [nMet nRxn]));
% the booleans have the size of the matrix
for f = {'SIntRxnBool', 'SConsistentRxnBool', 'fluxConsistentRxnBool', 'thermoFluxConsistentRxnBool', ...
         'FRuniqueColBool', 'FRnonZeroColBool', 'FRVcols', 'FRVicols', 'FRVdcols', 'leakRxnBool', 'siphonRxnBool'}
    assert(numel(out.(f{1})) == nRxn, f{1});
end
for f = {'SIntMetBool', 'SConsistentMetBool', 'fluxConsistentMetBool', 'thermoFluxConsistentMetBool', ...
         'FRuniqueRowBool', 'FRnonZeroRowBool', 'FRrows', 'FRirows', 'FRdrows', 'leakMetBool', 'siphonMetBool'}
    assert(numel(out.(f{1})) == nMet, f{1});
end
% ranks that do not depend on the solver
assert(out.rankFRvanilla == 72 && out.rankFRVvanilla == 95);
assert(out.rankS == 67);
assert(abs(out.maxSij - 104.81) < 1e-9);
% the rows and columns of the rank analysis split into independent and dependent ones
assert(isequal(out.FRirows | out.FRdrows, out.FRrows));
assert(isequal(out.FRVicols | out.FRVdcols, out.FRVcols));
assert(out.rankFR + out.FRrowRankDeficiency == nnz(out.FRrows));
assert(out.rankFRV + out.FRcolRankDeficiency == nnz(out.FRVcols));
% the exchange reactions are not stoichiometrically consistent
assert(~any(out.SConsistentRxnBool & ~out.SIntRxnBool));

%% printLevel 0 prints nothing from the function and gives the same booleans
txt0 = evalc('out0 = checkModelProperties(model, 0);');
assert(isempty(strfind(txt0, 'Diagnostics on size of boolean vectors')));
assert(isequal(out0.SIntRxnBool, out.SIntRxnBool) && isequal(out0.SConsistentRxnBool, out.SConsistentRxnBool));
assert(out0.rankS == out.rankS && out0.rankFRvanilla == out.rankFRvanilla);

%% fields that are already present are reused, and a wrong length is recomputed
pre = model;
pre.SIntRxnBool = out.SIntRxnBool;
pre.SIntMetBool = out.SIntMetBool;
pre.fluxConsistentMetBool = out.fluxConsistentMetBool;
pre.fluxConsistentRxnBool = out.fluxConsistentRxnBool;
evalc('outPre = checkModelProperties(pre, 0);');
assert(isequal(outPre.SIntRxnBool, out.SIntRxnBool));
assert(isequal(outPre.fluxConsistentRxnBool, out.fluxConsistentRxnBool));
assert(isequal(outPre.fluxConsistentMetBool, out.fluxConsistentMetBool));
short = pre;
short.SIntRxnBool = short.SIntRxnBool(1:end-1);
short.SIntMetBool = short.SIntMetBool(1:end-1);
evalc('outShort = checkModelProperties(short, 0);');
assert(numel(outShort.SIntRxnBool) == nRxn && numel(outShort.SIntMetBool) == nMet);
assert(isequal(outShort.SIntRxnBool, out.SIntRxnBool));

%% a small network with a dependent row, a dependent column and an inconsistent loop
%   EX_A  -> A                  exchange
%   r1    A -> X + Y
%   r1b   2 A -> 2 X + 2 Y      column of r1 up to a factor of two
%   r2    X + Y -> B            X and Y always occur together: dependent row of [F R]
%   EX_B  B ->                  exchange
%   i1    h[c] -> 2 D           elementally imbalanced loop
%   i2    D -> h[c]
mets = {'A'; 'X'; 'Y'; 'B'; 'h[c]'; 'D'};
rxns = {'EX_A'; 'r1'; 'r1b'; 'r2'; 'EX_B'; 'i1'; 'i2'};
S = zeros(6, 7);
S(1, 1) = 1;
S(1, 2) = -1; S(2, 2) = 1; S(3, 2) = 1;
S(1, 3) = -2; S(2, 3) = 2; S(3, 3) = 2;
S(2, 4) = -1; S(3, 4) = -1; S(4, 4) = 1;
S(4, 5) = -1;
S(5, 6) = -1; S(6, 6) = 2;
S(5, 7) = 1;  S(6, 7) = -1;
small.S = sparse(S);
small.mets = mets;
small.rxns = rxns;
small.rxnNames = rxns;
small.metFormulas = {'C2'; 'C'; 'C'; 'C2'; 'H'; 'H'};
small.lb = zeros(7, 1);
small.lb(1) = -1000;
small.ub = 1000 * ones(7, 1);
small.c = zeros(7, 1);
small.b = zeros(6, 1);

txt = evalc('sm = checkModelProperties(small, 3);');
assert(isequal(double(sm.SIntRxnBool'), [0 1 1 1 0 1 1]));
assert(isequal(double(sm.SIntMetBool'), ones(1, 6)));
assert(isequal(double(sm.SConsistentRxnBool'), [0 1 1 1 0 1 0]));
assert(isequal(double(sm.SInConsistentRxnBool'), [1 0 0 0 1 0 0]));
assert(isequal(double(sm.unknownSConsistencyRxnBool'), [0 0 0 0 0 0 1]));
assert(isequal(double(sm.leakRxnBool'), [0 0 0 0 0 1 1]));
assert(~any(sm.siphonRxnBool) && ~any(sm.siphonMetBool));
assert(isequal(double(full(sm.leakMetBool))', [0 0 0 0 1 1]));
assert(isequal(double(sm.fluxConsistentRxnBool'), [1 1 1 1 1 0 0]));
assert(isequal(double(sm.fluxConsistentMetBool'), [1 1 1 1 0 0]));
assert(isequal(double(sm.thermoFluxConsistentRxnBool'), [1 1 1 1 1 0 0]));
assert(isequal(double(sm.thermoFluxConsistentMetBool'), [1 1 1 1 0 0]));
assert(isequal(double(full(sm.FRrows)'), [1 1 1 1 0 0]));
assert(isequal(double(full(sm.FRVcols)'), [1 1 1 1 1 0 0]));
% ranks: the row of Y depends on the row of X, the column of r1b on the column of r1
assert(sm.rankFR == 3 && sm.rankFRV == 4 && sm.rankS == 5);
assert(sm.rankFRvanilla == 5 && sm.rankFRVvanilla == 6);
assert(sm.FRrowRankDeficiency == 1 && sm.FRcolRankDeficiency == 1);
assert(nnz(sm.FRirows) == 3 && nnz(sm.FRdrows) == 1);
assert(nnz(sm.FRVicols) == 4 && nnz(sm.FRVdcols) == 1);
assert(isequal(size(sm.FRW), [1 6]) && isequal(size(sm.FRVW), [7 1]));
assert(isequal(find(sm.FRwrows)', [2 3]) && isequal(find(sm.FRVwcols)', [2 3]));
% the dependency relations annihilate the restricted halves
Fh = -small.S; Fh(Fh < 0) = 0; Rh = small.S; Rh(Rh < 0) = 0;
assert(norm(sm.FRW * [Fh(:, sm.FRVcols), Rh(:, sm.FRVcols)], inf) < 1e-9);
assert(norm([Fh(sm.FRrows, :); Rh(sm.FRrows, :)] * sm.FRVW, inf) < 1e-9);
assert(sm.maxSij == 4);
% flat copy of the settings used: every printLevel gives the same booleans
for pl = [0 1 2]
    evalc('smp = checkModelProperties(small, pl);');
    assert(isequal(smp.SConsistentRxnBool, sm.SConsistentRxnBool) && isequal(smp.fluxConsistentRxnBool, sm.fluxConsistentRxnBool));
    assert(smp.rankFR == sm.rankFR && smp.rankFRV == sm.rankFRV);
end

% return to the original directory
cd(currentDir);
