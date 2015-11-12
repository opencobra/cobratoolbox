function [graph] = CNATranswesd(graph,epsilon,fullcheck,pathexact,acyclic,maxpathl)
%
% CellNetAnalyzer API function: 'CNATranswesd'
% --------------------------------------------
% --> Transitive reduction in weighted signed graphs (useful as false positive 
%     reduction method in reverse engineering of cellular interaction graphs).
%     This algorithm has been described in the followinhg reference:
%     Klamt S, Flassig R, Sundmacher K. 2010. TRANSWESD: inferring
%     cellular networks with transitive reduction. Bioinfomatics 26:2160-2168.
%
% Usage: [graph] = CNATranswesd(graph,epsilon,fullcheck,pathexact,maxpathl)
%
% In contrast to most CNA API functions, this function does
% not require a CNA project variable. A mandatory argument is 
% 'graph' which is a structure with the following fields:
%	graph.adjpos: adjacency matrix of the positive edges. 
%	      if graph.adjpos(i,k)>0, then a positive edge from
%	      i to k exists and graph.adjpos(i,k) stores its weight.
%	graph.adjneg: adjacency matrix of the negative edges. 
%	      if graph.adjneg(i,k)>0, then a negative edge from
%	      i to k exists and graph.adjneg(i,k) stores its weight.
%
% The other three arguments are optional:
%  epsilon: confidence factor. An edge from i to k with weight w 
%    can be explained by a path from i to k with weight z
%    (and is therefore deleted) if z<w*epsilon. Default: 0.95.
%    Here the length of a path is computed as the maximum weight of all its edges. 
%    For further explanations see reference given above.
%  fullcheck: whether all path lengths have to be recalculated after
%    removing an edge (1) or not (0). Default: 1.
%  pathexact: whether path lengths have to be calculated exactly (1)
%    or approximately (0). Default: 1.
%  acyclic: if 1, only edges between nodes from different components
%    will be considered for removal by transitive reduction. Default: 0.
%  maxpathl: maximum number of edges that a path may have if it is 
%    used to explain an edge. Choose Inf if any appropriate path 
%    (see parameter epsilon above) can explain an edge. Default: Inf.
%    If 2<maxpathl<INF (and maxpathl not too large) it is recommended
%    to use this feature only in combination with pathexact=fullcheck=1. 
%
%  The returned result is a graph with the same fields as in the input
%  graph plus graph.recadjpos and graph.recadjneg describing the transitive
%  reduction of the input graph as defined in the reference given above.


if(nargin<6)
	maxpathl=Inf;
end
if(nargin<5)
	acyclic=0;
end
if(nargin<4)
	pathexact=1;
end
if (nargin<3)
	fullcheck=1;
end
if(nargin<2)
	epsilon=0.95;
end
	
graph.nums=size(graph.adjpos,1);

if(acyclic)
	incimat=adj2inci(graph.adjpos,graph.adjneg);
	[scclabels,numscc]=scc_tarjan(incimat);
	disp([num2str(numscc),' components in the graph.']);
end

if(maxpathl==2)
	distpos=graph.adjpos;
	distpos(find(graph.adjpos==0))=Inf;
	distneg=graph.adjneg;
	distneg(find(graph.adjneg==0))=Inf;
elseif(pathexact)
	[distpos,distneg] = dfs_signeddist_max(graph.adjpos,graph.adjneg,maxpathl-1,1);
else
	[distpos,distneg] = approx_signeddist_max(graph.adjpos,graph.adjneg,1,maxpathl-1);
end


if(any(diag(distpos)<Inf))
	disp('Warning: network has positive cycles!');
	for i=1:graph.nums
		distpos(i,i)=Inf;
	end
end
if(any(diag(distneg)<Inf))
	disp('Warning: network has negative cycles!');
	for i=1:graph.nums
		distneg(i,i)=Inf;
	end
end

graph.recadjpos=graph.adjpos;
graph.recadjneg=graph.adjneg;
graph.removed_pos_edges=[];
graph.removed_neg_edges=[];

saved2=0;
%Transitive reduction

candidates=[];

