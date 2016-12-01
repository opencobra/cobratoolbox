% Routine implementing a simple preferential attachment (B-A) model for network growth
% The probability that a new vertex attaches to a given old vertex is proportional to the (total) vertex degree
% Vertices arrive one at a time
% INPUTs: n - final (desired) number of vertices, m - # edges to attach at every step
% OUTPUTs: edge list, [number of edges x 3]
% NOTE: Assume undirected simple graph
% Source: "The Structure and Function of Complex Networks", M.E.J. Newman;  "Emergence of Scaling in Random Networks" B-A.
% GB, March 18, 2006

function el = preferential_attachment(n,m)

vertices = 2;
if not(vertices<=n); fprintf('the number of final nodes is smaller than the initial\n');  return; end
el=[1 2 1; 2 1 1];  % start with an edge


while vertices < n
    vertices=vertices+1;  % add new vertex

    if m>=vertices
      for node=1:vertices-1
        el = [el; node vertices 1];
        el = [el; vertices node 1];
      end
      continue
    end
    
    deg=[];               % compute nodal degrees for this iteration
    for v=1:vertices; deg=[deg; v numel(find(el(:,1)==v))]; end
    deg=sortrows(deg);
    
    % add m edges
    r = randsample(deg(:,1),m,'true',deg(:,2)/max(deg(:,2)));
    while not(length(unique(r))==length(r))
      r = randsample(deg(:,1),m,'true',deg(:,2)/max(deg(:,2)));
    end

    for node=1:length(r)
      el = [el; r(node) vertices 1];
      el = [el; vertices r(node) 1];      
    end      
    
end