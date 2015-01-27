function [cycles, csigns]= CNAcomputeCycles(cnap, edge_constr, node_constr, undirected)
%
% CellNetAnalyzer API function 'CNAcomputeCycles'
% ---------------------------------------------
% --> calculation of cycles
%
% Usage: [cycles, csigns]= CNAcomputeCycles(cnap, edge_constr, node_constr, undirected)
% 
% cnap is a CellNetAnalyzer (signal-flow) project variable and mandatory argument. 
% The function accesses the following fields in cnap (see also manual):
%   cnap.interMat: contains the incidence matrix of a graph
%			or of a hypergraph; in the latter case hyperarcs
%			will be split internally and the resulting cycles
%			will be mapped back to the hypergraph
%   cnap.notMat: contains the minus signs along the (hyper)arcs
%   cnap.reacID: names of the columns (arcs/hyperarcs) in cnap.interMat  
%   cnap.numr: number of interactions (columns in cnap.interMat)
%   cnap.epsilon: smallest number greater than zero 
%
% The other arguments are optional:
%
%   edge_constr: [] or a vector of length 'cnap.numr'. if(edge_constr(i)==0)
%     then only those cycles are computed that do not include the interaction i;
%     if(edge_constr(i)~=0 & edge_constr(i)~=NaN) enforces interaction i, i.e. only 
%     those cycles will be computed that involve interaction i; interaction i remains
%     unconstrained if(edge_constr(i)=NaN);
%     several interactions may be suppressed/enforced simultaneously
%     (default: [])
%
%   node_constr: [] or a vector of length 'cnap.nums'. if(node_constr(i)==0)
%     then only those cycles are computed that do not include species i;
%     if(node_constr(i)~=0 & node_constr(i)~=NaN) enforces species i, i.e. only 
%     those cycles will be computed that involve species i; species i remains
%     unconstrained if(node_constr(i)=NaN);
%     several species may be suppressed/enforced simultaneously
%     (default: [])
%
%   undirected:  determines whether or not to treat edges as undirected (1) or 
%     directed (0); interactions cannot be enforced in undirected graphs
%     (default: 0)
%
%
% The following results are returned:
%
%   cycles: matrix that contains the cycles row-wise; the columns correspond to the
%     interactions;
%
%   csigns: vector indicating for each path whether it is positive (1) or negative (-1)
%


%%% Old: not supported anymore:
%   idx: maps the columns in 'cycles' onto the column indices in cnap.interMat,
%	     i.e. idx(i) refers to the column number in cnap.interMat (and to
%	     the row number in cnap.reacID)

error(nargchk(1, 4, nargin));

%A# default parameters:
cnap.local.rb= zeros(0, 2);
cnap.local.metvals= zeros(0, 2);
cnap.local.val_undirected= 0;

if nargin > 1
  edge_constr= reshape(edge_constr, length(edge_constr), 1);
  cnap.local.rb= find(~isnan(edge_constr));
  cnap.local.rb(:, 2)= edge_constr(cnap.local.rb);
  if nargin > 2
    node_constr= reshape(node_constr, length(node_constr), 1);
    cnap.local.metvals= find(~isnan(node_constr));
    cnap.local.metvals(:, 2)= node_constr(cnap.local.metvals);
    if nargin > 3
      cnap.local.val_undirected= undirected;
    end
  end
end

cnap= compute_loops(cnap);

cycles=zeros(size(cnap.local.elmoden,1),cnap.numr);
idx= cnap.local.mode_rates;
cycles(:,idx)= cnap.local.elmoden;
csigns=int32(cnap.local.elm_consts);
csigns(csigns==1)=-1;
csigns(csigns==0)=1;

