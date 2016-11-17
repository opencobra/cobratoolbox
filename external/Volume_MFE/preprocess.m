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
%     N = null(eq_constraints);
% eq_constraints = [eq_constraints; P.A_eq];
% eq_rhs = [eq_rhs; P.b_eq];
N = getNullSpace(P.A_eq,0);
% N = null(full(P.A_eq));
[U,S,V] = svd(full(N));
%make all singular values =1
S = [eye(size(V,1)); zeros(size(S,1)-size(S,2),size(S,2))];
N = U*S*V';
% prod(svd(N))
%     z = linsolve(eq_constraints, eq_rhs);
z = P.A_eq \ P.b_eq;
N_total = N;
p_shift = z;
P.b = P.b - P.A * z;
P.A = P.A*N;
dim = size(P.A,2);
% else % Please check this Ben. I added it to prevent an error in line 125: "Undefined function or variable "N_total"."
%     N_total = null(P.A_eq);
%     p_shift = zeros(size(N_total,1),1);
% end

fprintf('Now in %d dimensions after restricting\n', dim);

%remove zero rows
new_A = [];
new_b = [];
for i=1:size(P.A,1)
    if norm(P.A(i,:))>1e-6
        new_A = [new_A; P.A(i,:)];
        new_b = [new_b; P.b(i)];
    end
end
fprintf('Removed %d zero rows\n', size(P.A,1)-size(new_A,1));
P.A = new_A;
P.b = new_b;
dim = size(P.A,2);

fprintf('Rounding...\n');

if to_round==1
    T = eye(dim);
    LP.A = P.A;
%     LP.b = P.b-1e-6*sqrt(sum((P.A').^2,1))';
    LP.b = P.b;
    LP.c = zeros(dim,1);
    LP.lb = -Inf * ones(dim,1);
    LP.ub = Inf*ones(dim,1);
    LP.osense = 1;
    LP.csense = repmat('L',size(LP.A,1),1);
    solution = solveCobraLP(LP);
    if solution.stat == 1
        x0 = solution.full;
    else
        error('Could not find a point inside the polytope.');
    end
    [T_shift, Tmve] = mve_run(P.A,P.b+sqrt(sum((P.A').^2,1))'/sqrt(dim), x0);
    
    while(abs(det(Tmve))>20 || abs(det(Tmve))<1/20) 
        det(Tmve)
        p_shift = p_shift + N_total*T_shift;
        N_total = N_total * Tmve;
        T = T * Tmve;
        P.b = P.b - P.A*T_shift;
        P.A = P.A*Tmve;
        
        if min(P.A*(0*x0)<=P.b)==0
            
            LP.A = P.A;
            LP.b = P.b-1e-6*sqrt(sum((P.A').^2,1))';
            LP.c = zeros(dim,1);
            LP.lb = -Inf * ones(dim,1);
            LP.ub = Inf*ones(dim,1);
            LP.osense = 1;
            LP.csense = repmat('L',size(LP.A,1),1);
            solution = solveCobraLP(LP);
            if solution.stat == 1
                x0 = solution.full;
            else
                error('Could not find a point inside the polytope.');
            end
        else
            x0 = 0*x0;
        end
        
        
        [T_shift, Tmve] = mve_run(P.A,P.b, x0);
    end
    
    
%     Volume(Q);
    
%     [T,T_shift]=max_Ellipsoid(P.A, P.b);
%     P.b = P.b - P.A*T_shift;
%     P.A = P.A*T;
%     p_shift = p_shift + N_total*T_shift;
%     N_total = N_total * T;
%     Volume(P)
%     Volume(Q)
%     fprintf('hi\n');
else
    T = eye(size(N_total,2));
end

fprintf('Trying to find a point inside the convex body...\n');

% if isfield(P,'p')==0 || isempty(P.p)
% p=zeros(dim,1);
% options = optimset('Display','none');
% 
% LP.lb = -Inf*ones(size(P.A,2),1);
% LP.ub = -LP.lb;
% LP.osense = 1;
% LP.csense = 'L';
% LP.A = P.A;
% LP.b = P.b;
% 
% for i=1:2*size(P.A,2)
%     %     f = randn(dim,1);
%     if i<=size(P.A,2)
%         LP.c = randn(dim,1);
%     else
%         [~,f_index]=min(P.b-P.A*p);
%         %optimize in this direction with some small noise
%         LP.c = P.A(f_index,:)+randn(1,dim)*max(P.A(f_index,:))/100;
%     end
%     %     [y]=linprog(f,P.A, P.b,[],[],[],[],[],options);
%     [solution] = solveCobraLP(LP);
%     y = solution.full;
%     p = ((i-1)*p+y)/i;
%     if mod(i,10)==0
%         fprintf('%d its, %f frac of equations satisfied (this one has %f)\n', i, sum(P.A*p<=(P.b))/length(P.b),sum(P.A*y<=(P.b))/length(P.b));
%     end
%     %     fprintf('Number of low rows: %d\n', sum(P.b - P.A*p < eps_cutoff));
% end
% 
% %hopefully found a point reasonably inside the polytope
% %shift so that this point is the origin
% P.b = P.b - P.A*p;
% p_shift = p_shift + N_total*p;
% 
% if min(P.b) < -eps_cutoff
%     error('We tried to find a point inside the polytope but failed.');
% elseif min(P.b) < 0
%     fprintf('The point is very close to inside, so we slightly perturb P.b to make it be so.\n');
%     P.b = P.b + eps_cutoff;
% else
%     fprintf('We found a point inside the polytope!\n');
% end

fprintf('Final polytope is in %d dimensions.\n', dim);



P.N = N_total;
P.p_shift = p_shift;
P.T = T;

end

function [min_dist]=minDist(P)
dists = zeros(size(P.A,1),1);
for i=1:size(dists,1)
    dists(i) = P.b(i)/norm(P.A(i,:));
end

min_dist = min(abs(dists));
end