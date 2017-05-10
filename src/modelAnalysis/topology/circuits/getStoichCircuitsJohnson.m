function [C,csigns] = getStoichCircuitsJohnson(S,undirected)
%function C = getcircuitsjohnson(S)
% Finds all elementary circuits of a bidirectional Stoichiometric matrix using Johnson's circuit
% enumeration algorithm using code from the CellNetAnalyzer toolbox by Stefan Klampt
%
% INPUT 
% S             stoichiometric matrix
%
% OPTIONAL INPUT
% undirected    determines whether or not to treat edges as undirected (1) or directed (0); 
%               interactions cannot be enforced in undirected graphs (default: 0)
%
% OUTPUT
% C             matrix that contains the cycles row-wise (columns correspond to edges/the interactions)
% csigns        vector indicating for each path whether it is positive (1) or negative (-1)

if ~exist('undirected','var')
    undirected = 0;
end

[numNodes,numEdges]=size(S);

% cnap is the structure used by CNA
cnap.interMat = S;
cnap.notMat = abs(cnap.interMat); % arbitrary
cnap.reacID = (1:numEdges)'; % arbitrary names to edges
cnap.numr = numEdges;
cnap.epsilon = 1e-10;
edge_constr=[];
node_constr=[];

% CNAcomputeCycles in the CellNetAnalyzer toolbox by Stefan Klampt
% This function enumerates cycles (feedback loops) in signal flow networks.
% Usage: [cycles, csigns]= CNAcomputeCycles(cnap, edge_constr, node_constr, undirected)
% Arguments:
% cnap            CellNetAnalyzer (signal-flow) project variable and mandatory argument. 
%                 The function accesses the following fields in cnap : 
% cnap.interMat: contains the incidence matrix of a graph or of a hypergraph; 
%                in the latter case hyperarcs will be split internally and the resulting cycles will
%                be mapped back to the hypergraph 
% cnap.notMat:   contains the minus signs along the (hyper)arcs 
% cnap.reacID:   names of the columns (arcs/hyperarcs) in cnap.interMat 
% cnap.numr:     number of interactions (columns in cnap.interMat)
% cnap.epsilon:  smallest number greater than zero 
%
% The other arguments are optional:
% edge_constr: [] or a vector of length 'cnap.numr'. if(edge_constr(i)==0) then only those cycles 
%              are computed that do not include the interaction i; if(edge_constr(i)~=0 & 
%              edge_constr(i)~=NaN) enforces interaction i, i.e. only those cycles will be computed
%              that involve interaction i; interaction i remains unconstrained if(edge_constr(i)=NaN);
%              several interactions may be suppressed/enforced simultaneously(default: [])
% node_constr: [] or a vector of length 'cnap.nums'. if(node_constr(i)==0) then only those cycles 
%              are computed that do not include species i; if(node_constr(i)~=0 & node_constr(i)~=NaN)
%              enforces species i, i.e. only those cycles will be computed that involve species i;
%              species i remains unconstrained if(node_constr(i)=NaN); several species may be 
%              suppressed/enforced simultaneously; (default: [])
% undirected: determines whether or not to treat edges as undirected (1) or directed (0); 
%             interactions cannot be enforced in undirected graphs (default: 0)
%
% Results:
% cycles: matrix that contains the cycles row-wise (columns correspond to edges/the interactions)
% csigns: vector indicating for each path whether it is positive (1) or negative (-1)

[cycles, csigns] = CNAcomputeCycles(cnap,edge_constr, node_constr, undirected);
C = cycles';
end