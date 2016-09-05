function [depmat,idx,distpos,distneg]= CNAcomputeDepMat(cnap, maxdist, edge_constr, node_constr, algo)
%
% CellNetAnalyzer API function 'CNAcomputeDepMat'
% ---------------------------------------------
% --> calculation of the dependency matrix
%
% Usage: [depmat,idx,distpos,distneg]= CNAcomputeShortestSignedPaths(cnap, maxdist,...
%	            edge_constr, node_constr, algo)
% 
%   cnap: is a CellNetAnalyzer (signal-flow) project variable and mandatory argument. 
% 	The function accesses the following fields in cnap (see also manual):
%   		cnap.interMat: contains the incidence matrix of a graph or of a hypergraph; 
%                  in the latter case hyperarcs will be split internally
%   		cnap.notMat: contains the minus signs along the (hyper)arcs
%   		cnap.reacID: names of the columns (arcs/hyperarcs) in cnap.interMat  
%   		cnap.specID: names of the rows (species) in cnap.interMat  
%   		cnap.nums: number of species (rows in cnap.interMat)
%
% The other arguments are optional:
%
%   maxdist: limits the maximal path length of a shortest path; must be a
%     number greater zero; use 'Inf' to leave the maximal path length
%     unrestricted (default: Inf)
%
%   edge_constr: [] or a vector of length 'cnap.numr'. if(edge_constr(i)==0)
%     then (hyper-)arc i is removed from the network before calculation
%     (default: [])
%
%   node_constr: [] or a vector of length 'cnap.nums'. if(node_constr(i)==0)
%     then species i is removed from the network before calculation
%     (default: [])
%
%   algo: selects one of the following algorithms for computing the required
%         shortest signed paths:
%     1: exhaustive depth-first traversal
%     2: approximative algorithm
%     3: two-step algorithm (exact and in certain cases faster than algo 1)
%     (default: 1)
%
%
% The following results are returned:
%
%   depmat: dependency matrix of the model; 
%   	the entries in the matrix have the following meaning:
%		depmat(i,j)=1:  i does not affect j (non-affecting)
%		depmat(i,j)=2:  i is ambivalent factor of j
%				(i affect j positively and negatively) 
%		depmat(i,j)=3:  i is weak inhibitor of j
%				(i affects j only via negative paths; some of these
%				paths touch negative feedback loops )
%		depmat(i,j)=4:  i is weak activator of j
%				(i affects j only via positive paths; some of these
%				paths touch negative feedback loops )
%		depmat(i,j)=5:  i is strong inhibitor of j
%				(i affects j only via negative paths; none of these
%				paths touches a negative feedback loop)
%		depmat(i,j)=6:  i is a strong activator of j
%				(i affects j only via positive paths; none of these
%				paths touches a negative feedback loop)
%
%   idx: maps the rows/columns of distpos, distneg, dist onto the column indices
%     in cnap.interMat (idx = 1:cnap.nums when no species were removed)
%
%   The following two results are a "side-product" that could als seperately computed
%   via CNAcomputeShortestSignedPaths:
%   distpos: matrix with the shortest positive path lengths; '0' means no
%     positive path between the corresponding pair of nodes was found
%
%   distneg: matrix with the shortest negative path lengths; '0' means no
%     negative path between the corresponding pair of nodes was found
%


error(nargchk(1, 5, nargin));

%A# default parameters:
cnap.local.maxdist= Inf;
cnap.local.rb= zeros(0, 2);
cnap.local.metvals= zeros(0, 2);
cnap.local.valex= 0;
cnap.local.valexr= 0;
cnap.local.valapp= 1;

if nargin > 1
  cnap.local.maxdist= maxdist;
  if nargin > 2
    if ~isempty(edge_constr)
      cnap.local.valexr= 1;
      edge_constr= reshape(edge_constr, length(edge_constr), 1);
      cnap.local.rb= find(~isnan(edge_constr));
      cnap.local.rb(:, 2)= edge_constr(cnap.local.rb);
    end
    if nargin > 3
      if ~isempty(node_constr)
        cnap.local.valex= 1;
        node_constr= reshape(node_constr, length(node_constr), 1);
        cnap.local.metvals= find(~isnan(node_constr));
        cnap.local.metvals(:, 2)= node_constr(cnap.local.metvals);
      end
      if nargin > 4
        cnap.local.valapp= algo;
      end
    end
  end
end

cnap= compute_shortest_signed_paths(cnap);

idx= cnap.local.specsidx;
dist= cnap.local.distx;
distpos= cnap.local.distposx;
distneg= cnap.local.distnegx;

ss=size(dist,1);
negloops=[];
for i=1:ss
        if(distneg(i,i)>0)
               negloops(end+1)=i;
        end
end

depmat=zeros(ss,ss);
for i=1:ss
        li=i;
        zw=zeros(1,ss);
        zw2=2*sign(distpos(li,:))+sign(distneg(li,:));
        zw(find(zw2==0))=1;   %%non-affectring
        zw(find(zw2==3))=2;   %%ambivalent
        zw(find(zw2==1))=3;   %%inhibitor
        zw(find(zw2==2))=4;   %%activator
        if(any(zw==0))
                disp('Error');
                return;
        end
        negf=negloops(find(zw(negloops)>1));
        for k=1:ss
                if(zw(k)>2)
                        if(~any(dist(negf,k)))
                                zw(k)=zw(k)+2;
                        end
                end
        end
        depmat(i,:)=zw;
end

