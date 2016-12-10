classdef ConvexBody < handle
    properties
        %P = {x|Ax<=b} \cap {x|A_eq*x=b_eq}
        A
        b
        A_eq
        b_eq
        
        %{x|(x-v)'E(x-v) <= 1}
        E
        E_p
        
        %also store E_inv so we don't have to compute it everytime
%         E_inv
        
        %the radius of ball that K contains
        r
        
        %the dimension of our convex body
        dim
        
        %a point inside K \cap E
        p
        
        %input flags
        flagmap
        
        %number of phases until we get to uniform distribution
        m
        
        %the target accuracy
        eps
        
        %verbosity level for output to console
        verb
        
        %store an array of slacks, i.e. b-A*x, for coordinate hit-and-run
        slacks
        
        %store the ellipsoid slacks, i.e. 1-(x-v)'E(-v)
        slacks_E
        
        %the type of walk that will be used
        walk_type
    end
    
    methods
        function K = ConvexBody(P,E,eps,flags)
            %we initialize our ConvexBody object K
            
            %note that we shift everything by p, so we can now
            %assume p=0 throughout the implementation
            if isempty(E)
                K.E=[];
                K.E_p=[];
%                 K.E_inv=[];
            else
                K.E=E.E;
%                 K.E_inv=inv(K.E);
                K.E_p=E.v;
            end
            
            if isempty(P)
                K.A=[];
                K.b=[];
                K.dim=size(K.E,1);
                K.E_p = zeros(K.dim,1);
            else
                K.A = P.A;
                if ~isempty(K.E)
                    if size(K.A,2)~=size(K.E,1)
                        error('The ellipsoid and polytope dimensions don''t match.');
                    end
                end
                    
                if isfield(P,'p')==0 || isempty(P.p)
                    K.b = P.b;
                    K.dim = size(K.A,2);
                    if ~in_K(K,zeros(K.dim,1))
                       error('You did not provide a point inside the convex body.\nWe checked to see if the origin was inside K, but it was not.\nIf your body is a polytope, preprocess.m might help.%s\n', '');
                    end
                else
                    %shift so that the point inside is the origin
                    K.b = P.b - K.A * P.p;
                    K.dim = size(K.A,2);
                    if ~isempty(K.E)
                        K.E_p = K.E_p - P.p;
                    end
                    
                    if ~in_K(K,zeros(K.dim,1))
                       error('Point provided is not in the convex body.\nIf your body is a polytope, preprocess.m might help.\n%s', '');
                    end
                end
            end
            
            K.p = zeros(K.dim,1);
            K.flagmap = parseFlags(flags);
            K.eps = eps;
            K.m = -1;
         
            if isKey(K.flagmap,'walk')
                if strcmp(K.flagmap('walk'),'char')==1
                    K.walk_type = 0;
                elseif strcmp(K.flagmap('walk'),'har')==1
                    K.walk_type = 1;
                elseif strcmp(K.flagmap('walk'),'ball')==1
                    K.walk_type = 2;
                else
                    error('The walk %s provided is not valid. Valid walks are: char, har, or ball\n', K.flagmap('walk'));
                end
            else
                K.walk_type = 0;
            end
            
            
            if isKey(K.flagmap,'verb')
                K.verb=K.flagmap('verb');
            else
                K.verb = 1;
            end
        end
        
        %determine the starting Gaussian that will have most of its mass
        %inside K. "frac" is the percentage of our total error that we will
        %allow in this phase
        function a = getStartingGaussian(K,frac)
            %get the distances to each plane of P={x|Ax<=b}
            if ~isempty(K.A)
                dists = zeros(size(K.A,1),1);
                for i=1:size(dists,1)
                    dists(i) = K.b(i)/norm(K.A(i,:));
                end
            else
                dists=1e10;
            end
            
            lower = 0;
            upper = 1;
            
            if ~isempty(K.E)
                %shift the point so the ellipsoid is centered at 0
                pt=-K.E_p;
                if max(abs(pt))<=1e-6
                    %if K.p is the center of the ellipsoid, then the min
                    %distance calculation will have numerical stability
                    %issues, so we'll handle it separately
                    d=sqrt(min(eig(K.E)));
                else
                    d = ellipsoidDist(K.E,pt);
                end
            else
                %assign a really big value that won't affect our answer
                d = 1e10;
            end
            
            %set the radius of ball our convex body K contains
            K.r = min(min(dists),d);
            
            %first get an upper bound on a.
            its = 0;
            while its<1e4
                its = its+1;
                sum = 0;
                for i=1:size(dists,1)
                    sum = sum + exp(-upper*dists(i)^2)/(2*dists(i)*sqrt(pi*upper));
                end
                
                sigma_sqd = 1/(2*upper);
                
                t = (d-sigma_sqd*K.dim)/(sigma_sqd*sqrt(K.dim));
                sum = sum + exp(-t^2/8);
                if sum>frac*K.eps || t<=1
                    upper = upper*10;
                else
                    break;
                end
            end
            
            if its==1e4
                error('Cannot obtain sharp enough starting Gaussian. Modify your body so that it contains a larger ball around p.');
            end
            
            %now get the best value of a possible with a binary search.
            while upper - lower>upper*1e-7
                mid = (upper+lower)/2;
                sum = 0;
                for i=1:size(dists,1)
                    sum = sum + exp(-mid*dists(i)^2)/(2*dists(i)*sqrt(pi*mid));
                end
                
                sigma_sqd = 1/(2*mid);
                
                t = (d-sigma_sqd*K.dim)/(sigma_sqd*sqrt(K.dim));
                sum = sum + exp(-t^2/8);
                if sum<frac*K.eps && t>1
                    %too good of a function, will take too long to converge
                    upper = mid;
                else
                    %too much area outside Ax<=b to get good estimate
                    lower = mid;
                end
            end
            
            a = (upper+lower)/2;
            K.eps = (1-frac)*K.eps;
        end
        
        %a deterministic round algorithm for a general polytope
        function [T] = round_det(K)
           %compute the widths in every direction
           
           %to suppress the "Optimization terminated" output from linprog
           options = optimset('Display','none');
           
           widths = zeros(size(K.A,1),1);
           rhs = zeros(size(K.A,1),1);
           num_degenerate = 0;
           for i=1:length(widths)
               [x,max_dist] = linprog(-K.A(i,:), K.A, K.b,[],[],[],[],[],options);
               [y,min_dist] = linprog(K.A(i,:), K.A, K.b,[],[],[],[],[],options);
               
               
               widths(i) = abs(max_dist+min_dist)/norm(K.A(i,:),2);
               rhs(i) = K.A(i,:)*x;
               if widths(i) <=1e-8
                   %width in this direction is 0, so we live in a lower dimensional space
                   num_degenerate = num_degenerate + 1;
               end
           end
           
           done = 0;
           rounds_without_progress = 0;
           prev_max_over_min = 1e300;
           num_facets = size(K.A,1);
           T = eye(K.dim, K.dim);
           small_tol = 1e-2;
           cos_angles = zeros(length(widths),1);
                   
           while ~done
               
               max_over_min = max(widths)/min(widths);
               
               %check if we've made "progress" this round in improving the
               %max/min width
               
               if prev_max_over_min > (1+small_tol)*max_over_min
                    %we say we've made progress when we've improved by 1%
                   prev_max_over_min = max_over_min;
                    rounds_without_progress = 0;
               else
                    rounds_without_progress = rounds_without_progress + 1;
                end
               
               if max_over_min <= 2 || rounds_without_progress >= num_facets
                    %we've gone num_facets without progress, so we're 
                    %about as round as we're going to get
                    done = 1;
               else
                   %scale up along the shortest width
                   [~, min_index] = min(widths);
                   
                   %compute the angles of the facet we are scaling with the
                   %angles of the other facets (we store cos(theta) since
                   %that's all we need)
                   for i=1:length(widths)
                      cos_angles(i) = dot(K.A(i,:),K.A(min_index,:))/norm(K.A(i,:),2)/norm(K.A(min_index,:),2);
                   end
                   
                   %round the polytope
                   a = K.A(min_index,:);
                   
                   %rescale a to be a unit vector
                   a = a/norm(a);
                   round_mat = (eye(K.dim,K.dim) - a' * a / (1 + a*a'));
                   K.A = K.A * round_mat;
                   T = T*round_mat;
                   
                   %update the widths by the appropriate scaling so we don't 
                   %have to resolve all the LP's
                   for i=1:length(widths)
                       widths(i) = widths(i)*(1+abs(cos_angles(i))^3);
                   end
               end
           end
           
           x = zeros(K.dim,1);
           its = 0;
            for i=1:10
               [y]=linprog(randn(K.dim,1),K.A, K.b,[],[],[],[],[],options);
               its = its+1;
               x = ((its-1)*x+y)/its;
            end
           K.b = K.b+1e-3;
           
           avg = zeros(K.dim,1);
           
          
           for i=1:8*K.dim^3
               x = hitAndRun(K,x,0);
               avg = avg+x;
           end
           K.p = avg/8/K.dim^3;
        end
        
        %a deterministic rounding algorithm for a centrally symmetric polytope
        %must be centrally symmetric around the point K.p
        function [T] = round_CS(K)
            %compute distances to all the facets
            
            done = 0;
            rounds_without_progress = 0;
            prev_max_over_min = 1e300;
            num_facets = size(K.A,1);
            T = eye(K.dim, K.dim);
            
            while ~done
                dists = zeros(size(K.A,1),1);
                for i=1:size(dists,1)
                    dists(i) = (K.b(i) - dot(K.p,K.A(i,:)))/norm(K.A(i,:));
                end
                
                max_over_min = max(dists)/min(dists);
                
                if prev_max_over_min > max_over_min
                    prev_max_over_min = max_over_min;
                    rounds_without_progress = 0;
                else
                    rounds_without_progress = rounds_without_progress + 1;
                end
                
                if max_over_min <=2 || rounds_without_progress >= num_facets
                    %we've gone num_facets without progress, so we're 
                    %about as round as we're going to get
                    done = 1;
                else
                    %we need to scale up around the short direction
                    [~,min_index] = min(dists);
                    a = K.A(min_index,:);
                    round_mat = (eye(K.dim,K.dim) - a' * a / (1 + a*a'));
                    K.A = K.A * round_mat;
                    T = T*round_mat;
                end
                
            end
            
        end
        
        function [T, T_shift] = round(K,num_threads)
            if K.verb>=1
                fprintf('------Rounding Start------\n');
            end
            
            %get the radius of ball that contains K
            if K.flagmap('round')>0
                %it can be provided with the rounding flag
                R=K.flagmap('round');
            else
                %or if not, we just make a guess
                R=1e10;
            end
            
            %initialize some stuff
            done=0;
            tries=0;
            num_rounding_steps=8*K.dim^3;
            rounding_samples=0;
            
            %try to round the body with this number of rounding steps
            while ~done
                %store the original body in case we need to restart the
                %rounding
                old_A=K.A;
                old_b=K.b;
                old_E=K.E;
                %the global rounding matrix and shift
                T = eye(K.dim);
                T_shift = zeros(K.dim,1);
                %the rounding matrix for each iteration
                round_it=1;
                max_s=Inf;
                x = zeros(K.dim,num_threads);
                resetSlacks(K,x);
                s_cutoff = 4.0;
                p_cutoff = 8.0;
                last_round_under_p = 0;
                fail=0;
                num_its = log(R)/log(20);
                %we may need multiple rounding iterations to round the body
                %we keep going until it "looks" like its not converging, or
                %the number of iterations is too high
                while (max_s>s_cutoff) && round_it<=num_its
                    [s,V,x,shift]=round_body(K,x,num_rounding_steps,0);
                    
                    rounding_samples=rounding_samples+num_rounding_steps;
                    max_s = max(s);
                    
                    if max_s <= p_cutoff && max_s > s_cutoff
                        if last_round_under_p
                            fprintf('Seem to be close to round. Doubling number of steps, not restarting.\n');
                            num_rounding_steps = num_rounding_steps*2;
                            [s,V,x]=round_body(K,x,num_rounding_steps,0);
                            max_s = max(s);
                        else
                           last_round_under_p = 1; 
                        end
                    else
                        last_round_under_p = 0;
                    end
                    
                    S=diag(s);
                    round_mat = V*S;
                    r_inv = diag(1./s)*V';
                    
                    if round_it~=1 && max_s>=4*prev_max_s% || abs(det(round_mat)) >= 4*prev_det)
                        if K.verb>=2
                            fprintf('phase %d bad...det:%e, max_s: %e, restarting\n', round_it, abs(det(round_mat)), max_s);
                        end
                        fail=1;
                        break;
                    end
                    if K.verb>=2
                        fprintf('phase %d: det: %e, max_s: %e\n', round_it, abs(det(round_mat)), max_s);
                    end
                    %                     det_round=det_round*abs(det(round_mat));
                    round_it=round_it+1;
