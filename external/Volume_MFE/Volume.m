function [volume,T,steps,r_steps] = Volume(P,E,eps,p,flags)
%[volume,T,steps] = Volume(P,E,eps,p,flags)
%This function is a randomized algorithm to approximate the volume of a convex
%body K = P \cap E with relative error eps. The last 4 parameters are optional; 
%you can see the default values at the top of Volume.m.

%---INPUT VALUES---
%P: the polytope [A b] which is {x | Ax <= b}
%E: the ellipsoid [Q v] which is {x | (x-v)'Q^{-1}(x-v)<=1}
%eps: the target relative error
%p: a point inside P \cap E close to the center
%flags: a string of input flags. see parseFlags.m

%---RETURN VALUES---
%volume: the computed volume estimate
%T: the rounding matrix. If no rounding, then T is identity matrix
%steps: the number of steps the volume algorithm took
%r_steps: the number of steps the rounding algorithm took

%assign default values if not assigned in function call
if exist('flags','var')==0
    flags = '';
end
if exist('p','var')==0
    dim = size(P,2)-1;
    if isempty(P)
        dim = size(E,1);
    end
    p = zeros(dim,1);
end
if exist('eps','var')==0
    eps = 0.20;
end
if exist('E','var')==0
    E=[];
end

%prepare our objects
K = ConvexBody(P,E,eps,p,flags);
if K.verb>=1
    fprintf('--------%d-Dimension Convex Body------\n\n', K.dim);
end

%make sure the provided point is inside the body
if ~in_K(K,zeros(K.dim,1))
    error('The point provided is not in the convex body! Please provide a different center point.');
end

%let's initialiez some helpful constants
[ratio,num_threads,C] = assignConstants(K);

if isKey(K.flagmap,'round')
    %rounding phase
    
    %round the body once as a preprocessing step
    %note that K is modified inside round()
    [T,r_steps]=round(K,num_threads);
else
    %we are not rounding the body
    T=eye(K.dim);
    r_steps = 0;
end

%make it so the min distance to dK from 0 is exactly 1
%helpful for sampler
% [det_round]=unitBallify(K,det_round);

if K.verb>=1
    fprintf('------Volume Start------\n');
end

%these are our starting points for each thread
%we shifted our body so that K contains the origin, so x \in K
x = zeros(K.dim,num_threads);

%compute the annealing schedule that keeps E(Y^2)/E(Y)^2<=C
[a_sched] = getAnnealingSchedule(K,ratio,num_threads,C);
K.m = length(a_sched);

%compute the initial volume, multiplied by the determinant of the rounding
% matrix.
volume = (pi/a_sched(1))^(K.dim/2)*abs(det(T));

%initialize additional helpful variables
fn = zeros(length(a_sched),1);
its = zeros(length(a_sched),1);

if K.verb>=1
    fprintf('Num Phases: %d\n', K.m);
end
for i=1:length(a_sched)-1
    if K.verb>=1
        fprintf('Phase %d Volume: %e', i-1,volume);
        if K.verb>=2
            %compute how many "ratios" we've stepped down so far
            sigma_index=round(log(a_sched(i)/a_sched(1))/log(ratio));
            fprintf(',   sigma_%d=%e', sigma_index,1/sqrt(2*a_sched(i)));
        end
        fprintf('\n');
    end
    %prepare to sample this volume phases
    
    %allocate the error to this phase
    curr_eps = K.eps/sqrt(K.m);
    
    %initialize the sliding window of size W
    W = ceil(4*K.dim^2+500);
    min_val=-1e100;
    max_val=1e100;
    min_index=W;
    max_index=W;
    last_W = zeros(W,1);
    
    %this is the flag for when we converge
    done=0;
    
    %keep taking steps until we converge
    while ~done
        %advance each of the threads one step
        for j=1:num_threads
            
            %take one step of hit-and-run
            x(:,j) = hitAndRun(K,x(:,j),a_sched(i));
            
            %update the current volume ratio with this new point
            its(i) = its(i)+1;
            fn(i) = fn(i) + eval_exp(x(:,j),a_sched(i+1))/eval_exp(x(:,j),a_sched(i));
            
            %add the current point to the sliding winow
            index = mod(its(i)-1,W)+1;
            val = fn(i)/its(i);
            
            %Update the sliding window, keeping track of min/max over last W
            %steps. For random points, this will work in O(1) expected amortized time.
            last_W(index)=val;
            if val<=min_val
                min_val=val;
                min_index=index;
            elseif min_index==index
                [min_val,min_index]=min(last_W);
            end
            if val>=max_val
                max_val=val;
                max_index=index;
            elseif max_index==index
                [max_val,max_index]=max(last_W);
            end
            
            %check to see if the last W points are within sufficiently
            %small relative error. if so, stop this volume phase
            if (max_val-min_val)/max_val<=curr_eps/2
                done=1;
                break;
            end
            
        end
        
    end
    if K.verb>=2
        fprintf('Steps in Phase %d: %d\n', i-1, its(i));
    end
    volume = volume*mean(last_W);
end

if K.verb>=1
    fprintf('------Volume Complete------\n\n');
    fprintf('Final Volume: %e,  final sigma=%e\n',volume, 1/sqrt(2*a_sched(end)));
    fprintf('Total steps: %d\n', sum(its));
end

steps=sum(its);
end

function [ratio,num_threads,C] = assignConstants(K)
%initialize some hard-coded constants
if isKey(K.flagmap,'ratio')
    ratio = K.flagmap('ratio');
else
    ratio = 1-1/K.dim;
end
if isKey(K.flagmap,'num_t')
    num_threads = K.flagmap('num_t');
else
    num_threads = 5;
end
if isKey(K.flagmap,'C')
    C = K.flagmap('C');
else
    C = 2;
end
end