% Dynamic simulation of mutual inhibitory switch circuit (OR logics)
% Example code from the Odefy paper

% Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
% Free for non-commerical use, for more information: see LICENSE.txt
% http://cmb.helmholtz-muenchen.de/odefy

InitOdefy;
model = ExpressionsToOdefy({'a = a || ~b', 'b = b || ~a'});
[states, graph] = BooleanStates(model);
PrettyPrintStates(model, states);
simstruct = CreateSimstruct(model);
OdefyPhasePlane(simstruct, 1, 0:0.1:1, 2, 0:0.1:1, 'markends', true);