function [P] = preprocess( P , to_round)
%PREPROCESS Takes in an object P, which is a polytope with the following
%properties:
%
%the polytope is {x | P.A * x <= P.b} \cap {x | P.A_eq * x = P.b_eq}
%P.A
%P.b
%P.A_eq
%P.b_eq
%
%an optional argument P.p, which is a point satisfying P.A * P.p <= P.b
%
% The algorithm will first restrict to the equality subspace defined by
% P.A_eq, P.b_eq. Then, it will look at the width of the polytope in each
% facet direction. If it finds a width 0 facet, say with normal vector a_i,
% then the polytope actually lies in a lower dimensional subspace (defined
% by a_i and the point found by the LP solver when optimizing w.r.t. a_i).
% So, we further restrict based on all width 0 facets.
%
% After this preprocessing, you still may want to round the polytope for
% the volume algorithm to be accurate and efficient.
%
% Example usage:
%
% P = makeBody('cube',10);
% P = preprocess(P);
% vol = Volume(P);


%restrict to the degenerate subspace

N = getNullSpace(P.A_eq,0);

%in case we want the volume dilation factor when restricting to the null space, uncomment
%the below line (e.g. if the product of all the singular values of N = 1, then there is no
%volume change)

%vol_change = prod(svd(N));


%find a point in the null space to define the shift
z = P.A_eq \ P.b_eq;
N_total = N;
p_shift = z;
P.b = P.b - P.A * z;
P.A = P.A*N;
dim = size(P.A,2);

fprintf('Now in %d dimensions after restricting\n', dim);

%remove zero rows
row_norms = sqrt(sum(P.A.^2,2));
P.A = P.A(row_norms>1e-6,:);
P.b = P.b(row_norms>1e-6,:);

%maybe add LP presolve here

fprintf('Removed %d zero rows\n', sum(row_norms>1e-6));

%scale the matrix to help with numerical precision
dim = size(P.A,2);
[cs,rs] = gmscale(P.A,0,0.99);
P.A = diag(1./rs)*P.A*diag(1./cs);
P.b = diag(1./rs)*P.b;
N_total = N_total*diag(1./cs);

row_norms = sqrt(sum(P.A.^2,2));
P.A = diag(1./row_norms)*P.A;
P.b = diag(1./row_norms)*P.b;

fprintf('Rounding...\n');

if to_round==1
    T = eye(dim);
    
    %the below loop looks silly for an interior point method, but is actually
    %quite important for numerical stability. while normally you'd only call an optimization routine
    %once, we call it iteratively--where in each iteration, we map a large
    %ellipsoid to the unit ball. the idea is that the "iterative roundings"
    %will make each subsequent problem easier to solve numerically.
    max_its = 20;
    its = 0;
    reg=1e-3;
    Tmve = eye(dim);
    converged = 0;
    while (max(eig(Tmve))>6*min(eig(Tmve)) && converged~=1) || reg>1e-6 || converged==2
        tic;
        its = its+1;
        [x0,dist] = getCCcenter(P.A,P.b);
        reg = max(reg/10,1e-10);
        [T_shift, Tmve,converged] = mve_run_cobra(P.A,P.b, x0,reg);
        
        [P,N_total, p_shift, T] = shiftPolytope(P, N_total, p_shift, T, Tmve, T_shift);
        row_norms = sqrt(sum(P.A.^2,2));
        P.A = diag(1./row_norms)*P.A;
        P.b = diag(1./row_norms)*P.b;
        if its==max_its
            break;
        end
        
        fprintf('Iteration %d: reg=%.1e, ellipsoid vol=%.1e, longest axis=%.1e, shortest axis=%.1e, x0 dist to bdry=%.1e, time=%.1e seconds\n', its, reg, det(Tmve), max(eig(Tmve)), min(eig(Tmve)), dist, toc);
    end
    
    if its==max_its
        fprintf('Reached the maximum number of iterations, rounding may not be ideal.\n');
    end
    
else
    T = eye(size(N_total,2));
end

if min(P.b)<=0
    [x,~] = getCCcenter(P.A,P.b);
    [P,N_total,p_shift,T] = shiftPolytope(P,N_total,p_shift,T,eye(dim),x);
    fprintf('Shifting so the origin is inside the polytope...rounding may not be ideal.\n');
else
    fprintf('Maximum volume ellipsoid found, and the origin is inside the transformed polytope.\n');
end

P.N = N_total;
P.p_shift = p_shift;
P.T = T;

end

%compute the center of the Chebyshev ball in the polytope Ax<=b
function [CC_center,radius] = getCCcenter(A,b)
dim = size(A,2);
a_norms = sqrt(sum(A.^2,2));

LP.A = [A a_norms];
LP.b = b;
LP.c = [zeros(dim,1); 1];
LP.lb = -Inf * ones(dim+1,1);
LP.ub = Inf*ones(dim+1,1);
LP.osense = -1;
LP.csense = repmat('L',size(LP.A,1),1);
solution = solveCobraLP(LP);
if solution.stat == 1
    CC_center = solution.full(1:dim);
    radius = solution.obj;
else
    solution
    error('Could not solve the LP, consult the information above.');
end
end

%shift the polytope by a point and apply a transformation, while retaining
%the information to undo the transformation later (to recover the samples)

%let x denote the original space, y the current space, and z the new space
%we have
%
%   P.A y <= P.b   and x = N*y+p
%
%  applying the transformation
%
%   trans * z + shift = y
%
% yields the system
%
%  x = (N * trans) * z + N*shift + p
%  (P.A * trans) * z <= P.b - P.A * shift
function [P,N,p,T] = shiftPolytope(P,N,p,T,trans, shift)
p = p + N*shift;
N = N * trans;
T = T * trans;
P.b = P.b - P.A*shift;
P.A = P.A*trans;
end