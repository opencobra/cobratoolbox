% Implementation of breadth-first-search of a graph
% INPUTs: adjacency list, starting node index
% OUTPUTs: BFS tree, in adjacency list format (directed)

function T=BFS(adjL,i0)

discovered=[i0];
q=[i0];
T=cell(length(adjL),1);

while not(isempty(q))
    j=q(1); q=q(2:length(q)); % pop the front
    neigh=adjL{j};
    for nn=1:length(neigh)
        if isempty(find(discovered==neigh(nn)))
            T{j}=[T{j}, neigh(nn)];
            discovered=[discovered, neigh(nn)];
            q=[q, neigh(nn)];
        end
    end
end