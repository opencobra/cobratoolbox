function [R1_missing,R2_missing,R12_bounds,R12_bounds_mismatch] = compareBounds2Models(model1,model2)
% This function compares the bounds between two models
%
%
%


% find the overlapping set of reaction between the two models
R1 = model1.rxns;
R2 = model2.rxns;
R12 = unique([R1;R2]);
R1_missing = '';
R2_missing = '';
R12_bounds_mismatch = {};
mismatch_lb = 0;
mismatch_ub = 0;
cnt = 1;
cntM = 1;
for i = 1 : length(R12)
        r1 = find(ismember(R1,R12(i)));
        r2 = find(ismember(R2,R12{i}));
    if isempty(r1) % reaction does not exist in model1
        R1_missing = [R1_missing;R12{i}];
    elseif isempty(r2) % reaction does not exist in model2
        R2_missing = [R2_missing;R12{i}];
    else
        % compare bounds in both models
        % lower bound
        if model1.lb(r1) == model2.lb(r2)
            R12_bounds(cnt,1) = R12(i);
            R12_bounds{cnt,2} = 'identical lower bound';
            R12_bounds(cnt,3) = num2cell(model1.lb(r1));
            R12_bounds(cnt,4) = num2cell(model2.lb(r2));
            cnt = cnt+1;
        else
            R12_bounds_mismatch(cntM,1) = R12(i);
            R12_bounds_mismatch{cntM,2} = 'NOT identical lower bound';
            R12_bounds_mismatch(cntM,3) = num2cell(model1.lb(r1));
            R12_bounds_mismatch(cntM,4) = num2cell(model2.lb(r2));
            mismatch_lb = mismatch_lb +1;
            cntM = cntM+1;
        end
        if model1.ub(r1) == model2.ub(r2)
            R12_bounds(cnt,1) = R12(i);
            R12_bounds{cnt,2} = 'identical upper bound';
            R12_bounds(cnt,3) = num2cell(model1.ub(r1));
            R12_bounds(cnt,4) = num2cell(model2.ub(r2));
            cnt = cnt+1;
        else
            R12_bounds_mismatch(cntM,1) = R12(i);
            R12_bounds_mismatch{cntM,2} = 'NOT identical upper bound';
            R12_bounds_mismatch(cntM,3) = num2cell(model1.ub(r1));
            R12_bounds_mismatch(cntM,4) = num2cell(model2.ub(r2));
            mismatch_ub = mismatch_ub +1;
            cntM = cntM+1;
        end
    end
end
mismatch_lb
mismatch_ub

