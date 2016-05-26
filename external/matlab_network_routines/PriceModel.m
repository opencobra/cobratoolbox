% Routine implementing the Price model for network growth
% Notes:
%   p_k - fraction of vertices with degree k
%   probability a new vertex attaches to any of the degree-k vertices is 
%   (k+1)p_k/(m+1), where m - mean number of new citations per vertex
% Source: "The Structure and Function of Complex Networks", M.E.J. Newman
% INPUTs: n - final number of vertices
% OUTPUTs: adjacency matrix, directed
% GB, Last modified: March 18, 2006

function adj = PriceModel(n)

adj = zeros(n);
adj(1,1) = 1; 
vertices = 1;

while vertices < n
    % attach new vertex 
    vertices = vertices + 1;
    adj(vertices,vertices) = 1; 
    
    indeg = sum(adj); % get indegree values
    m = 0; % mean in-degree (per vertex)
    for k=1:vertices
      pk(k) = numel(find(indeg==k))/vertices;
      m = m + pk(k)*k;
    end
    
    % attach new edges with probability (k+1)pk/(m+1)
    for k=1:vertices
        if rand < (k+1)*pk(k)/(m+1); adj(vertices,k)=adj(vertices,k)+1; end
    end

end

adj=adj-diag(diag(adj));  % remove self-loops