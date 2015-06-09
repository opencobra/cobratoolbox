% Build edge lists for simple canonical graphs, ex: trees and lattices 
% INPUTS: number of nodes, net type, branch factor (for trees only)
% Types can be 'line','circle','star','btree','tree','htree','trilattice','sqlattice','hexlattice', 'clique'
% OUTPUTS: edgelist (mx3); additional outputs possible, see specific graph construction routine
% Other functions used: symmetrize_edgeL.m, adj2edgeL.m
% GB, Last Updated: November 18, 2009

function el=canonical_nets(n,type,b)

if strcmp(type,'line')
    el=build_line(n);
elseif strcmp(type,'circle')
    el=build_circle(n);
elseif strcmp(type,'star')
    el=build_star(n);
elseif strcmp(type,'btree')
    el=build_binary_tree(n);
elseif strcmp(type,'tree')
    el=build_tree(n,b);
elseif strcmp(type,'htree')
    el=build_hierarchical_tree(n,b);
elseif strcmp(type,'trilattice')
    el=build_triangular_lattice(n);
elseif strcmp(type,'sqlattice')
    el=build_square_lattice(n);
elseif strcmp(type,'hexlattice')
    el=build_hexagonal_lattice(n);
elseif strcmp(type,'clique')
    el=build_clique(n);
end

%XXX canonical nets functions XXXXXXXXXXXXXXXX

function el_line=build_line(n) % line ======================================

el_line = [[1:n-1]' [2:n]' ones(n-1,1)];
el_line = symmetrize_edgeL(el_line);


function el_cir=build_circle(n) % circle ===================================

el_cir = [[1:n-1]' [2:n]' ones(n-1,1)];
el_cir = [el_cir; 1 n 1];
el_cir = symmetrize_edgeL(el_cir);


function el_star=build_star(n) % star ======================================

