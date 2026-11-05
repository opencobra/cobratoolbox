% The COBRAToolbox: testKLDis.m
%
% Purpose:
%     - test the functionality of KLDis
%
% Function under test:
%     src/analysis/KLdistance/KLDis.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model and no solver, hand-built matrices.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Loic Marx
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which(mfilename)));

% declare the requirements of this test (a Tier 1 test has none)
prepareTest();

% set the tolerance
tol = 1e-6;

% Generate 2 matrix of the same size
P = [1 2; 2 1];
Q = [3 2; 2 3];

% run the function 
KLD = KLDis(P,Q);

% compare the scaled matrix against the reference data
assert(norm(KLD - 0.12723233459191 * [1; 1]) < tol)

Q2 = [inf inf]; 
P2 = [inf inf];

% Test if KLDis throws an error
assert(verifyCobraFunctionError('KLDis','inputs', {P, Q(:,1)}, 'testMessage', 'the number of columns in P and Q should be the same'));
assert(verifyCobraFunctionError('KLDis','inputs', {P2, Q2}, 'testMessage', 'the inputs contain non-finite values!'));

%% a single reference distribution Q is compared with every row of P

Pmany = [1 2; 2 1; 1 1];
Qsingle = [3 1];
KLDsingle = KLDis(Pmany, Qsingle);

% one distance per row of P, equal to the definition on the normalised distributions
Pnorm = Pmany ./ sum(Pmany, 2);
Qnorm = Qsingle / sum(Qsingle);
assert(isequal(size(KLDsingle), [3, 1]));
assert(norm(KLDsingle - sum((Pnorm - Qnorm) .* log10(Pnorm ./ Qnorm), 2)) < tol);

% worked by hand for P = [1/2 1/2] and Q = [3/4 1/4]: (1/4)*log10(2) - (1/4)*log10(2/3)
assert(abs(KLDsingle(3) - 0.25 * log10(3)) < tol);

% a distribution has distance zero to itself, whatever its scale
assert(abs(KLDis([6 2], Qsingle)) < tol);

%% a bin that is empty in both distributions adds nothing to the distance

% the 0/0 of that bin is NaN and is resolved to 0, so the result is that of the other two bins
assert(abs(KLDis([0 1 1], [0 1 3]) - 0.25 * log10(3)) < tol);
assert(norm(KLDis([0 1 1; 0 3 1], [0 1 3; 0 1 3]) - [0.25 * log10(3); 0.5 * log10(9)]) < tol);

% change the directory
cd(currentDir)
