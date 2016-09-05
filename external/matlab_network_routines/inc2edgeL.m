% Converts an incidence matrix to an edgelist
% inputs: inc - incidence matrix nxm
% outputs: edgelist - mx3
% GB, Last Updated: June 9, 2006

function el = inc2edgeL(inc)

m = size(inc,2); % number of edges
el = zeros(m,3); % initialize edgelist [n1, n2, weight]

for e=1:m
    ind_m1 = find(inc(:,e)==-1);
    ind_p1 = find(inc(:,e)==1);
    
    if numel(ind_m1)==0 & numel(ind_p1)==1  % undirected, self-loop
        el(e,:) = [ind_p1 ind_p1 1];  
        
    elseif numel(ind_m1)==0 & numel(ind_p1)==2 % undirected
        el(e,:) = [ind_p1(1) ind_p1(2) 1];
        el=[el; ind_p1(2) ind_p1(1) 1];
        
    elseif numel(ind_m1)==1 & numel(ind_p1)==1 % directed
        el(e,:) = [ind_m1 ind_p1 1];
        
    end
end