el_star = [ones(n-1,1) [2:n]' ones(n-1,1)]; 
el_star = symmetrize_edgeL(el_star);


function el_clique = build_clique(n)

el_clique = adj2edgeL(ones(n)-eye(n));


function el_bt=build_binary_tree(n) % binary tree ==========================

el_bt=[];

for i=2:n
  if mod(i,2)==0
    el_bt=[el_bt; i i/2 1];
  else
    el_bt=[el_bt; i (i-1)/2 1];
  end
end
el_bt=symmetrize_edgeL(el_bt);


function el=build_tree(n,b)
% tree with n nodes and arbitrary branching factor b

nodes=1;
queue=1;
el=[];

while nodes < n
    if nodes+b > n
        % add (n-nodes) to first stack member
        for i=1:n-nodes
            el=[el; queue(1) i+nodes 1];
        end
        nodes=n;
    else
        % add b new edges: 
        for bb=1:b
            el=[el; queue(1) nodes+bb 1];
            queue=[queue nodes+bb];
        end
        queue=queue(2:length(queue)); % remove first member
        nodes=nodes+b;                % update node number
    end
end
el=symmetrize_edgeL(el);


function el=build_hierarchical_tree(n,b)

% build a tree with n nodes and b as a branch factor, where nodes on one level are connected
% INPUTs: number of nodes - n, branch factor - b
% OUTPUTs: edgelist


L=ceil(log(1+n*(b-1))/log(b));   % L=log(1+n(b-1))/log(b)
el=build_tree(n,b);    %  build the base

% add the cross-level links
for k=1:L
    
    start_node=1+round((b^(k-1)-1)/(b-1));
  
    for bb=1:b^(k-1)-1
        if start_node+bb-1>n | start_node+bb>n
            el=symmetrize_edgeL(el);
            return
        end
        el=[el; start_node+bb-1, start_node+bb,1];
    end
    
end
el=symmetrize_edgeL(el);



function [el_tr,adj_tr,f1,f2]=build_triangular_lattice(n)

% triangular lattice ============================
% build triangular lattice with n nodes
% as close to a "square" shape as possible
el_tr=[];
x=factor(n);
if numel(x)==1
    el_tr=[el_tr; n 1 1];
    n=n-1;
    x=factor(n);
end

if mod(numel(x),2)==0  % if there's an even number of factors, split in two
    f1=prod(x(1:numel(x)/2)); 
    f2=prod(x(numel(x)/2+1:numel(x)));
elseif mod(numel(x),2)==1
    f1=prod(x(1:(numel(x)+1)/2)); 
    f2=prod(x((numel(x)+1)/2+1:numel(x)));
end

% the lattice will be f1xf2
% inner mesh
for i=2:f1-1
  for j=2:f2-1
    % (i,j)->f2*(i-1)+j
    el_tr=[el_tr; f2*(i-1)+j f2*(i-2)+j 1];
    el_tr=[el_tr; f2*(i-1)+j f2*(i)+j 1];
    el_tr=[el_tr; f2*(i-1)+j f2*(i-1)+j-1 1];
    el_tr=[el_tr; f2*(i-1)+j f2*(i-1)+j+1 1];
    el_tr=[el_tr; f2*(i-1)+j f2*i+j+1 1]; % added for tri lattice
  end
end
% four corners
el_tr=[el_tr; 1 2 1];
el_tr=[el_tr; 1 f2+1 1];
el_tr=[el_tr; 1 f2+2 1]; % added for tri lattice
el_tr=[el_tr; f2 f2-1 1];
el_tr=[el_tr; f2 2*f2 1];
el_tr=[el_tr; f2*(f1-1)+1 f2*(f1-2)+1 1];
el_tr=[el_tr; f2*(f1-1)+1 f2*(f1-1)+2 1];
el_tr=[el_tr; f1*f2 f2*(f1-1) 1];
el_tr=[el_tr; f1*f2 f2*f1-1 1];

% four walls
for j=2:f2-1
  el_tr=[el_tr; j j-1 1];
  el_tr=[el_tr; j j+1 1];
  el_tr=[el_tr; j f2+j 1];
  el_tr=[el_tr; j f2+j+1 1]; % added for tri lattice
  
  el_tr=[el_tr; f2*(f1-1)+j f2*(f1-1)+j-1 1]; 
  el_tr=[el_tr; f2*(f1-1)+j f2*(f1-1)+j+1 1];
  el_tr=[el_tr; f2*(f1-1)+j f2*(f1-2)+j 1];
end
for i=2:f1-1
  el_tr=[el_tr; f2*(i-1)+1 f2*(i-2)+1 1];
  el_tr=[el_tr; f2*(i-1)+1 f2*i+1 1];
  el_tr=[el_tr; f2*(i-1)+1 f2*(i-1)+2 1];
  el_tr=[el_tr; f2*(i-1)+1 f2*i+2 1]; % added for tri lattice
  
  el_tr=[el_tr; f2*i f2*(i-1) 1];
  el_tr=[el_tr; f2*i f2*(i+1) 1];
  el_tr=[el_tr; f2*i f2*i-1 1];
end

el_tr=symmetrize_edgeL(el_tr);


function [el_sq,adj_sq]=build_square_lattice(n)

% square latice ====================================
el_sq=[];
x=factor(n);
if numel(x)==1
    el_sq=[el_sq; n 1 1];
    n=n-1;
    x=factor(n);
end

if mod(numel(x),2)==0
    f1=prod(x(1:numel(x)/2)); f2=prod(x(numel(x)/2+1:numel(x)));
elseif mod(numel(x),2)==1
    f1=prod(x(1:(numel(x)+1)/2)); f2=prod(x((numel(x)+1)/2+1:numel(x)));
end

% the lattice will be f1xf2
% inner mesh
for i=2:f1-1
    for j=2:f2-1
        % (i,j)->f2*(i-1)+j
        el_sq=[el_sq; f2*(i-1)+j f2*(i-2)+j 1];
        el_sq=[el_sq; f2*(i-1)+j f2*(i)+j 1];
        el_sq=[el_sq; f2*(i-1)+j f2*(i-1)+j-1 1];
        el_sq=[el_sq; f2*(i-1)+j f2*(i-1)+j+1 1];
    end
end
% four corners
el_sq=[el_sq; 1 2 1];
el_sq=[el_sq; 1 f2+1 1];
el_sq=[el_sq; f2 f2-1 1];
el_sq=[el_sq; f2 2*f2 1];
el_sq=[el_sq; f2*(f1-1)+1 f2*(f1-2)+1 1];
el_sq=[el_sq; f2*(f1-1)+1 f2*(f1-1)+2 1];
el_sq=[el_sq; f1*f2 f2*(f1-1) 1];
el_sq=[el_sq; f1*f2 f2*f1-1 1];
% four walls
for j=2:f2-1
    el_sq=[el_sq; j j-1 1];
    el_sq=[el_sq; j j+1 1];
    el_sq=[el_sq; j f2+j 1];
  
    el_sq=[el_sq; f2*(f1-1)+j f2*(f1-1)+j-1 1]; 
    el_sq=[el_sq; f2*(f1-1)+j f2*(f1-1)+j+1 1];
    el_sq=[el_sq; f2*(f1-1)+j f2*(f1-2)+j 1];
end
for i=2:f1-1
    el_sq=[el_sq; f2*(i-1)+1 f2*(i-2)+1 1];
    el_sq=[el_sq; f2*(i-1)+1 f2*i+1 1];
    el_sq=[el_sq; f2*(i-1)+1 f2*(i-1)+2 1];
  
    el_sq=[el_sq; f2*i f2*(i-1) 1];
    el_sq=[el_sq; f2*i f2*(i+1) 1];
    el_sq=[el_sq; f2*i f2*i-1 1];
end

el_sq=symmetrize_edgeL(el_sq);


function el_hex=build_hexagonal_lattice(n)

% hexagonal lattice ==========================================
% construct subgraph of the triangular lattice, f1xf2
el_hex=[];
x=factor(n);

if numel(x)==1
    el_hex=[el_hex; n 1 1];
    n=n-1;
    x=factor(n);
end

if mod(numel(x),2)==0
    f1=prod(x(1:numel(x)/2)); f2=prod(x(numel(x)/2+1:numel(x)));
elseif mod(numel(x),2)==1
    f1=prod(x(1:(numel(x)+1)/2)); f2=prod(x((numel(x)+1)/2+1:numel(x)));
end

% the lattice will be f1xf2
% inner mesh
fmax=max(f1,f2);
fmin=min(f1,f2);

for ff=1:fmin  % from 1 to fmin
    % rows are from ff*fmax+1 to (ff+1)*fmax - 1
    %           (ff+1)*fmax+1 to (ff+2)*fmax - 2
    for gg=1:fmax % in range(fmax):
        if gg<fmax  % if it's not the last node in the row
            el_hex=[el_hex; (ff-1)*fmax+gg,(ff-1)*fmax+gg+1,1];
        end
        if ff<fmin & mod(gg,4)==1      %  gg%4==1
            % connect (ff-1)*fmax+gg to ff*fmax+gg+1
            % and (ff-1)*fmax+gg+3 to ff*fmax+gg+2
            n1=(ff-1)*fmax+gg;
            n2=ff*fmax+gg+1;
            if n1<fmin*fmax & n2<fmin*fmax & gg+1<=fmax
                el_hex=[el_hex; n1 n2 1];
            end
            n1=(ff-1)*fmax+gg+3;
            n2=ff*fmax+gg+2;
            if n1<fmin*fmax & n2<fmin*fmax & gg+3<=fmax
                el_hex=[el_hex; n1 n2 1];
            end
        end
    end
end
el_hex=symmetrize_edgeL(el_hex);