%                     prev_det = abs(det(round_mat));
                    prev_max_s = max_s;
                    
                    %apply the rounding to our points and to the body
                    for j=1:num_threads
                        x(:,j)=r_inv*x(:,j);
                    end
                    if ~isempty(K.A)
                        K.A=K.A*round_mat;
                        T_shift = T_shift + T * shift;
                        for j=1:num_threads
                            K.slacks(:,j) = K.b - K.A*x(:,j);
                        end
                    end
                    if ~isempty(K.E)
                        K.E=round_mat'*K.E*round_mat;
                        K.E_p = r_inv * K.E_p;
                        for j=1:num_threads
                           K.slacks_E(j) = (x(:,j)-K.E_p)'*K.E*(x(:,j)-K.E_p); 
                        end
                    end
                    
                    %update global rounding matrix
                    T=T*round_mat;
                end
                if round_it<=num_its && fail==0
                    %converged to sufficiently round body, exit the loop
                    if K.verb>=1
                        fprintf('Round att. %d succ. for %d its--took %d its.\n', tries+1, num_rounding_steps,round_it-1);
                    end
                    done=1;
                else
                    %failed to converge, double the number of points and
                    %try again
                    if K.verb>=1
                        fprintf('Round. fail for %d its, restarting with %d its\n', num_rounding_steps, 2*num_rounding_steps);
                    end
                    tries=tries+1;
                    num_rounding_steps=num_rounding_steps*2;
                    K.A=old_A;
                    K.b=old_b;
                    K.E=old_E;
