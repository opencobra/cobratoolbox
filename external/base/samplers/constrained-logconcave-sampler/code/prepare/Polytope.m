classdef Polytope < handle
% The polytope is defined by {Tx+y where Ax=b, lb <= x <= ub}
    properties
        % constraint matrix A
        A
        
        % constraint vector b
        b
        
        % lower bound lb
        lb
        
        % upper bound ub
        ub
        
        % transformation T of the domain
        T
        
        % shift of the domain
        y
        
        % options
        opts
    end
    
    properties (Access = private)
        centerCache
    end
    
	properties (Dependent)
        % the number of variables
        n
        
        % analytic center
        center
	end
   
    methods
        function o = Polytope(P, opts)
            % Convert a structure P into the polytope object with the following fields
            %  .Aineq
            %  .bineq
            %  .Aeq
            %  .beq
            %  .lb
            %  .ub
            % describing a polytope
            %   {Aineq x <= bineq, Aeq x = beq, lb <= x <= ub}
            nP = P.n;
			
            %% Set all non-existence fields
            if ~(isprop(P,'Aineq') || isfield(P,'Aineq')) || isempty(P.Aineq)
                P.Aineq = sparse(zeros(0,nP));
            end
            
            if ~(isprop(P,'bineq') || isfield(P,'bineq')) ||isempty(P.bineq)
                P.bineq = zeros(size(P.Aineq,1),1);
            end

            if ~(isprop(P,'Aeq') || isfield(P,'Aeq')) ||isempty(P.Aeq)
                P.Aeq = sparse(zeros(0,nP));
            end
            
            if ~(isprop(P,'beq') || isfield(P,'beq')) ||isempty(P.beq)
                P.beq = zeros(size(P.Aeq,1),1);
            end
            
            if ~(isprop(P,'lb') || isfield(P,'lb')) ||isempty(P.lb)
                P.lb = -Inf*ones(nP,1);
            end
            
            if ~(isprop(P,'ub') || isfield(P,'ub')) ||isempty(P.ub)
                P.ub = Inf*ones(nP,1);
            end
            
            %% Check the input dimensions
            assert(all(size(P.Aineq) == [length(P.bineq), nP]));
            assert(all(size(P.Aeq) == [length(P.beq), nP]));
            assert(all(size(P.lb) == [nP 1]));
            assert(all(size(P.ub) == [nP 1]));
            assert(all(P.lb <= P.ub));
            
            %% Convert the polytope into {Ax=b, lb<=x<=ub} form
            numIneq = size(P.Aineq,1);
            numEq = size(P.Aeq,1);

            o.A = [P.Aeq sparse(numEq,numIneq); P.Aineq speye(numIneq)];

            o.b = [P.beq; P.bineq];
            o.lb = [P.lb; zeros(numIneq,1)];
            o.ub = [P.ub; Inf*ones(numIneq,1)];
            
            %% Move all variables with lb == ub to Ax = b
            fixedVars = P.ub - P.lb < 2*eps;
            if sum(fixedVars) ~= 0
                I = speye(length(o.lb));
                o.A = [I(fixedVars,:); o.A];
                o.b = [(o.lb(fixedVars)+o.ub(fixedVars))/2; o.b];
                o.ub(fixedVars) = +Inf;
                o.lb(fixedVars) = -Inf;
            end
            
            %% Update the transformation Tx + y
            n = length(o.ub);
            o.T = sparse(nP, n);
            o.T(:,1:nP) = speye(nP);
            o.y = zeros(nP, 1);
            
            %% Update the center cache
            o.centerCache = [];
            
            %% Set the options
            defaults.removeFixedVariablesTol = 1e-8;
            defaults.scaleLP = true;
            
            if ~exist('opts', 'var'), opts = struct; end
            o.opts = setDefault(opts, defaults);
        end
        
        function n = get.n(o)
            % compute the dimension of the polytope
            n = size(o.A,2);
        end
        
        function changed = rescale(o)
            % Rescale the problem so it is in a better numerical form.
            
            % do not rescale if A has zero or one contraints/variables
            if min(size(o.A))<=1, return; end

            [cscale,rscale] = gmscale(o.A,0,0.9);
            changed = any(cscale ~= 1) || all(rscale ~= 1);
            if ~changed, return; end
            
            o.A = spdiag(1./rscale)*o.A;
            o.b = o.b./rscale;
            o.lb = o.lb .* cscale;
            o.ub = o.ub .* cscale;
            o.appendMap(spdiag(1./cscale));
        end
        
        function changed = removeFixedVariables(o)
            % Remove fixed variables implied by Ax = b
            
            tol = o.opts.removeFixedVariablesTol;

            % remove zero rows
            zeroRows = full(sum(o.A~=0, 2))==0;
            o.A = o.A(~zeroRows,:);
            o.b = o.b(~zeroRows);

            % compute the width of each variables
            % if the width < tol, we consider it as fixed variables
            JLdim = ceil(3 * log(1+o.n));
            JLdir = randn(size(o.A,2),JLdim) ./ sqrt(JLdim);
            so = LinearSystemSolver(o.A);
            so.Prepare(speye(size(o.A,2)));
            d = JLdir - o.A' * so.Solve(o.A * JLdir);
            d = sqrt(sum(d.^2, 2));
            x = o.A' * so.Solve(o.b);
            fixedVars = find(d < tol);
            fixedVals = x(fixedVars);
            changed = ~isempty(fixedVars) || ~isempty(zeroRows);
            if isempty(fixedVars), return; end
            
            % remove all fixed variables
            S = speye(o.n);
            w = zeros(o.n,1);
            w(fixedVars) = fixedVals;
            fixedVarFlags = zeros(o.n,1);
            fixedVarFlags(fixedVars) = 1;
            S = S(:,~fixedVarFlags);
            o.appendMap(S, w);
            o.lb = o.lb(~fixedVarFlags);
            o.ub = o.ub(~fixedVarFlags);
        end
        
        function changed = reorder(o)
            % Reorder vertices such that cholesky has better sparsity pattern
            
            % compute the cost of chol decomposition
            function s = CholCost(H, P)
                count = symbfact(H(P,P));
                s = sum(count.^2);
            end
            
            m = size(o.A,1);
            H = o.A * o.A' + spdiag(ones(m,1));
            
            p_dissect = dissect(H);
            s_dissect = CholCost(H, p_dissect);
            
            p_amd = amd(H);
            s_amd = CholCost(H, p_amd);
            
            if (s_dissect < s_amd)
                p = p_dissect;
            else
                p = p_amd;
            end
            
            [~, Q] = etree(H(p,p));
            p = p(Q);
            
            changed = ~all(p == 1:m);
            if ~changed, return; end
            
            o.A = o.A(p,:);
            o.b = o.b(p);
        end
        
        function changed = removeDepRows(o)
            % Remove redundant rows in A
            
            I = detectIndepRows(o.A);
            changed = (size(I,1) ~= size(o.A,1));
            if ~changed, return; end
            
            o.A = o.A(I, :);
            o.b = o.b(I);
        end
        
        function changed = extractCollapsedVariables(o)
            % Extract collapsed variables and move it to constraints
            
            f = TwoSidedBarrier(o.lb, o.ub);
            [c, Ac, bc] = analyticCenter(o.A, o.b, f);
            o.centerCache = c;
            
            changed = (size(Ac,1) > 0);
            if ~changed, return; end
            
            % update the A and b
            o.A = [Ac; o.A];
            o.b = [bc; o.b];
        end
        
        function changed = splitDenseCols(o, maxNZ)
            % Rewrite P so that each cols has no more than maxNZ non-zeros
            
            changed = false;
            if isempty(o.A) || size(o.A,1) <= maxNZ, return; end
            
            % return the original P if it is too dense
            if (nnz(o.A) > maxNZ * size(o.A,1))
                return;
            end

            A = o.A;
            b = o.b;
            ub = o.ub;
            lb = o.lb;
            nzCounts = full(sum(A~=0,1));
            while max(nzCounts)>maxNZ
                [m,n] = size(A);
                badCols = find(nzCounts > maxNZ);
                numBadCols = length(badCols);
                newA = spalloc(m, numBadCols, sum(nzCounts));

                counter = 1;
                for i = badCols
                  nzIndices = find(A(:,i));
                  midpoint = nzIndices(floor(length(nzIndices)/2));
                  last = nzIndices(end);
                  newA(midpoint+1:last, counter) = A(midpoint+1:last,i);
                  A(midpoint+1:last,i) = 0;
                  counter = counter+1;
                end

                A = [A newA];
                A = [A; sparse(numBadCols, n) -speye(numBadCols,numBadCols)];
                b = [b; zeros(numBadCols,1)];
                A(m+1:m+numBadCols,badCols) = speye(numBadCols,numBadCols);
                ub = [ub; ub(badCols)];
                lb = [lb; lb(badCols)];

                nzCounts = full(sum(A~=0,1));
            end
            
            changed = (length(ub) > o.n);
            if ~changed, return; end
            
            o.T = o.T * [speye(o.n) sparse(o.n, length(ub)-o.n)];
            o.A = A;
            o.b = b;
            o.ub = ub;
            o.lb = lb;
        end
        
        function w = estimateWidth(o)
            % Compute the width of the Dikin ellipse of the polytope:
            % w_i = sqrt(ei' H^{-1/2} (I - P) H^(-1/2} ei)
            % WARNING: This function is not accurate if the polytope is unbounded
        
            x = o.center; A = o.A;
            f = TwoSidedBarrier(o.lb, o.ub);
            f.SetExtraHessian(1e-20 * ones(size(x,1),1));
            Hinv = f.HessianInv(x);
            HinvSqrt = f.SqrtHessianInv(x);
            
            JLsize = ceil(3 * log(1+o.n));
            JLdir = randn(o.n, JLsize) ./ sqrt(JLsize);
            z = LinearSystemSolve(A, A * (HinvSqrt * JLdir), Hinv);
            w = HinvSqrt * JLdir - Hinv * (A' * z);
            w = sqrt(sum(w.^2, 2));
        end
        
        function c = get.center(o)
            % computer the analytic center of the polytope
            
            if ~isempty(o.centerCache)
                c = o.centerCache;
            else
                f = TwoSidedBarrier(o.lb, o.ub);
                c = analyticCenter(o.A, o.b, f);
                o.centerCache = c;
            end
        end
        
        % Whenever the polytope is changed, the cache is deleted.
        function set.A(o,A)
            o.A = A;
            o.centerCache = [];
        end
        
        function set.b(o,b)
            o.b = b;
            o.centerCache = [];
        end
        
        function set.lb(o,lb)
            o.lb = lb;
            o.centerCache = [];
        end
        
        function set.ub(o,ub)
            o.ub = ub;
            o.centerCache = [];
        end
        
        function simplify(o)
            % Runs all appropriate preprocessings
            
            if o.opts.scaleLP, o.rescale();end
            o.splitDenseCols(30);
            o.reorder();
            n = +Inf;
            while o.n < n
                n = o.n;
                o.removeDepRows();
                o.extractCollapsedVariables();
                o.removeFixedVariables();
            end
            o.reorder();
        end
    end
    
    methods (Access = private)
        function o = appendMap(o, S, z)
            % Perform a change of variables
            % from the representation {Tx+y : x in P} to 
            % {Tx+y, x = Sw+z : Sw+z in P}
            %
            % WARNING: This does not handle the ub and lb changes
            % It only update A, T and y
            
            if ~exist('z', 'var'), z = zeros(size(S,1),1); end
            
            o.b = o.b - o.A * z;
            o.A = o.A * S;
            o.y = o.y + o.T * z;
            o.T = o.T * S;
        end
    end
end