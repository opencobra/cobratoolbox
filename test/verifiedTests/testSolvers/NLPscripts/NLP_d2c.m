function d2c = NLP_d2c(x, lam, Prob)
% d2c=NLP_d2c(x, lam, Prob)
% From tomlab quickguide

% The only nonzero element in the second derivative matrix for the single
% constraint is the (1,1) element, which is a constant -2.

d2c = lam(1) * [-2 0; 0 0];
