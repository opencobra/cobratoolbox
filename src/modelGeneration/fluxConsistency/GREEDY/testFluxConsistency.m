%test function to check Flux Consistency in one LP, does not work yet
%Ronan

epsilon = 1e-8;
printLevel=2;

S=zeros(4,6);
S(1,1)=-1;
S(2,1)=1;
S(2,2)=-1;
S(3,2)=1;
S(3,3)=1;
S(1,3)=-1;
S(2,4)=-1;
S(4,4)=1;
S(1,5)=1;
S(3,6)=-1;
model.S=S;
model.lb=zeros(6,1);
model.ub=10*ones(6,1);
model.b=zeros(4,1);

[fluxConsistent,sol]=checkFluxConsistency(model,epsilon);
nnz(fluxConsistentBool)
model.S;
x=sol.full;
[m,n]=size(model.S);
for j=1:n
    fprintf('%d\t%d\t%d\t%d\t%d\t%d\n',x(j),x(j+n),x(j+m+2*n),x(j+m+3*n),x(j+m+4*n),x(j+m+5*n));
end
