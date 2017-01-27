function [volume,steps] = Zonotope( dim, addtl_lines, eps )
%ZONOTOPE This is a wrapper function for VolumeZ, which will call it with a
%zonotope. The dimension and number of lines for the zonotope is specified
%as input. So that the zonotope contains a significant volume, we first
%initialize it as the unit cube and add "addtl_lines" lines to it

Z_str = strcat(strcat(strcat(strcat('Z', num2str(dim)),'_'),num2str(addtl_lines)),'.mat');

if exist(Z_str, 'file')==2
   load(Z_str);
else
    new_vecs = randn(addtl_lines,dim);

    for i=1:addtl_lines
        new_vecs(i,:)=new_vecs(i,:)/norm(new_vecs(i,:));
    end
    Z = [eye(dim,dim); new_vecs];
    save(Z_str,'Z');
end

p = 0.5*ones(dim,1);

%have our volume algorithm estimate the volume
[volume,~,steps] = VolumeZ([],[],Z,eps,p,'-round');

% m = dim+addtl_lines;
% tic;
% %compute the volume of the zonotope
% actual_vol=0;
% curr_comb = zeros(dim,1);
% for i=1:dim
%     curr_comb(i)=i;
% end
% for i=1:nchoosek(m,dim)
%    if mod(i,1e7)==0 
%        fprintf('%e...', actual_vol);
%    end
%    V = Z(curr_comb,:);
%    actual_vol = actual_vol+abs(det(V));
%    
%    %advance combination by 1
%    j = 0;
%    while curr_comb(dim-j)==m-j
%        j=j+1;
%        if dim-j==0
%            break;
%        end
%    end
%    if dim-j~=0
%        curr_comb(dim-j) = curr_comb(dim-j)+1;
%     for k=dim-j+1:dim
%           curr_comb(k) = curr_comb(k-1)+1; 
%     end
% 
%    end
% end
% toc

% fprintf('Computed Volume: %e\n', volume);
% fprintf('Actual Volume: %e\n', actual_vol);
% fprintf('Error: %f\n', abs(actual_vol-volume)/actual_vol);


end

