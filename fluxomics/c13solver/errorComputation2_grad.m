function [out] = errorComputation2_grad(x,Prob)

model = Prob.user.model;
f0 = errorComputation2(x,Prob);
if length(x) == length(model.lb)
    method = 1;
else
    method = 2; % in terms of alpha
end

out = zeros(size(x));

if isfield(Prob.user, 'diff_interval')
    diff = Prob.user.diff_interval;
else
    diff = 1e-5;
end
if isfield(Prob.user, 'useparfor')
    useparfor = Prob.user.useparfor;
else
    useparfor = false;
end


if method == 2
    if useparfor
        parfor i = 1:length(x)
            xnew = x;
            tdiff = diff/norm(model.N(:,i));
            xnew(i) = xnew(i) + tdiff;
            f1 = errorComputation2(xnew, Prob);
            out(i) = (f1-f0)/tdiff;
        end
    else
        for i = 1:length(x)
            xnew = x;
            tdiff = diff/norm(model.N(:,i));
            xnew(i) = xnew(i) + tdiff;
            f1 = errorComputation2(xnew, Prob);
            out(i) = (f1-f0)/tdiff;
        end
    end
elseif method == 1
    idxzero = false(size(x));
    for i = 1:length(model.isotopomer)
        if isempty(model.isotopomer{i})
            idxzero(i) = true;
        end
    end

    if length(x) ~= length(model.lb)
        display('shoot');
        pause;
    end

    out = NaN*ones(length(x),1);
    out(idxzero) = 0;
else
    display('whoops');
    return;
end

return;