function [ret] = eval_exp(x, a_i)
ret = exp(-a_i * norm(x,2)^2);
end