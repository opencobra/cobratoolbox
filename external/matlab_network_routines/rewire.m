% Degree-preserving random rewiring
% Note 1: Assume unweighted undirected graph
% INPUTS: edgelist, el (mx3) and number of rewirings, k
% OUTPUTS: rewired edgelist

function el = rewire(el,k)

rew=0;

while rew<k

    % pick two random edges
    ind = randi(length(el),1,2);
    edge1=el(ind(1),:); edge2=el(ind(2),:);
    
    if length(intersect(edge1(1:2),edge2(1:2)))>0; continue; end % the two edges cannot overlap
    
    % else: rewire
    if not(ismember([edge1(1),edge2(2),1],el,'rows')) & not(ismember([edge1(2),edge2(1),1],el,'rows'))
      
      % first possibility: (e11,e22) & (e12,e21)
      el(ind(1),:)=[edge1(1),edge2(2),1];
      el(ind(2),:)=[edge1(2),edge2(1),1];
      
      % add the symmetric equivalents
      [~,inds1] = ismember([edge1(2),edge1(1),1],el,'rows');
      el(inds1,:)=[edge2(2),edge1(1),1];
      
      [~,inds2] = ismember([edge2(2),edge2(1),1],el,'rows');
      el(inds2,:)=[edge2(1),edge1(2),1];

      rew = rew + 1;
      
    elseif not(ismember([edge1(1),edge2(1),1],el,'rows')) & not(ismember([edge1(2),edge2(2),1],el,'rows'))
      
      % second possibility: (e11,e21) & (e12,e22)
      el(ind(1),:)=[edge1(1),edge2(1),1];
      el(ind(2),:)=[edge1(2),edge2(2),1];
    
      % add the symmetric equivalents
      [~,inds1] = ismember([edge1(2),edge1(1),1],el,'rows');
      el(inds1,:)=[edge2(1),edge1(1),1];
      
      [~,inds2] = ismember([edge2(2),edge2(1),1],el,'rows');
      el(inds2,:)=[edge2(2),edge1(2),1];
  
      rew = rew + 1;
      
    else
      'creates a double edge';
      continue
    end

end