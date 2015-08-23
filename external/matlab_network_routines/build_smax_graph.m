% Construct the graph with the maximum possible s-metric, given the degree
% sequence; the s-metric is the sum of products of degrees across all edges
% Source: Li et al "Towards a Theory of Scale-Free Graphs"
% INPUTs: degree sequence: 1xn vector of positive integers
% OUTPUTs: edgelist of the s-max graph, mx3
% Other routines used: purge.m

function gA=build_smax_graph(deg)

didj=[];
for ii=1:length(deg)-1
    for jj=ii+1:length(deg)
        % [deg_i*deg_j, 'B', deg_i, deg_j, 'B', i, j] - 'B' for sorting purposes
        didj=[didj; deg(ii)*deg(jj), 2, deg(ii), deg(jj), 2, ii,jj];
    end
end

didj=sortrows(didj);
didj=didj(end:-1:1,:);  % reverse to decreasing order

w=deg; % number of remaining stubs - originally equals the degrees
[dummy,maxdegind]=max(deg);  % the index of the maximum degree
A=[maxdegind];
B=purge([1:length(deg)],maxdegind);
wA=deg(maxdegind);  % remaining stubs in A
dB=sum(deg(B));  % total degree of unattached vertices in B

gA=[]; % initialize empty edgelist

while sum(w)>0  % while there are still stubs to connect
    
    % STEP 1 (LINK SELECTION)
    if size(didj,1)==0
        if sum(w)>0  % connect all stubs left
            wstubs=[];
            cnt=1;
            for ww=1:length(w)
                while w(ww)>0
                    wstubs=[wstubs; cnt, ww];
                    w(ww)=w(ww)-1;
                    cnt=cnt+1;
                end
            end
            for xx=1:size(wstubs,1)/2
                n1=wstubs(xx,2);
                n2=wstubs(xx+size(wstubs,1)/2,2);
                
                ind1=find(gA(:,1)==n1);
                if length(ind1)==0
                    first_case=false;
                else
                    ind2=find(gA(ind1,2)==n2);
                    if length(ind2)==0
                        first_case=false;
                    else
                        first_case=true;
                    end
                end
                ind2=find(gA(:,1)==n2);
                if length(ind2)==0
                    second_case=false;
                else
                    ind1=find(gA(ind2,2)==n1);
                    if length(ind1)==0
                        second_case=false;
                    else
                        second_case=true;
                    end
                end
                if first_case  %if [n1,n2,1] in gA and not(n1==n2):
                    gA=[gA; n1,n2,1];
                elseif second_case % if [n2,n1,1] in gA and not(n1==n2):
                    gA=[gA; n2,n1,1];
                elseif n1==n2
                    gA=[gA; n1,n2,1];
                end
            
                
            end
        end
        return  % gA
    end

    % eliminate zero stubs in didj
    didj_new=[];
    for ii=1:size(didj,1)
        if w(didj(ii,6))>0 & w(didj(ii,7))>0
            didj_new=[didj_new; didj(ii,:)];
        end
    end
    didj=didj_new;
    
    if size(didj,1)==0; continue; end
    
    for ii=1:size(didj,1)
    
        edge=[didj(ii,6), didj(ii,7)];
        
        if length(find(A==edge(1)))>0 & length(find(A==edge(2)))>0
            didj(ii,:)=[didj(ii,1),100,w(edge(1)),w(edge(2)),100,edge(1),edge(2)];
        elseif length(find(A==edge(1)))>0 & length(find(B==edge(2)))>0
            didj(ii,:)=[didj(ii,1),100,w(edge(1)),w(edge(2)),2,edge(1),edge(2)];
        elseif length(find(B==edge(1)))>0 & length(find(A==edge(2)))>0
            didj(ii,:)=[didj(ii,1),2,w(edge(1)),w(edge(2)),1,edge(1),edge(2)];
            didj(ii,:)=[didj(ii,1),100,w(edge(2)),w(edge(1)),2,edge(2),edge(1)];
        else
            didj(ii,:)=[didj(ii,1),2,w(edge(1)),w(edge(2)),2,edge(1),edge(2)];
        end
        
    end
    
    didj=sortrows(didj);
    didj=didj(end:-1:1,:);
    link_select=[didj(1,6),didj(1,7)];  % select the first link that starts in A
    
    % STEP 2 (LINK ADDITION)
    n1=link_select(1);
    n2=link_select(2);
    
    % if (n1 in A and n2 in B) or (n1 in B and n2 in A)
    if (length(find(A==n1))>0 & length(find(B==n2))>0) | (length(find(B==n1))>0 & length(find(A==n2))>0)
        gA=[gA; n1, n2, 1];
        if length(find(A==n1))>0 & length(find(B==n2))>0
            B=purge(B,n2);
            A=[A; n2];
        end
        if length(find(B==n1))>0 & length(find(A==n2))>0
            B=purge(B,n1);
            A=[A; n1];
        end
        
        w(n1)=w(n1)-1;
        w(n2)=w(n2)-1;
        wA=sum(w(A));
        dB=sum(deg(B));
        
        didj=didj(2:size(didj,1),:); % remove link from top
    
    elseif length(find(A==n1))>0 & length(find(A==n2))>0
        % check the tree condition
        if dB==2*length(B)-wA
            didj=didj(2:size(didj,1),:);
            
        elseif wA==2 & length(B)>0 % results in a disconnected graph
            didj=didj(2:size(didj,1),:);
            
        else  % add it!
            gA=[gA; n1,n2,1];
            
            w(n1)=w(n1)-1;
            w(n2)=w(n2)-1;
            
            wA=sum(w(A));
            dB=sum(deg(B));
            
            didj=didj(2:size(didj,1),:);
        end
    end
end
