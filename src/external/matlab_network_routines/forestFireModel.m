% Implementation of the forest fire model by Leskovec et al
% Source: Graphs over Time: Densification Laws, Shrinking Diameters and Possible Explanations
% Inputs: forward burning probability p in [0,1], 
%         backward burning ratio r, in [1,inf),
%         T - number of nodes
% Outputs: adjacency list of the constructed (directed) graph 
% Note 1: mean = 1/(1-p) => 1/(N*(1-p))<=1 <=> 1/(1-p)<=N <=> 1-p>=1/N <=> p<=1-1/N
% Note 2: r is the ratio between outlinks and inlinks selected at every "back burn" step 
% Last updated: May 10, 2011


function L = forestFireModel(T,p,r)

if T==1
  L{1} = []; % a single node, no edges
  return
elseif T>=2
  L{1} = [2]; L{2} = [1]; % two nodes, a single edge 
end


for t=3:T
  
  L{t} = [];                % new node arrives
  w = randi(t-1);  % pick a node from 1->t-1 uniformly at random
  queue=[w]; visited = []; 
  
  while not(isempty(queue))
    
    w = queue(1); visited = [visited w];

    outlinks = L{w}; inlinks = [];
    for ll=1:length(L)
      if sum(find(L{ll}==w))>0; inlinks = [inlinks ll]; end
    end
  
    L{t} = [L{t} w];   % connect t to w
    
    % generate a number from a binomial distribution with mean (1-p)^(-1) => binornd(N,1/(N(1-p)))
    N = length(unique([outlinks inlinks]));   
    if 1/(N*(1-p))>1; x=N; end;
    if 1/(N*(1-p))<=1; x = binornd(N,1/(N*(1-p)),1,1); end

    NN = [inlinks outlinks];
    w = [ones(size(inlinks)) ones(size(outlinks))*r];
    w = w/sum(w);
    
    inds = randsample(length(NN),x,true,w);
    ws = unique(NN(inds));
    
    L{t} = unique([L{t} ws]);  % add as outlinks to new node 
    
    for ii=1:length(ws)
      if sum(find(visited==ws(ii)))==0; queue = [queue ws(ii)]; end
    end
    queue = queue(2:length(queue));  % remove w from queue
  end
  
end


for ll=1:length(L); L{ll} = setdiff(L{ll},ll); end  % remove self-loops