if 0
    load textbook.mat
else
    S=[-1  0  1 1 0;
        1 -1  0 0 0;
        0  1 -1 0 -1];
    
    model.S=S;
    model.lb=[0 0 -10 5 5]';
    model.ub=[5 5 0 0 0]';
    model.c=zeros(5,1);
    model.c(5,1)=1;
    
    
end
v = checkThermodynamicConsistency(model);

disp(norm(v))