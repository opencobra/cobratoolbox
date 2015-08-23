function [vol] = Simplex(dim, eps, type)
%SIMPLEX This function will call Volume with a simplex with the specified
%dimension/accuracy. If type=1, then the simplex will be isotropic. If
%type=2, then the simplex will be standard.
%The volume of the isotropic simplex is \sqrt{n+1)/(n! \sqrt{2^n}).
%The volume of the standard simplex is 1/n!.

if type==1
    [P,p,actual_vol] = makeBody('isotropic_simplex',dim);
    [vol] = Volume(P,[],eps,p);
elseif type==2
    [P,p,actual_vol] = makeBody('standard_simplex', dim);
    [vol] = Volume(P,[],eps,p,'-round');
end

fprintf('Computed Volume: %e\n', vol);
fprintf('Actual Volume: %e\n', actual_vol);
fprintf('Error: %f\n', abs(actual_vol-vol)/actual_vol);

end