% The COBRAToolbox: testHillformula.m
%
% Purpose:
%     - Verify that the helper routine `hillformula` returns the correct
%       Hill-notation strings and throws the expected errors for bad inputs.
%
% Authors:
%     - Farid Zare  04/06/2025
%

global CBTDIR


currentDir = cd(fileparts(which(mfilename)));   % stash caller’s path
testPath   = pwd;                               % path for reference data
tol        = 1e-12;                             % generic tolerance

fprintf('   Testing testHillFormula ... \n')

% 3 -- Functional tests

% -------- Case 1 : methane from an atomic structure -------------------- %
r1.C = 1; r1.H = 4;
sp = hillformula(r1);
assert(iscell(sp) && strcmp(sp{1},'CH4'),                                   ...
    'Methane structure → wrong Hill string')

% -------- Case 2 : methanol round-trip --------------------------------- %
sp = hillformula('CH3OH');     % string-in
assert(strcmp(sp{1},'CH4O'),   ...
    'Methanol string → wrong Hill string')

% -------- Case 3 : sulphuric acid (no carbon) -------------------------- %
sp = hillformula('H2SO4');
assert(strcmp(sp{1},'H2O4S'),  ...
    'H2SO4 → wrong Hill string (alphabetical ordering failed)')

% -------- Case 4 : isotopes (D, T) and charge field Q ------------------ %
r4.C = 6; r4.H = 3; r4.D = 1; r4.Q = -1;
sp = hillformula(r4);          % C-first ordering, charge at tail
assert(strcmp(sp{1},'C6DH3-'), ...
    'Isotopes or charge handling failed')


% 4 -- Error-handling tests

% (a) No inputs --------------------------------------------------------- %
verifyCobraFunctionError('hillformula','inputs',{});

% (b) Too many inputs --------------------------------------------------- %
verifyCobraFunctionError('hillformula','inputs',{'H2O','extraArg'});

% (c) Wrong-type input (numeric) ---------------------------------------- %
verifyCobraFunctionError('hillformula','inputs',{42});

% 5 -- Wrap-up
% ----------------------------------------------------------------------- %%
cd(currentDir)                 % restore caller’s working directory
% output a success message
fprintf('Done.\n');