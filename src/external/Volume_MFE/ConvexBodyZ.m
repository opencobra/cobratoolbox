classdef ConvexBodyZ < handle
    properties
        %P = {x|Ax<=b}
        A
        b
        
        %{x|(x-v)'E(x-v) <= 1}
        E
        v
        
        %store the zonotope
        Z
        %store the max we shrink Z, for determining how small ball it
        %contains
        Z_shrink
        
        %also store E_inv so we don't have to compute it everytime
        E_inv
        
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
       
    end
    
    methods
        function K = ConvexBodyZ(P,E,Z,eps,p,flags)
            %we initialize our ConvexBody object K
            
            %note that we shift everything by p, so we can now
            %assume p=0 throughout the implementation
            if isempty(E)
                K.E=[];
                K.v=[];
                K.E_inv=[];
            else
                K.E=E(:,1:end-1);
                K.E_inv=inv(K.E);
                K.v=E(:,end);
                K.dim=size(K.E,1);
            end
            
            if isempty(P)
                K.A=[];
                K.b=[];
            else
                K.A = P(:,1:end-1);
                K.b = P(:,end);
                K.dim=size(K.A,2);
            end
            
            K.Z_shrink = 1;
            if isempty(Z)
                K.Z=[];
            else
                K.Z=Z;
                K.dim=size(Z,2);
            end
            
            K.p = p;
            K.flagmap = parseFlags(flags);
            K.eps = eps;
            K.m = -1;
            K.verb=1;
            if isKey(K.flagmap,'verb')
                K.verb=K.flagmap('verb');
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
                    dists(i) = (K.b(i) - dot(K.p,K.A(i,:)))/norm(K.A(i,:));
                end
            else
                dists=1e10;
            end
            
            lower = 0;
            upper = 1;
            
            if ~isempty(K.E)
                %shift the point so the ellipsoid is centered at 0
                pt=K.p-K.v;
                if max(abs(pt))<=1e-6
                    %if K.p is the center of the ellipsoid, then the min
                    %distance calculation will have numerical stability
                    %issues, so we'll handle it separately
                    d=sqrt(min(eig(K.E)));
                else
                    options.display=false;
                    options.interval_search=false;
                    d=min_elp_dist(pt,K.E,options);
                end
            else
                %assign a really big value that won't affect our answer
                d = 1e10;
            end

            if ~isempty(K.Z)
                %let's just assume the zonotope has the generators for the unit
                %cube and call it a day

            dists = [dists; 0.5*ones(2*K.dim,1)/K.Z_shrink];
            end
            
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
            while upper - lower>1e-7
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
        
        function [T] = round(K,num_threads)
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
            
            %initialize sum stuff
            done=0;
            tries=0;
            num_rounding_steps=8*K.dim^3;
            rounding_samples=0;
            
            %try to round the body with this number of rounding steps
            while ~done
                %store the original body in case we need to restart the
                %rounding
                old_A=K.A;
                old_E=K.E;
                old_E_inv=K.E_inv;
                old_p = K.p;
                old_Z = K.Z;
                
                %the global rounding matrix
                T = eye(K.dim);
                %the rounding matrix for each iteration
                round_mat=eye(K.dim);
                round_mat(1,1)=3;
                round_it=1;
                max_s=3;
                x = zeros(K.dim,num_threads);
                det_cutoff=2^sqrt(K.dim/2);
                fail=0;
                %we may need multiple rounding iterations to round the body
                %we keep going until it "looks" like its not converging, or
                %the number of iterations is too high
                while (abs(det(round_mat))>det_cutoff||max_s>2.5) && round_it<log(R)/log(20)
                    [s,V,x]=round_body(K,x,num_rounding_steps,0);
                    rounding_samples=rounding_samples+num_rounding_steps;
                    max_s = max(s);
                    S=diag(s);
                    round_mat = V*S;
                    r_inv = diag(1./s)*V';
                    
                    if round_it~=1 && (max_s>=1.2*prev_max_s || abs(det(round_mat)) >= 1.2*prev_det)
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
                    prev_det = abs(det(round_mat));
                    prev_max_s = max_s;
                    
                    %apply the rounding to our points and to the body
                    for j=1:num_threads
                        x(:,j)=r_inv*x(:,j);
                    end
                       
                    if max(abs(K.p))>1e-6
                        K.p = r_inv*K.p;
                    end
                    if ~isempty(K.A)
                        K.A=K.A*round_mat;
                    end
                    if ~isempty(K.E)
                        R=V*diag(1./s);
                        R_inv=S*V';
                        K.E=R'*K.E*R;
                        K.E_inv = R_inv*K.E_inv*R_inv';
                    end
                    
                    if ~isempty(K.Z)
                        K.Z = (r_inv*(K.Z.')).';
                        K.Z_shrink = K.Z_shrink*max_s;
                    end
                    
                    %update global rounding matrix
                    T=T*round_mat;
                end
                if round_it<10 && fail==0
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
                    K.E=old_E;
                    K.E_inv=old_E_inv;
                    K.p = old_p;
                    K.Z = old_Z;
                    K.Z_shrink = 1;
                end
            end
            if K.verb>=1
                fprintf('------Rounding Complete------\n\n');
            end
        end
        
        %the below is a helper function for round() above. it will sample
        %from K for the specified number of points, and use MATLAB's SVD
        %function to compute the transformation that puts the points in
        %isotropic position
        function [s,V,x] = round_body(K,x,its,a)
            svd_pts = zeros(its,K.dim);
            th_num = 1;
            
            for i=1:its
                x(:,th_num) = hitAndRun(K,x(:,th_num),a);
                svd_pts(i,:) = x(:,th_num);
                th_num = mod(th_num,size(x,2))+1;
            end
            
            for i=1:size(svd_pts,1)
                svd_pts(i,:)=svd_pts(i,:)-K.p';
            end
            
            s = svd(svd_pts.');
            s = s/min(s);
            if max(s) >= 2
                for i=1:size(s,1)
                    if s(i)<2
                        s(i)=1;
                    end
                end
                
                [~,~,V] = svd(svd_pts,0);
            else
                s=0*s+1;
                V=eye(K.dim);
            end
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
            
            if ~isempty(K.Z)
               %to find the values of \alpha s.t. x+\alpha*u intersects the
               %boundary of our zonotopes, let's form an LP. we then
               %min/max the values of \alpha
               
               Aeq = [K.Z.' -u];
               num_var = size(K.Z,1);
               f = [zeros(num_var,1); 1];
               lb = [zeros(num_var,1); -Inf];
               ub = [ones(num_var,1); Inf];
               
               %suppress the print statment MATLAB gives every time you do an lp solve
               options = optimset('Display','none');
               
               %this will minimize value of \alpha
               y = linprog(f,[],[],Aeq,x,lb,ub,[],options);
               lower = max(lower,y(end));
               
               %now maximize it
               f(end)=-1;
               y = linprog(f,[],[],Aeq,x,lb,ub,[],options);
               upper = min(upper,y(end));
               
            end
            
            upper = x+(upper-1e-6)*u;
            lower = x+(lower+1e-6)*u;
            
        end
        
        %if you want to compute the two intersection points of a chord and
        %an ellipsoid, it reduces to solving a quadratic equation.
        function [lambda] = dists_to_ellipsoid(K,x,u)
            x=x-K.v;
            a=u'*K.E_inv*u;
            bb=u'*K.E_inv*x+x'*K.E_inv*u;
            c=x'*K.E_inv*x-1;
            disc = sqrt(bb^2-4*a*c);
            lambda = zeros(2,1);
            lambda(1) = min((-bb-disc)/(2*a), (-bb+disc)/(2*a));
            lambda(2) = max((-bb-disc)/(2*a), (-bb+disc)/(2*a));
        end
        
        %membership oracle of K = P \cap E
        function [is_true] = in_K(K,x)
            
            if isempty(K.E) || (x-K.v)'*K.E_inv*(x-K.v)<=1
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
        function [new_a] = getNextGaussian(a, its, ratio, C, K,x)
            last_a = a;
            
            done = 0;
            k = 1;
            pts = zeros(K.dim, its);
            th_num = 1;
            for i=1:its
                x(:,th_num) = hitAndRun(K,x(:,th_num),last_a);
                pts(:,i) = x(:,th_num);
                th_num = mod(th_num,size(x,2))+1;
            end
            last_ratio = 0.1;
            fn = zeros(its,1);
            while ~done
                a = last_a * ratio^k;
                
                for i=1:its
                    fn(i) = eval_exp(pts(:,i)-K.p,a)/eval_exp(pts(:,i)-K.p,last_a);
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
            next_pt = rand_exp_range(lower-K.p, upper-K.p, a)+K.p;
            
        end
        
        %         function [next_pt] = ballWalk(K,x,a,delta)
        %             next_pt = x;
        %             f_x = eval_exp(x,a);
        %             K.tries = K.tries+1;
        %             u = randn(K.dim,1);
        %             y = x+delta*u./norm(u).*rand()^(1/K.dim);
        %             if in_K(K,y)
        %                 K.success=K.success+1;
        %                 f_y = eval_exp(y,a);
        %                 pr = rand();
        %                 if pr<=f_y/f_x
        %                     next_pt = y;
        %                 end
        %             end
        %         end
        
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
            for i=1:num_threads
                x(:,i)=K.p;
            end
            
            it=1;
            
            curr_fn=2;
            curr_its=1;
            
            while curr_fn/curr_its>1.001 && a_vals(it) >= a_stop
                it=it+1;
                if isKey(K.flagmap,'ratio')
                    a_vals(it) = a_vals(it-1)*ratio;
                else
                    [a_vals(it)] = getNextGaussian(a_vals(it-1), 5e2*C+4*K.dim^2, ratio, C, K, x);
                end
                curr_fn = 0;
                curr_its = 0;
                th_num=1;
                %take a few steps to see if we've reached the target
                %distribution
                for j=1:ceil(150/K.eps)
                    
                    x(:,th_num) = hitAndRun(K,x(:,th_num),a_vals(it-1));
                    
                    curr_its = curr_its+1;
                    curr_fn = curr_fn + eval_exp(x(:,th_num)-K.p,a_vals(it))/eval_exp(x(:,th_num)-K.p,a_vals(it-1));
                    
                    th_num = mod(th_num,size(x,2))+1;
                    
                end
            end
            if a_vals(it)>=a_stop
                a_vals=a_vals(1:end-1);
                a_vals(end)=a_stop;
            else
                a_vals(end)=a_stop;
            end
        end
        
    end
    
end