%                     K.E_inv=old_E_inv;
                end
            end
            if K.verb>=1
                fprintf('------Rounding Complete------\n\n');
            end
        end
        
        %the below is a helper function for round() above. it will sample
        %from K for the specified number of points, and use MATLAB's SVD
        %function to compute the transformation that points the points in
        %isotropic position
        function [s,V,x,M] = round_body(K,x,its,a)
            wait_time = K.dim^2+1-mod(K.dim^2,size(x,2));
            svd_pts = zeros(floor(its/wait_time),K.dim);
            th_num = 1;
            
            for i=1:its
                if ~in_K(K,x(:,th_num))
                   error('Found a point not in K.'); 
                end
                
                x(:,th_num) = getNextPoint(K,x(:,th_num),a,th_num);
                if mod(i,wait_time)==0
                    svd_pts(i/wait_time,:) = x(:,th_num);
                end
                th_num = mod(th_num,size(x,2))+1;
            end
            
            M = mean(svd_pts)';
            for i=1:size(svd_pts,1)
                svd_pts(i,:) = svd_pts(i,:) - M';
            end
            
            for i=1:size(x,2)
                x(:,i) = x(:,i)-M;
            end
            
            if ~isempty(K.A)
                K.b = K.b - K.A * M;
            end
            
            if ~isempty(K.E)
               K.E_p = K.E_p - M; 
            end
            
            s = svd(svd_pts);
            s = s/min(s);
            if max(s) >= 2
                for i=1:size(s,1)
                    if s(i)<2
                        s(i)=1;
                    end
                end
                
                [~,~,V] = svd(svd_pts,0);
