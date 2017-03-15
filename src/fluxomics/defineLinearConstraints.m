function [A, b_L, b_U, model] = defineLinearConstraints(model, method)

fOffset = 1e-4;

if nargin < 2
    method = 1;
end

b_L = model.lb;
b_U = model.ub;
A = model.N;

%marked = zeros(length(model.lb), 1);
% for i = 1:size(A, 1)
%     if all(abs(A(i,:)) < 1e-5)
%         marked(i) = 2;
%         if b_L(i) > 1e-5 || b_U(i) < -1e-5
%             display('upperbound/lowerbound error');
%             pause;
%         end
%     end
% end
% marked
% pause;

%marked = zeros(size(A,1), 1);
% for  i = 1:length(model.lb)     
%     tmarked = marked;
%     tmarked(i) = 1;
%
%     LPproblem.A = model.S;
%
%     LPproblem.b = zeros(length(model.mets),1);
%     LPproblem.csense = ['E' * ones(length(model.mets), 1)];
%     LPproblem.ub = model.ub;
%     LPproblem.ub(tmarked ~= 0) = 1e6;
%     LPproblem.lb = model.lb;
%     LPproblem.lb(tmarked ~= 0) = -1e6;
%
%     LPproblem.osense = 1;
%
%     %minimize
%     LPproblem.c = zeros(length(model.lb),1);
%     LPproblem.c(i) = 1;
%     soln = solveCobraLP(LPproblem);
%     vmin = soln.obj;
%
%     %maximize
%     LPproblem.c = -LPproblem.c;
%     soln = solveCobraLP(LPproblem);
%     vmax = -soln.obj;
%
%     %[i b_L(i) vmin vmax b_U(i)]
%     if (vmin > b_L(i) + 1e-2 && vmax < b_U(i) - 1e-2)
%         %[i b_L(i) vmin vmax b_U(i)]
%         marked(i) = 1;
%     end
%
% end
% display ('done1');

marked = zeros(size(model.lb));
n = length(model.lb);
dirs = zeros(size(model.lb));
for i = 1:n
    if model.lb(i) == 0 && model.ub(i) > fOffset
        dirs(i)  = 1;
    elseif model.lb(i) < -fOffset && model.ub(i) == 0
        dirs(i) = -1;
    end
end



for i = 1:n
    if mod(i,10) == 0
        i;
    end

    LPproblem.A = model.S;

    LPproblem.b = zeros(length(model.mets),1);
    LPproblem.csense = ['E'*ones(length(model.mets), 1)];
    LPproblem.csense = char(LPproblem.csense);
    LPproblem.ub = model.ub;
    LPproblem.lb = model.lb;
    LPproblem.lb(marked > 0) = fOffset;
    LPproblem.ub(marked < 0) = -fOffset;

    LPproblem.osense = 1;

    %maximize
    LPproblem.c = -dirs;
    LPproblem.c(marked == 0 ) = 0;
    soln = solveCobraLP(LPproblem);
    vm = soln.full;

    if soln.stat ~= 1
        soln
        i
        pause;
    end

    [model.lb model.ub dirs vm];

    indexes = (vm.*dirs > fOffset) & marked == 0 & dirs ~= 0;
    markednew = marked;
    markednew(indexes) = dirs(indexes);

    [model.lb model.ub dirs vm markednew];

    if markednew == marked
        break;
    else
        marked = markednew;
    end
%     if( vmin < b_L(i) - 1e-7 || vmax > b_U(i) + 1e-7)
%         [i b_L(i) vmin vmax b_U(i)]
%         pause;
%     end
%     if (abs(vmin) < 1e-6 && abs(vmax) < 1e-6)
%         marked(i) = 2;
%     end
end
%model.redundant_constraints = marked;
if method == 1
    if isfield(model, 'N')
        A = model.N;
    else
        A = null(model.S);
    end
elseif method ==2
    A = model.S;
end
b_L(marked > 0) = fOffset;
b_U(marked < 0) = -fOffset;
[b_L b_U];
x = sum(abs(A),2) < 1e-9;
b_L = b_L(~x);
b_U = b_U(~x);
A = A(~x, :);
return
