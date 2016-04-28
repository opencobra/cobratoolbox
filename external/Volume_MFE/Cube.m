function [volume,steps,r_steps,actual_vol] = Cube(dim, eps, type)
%CUBE This function will call Volume with a cube with the specified
%dimension/accuracy. If type=2, then the cube will be randomly
%linearly transformed. The volume of the cube is 2^dim*det(T), where T is
%the linear transformation.

[K,p] = makeBody('cube', dim);

if type==2
    filename = strcat(strcat('T', int2str(dim)),'.mat');
    if exist(filename, 'file')==2
        load(filename);
    else
        T = randn(dim,dim);
        save(filename, 'T');
    end
else
    T = eye(dim);
end

K(:,1:end-1) = K(:,1:end-1)*T;

if type==2
    [volume,~,steps,r_steps] = Volume(K,[],eps,p,'-round 100000');
else
    [volume,~,steps,r_steps] = Volume(K,[],eps,p);
end

actual_vol = 2^dim/abs(det(T));
fprintf('Computed Volume: %e\n', volume);
fprintf('Actual Volume: %e\n', actual_vol);
fprintf('Error: %f\n', abs(actual_vol-volume)/actual_vol);

end