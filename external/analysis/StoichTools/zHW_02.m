%% zHW: Hill Notation
%
% An analysis of a compound shows it to be 63.94 mass% Carbon, 7.15 mass%
% Hydrogen, and the rest (28.91%) is Oxygen. What is the Hill Notation for
% this compound?

%% Problem Data
%
% The problem data is given as mass fractions of the atomic species.

wC = 0.6394;
wH = 0.0715;
wO = 1 - wC - wH;

%% Convert to Molar Units

nC = wC/molweight('C');
nH = wH/molweight('H');
nO = wO/molweight('O');

%% Approximate Atomic Representation
%
% This is the trickiest part of the problem. Here we construct
% approximate ratios of carbon, hydrogen, and oxygen in the compound and
% put this into an atomic represenation using a Matlab structure.

d = min([nC nH nO]);

r = struct([]);
r(1).C = round(nC/d);
r(1).H = round(nH/d);
r(1).O = round(nO/d);

%% Error Analysis
% 
% Let's see if our simple approximation solved the problem. If not, we
% would need to do some more work to develop a better approximation.

vC = r.C*molweight('C');
vH = r.H*molweight('H');
vO = r.O*molweight('O');

vT = vC+vH+vO;

fprintf('Approximation Errors\n');
fprintf('    Carbon: %5.2f %%\n',100*(vC/vT-wC)/wC);
fprintf('  Hydrogen: %5.2f %%\n',100*(vH/vT-wH)/wH);
fprintf('    Oxygen: %5.2f %%\n',100*(vO/vT-wO)/wO);

%% Hill Formula
%
% The error analysis shows the approximate atomic representation is an
% acceptable solution to the problem. So the last step is to construct the
% Hill Formula.

s = hillformula(r);
fprintf('\nFormula in Hill Notation = %s\n',s{:});