for k=1:graph.nums

	adjp=find(graph.adjpos(k,:));
	adjn=find(graph.adjneg(k,:));

	for il=1:length(adjp)
	    i=adjp(il);
	    if(~acyclic || scclabels(k)~=scclabels(i));
		w=graph.adjpos(k,i);
		adjp1=adjp;
		adjp1(il)=[];
		adjp1=adjp1(find(graph.adjpos(k,adjp1)<w*epsilon));
		if(any(distpos(adjp1,i)<w*epsilon))
			candidates(end+1,:)=[k,i,w,1];
		else
			adjn1=adjn(find(graph.adjneg(k,adjn)<w*epsilon));
			if(any(distneg(adjn1,i)<w*epsilon))
				candidates(end+1,:)=[k,i,w,1];
			end
		end
            end
	end

	for il=1:length(adjn)
   	    i=adjn(il);
	    if(~acyclic || scclabels(k)~=scclabels(i));
		w=graph.adjneg(k,i);
		adjn1=adjn;
		adjn1(il)=[];
		adjn1=adjn1(find(graph.adjneg(k,adjn1)<w*epsilon));
		if(any(distpos(adjn1,i)<w*epsilon))
			candidates(end+1,:)=[k,i,w,-1];
		else
			adjp1=adjp(find(graph.adjpos(k,adjp)<w*epsilon));
			if(any(distneg(adjp1,i)<w*epsilon))
				candidates(end+1,:)=[k,i,w,-1];
			end
		end
            end
	end
end

edgecand=size(candidates,1);
disp(' ');
if(fullcheck)
	disp(['Edge candidates to check ',num2str(edgecand),' (full check)']);
else
	disp(['Edge candidates to check ',num2str(edgecand),' (simplified procedure)']);
end
disp(' ');


if(edgecand)
	[zw,idxsort]=sort(candidates(:,3),'descend');
	candidates=candidates(idxsort,:);
end

for c=1:edgecand

	k=candidates(c,1);
	j=candidates(c,2);
	w=candidates(c,3);
	s=candidates(c,4);

	if(fullcheck)
		disp(['Candidate ',num2str(c),': edge ',num2str(k),'-->',num2str(j),', ',num2str(w)]);
	end
	
	dontremove=0;
	if(s>0)
		graph.recadjpos(k,j)=0;
	else
		graph.recadjneg(k,j)=0;
	end

	if(fullcheck)
		predecs=[k (find(distpos(:,k)<Inf | distneg(:,k)<Inf))'];
		disp(['		Checking edge (',num2str(length(predecs)),' predecessors)'])
		if(pathexact)
			[distposn,distnegn] = dfs_signeddist_max(graph.recadjpos,graph.recadjneg,maxpathl,1,predecs);
		else
			[distposn,distnegn] = approx_signeddist_max(graph.recadjpos,graph.recadjneg,0,maxpathl);
		end

		for m=predecs
			zw=find(graph.adjpos(m,:)~=graph.recadjpos(m,:));
			zw1=find(graph.adjneg(m,:)~=graph.recadjneg(m,:));
			if((~isempty(zw) && (any(distposn(m,zw)==Inf) || any(distposn(m,zw)>epsilon*graph.adjpos(m,zw)))) || (~isempty(zw1) && (any(distnegn(m,zw1)==Inf) || any(distnegn(m,zw1)>epsilon*graph.adjneg(m,zw1)))))
				dontremove=1;
				break;
			end
		end
	end

	if(dontremove)
		if(s>0)
			graph.recadjpos(k,j)=w;
		else
			graph.recadjneg(k,j)=w;
		end
		saved2=saved2+1;
		disp('Reinserted!');
	else
		if(s>0)
			graph.removed_pos_edges=[graph.removed_pos_edges; k j];
		else
			graph.removed_neg_edges=[graph.removed_neg_edges; k j];
		end
		%if(fullcheck)
			%	distpos(predecs,:)=distposn(predecs,:);
			%	distneg(predecs,:)=distnegn(predecs,:);
		%end
	end
end

disp(['Removed ',num2str(size(graph.removed_pos_edges,1) + size(graph.removed_neg_edges,1)),' edges; ',num2str(saved2),' edges reinserted.']);


