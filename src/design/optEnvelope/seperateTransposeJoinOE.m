function [A_w, Ay_w, B_w, C_w, lb_w, ub_w, wSize] = seperateTransposeJoinOE(A, Ay, B, C, ySize, yMax, aSizeCol, highNum, zSize)
% seperateTransposeJoinOE transposes and joins arrays for a MILP
%
% Helper for milpOEReinserts.m that transposes and joins the constraint
% arrays needed to build the dual MILP used for reaction reinsertion.
%
% USAGE:
%
%    [A_w, Ay_w, B_w, C_w, lb_w, ub_w, wSize] = seperateTransposeJoinOE(A, Ay, B, C, ySize, yMax, aSizeCol, highNum, zSize)
%
% INPUTS:
%    A:             Constraint matrix to transpose and join [matrix]
%    Ay:            Constraint matrix associated with the y (knockout)
%                   variables [matrix]
%    B:             Right hand side vector of the constraints [double array]
%    C:             Objective coefficient vector [double array]
%    ySize:         Number of y (knockout) variables [double]
%    yMax:          Upper bound for the y variables [double]
%    aSizeCol:      Number of columns of A [double]
%    highNum:       Large finite number used as a big-M bound [double]
%    zSize:         Number of z (auxiliary) variables [double]
%
% OUTPUTS:
%    A_w:           Transposed and joined constraint matrix [matrix]
%    Ay_w:          Joined matrix for the y variables [matrix]
%    B_w:           Joined right hand side vector [double array]
%    C_w:           Joined objective coefficient vector [double array]
%    lb_w:          Lower bounds for the joined problem [double array]
%    ub_w:          Upper bounds for the joined problem [double array]
%    wSize:         Number of w (dual) variables [double]
%
% NOTE:
%    This function is not designed for stand-alone use. It is used by
%    milpOEReinserts.m.
%
% .. Author: - Kristaps Berzins

wSize=size(A',2);

wMax=highNum*ones(wSize,1);

HConst=zeros(3*zSize,1);
Hy=zeros(3*zSize,ySize);
D=sparse(3*zSize,wSize+zSize);
Cz=zeros(zSize,1);
zInd=1;

d1=[0;1;-1];
d2=[1;-1;1];
hc=[0;1;0];
hy=[-1;1;0];

for k=1:wSize
    [maxVal,indMax]=max(Ay(k,:));
    [minVal,indMin]=min(Ay(k,:));
    if (maxVal~=0)
        val=maxVal;
        ind=indMax;
    end
    if (minVal~=0)  %for minus values
        val=minVal;
        ind=indMin;
    end
    if (maxVal~=0  || minVal~=0)
        constInd=3*zInd-2:3*zInd;
        Cz(zInd,1)=val;
        D(constInd,k)=d1;
        D(constInd,zInd+wSize)=d2;
        HConst(constInd)=wMax(k,1)*hc;
        Hy(constInd,ind)=wMax(k,1)*hy;
        zInd=zInd+1;
    end
end

C_w=[B;
    -Cz
    ];
A_w=[
    A', zeros(aSizeCol, zSize);
    D;
    ];
Ay_w=[
    zeros(aSizeCol, ySize);
    Hy;
    ];
B_w=[
    C;
    HConst;
    ];
lb_w=zeros(wSize+zSize+ySize, 1);
ub_w=[highNum*ones(wSize+zSize, 1); yMax*ones(ySize,1)];


