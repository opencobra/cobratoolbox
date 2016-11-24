%for i=1:12, depending on which model wanted
i=1;
model=results(i).model;
%initial forward and reverse half stoichiometric matrices
F1       = -model.S;
F1(F1<0)  =    0;
R1       =  model.S;
R1(R1<0)  =    0;
%take the rows so the remainder [F R] is full row rank
F = F1(model.FRrows,:);
R = R1(model.FRrows,:);
%test
if 0
    rank(full([F R]))
    size(F,1)
end