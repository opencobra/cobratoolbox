
s = [1 1 1 1 1]';
t = [2 3 4 5 6]';
G = graph(s',t');
I = full(incidence(G))

n = length(s);

ind = (1:n)'
A = full(sparse([s;t],[ind;ind],[ones(n,1)*-1;ones(n,1)]));

A

I


A - I


s = [1 1 1 1 1]';
t = [6 3 4 5 2]';
G = graph(s',t');
I = full(incidence(G))

ind = (1:n)'
A = full(sparse([s;t],[ind;ind],[ones(n,1)*-1;ones(n,1)]));

A

I


A - I


s = [1 1 1 1 1 6]';
n = length(s);
t = [6 3 4 5 2 1]';
G = graph(s',t');%switches orientation of duplicates
I = full(incidence(G))

ind = (1:n)'
A = full(sparse([s;t],[ind;ind],[ones(n,1)*-1;ones(n,1)]));

A

I


A - I

s = [1 1 1 1 1 6]';
n = length(s);
t = [6 3 4 5 2 1]';
G = digraph(s',t'); %does not switch orientation of duplicates
I = full(incidence(G))

ind = (1:n)'
A = full(sparse([s;t],[ind;ind],[ones(n,1)*-1;ones(n,1)]));

A

I


A - I
