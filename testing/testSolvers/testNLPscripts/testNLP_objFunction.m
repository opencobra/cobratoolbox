function f = testNLP_objFunction(x, Prob)
% f = testNLP_objFunction(x, Prob)
% From tomlab quickguide

if isempty(Prob.uP)
   alpha = 100;
else
   alpha = Prob.uP(1);
end

f = alpha*(x(2)-x(1)^2)^2 + (1-x(1))^2;