clear
test=3;
switch test
    case 1
    A= [-1 -1 0;
        2  0 -2;
        1  0  -1;
        0  1  1];
    
    %forward and reverse half stoichiometric matrices
    F=-A;
    F(F<0)=0;
    R=A;
    R(R<0)=0;
    
    rank([F R])
    
    %null([F R]')
    
    %[0;-1;2;0] is a vector in the left nullspace
    z=[0;-1;2;0]
    
    [F R]'*z
    
    case 2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    B= [-1 -1  0;
        -1  0  1;
        1  0 -1;
        0  1  1];
    
    if 0
        model.S=B;
        [inform,m]=checkStoichiometricConsistency(model,1);
    else
        m=[1;1;2;1];
        B'*m
    end
    %forward and reverse half stoichiometric matrices
    F=-B;
    F(F<0)=0;
    R=B;
    R(R<0)=0;
    
    rank([F R])
    
    null([F R]')
    
    %[0;-1;2;0] is a vector in the left nullspace
    z=[0;-1;2;0]
    
    [F R]'*z
    case 3
        F=[1 0 0;
           0 1 0;
           0 0 1;
           1 0 0;
           0 1 0;
           0 0 1];
          
       R =[0 0 1;
           1 0 0;
           0 1 0;
           0 1 0;
           0 0 1;
           1 0 0];
       
       S=-F+R;
       model.S=S;
       [inform,m]=checkStoichiometricConsistency(model,1);
       
       [m,n]=size(S);
       fprintf('%s%s\n','[F R] row rank deficiency: ', int2str(m - rank([F R])))
       fprintf('%s%s\n','[F;R] column rank deficiency: ', int2str(n - rank([F;R])))
end