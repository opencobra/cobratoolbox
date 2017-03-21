function [out] = errorComputation2(x,Prob)
expdata = Prob.user.expdata;
model = Prob.user.model;
out = 0;
if iscell(expdata)
    for i = 1:length(expdata)
        t = scoreC13Fit(x,expdata{i},model);
        out = out + t.error;
    end
else
    t = scoreC13Fit(x,expdata,model);
    out = t.error;
end

% if isfield(Prob.user, 'scaled')
%     out = out*Prob.user.scaled;
% end

if isfield(Prob.user, 'objective')
    error = out;
    out = Prob.user.objective'*x;
    if error > Prob.user.max_error
        out = out + Prob.user.multiplier*(Prob.user.max_error-error)^2;
    end
end

if isnan(out)
    save errorFile x Prob
end
return;
