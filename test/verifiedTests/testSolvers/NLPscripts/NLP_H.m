function H = NLP_H(x, Prob)
% H = NLP_H(x, Prob)
% From tomlab quickguide

if isempty(Prob.uP)
    alpha = 100;
else
    alpha = Prob.uP(1);
end

H = [12 * alpha * x(1) ^ 2 - 4 * alpha * x(2) + 2, -4 * alpha * x(1);
     -4 * alpha * x(1),    2 * alpha];
