% Random graph construction routine with various models
% INPUTS:  N - number of nodes
%          p - probability, 0<=p<=1, for all other inputs, p is not considered
%          E - fixed number of edges
%          distribution - probability distribution: use the "connecting-stubs model" generation model
%          degrees - particular degree sequence, used only if distribution = 'sequence'
% OUTPUTS: adj - adjacency matrix of generated graph (symmetric)
% Note 1: Default is Erdos-Renyi graph G(n,0.5)
% Note 2: Generates undirected, simple graphs only
% Note 3: In the worst-case scenario for a given degree distribution, the algorithm is very slow, and it works by restarting itself.
% Source: Various random graph models from the literature
% Other routines: numedges.m, isgraphic.m
% GB, October 31, 2005

function adj = random_graph(n,p,E,distribution,degrees)

adj=zeros(n); % initialize adjacency matrix

switch nargin
    case 1  % just the number of nodes, n
        % 0.5 - default probability of attachment
        for i=1:n
            for j=i+1:n
                if rand<=0.5; adj(i,j)=1; adj(j,i)=1; end
            end
        end
 
    case 2 % the number of nodes and the probability of attachment, n, p
        for i=1:n
            for j=i+1:n
                if rand<=p; adj(i,j)=1; adj(j,i)=1; end
            end
        end
  
    case 3 % fixed number of nodes and edges, n, E     
        while numedges(adj) < E
            i=randi(n); j=randi(n);
            if i==j | adj(i,j)>0; continue; end  % do not allow self-loops or double edges
            adj(i,j)=adj(i,j)+1; adj(j,i)=adj(i,j);
        end
    
    otherwise % pick from a distribution; generate *n* random numbers from a distribution
        Nseq=1;  % ensure the while loops start
        switch distribution
         case 'uniform'
          while not(isgraphic(Nseq)) % make sure Nseq is a graphic sequence
            Nseq = randi(n-1,1,n);
          end
         case 'normal'
          while not(isgraphic(Nseq)) % make sure Nseq is a graphic sequence
            Nseq = ceil((n-1)/10*randn(1,n)+(n-1)/2);
          end
         case 'binomial'
          p=0.5;  % default parameter for binomial distribution
          while not(isgraphic(Nseq)) % make sure Nseq is a graphic sequence
            Nseq = ceil(binornd(n-1,p,1,n));
          end
         case 'exponential'
          while not(isgraphic(Nseq)) % make sure Nseq is a graphic sequence
            Nseq = ceil(exprnd((n-1)/4,1,n));
          end
          
         case 'sequence'
          if nargin<5; fprintf('for distribution="sequence", need to specify a custom degree sequence\n'); return; end
          if not(isgraphic(degrees)); fprintf('degrees is not a graphic sequence - select a different sequence\n'); return; end
          Nseq = degrees;
        end
           
        % connect stubs at random
        stubs=Nseq;
  
        old_sum = 0;
        cnt=0;
        
        while sum(stubs)>0   % while no more stubs are left to connect

          new_sum = sum(stubs);
          if old_sum==new_sum; cnt = cnt+1; end
          if old_sum~=new_sum; cnt=0; end
          if cnt>100; stubs = Nseq; adj=zeros(length(Nseq)); cnt=0; end
          old_sum = sum(stubs);
          
          [~,n1] = max(stubs);
  
          ind = find(stubs>0);
          n2 = ind(randi(length(ind)));
          
          if n1==n2; continue; end

          if adj(n1,n2)>0; continue; end
          adj(n1,n2)=1; adj(n2,n1)=1;
          stubs(n1) = stubs(n1) - 1;
          stubs(n2) = stubs(n2) - 1;

        end
        
end  % end nargin options