%                 V = eye(K.dim);
            else
                s=0*s+1;
                V=eye(K.dim);
            end
        end
        
        %an optimization of get_boundary_pts for coordinate hit-and-run
        function [upper, lower] = get_boundary_pts_char(K,x,coord,th_num)
            if ~isempty(K.A)
                ratios = K.slacks(:,th_num)./K.A(:,coord);
                tmp = 1./ratios;
                lower = 1/min(tmp);
                upper = 1/max(tmp);
                %in case polytope is unbounded in this direction
                if lower > 1e-6
                    lower=-1e300;
                elseif upper <-1e-6
                    upper=1e300;
                end
            else
                lower = -1e300;
                upper = 1e300;
            end
            
            if ~isempty(K.E)
                [lambda] = dists_to_ellipsoid_coord(K,x,coord,th_num);
                u = zeros(K.dim,1);
                u(coord)=1;
                [lambda_test] = dists_to_ellipsoid(K,x,u);
                if abs(lambda(1)-lambda_test(1))>1e-7 || abs(lambda(2)-lambda_test(2))>1e-7
                   fprintf('error\n'); 
                end
                lower = max(lower, lambda(1));
                upper = min(upper, lambda(2));
            end
            
            lower = x(coord)+lower;
            upper = x(coord)+upper;
        end
        
        %method is (max_i (b-Ax)_i/(Au)i, min...)
        function [upper, lower] = get_boundary_pts(K,x,u)
            if ~isempty(K.A)
                bAx = K.b-K.A*x;
                Au = K.A*u;
                
                temp = bAx./Au;
                %     for i=1:size(bAx,1)
                %         if Au(i)<0
                %             lower = max(lower, tmp(i));
                %         else
                %             upper = min(upper, tmp(i));
                %         end
                %     end
                %MATLAB is dumb and slow unless you do vectorized stuff
                %the below is equivalent to the above commented out for-loop
                
                tmp = 1./temp;
                lower = 1/min(tmp);
                upper = 1/max(tmp);
                %in case polytope is unbounded in this direction
                if lower > 1e-6
                    lower=-1e300;
                elseif upper <-1e-6
                    upper=1e300;
                end
            else
                lower=-1e300;
                upper=1e300;
            end
            
            %also, check to see intersection of ray with ellipsoid, and take min of
            %both K and E to solve for the point, we get a quadratic function of lambda,
            %where lambda solves x+lambda*u on E. one lambda should be positive,
            %the other negative.
            if ~isempty(K.E)
                [lambda] = dists_to_ellipsoid(K,x,u);
                
                lower = max(lower, lambda(1));
                upper = min(upper, lambda(2));
            end
            
            upper = x+(upper-1e-6)*u;
            lower = x+(lower+1e-6)*u;
        end
        
        %if you want to compute the two intersection points of a chord and
        %an ellipsoid, it reduces to solving a quadratic equation.
        function [lambda] = dists_to_ellipsoid(K,x,u)
            x=x-K.E_p;
            a=u'*K.E*u;
            bb=u'*K.E*x+x'*K.E*u;
            c=x'*K.E*x-1;
            disc = sqrt(bb^2-4*a*c);
            lambda = zeros(2,1);
            lambda(1) = min((-bb-disc)/(2*a), (-bb+disc)/(2*a));
            lambda(2) = max((-bb-disc)/(2*a), (-bb+disc)/(2*a));
        end
        
        %a version of dists_to_ellispoid that runs faster for coordinate
        %hit-and-run to only operate on one dimension
        function [lambda] = dists_to_ellipsoid_coord(K,x,coord,th_num)
            x = x-K.E_p;
            c = K.slacks_E(th_num)-1;
            bb = K.E(coord,:)*x + x'*K.E(:,coord);
            a = K.E(coord,coord);
            disc = sqrt(bb^2-4*a*c);
            
            if length(bb)>1 || length(a)>1 || length(c)>1
               fprintf('hi\n'); 
            end

            lambda = zeros(2,1);
            lambda(1) = min((-bb-disc)/(2*a), (-bb+disc)/(2*a));
            lambda(2) = max((-bb-disc)/(2*a), (-bb+disc)/(2*a));
        end
        
        %membership oracle of K = P \cap E
        function [is_true] = in_K(K,x)
            
            if isempty(K.E) || (x-K.E_p)'*K.E*(x-K.E_p)<=1
                in_E=1;
            else
                in_E=0;
            end
            if isempty(K.A) || min(K.A*x<=K.b)
                in_P = 1;
            else
                in_P = 0;
            end
            is_true = in_E && in_P;
        end
        
        %try to step as far as we can while maintaining variance/mean^2 <C
        function [new_a,x] = getNextGaussian(a, its, ratio, C, K,x)
            its = its + size(x,2)-mod(its,size(x,2));
            
            last_a = a;
            
            done = 0;
            k = 1;
            pts = zeros(K.dim, its);
            th_num = 1;
            for i=1:its
                x(:,th_num) = getNextPoint(K,x(:,th_num),last_a,th_num);
                pts(:,i) = x(:,th_num);
                th_num = mod(th_num,size(x,2))+1;
            end
            last_ratio = 0.1;
            fn = zeros(its,1);
            while ~done
                a = last_a * ratio^k;
                
                for i=1:its
                    fn(i) = eval_exp(pts(:,i),a)/eval_exp(pts(:,i),last_a);
                end
                
                
                if var(fn)/(mean(fn)^2)>=C || mean(fn)/last_ratio<1+1e-5
                    if k~=1
                        k = k/2;
                    end
                    done = 1;
                else
                    k = 2*k;
                end
                last_ratio = mean(fn);
            end
            
            new_a = last_a * ratio^k;
        end
        
        %generates the next point of an iteration of the Hit and Run algorithm
        function [next_pt] = hitAndRun(K,x,a)
            %get upper and lower bound of points in K
            %from point pt along direction dir
            u = randn(K.dim,1);
            u = u./norm(u);
            [upper,lower] = get_boundary_pts(K,x,u);
            
            %generate a random point along the chord based on weighted dist.
            next_pt = rand_exp_range(lower, upper, a);
            
        end
        
        %a step of the ball walk
        function [next_pt] = ballWalk(K,x,a,delta)
            next_pt = x;
            f_x = eval_exp(x,a);
            u = randn(K.dim,1);
            y = x+delta*u./norm(u).*rand()^(1/K.dim);
            if in_K(K,y)
                f_y = eval_exp(y,a);
                pr = rand();
                if pr<=f_y/f_x
                    next_pt = y;
                end
            end
        end
        
        %generate the next point from coordinate hit-and-run
        function [x] = coordHitAndRun(K,x,a,th_num)
            %pick the random coordinate to change, and turn it into a
            %direction
            coord = randi(K.dim,1,1);
            [upper,lower] = get_boundary_pts_char(K,x,coord,th_num);
            old_x = x;
            %generate a random point along this chord
            x(coord) = rand_exp_range_coord(lower,upper,a);
            if ~isempty(K.A)
                K.slacks(:,th_num) = K.slacks(:,th_num) + K.A(:,coord).*(old_x(coord) - x(coord));
            end
            if ~isempty(K.E)
                alpha = x(coord)-old_x(coord);
                K.slacks_E(th_num) = K.slacks_E(th_num) + alpha*K.E(coord,:)*(old_x-K.E_p) ...
                    + alpha*(old_x-K.E_p)'*K.E(:,coord) + alpha^2*K.E(coord,coord);
            end
        end
        
        %generate the next point from x \in K according to some pre-defined random walk
        function [x] = getNextPoint(K,x,a,th_num)
            if K.walk_type == 0  
               x = coordHitAndRun(K,x,a,th_num);   
            elseif K.walk_type == 1
               x = hitAndRun(K,x,a);
            else
                delta = 4*K.r/sqrt(max(1,a)*K.dim);
                x = ballWalk(K,x,a,delta);
            end            
        end
        
        %this will compute the annealing schedule to the target
        %distribution (likely the uniform distribution, i.e. the volume)
        %while keeping the variance bounded by C at each cooling step
        function [a_vals] = getAnnealingSchedule(K,ratio,num_threads,C)
            
            %get the starting Gaussian
            if isKey(K.flagmap,'a_0')
                a_vals(1) = K.flagmap('a_0');
            else
                a_vals(1) = getStartingGaussian(K,0.1);
            end
            
            %get our stopping Gaussian. If not defined, assume we go to
            %uniform distribution
            if isKey(K.flagmap,'a_stop')
                a_stop=K.flagmap('a_stop');
            else
                a_stop = 0;
            end
            
            %if we are already flatter than our target, back up!
            if a_vals(1)<=a_stop
                a_vals(1)=a_stop;
                return;
            end
            
            x = zeros(K.dim,num_threads);
            
            %store an array of slacks, i.e. b-A*x, for coordinate hit-and-run
            resetSlacks(K,x);
            
            it=1;
            
            curr_fn=2;
            curr_its=1;
            
            while curr_fn/curr_its>1.001 && a_vals(it) >= a_stop
                it=it+1;
                if isKey(K.flagmap,'ratio')
                    a_vals(it) = a_vals(it-1)*ratio;
                else
                    [a_vals(it),x] = getNextGaussian(a_vals(it-1), 5e2*C+K.dim^2/2, ratio, C, K, x);
                end
                curr_fn = 0;
                curr_its = 0;
                th_num=1;
                %take a few steps to see if we've reached the target
                %distribution
                for j=1:ceil(150/K.eps)
                    
                    x(:,th_num) = getNextPoint(K,x(:,th_num),a_vals(it-1),th_num);
                    
                    curr_its = curr_its+1;
                    curr_fn = curr_fn + eval_exp(x(:,th_num),a_vals(it))/eval_exp(x(:,th_num),a_vals(it-1));
                    
                    th_num = mod(th_num,size(x,2))+1;
                    
                end
            end
            if a_vals(it)>=a_stop
                a_vals=a_vals(1:end-1);
                a_vals(end)=a_stop;
            else
                a_vals(end)=a_stop;
            end
            %                 a_vals
            b_vals = zeros(length(a_vals),1);
            for ij=1:length(a_vals)-1
                b_vals(ij)=a_vals(ij+1)/a_vals(ij);
            end
            %                 b_vals
        end
        
        %x is an K.dim x num_threads vector
        %ensures that K.slacks(:,i) = K.b - K.A * x(:,i)
        %for every thread i
        function [] = resetSlacks(K,x)
            num_threads = size(x,2);
           if ~isempty(K.A)
           if isempty(K.slacks)
              K.slacks = zeros(length(K.b),num_threads); 
           end
            
           for i=1:num_threads
               K.slacks(:,i) = K.b - K.A*x(:,i); 
           end
           end 
           
           if ~isempty(K.E)
              for i=1:num_threads
                 K.slacks_E(i) = (x(:,i)-K.E_p)'*K.E*(x(:,i)-K.E_p); 
              end
           end
        end
        
    end
    
    
end