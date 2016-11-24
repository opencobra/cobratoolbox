function [ body,p,volume] = makeBody( shape, dim )
%MAKEBODY This function will create some example bodies that can be used to
%call "Volume". "body" will be the body, either a polytope or ellipsoid.

%A polytope is given in the form [A b], {x | Ax <= b}. The polytope will be
%an m x (n+1) matrix, for m constraints and n dimensions.
%An ellipsoid is given in the form [E v], {x | (x-v)'E(x-v)<=1}. The
%ellipsoid will be an n x (n+1) matrix, for n dimensions.

if strcmp(shape,'cube')==1
    body = zeros(2*dim,dim+1);
    for i=1:dim
        body(2*i-1,i)=1;
        body(2*i,i)=-1;
    end
    body(:,end)=1;
p = zeros(dim,1);
    volume=2^dim;
elseif strcmp(shape,'long_box')==1
    body = zeros(2*dim,dim+1);
    for i=1:dim
        body(2*i-1,i)=1;
        body(2*i,i)=-1;
    end
    body(:,end)=1;
    body(1,end)=100;
    body(2,end)=100;
p = zeros(dim,1);
    volume=2^dim*100;
elseif strcmp(shape,'standard_simplex')==1
    body = zeros(dim+1,dim+1);
    body(1:dim,1:dim) = -eye(dim);
    body(1:dim,dim+1) = 1/(dim+1);
    body(dim+1,1:dim) = 1;
    body(dim+1,dim+1) = 1/(dim+1);
p = zeros(dim,1);   
    volume=1/factorial(dim);
elseif strcmp(shape,'isotropic_simplex')==1
    %we need to do some computation to determine this one
    x=zeros(dim,dim+1);
    for i=1:dim
        x(i,i)=sqrt(1-norm(x(:,i))^2);
        for j=i+1:dim+1
            x(i,j)=(-1/dim-dot(x(:,i),x(:,j)))/x(i,i);
        end
    end
    
    vol_mat = zeros(dim,dim);
    for i=2:dim+1
        vol_mat(i-1,:)=x(:,i)-x(:,1);
    end
 
    p = zeros(dim,1);   
    volume=dim^dim/factorial(dim)*abs(det(vol_mat));
    %now that we have vertices, we can express as polytope
    body = [x' ones(dim+1,1)];
elseif strcmp(shape,'ball')==1
    body = zeros(dim,dim+1);
    body(1:dim,1:dim)=eye(dim);
    p = zeros(dim,1);
    volume=pi^(dim/2)/gamma(dim/2+1);
elseif strcmp(shape,'ellipsoid')==1
    body = zeros(dim,dim+1);
    body(1:dim,1:dim)=eye(dim);
    body(dim,dim)=1e4;
    p = zeros(dim,1);
    volume=pi^(dim/2)/gamma(dim/2+1)*100;
elseif strcmp(shape,'birkhoff')==1
    %describe system as Ax<=b and Cx=d
    %need to get subspace spanned by Cd 
    %and apply that transformation to Ax<=b
    %b starts out as all zeros, d as all ones
    A=zeros(dim^2,dim^2);
    C=zeros(2*dim,dim^2);
    for i=1:dim
        %row constraints
        for j=(i-1)*dim+1:i*dim
          C(i,j)=1; 
        end
        
        %col constraints
        for j=i:dim:dim^2
           C(dim+i,j)=1; 
        end
    end
    
    for i=1:dim^2
       A(i, i)=-1;
    end
    
    nullC=null(C);
    %let v be any solution to Cx=d
    v=ones(dim^2,1)/dim;
    
    new_A=A*nullC;
    new_b=zeros(dim^2,1)-A*v;
    body=[new_A new_b];
    p=zeros((dim-1)^2,1);
    
elseif strcmp(shape,'zonotope')==1
    
%     body = rand(dim,dim)-0.5;
%     for i=1:dim
%        body(i,:) = dim^2*body(i,:)./norm(body(i,:)); 
%     end
%     p=body*(0.5*ones(dim,1));

    %set the zonotope as the unit cube, then add some random vectors
    new_vecs = randn(dim,dim);
    for i=1:dim
        new_vecs(i,:)=new_vecs(i,:)/norm(new_vecs(i,:));
    end
    body = [eye(dim,dim); new_vecs];
    p = 0.5*ones(dim,1);
else
    fprintf('Possible shapes:\n\n');
    fprintf('cube\n');
    fprintf('standard_simplex\n');
    fprintf('isotropic_simplex\n');
    fprintf('long_box\n');
    fprintf('ball\n');
    fprintf('ellipsoid\n');
    fprintf('birkhoff\n');
    return;
end
end