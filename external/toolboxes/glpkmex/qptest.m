% QP test problem. Demo file
%
clc;

disp('----------------------------------');
disp('Problem #1:');
disp(' ');
disp('min x1^2 + x^2  - 3*x1 - 1/4*x2');
disp(' ');
disp('subject to');
disp(' |x1|+|x2| <= 1');
disp('----------------------------------');

H=2*eye(2);
q=[-3,-1/4]';
A=[1 1;1 -1;-1 1;-1 -1];
b=ones(4,1);

[x, obj, lambda, info] = qpng (H, q, A, b)

pause;
clc

disp('----------------------------------');
disp('Problem #2:');
disp(' ');
disp('min 4*x1^2 + 1 x1*x2 + 4*x2^2 + 3*x1 ? 4*x2');
disp(' ');
disp('s.t. x1+x2 <= 5');
disp('     x1-x2 == 0');
disp('     x1 >= 0');
disp('     x2 >= 0');
disp('----------------------------------');

H=[8 1;1 8];
q=[3 -4]';
A=[1 1; 1 -1];
b=[5 0]';
ctype=char(['U', 'E']');
lb=[0 0]';
ub=[];

[x, obj, lambda, info] = qpng (H, q, A, b,ctype,lb,ub)

pause;
clc

disp('----------------------------------');
disp('Problem #3:');
disp(' ');
disp('min .5*x1''*H*x + q''*x');
disp(' ');
disp('s.t. -2.5 <= x1 <= 2.5');
disp('----------------------------------');

H=[.16 -1.2 2.4 -1.4;
   -1.2 12.0 -27.0 16.8;
   2.4 -27.0 64.8 -42.0;
   -1.4 16.8 -42.0 28.0];
q=[5.04 -59.4 146.4 -96.6]';
A=[-1 0 0 0; 1 0 0 0];
b=[2.5; 2.5];

[x, obj, lambda, info] = qpng (H, q, A, b)

pause;
clc

disp('----------------------------------');
disp('Problem #4:');
disp(' Solve a portfolio example. ');
disp(' See Section 13.7 of "Applications of optimization with Xpress-MP.');
disp('----------------------------------');

H=[4 3 -1 0;
   3 6 1 0;
   -1 1 10 0;
   0 0 0 10];
q=[];
A=[1 1 1 1;
   8 9 12 7];
b=[1; 7];
ctype=char(['E', 'L']');
lb=zeros(4,1);
ub=[];

[x, obj, lambda, info] = qpng (H, q, A, b, ctype, lb, ub)

pause;
clc

disp('----------------------------------');
disp('Problem #5:');
disp(' An indefinite QP problem is not solved x*=(3, 25/4). ');
disp(' ');
disp('min .5*x1^2 - .5*x2^2');
disp(' ');
disp('s.t. x2 >= 0');
disp('s.t. x1+x2 >= 2');
disp('s.t. -5x1+4x2 <= 10');
disp('s.t. x1 <= 3');
disp('----------------------------------');

H=[1 0;0 -1];
q=[];
A=[0 1;1 2;-5 4;1 0];
b=[0 2 10 3]';
ctype=char(['L', 'L', 'U', 'U']);

[x, obj, lambda, info]=qpng(H, q, A, b)