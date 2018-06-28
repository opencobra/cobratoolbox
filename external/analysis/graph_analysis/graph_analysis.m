%Tristan Ursell
%April 2012
%Connected component analysis on an undirected graph, with various
%thresholding and connectivity constraints.
%
% [groups,orphans] = graph_analysis(W);
% [groups,orphans] = graph_analysis(W,'field',value,...);
% [groups,~] = graph_analysis(W,'field',value,...);
%
% W is the N x N adjaceny matrix for a symmetric graph.  Thus W should be a
% symmetric matrix, if it is not, this function will give an error.  Self
% connections (i.e. diagonal elements) are not allowed and will be removed
% automatically. The values of the parameters below are applied as a union
% set, that is, all original elements must meet all of the conditions 
% specified by the parameters to be included in a group of connected
% components.
%
% If only W is given, then all components with W > 0 will be analyzed and
% grouped, with the default constraints.
%
% 'min_conn' (0 <= min_conn <= max_conn) specifies the minimum degree of
% connectivity (not including itself) for any element in W to be included
% in a group. The default 'min_conn' value is 1.
%
% 'max_conn' (min_conn <= max_conn <= N) specifies the maximum degree of
% connectivity for any element in W to be included in a group. The default
% 'max_conn' value is N.
%
% 'min_like' is the minimum likelihood value for an element in W to be
% included in any group. The default value is 0.  The 'likelihood' is not
% necessarily a probability, and hence is not bounded between zero and one.
% However, for any two elements in W, the ratio of likelihoods should be 
% equal to their ratio of probabilities.
%
% 'max_link' is the maximum number of linkages to search for in the
% network.  This parameter is useful when you know that the network has
% some maximum number of connections between the elements in the network 
% (e.g. if the graph has the property that any two nodes are no more
% than N connections away, you can set max_link = N, to speed up the code).
% Choosing smaller values of 'max_link' can significantly speed up the code. 
% The default value is the size of the current sub-block.
%
% 'max_rank' (1 <= max_rank <= N) is the number of highest likelihood
% values to use in forming connected groups. For instance, if max_rank = 3,
% and a row of W is:
%
%   1 3 6 4 4 5 6 8 0 3 1
%
% then the matrix row will become:
% 
%   0 0 1 0 0 0 1 1 0 0 0
% 
% If a row of W is:
%
%   1 3 6 4 4 6 6 6 0 3 1
% 
% with max_rank = 1,2,3 or 4, the row becomes:
%
%   0 0 1 0 0 1 1 1 0 0 0
% 
% with max_rank = 5, the same row becomes:
% 
%   0 0 1 1 1 1 1 1 0 0 0
%
% The default value of 'max_rank' is N.
%
% 'plot' with value 1 will generate plots of the grouping algorithm as
% it creates block diagonal groups in from top left to bottom right in W.
%
% The output 'groups' is a structure array with fields:
%
% groups(i).num_els = number of elements in group i.
% groups(i).block = sub-block identity of group i.
% groups(i).elements = elements of W that are in group i.
% groups(i).degrees = degrees of connection for each element in group i.
% orphans = elements of W that were not in any group, becasue they did not
% meet the constraints.
%
% The number of distinct groups is length(groups).
%
%Example with a block diagonal random matrix W:
%
%W=blkdiag(rand(50,50),rand(100,100),rand(200,200),rand(300,300));
%W=(W+W')/2;
%
%figure;
%imagesc(W)
%axis equal tight
%xlabel('Elements of W')
%ylabel('Elements of W')
%title('Random Block-Diagonal Adjacency Matrix')
%
% %more inclusive connections, less inclusive probability
%[groups,orphans]=graph_analysis(W,'min_like',0.95,'min_conn',3,'plot',1);
%
% %less inclusive connections, more inclusive probability
%[groups,orphans]=graph_analysis(W,'min_like',0.9,'min_conn',6,'plot',1);
%

function [groups,orphans]=graph_analysis(W,varargin)

%*******CHECK and PARSE INPUTS*****************
if size(W,1)~=size(W,2)
    error('The input adjacency matrix must be square.')
end

%check to make sure W is symmetric
if sum(sum(abs(W'-W)))>0
    error('W is not symmetric -- try symmetrizing it first.  This corresponds to an undirected graph.')
end

%size of W
N=size(W,1);

%number of input fields
f1=find(strcmp('min_conn',varargin));
f2=find(strcmp('max_conn',varargin));
f3=find(strcmp('min_like',varargin));
f4=find(strcmp('max_rank',varargin));
f5=find(strcmp('max_link',varargin));
f6=find(strcmp('plot',varargin));

%process fields
if ~isempty(f1)
    min_conn=round(varargin{f1+1});
    if min_conn<0
        error('The minimum degree of connectivity must be greater than 0. error in: min_conn');
    end
else
    min_conn=1;
end

if ~isempty(f2)
    max_conn=round(varargin{f2+1});
    if max_conn>N
        error('The maximum degree of connectivity must be less than the size of the matrix. error in: max_conn')
    elseif max_conn<min_conn
        error('The maximum degree of connectivity must be greater than the minimum degree of connectivity. error in: max_conn')
    end
else
    max_conn=N;
end

if ~isempty(f3)
    min_like=varargin{f3+1};
    if min_like>max(W(:))
        warning('There are no elements in the matrix meet the minimum likelihood requirement. error in: min_like')
    end
else
    min_like=0;
end

if ~isempty(f4)
    max_rank=round(varargin{f4+1});
    if max_rank<1
        error('The number of highest ranked elements to keep in a group must be greater than 1. error in: max_rank')
    elseif max_rank>max_conn
        error('The number of highest ranked elements to keep in a group must less than the maximum degree of connectivity. error in: max_rank')
    end
else
    max_rank=N;
end

if ~isempty(f5)
    max_link=round(varargin{f5+1});
    if max_link<1
        error('The number of highest ranked elements to keep in a group must be greater than 1. error in: max_link')
    elseif max_link>N
        max_link=-1;
    end
else
    max_link=-1;
end

if ~isempty(f6)
    if varargin{f6+1}==1
        plotq=1;
        if N>1000
            warning('For large matrices, plotting may take time.')
        end
    else
        plotq=0;
    end
else
    plotq=0;
end

%**********************************************************
%get rid of diagonal elements
W=W.*~eye(size(W));

%sort the rows of W for possible block diagonalization
[~,Wsort]=sort(W,2,'descend');

%individual row thresholds
row_list=(1:N)';
col_list=Wsort(:,max_rank);
list3=sub2ind(size(W),row_list,col_list);
W_thresh=W(list3);
clear Wsort

%perform ranked row thresholding
for i=1:N
    W(i,:)=and(W(i,:)>W_thresh(i),W(i,:)>=min_like);
end

%symmetrize the matrix
W=(W+W')>0;

%calculate the degrees of connection per element
Degs=sum(W,1);
max_deg=max(Degs);

%connectivity constraints
true_list=and(Degs>=min_conn,Degs<=max_conn);

mask1=zeros(size(W));
mask1(true_list,:)=1;
mask1(:,true_list)=1;   

%put in diagonal elements, and apply connection and min_like constraints
W_conn=((W+eye(size(W))).*mask1)>0;

clear mask1 W

%find block-diagonal super-groups in W_conn
[conn_rw,conn_cl]=find(tril(W_conn));
group_mat=zeros(N);
disp('Finding diagonal sub-spaces ...')
for i=1:length(conn_rw)
    group_mat(conn_cl(i):conn_rw(i),conn_cl(i):conn_rw(i))=1;
end
disp('... finished.')
group_mat=group_mat>0;

%parse super-groups from W_conn
L1=bwlabel(group_mat,4);

%******** Parse the network *******
%initialize group counting variable
if plotq==1
    h1=figure;
end

grp=0;
for i=1:max(L1(:))
    clear block

    %get super-group block
    block=L1==i;
    
    %find bounds of block in W_conn
    lin_proj=sum(block,1)>0;
    sub_list=find(lin_proj,1,'first'):find(lin_proj,1,'last');
    subspace=single(W_conn(sub_list,sub_list));
    rem_els=sum(subspace,2)>0;
    
    blck_grp=0;
    %perform parsing of network in this block
    %while and(sum(rem_els)>0,blck_grp<length(rem_els))
    while sum(rem_els)>0
        %find starting position
        init_val=find(rem_els,1,'first');
        
        start_el=zeros(size(rem_els));
        start_el(init_val)=1;
         
        %number of remaining elements
        N_els=sum(rem_els);
        
        disp(['Remaining elements: ' num2str(N_els)])
        
        %update maximum number of steps between elements dependent on user
        %defined maximum linkage
        if max_link==-1
            max_steps=N_els-1; %maximum number of possible steps to be taken in network
        else
            if max_link>(N_els-1)
                max_steps=N_els-1;
            else
                max_steps=max_link;
            end
        end
           
        %find elements that form group with init_val
        clear curr_group
        curr_group=start_el;
        for j=1:max_steps
            curr_group=(subspace*single(curr_group))>0;
        end
        
        %keep track of group numbers
        grp=grp+1;
        groups(grp).num_els=sum(curr_group==1);
        groups(grp).block=i;
        groups(grp).elements=sub_list(1)-1+find(curr_group)';
        groups(grp).degrees=Degs(groups(grp).elements);
           
        %find new starting position
        rem_els=rem_els-curr_group;
        blck_grp=blck_grp+1;
    end

    if plotq==1     
        figure(h1);
        sub_plot=(subspace-eye(size(subspace)))>0;
        for j=1:blck_grp
            subplot(1,2,1)
            imagesc(2*block+group_mat)
            axis equal tight
            xlabel('elements')
            ylabel('elements')
            colormap(gray)
            
            curr_group=groups(grp-blck_grp+j).elements-sub_list(1)+1;
            subsubspace1=zeros(size(sub_plot));
            subsubspace2=zeros(size(sub_plot));
            subsubspace1(curr_group,:)=1;
            subsubspace2(:,curr_group)=1;
            sub_diagram=subsubspace1.*subsubspace2;
            
            clear sb_gr
            sb_gr(:,:,1)=sub_diagram.*~sub_plot;
            sb_gr(:,:,2)=sub_diagram.*sub_plot;
            sb_gr(:,:,3)=sub_plot.*~sub_diagram;
            
            subplot(1,2,2)
            imagesc(sb_gr)
            title(['Block: ' num2str(i) ', Sub-Group: ' num2str(j) ', Group: ' num2str(grp-blck_grp+j) ', green = current group members, red = grouping mask, blue = non-group elements'])
            xlabel('sub-elements')
            ylabel('sub-elements')
            axis equal tight
            pause
        end
    end
end
if plotq==1
    close(h1);
end

%handle lack of output
if and(nargout==1,~exist('groups','var'))
    warning('No groups in the matrix met the given requirements.')
    groups=[];
    orphans=1:N;
    return
else
    orphans=setdiff(1:N,[groups.elements]);
end

if plotq==1
    h2=figure;
    %plot groups
    B(:,:,1)=0.5*(group_mat>0).*~W.*~eye(size(W));
    B(:,:,2)=0.5*(group_mat>0).*~W.*~eye(size(W));
    B(:,:,3)=0.6*(group_mat>0).*~W.*~eye(size(W));
    
    boxes=regionprops(L1,'BoundingBox');
    
    cmap=jet;
    for i=1:length(groups)
        curr_group=groups(i).elements;
        choose_mat=zeros(size(W));
        choose_mat(curr_group,:)=1;
        choose_mat(:,curr_group)=1;
        point_group=choose_mat.*W_conn;
        
        color_vec=cmap(modone(ceil(1/2*(1+rand)*64*i),64),:);
        
        B(:,:,1)=B(:,:,1)+(point_group==1)*color_vec(1);
        B(:,:,2)=B(:,:,2)+(point_group==1)*color_vec(2);
        B(:,:,3)=B(:,:,3)+(point_group==1)*color_vec(3);
    end
    
    subplot(2,2,[2,4])
    imagesc(B)
    axis equal tight
    title([num2str(length(groups)) ' groups in ' num2str(max(L1(:))) ' isolated sub-spaces'])
    xlabel('Elements')
    ylabel('Elements')
    
    for i=1:max(L1(:))
        if i>max(L1(:))/2
            coord1=[boxes(i).BoundingBox];
            text(coord1(1)-2,coord1(1)+coord1(3)/2,num2str(i),'color',[1 1 1]);
        else
            coord1=[boxes(i).BoundingBox];
            text(coord1(1)+coord1(3)+1,coord1(1)+coord1(3)/2,num2str(i),'color',[1 1 1]);
        end
    end
    
    subplot(2,2,1)
    hist(Degs,0:max(Degs))
    xlabel('Degrees of Connection')
    ylabel(['Number of elements (of ' num2str(N) ')'])
    
    subplot(2,2,3)
    hist([groups.num_els],1:1:max([groups.num_els]))
    xlabel('Number of Elements in Group')
    ylabel(['Number of Groups (of ' num2str(length(groups)) ')'])
end


%MODONE    Modulus after division starting from 1.
function r = modone(x,y)
if y==0
    r = NaN;
else
    n = floor(x/y);
    r = x - n*y;
    r(r==0)=y;
end

