function [x,T,steps] = Sample(P,E,eps,p,flags,start_pt)
%[x,samples,T] = Sample(P,E,eps,p,flags,start_pt)
%This function is a randomized algorithm to approximately sample from a convex
%body K = P \cap E with error parameter eps. The last 5 parameters are optional; 
%you can see the default values at the top of Sample.m.

%---INPUT VALUES---
%P: the polytope [A b] which is {x | Ax <= b}
%E: the ellipsoid [Q v] which is {x | (x-v)'Q^{-1}(x-v)<=1}
%eps: the target error
%p: a point inside P \cap E close to the center
%flags: a string of input flags. see parseFlags.m
%start_pt: if you want a starting point for hit-and-run

%---RETURN VALUES---
%x: the point approximately from the target distribution (default uniform)
%T: the rounding matrix. If no rounding, then T is identity matrix
%steps: the number of steps it took to reach the target point

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
if exist('start_pt','var')==0
   dim = size(P,2)-1;
   if isempty(P)
       dim = size(E,1);
   end
   start_pt=zeros(dim,1);
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

%let's initialize some helpful constants
[ratio,num_threads,C] = assignConstants(K);

if isKey(K.flagmap,'round')
    %rounding phase
    
    %round the body once as a preprocessing step
    %note that K is modified inside round()
    [T]=round(K,num_threads);
else
    %we are not rounding the body
    T=eye(K.dim);
end

if K.verb>=1
    fprintf('------Sample Start------\n');
end

%these are our starting points for each thread
%we shifted our body so that K contains the origin, so x \in K
x = start_pt;

%compute the annealing schedule that keeps E(Y^2)/E(Y)^2<=C
[a_sched] = getAnnealingSchedule(K,ratio,num_threads,C);
K.m = length(a_sched);

%initialize additional helpful variables
fn = zeros(length(a_sched),1);
its = zeros(length(a_sched),1);
curr_mean = zeros(K.dim,1);

if K.verb>=1
    fprintf('Num Phases: %d\n', K.m);
end

for i=1:length(a_sched)
    if K.verb>=1
        fprintf('Phase %d,    sigma_%d=%e\n', i-1,round(log(a_sched(i)/a_sched(1))/log(ratio)), 1/sqrt(2*a_sched(i)));
    end
    %prepare to sample
    
    %initialize the sliding window of size W
    W = ceil(4*K.dim^2+500);
    min_val=-1e100;
    max_val=1e100;
    min_index=W;
    max_index=W;
    last_W = zeros(W,1);
    
    %this is the flag for when we converge
    done=0;
    
    %get a random normal for a hyperplane through a guess for the current
    %mean of our distribution
    
    %use the mean of the last phase as the guess for the mean now. we
    %don't have to have the exact mean, just reasonably close
    last_mean = curr_mean;
    h_normal=randn(K.dim,1);
    curr_mean=zeros(K.dim,1);
    
    %keep taking steps until we converge
    while ~done
        
        %take one step of hit-and-run
        x = hitAndRun(K,x,a_sched(i));
        
        %update the current volume ratio with this new point
        its(i) = its(i)+1;
        curr_mean = (curr_mean*(its(i)-1) + x)/its(i);
        
        %recompute our convergence test
        if isKey(K.flagmap,'c_test') && K.flagmap('c_test')==2
            fn(i)=fn(i)+norm(x-last_mean)^2;
        else
            fn(i) = fn(i) + (dot(x-last_mean,h_normal)>0);
        end
        %
        %             %add the current point to the sliding winow
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
        %satisfy some condition dependent on our error parameter
        if isKey(K.flagmap,'c_test') && K.flagmap('c_test')==2
            if (max_val-min_val)/max_val<=eps
                done=1;
            end
        else
            if max_val-min_val<=eps
                done=1;
            end
        end
        
    end
    
    if K.verb>=2
        fprintf('Steps in Phase %d: %d\n', i-1, its(i));
    end
end
if K.verb>=1
    fprintf('------Sample End------\n');
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
num_threads = 1;
if isKey(K.flagmap,'C')
    C = K.flagmap('C');
else
    C = 2;
end
end