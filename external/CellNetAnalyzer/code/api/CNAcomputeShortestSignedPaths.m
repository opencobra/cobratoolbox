function [distpos, distneg, idx, dist]= CNAcomputeShortestSignedPaths(cnap, maxdist, edge_constr, node_constr, algo)
%
% CellNetAnalyzer API function 'CNAcomputeShortestSignedPaths'
% ---------------------------------------------
% --> calculation of shortest signed paths lengths
%
% Usage: [distpos, distneg, idx, dist]= CNAcomputeShortestSignedPaths(cnap, maxdist,...
%	            edge_constr, node_constr, algo)
% 
%   cnap is a CellNetAnalyzer (signal-flow) project variable and mandatory argument. 
% 	The function accesses the following fields in cnap (see also manual):
%   		cnap.interMat: contains the incidence matrix of a graph or of a hypergraph; 
%                  in the latter case hyperarcs will be split internally
%   		cnap.notMat: contains the minus signs along the (hyper)arcs
%   		cnap.reacID: names of the columns (arcs/hyperarcs) in cnap.interMat  
%  		cnap.specID: names of the rows (species) in cnap.interMat  
%   		cnap.nums: number of species (rows in cnap.interMat)
%
% The other arguments are optional:
%
%   maxdist: limits the maximal path length of a shortest path; must be a
%     number greater zero; use 'Inf' to leave the maximal path length
%     unrestricted  (default: Inf)
%
%   edge_constr: [] or a vector of length 'cnap.numr'. if(edge_constr(i)==0)
%     then (hyper-)arc i is removed from the graph before calculation
%     (default: [])
%
%   node_constr: [] or a vector of length 'cnap.nums'. if(node_constr(i)==0)
%     then species i is removed from the graph before calculation
%     (default: [])
%
%   algo: selects one of the following algorithms:
%     1: exhaustive depth-first traversal
%     2: approximative algorithm
%     3: two-step algorithm (exact and in certain cases faster than algo 1)
%     (default: 1)
%
% The following results are returned:
%
%   distpos: matrix with the shortest positive path lengths; '0' means no
%     positive path between the corresponding pair of nodes was found
%
%   distneg: matrix with the shortest negative path lengths; '0' means no
%     negative path between the corresponding pair of nodes was found
%
%  idx: maps the rows/columns of distpos, distneg, dist onto the species indices
%     in cnap.interMat (idx = 1:cnap.nums if no species was removed)
%
%   dist: matrix with the shortest (unsigned) paths lengths; '0' means no
%     path between the corresponding pair of nodes was found

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
