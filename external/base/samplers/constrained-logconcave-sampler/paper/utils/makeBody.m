function [ P ] = makeBody( body_type, dim, num_facets )
%MAKEBODY make a convex body in the sampler format
%the hmc supporting functions will fill in anything that is not provided,
%so we can specify each polytope concisely
if nargin<2
	dim = 100;
end
warning('will be removed soon');
if strcmp(body_type,'cube')==1
    lb = -0.5;
    ub = 0.5;
    P.lb = lb*ones(dim,1);
    P.ub = ub*ones(dim,1);
    %P.p = ones(dim,1) .* P.lb + (P.ub-P.lb)./2;
elseif strcmp(body_type,'cube_lifted')==1
    %an alternate representation of the cube that is lifted to 2n dims
    %primarily for testing purposes
    P.lb = zeros(2*dim,1);
    P.ub = Inf*ones(2*dim,1);
    
    P.Aeq = [speye(dim) speye(dim)];
    P.beq = ones(dim,1);
    P.p = .5*ones(2*dim,1);
elseif strcmp(body_type,'cube_ineq')==1
    %version of cube with "free" vars and inequalities, for testing
    P.lb = -Inf*ones(dim,1);
    P.ub = Inf*ones(dim,1);
    P.Aineq = [speye(dim); -speye(dim)];
    P.bineq = [ones(dim,1); zeros(dim,1)];
elseif strcmp(body_type,'simplex')==1
    P.Aeq = ones(1,dim);
    P.beq = 1;
    P.lb = zeros(dim,1);
    %P.p = ones(dim,1)*1/dim;
elseif strcmp(body_type,'fulldim_simplex')==1
    P.Aineq = ones(1,dim); 
    P.bineq = 1;
    alpha = 1/dim/(sqrt(dim)+1);
    P.lb = zeros(dim,1) - alpha;
    P.bineq = P.bineq - (alpha)*dim;
elseif strcmp(body_type,'random_sparse')==1
    facets = 5*dim;
    
    P.Aineq = zeros(facets,dim);
    k = 5; %number of nnz's per facet
    for i=1:facets
        coords = randperm(dim,k);
        coord_signs =  2*(randi(2,1,k)-1.5);
        P.Aineq(i,coords) = coord_signs/sqrt(k);
    end
    P.lb = -sqrt(dim)*ones(dim,1);
    P.ub = -P.lb;
    P.bineq = ones(facets,1);
    %P.p = zeros(dim,1);
elseif strcmp(body_type,'random_walk')==1
    e = ones(dim,1);
    P.Aeq = [spdiags([e -e], 0:1, dim-1, dim) spdiags(e, 0, dim-1, dim-1)];
    P.beq = zeros(dim-1,1);
    P.lb = -ones(2*dim-1,1);
    P.ub = ones(2*dim-1,1);
    P.lb(1:(dim-1)) = -5*sqrt(dim);
    P.ub(1:(dim-1)) = 5*sqrt(dim);
    %P.p = .5*ones(dim,1);
elseif strcmp(body_type,'long_box')==1
    lb = 0;
    ub = 1;
    long_ub = 1e6;
    P.lb = lb*ones(dim,1);
    P.ub = ub*ones(dim,1);
    P.ub(1) = long_ub;
    %P.p = ones(dim,1) .* P.lb + (P.ub-P.lb)./2;
elseif strcmp(body_type,'birkhoff')==1
    %birkhoff polytope. note that dim => dim^2 for this one.
    P.lb = zeros(dim^2,1);
    P.Aeq = sparse(2*dim-1,dim^2);
    P.beq = ones(2*dim-1,1);
    for i=1:dim
        %row constraints
%         for j=(i-1)*dim+1:i*dim
%             P.Aeq(i,j)=1;
%         end
        j_range = (i-1)*dim+1:i*dim;
        P.Aeq(i,j_range) = 1;
        
        %col constraints
%         for j=i:dim:dim^2
%             P.Aeq(dim+i,j)=1;
%         end
        if i==dim
            break;
        end
        j_range = i:dim:dim^2;
        P.Aeq(dim+i,j_range)=1;
    end
elseif strcmp(body_type,'random')==1
    if nargin<3
        num_facets = 3*dim;
    end
    if num_facets < dim
        error('Number of facets must be > dimension to be bounded');
    end
    
    P.Aineq = zeros(num_facets, dim); %the rows will be dense, so don't make a sparse matrix
    for i=1:num_facets
        w = randn(1,dim);
        w = w/norm(w); %tangent to the unit ball in R^n
        P.Aineq(i,:) = w;
    end
    P.bineq = ones(num_facets,1);
    %P.p = zeros(dim,1);
elseif strcmp(body-type,'dense_rowcol')==1
    vec = rand(dim,1)-.5;
    P.Aineq = [-eye(dim+1,dim) [vec; 0]; ones(1,dim) 0];
    P.bineq= ones(dim+2,1)/(dim+1);
    %P.p = zeros(dim,1);
elseif strcmp(body_type,'dense_col')==1
    P.Aineq = [speye(dim,dim); -speye(dim,dim)];
    P.Aineq = [P.A ones(2*dim,1)];
    P.Aineq = [P.A; zeros(2,dim+1)];
    P.Aineq(end-1,end)=1;
    P.Aineq(end,end)=-1;
    P.bineq = ones(2*dim,1);
    P.bineq = [P.bineq; .1; .1];
    %P.p = zeros(dim+1,1);
else
    error('body not found');
end

end