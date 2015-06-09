% Add multiple edges in an edgelist
% INPUTS: original (non-compact) edgelist
% OUTPUTS: final compact edgelist (no row repetitions)
% GB, Last updated: October 7, 2009

function elc=add_edge_weights(el)

el2=[el(:,1), el(:,2)]; % make the edge list searchable w/o the weights
visited=[];             % mark visited edges

elc=[];
for e=1:size(el,1)
    if sum(ismember(visited,el2(e,:),'rows'))==0  % if not visited yet
        ind=ismember(el2,el2(e,:),'rows');
        ind=find(ind==1);     % these are all the ocurrences of el(e,:)
        elc=[elc; el(e,1), el(e,2), sum(el(ind,3))];
        visited=[visited; el2(e,:)];
    end
end