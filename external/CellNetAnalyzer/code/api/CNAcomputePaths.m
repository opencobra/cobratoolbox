function [paths, psigns]= CNAcomputePaths(cnap, edge_constr, node_constr, addin, addout, specstart, specend)
%
% CellNetAnalyzer API function 'CNAcomputePaths'
% ---------------------------------------------
% --> calculation of paths
%
% Usage: [paths, psigns]= CNAcomputePaths(cnap, edge_constr,...
%	            node_constr, addin, addout, specstart, specend)
% 
% cnap is a CellNetAnalyzer (signal-flow) project variable and mandatory argument. 
% The function accesses the following fields in cnap (see also manual):
%   cnap.interMat: contains the incidence matrix of a graph
%			or of a hypergraph; in the latter case hyperarcs
%			will be split internally and the resulting paths
%			will be mapped back to the hypergraph
%   cnap.notMat: contains the minus signs along the (hyper)arcs
%   cnap.reacID: names of the columns (arcs/hyperarcs) in cnap.interMat  
%   cnap.numr: number of interactions (columns in cnap.interMat)
%   cnap.epsilon: smallest number greater than zero 
%
% The other arguments are optional:
%
%   edge_constr: [] or a vector of length 'cnap.numr'. if(edge_constr(i)==0)
%     then only those paths are computed that do not include the interaction i;
%     if(edge_constr(i)~=0 & edge_constr(i)~=NaN) enforces interaction i, i.e. only 
%     those paths will be computed that involve interaction i; interaction i remains
%     unconstrained if(edge_constr(i)=NaN);
%     several interactions may be suppressed/enforced simultaneously
%     (default: [])
%
%   node_constr: [] or a vector of length 'cnap.nums'. if(node_constr(i)==0)
%     then only those paths are computed that do not include species i;
%     if(node_constr(i)~=0 & node_constr(i)~=NaN) enforces species i, i.e. only 
%     those paths will be computed that involve species i; species i remains
%     unconstrained if(node_constr(i)=NaN);
%     several species may be suppressed/enforced simultaneously
%     (default: [])
%
%   addin: [0|1] wheter or not to add nodes from the input layer to the set of start nodes
%     (default: 0)
%
%   addout: [0|1] wheter or not to add nodes from the output layer to the set of end nodes
%     (default: 0)
%
%   specstart: either a string of start node names separated
%     by whitespace or an array of start node indices
%     (default: [])
%
%   specend: either a string of end node names separated by
%     whitespace or an array of end node indices
%     (default: [])
%
%
% The following results are returned:
%
%   paths: matrix that contains the paths row-wise; the columns correspond to the
%     interactions; 
%
%   psigns: vector indicating for each path whether it is positive (1) or negative (-1)
%

% Old:
%   idx: maps the columns in 'paths' onto the column indices in cnap.interMat,
%	     i.e. idx(i) refers to the column number in cnap.interMat (and to the
%	     row in cnap.reacID)

error(nargchk(1, 7, nargin));

%A# default parameters:
cnap.local.rb= zeros(0, 2);
cnap.local.metvals= zeros(0, 2);
cnap.local.val_addin= 0;
cnap.local.val_addout= 0;
cnap.local.val_specstartc= [];
cnap.local.val_specendc= [];

if nargin > 1
  edge_constr= reshape(edge_constr, length(edge_constr), 1);
  cnap.local.rb= find(~isnan(edge_constr));
  cnap.local.rb(:, 2)= edge_constr(cnap.local.rb);
  if nargin > 2
    node_constr= reshape(node_constr, length(node_constr), 1);
    cnap.local.metvals= find(~isnan(node_constr));
    cnap.local.metvals(:, 2)= node_constr(cnap.local.metvals);
    if nargin > 3
      cnap.local.val_addin= addin;
      if nargin > 4
        cnap.local.val_addout= addout;
        if nargin > 5
          cnap.local.val_specstartc= specstart;
          if nargin > 6
            cnap.local.val_specendc= specend;
          end
        end
      end
    end
  end
end

cnap= compute_paths(cnap);

paths=zeros(size(cnap.local.elmoden,1),cnap.numr);
idx= cnap.local.mode_rates;
paths(:,idx)= cnap.local.elmoden;
psigns=int32(cnap.local.elm_consts);
psigns(psigns==1)=-1;
psigns(psigns==0)=1;
