function g = NLP_gradFunction(x, Prob)
% g = NLP_gradFunction(x, Prob)
% From tomlab quickguide

if isempty(Prob.uP)
    alpha = 100;
else
    alpha = Prob.uP(1);
end

g = [-4 * alpha * x(1) * (x(2) - x(1) ^ 2) - 2 * (1 - x(1)); 2 * alpha * (x(2) - x(1) ^ 2)];
