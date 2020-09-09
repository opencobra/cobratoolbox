% Thanks for Carlos Lopez for this file and many other enhancements to the mp toolbox.
%quick and dirty tests
precision=1000;%notice that tol~=(.5)^precision;
a42=mp(rand(4,2),precision);%It will be nice to use mprand, but it doesn't work
b42=mp(rand(4,2),precision);

%2) direct/inverse pairs
c_mp=norm(asin(sin(a42))-a42);disp(['2.1 sin/asin' setstr(9) num2str(c_mp)])
c_mp=norm(acos(cos(a42))-a42);disp(['2.2 cos/acos' setstr(9) num2str(c_mp)])
c_mp=norm(atan(tan(a42))-a42);disp(['2.3 tan/atan' setstr(9) num2str(c_mp)])
c_mp=norm(asinh(sinh(a42))-a42);disp(['2.4 sinh/asinh' setstr(9) num2str(c_mp)])
c_mp=norm(acosh(cosh(a42))-a42);disp(['2.5 cosh/acosh' setstr(9) num2str(c_mp)])
c_mp=norm(atanh(tanh(a42))-a42);disp(['2.6 tanh/atanh' setstr(9) num2str(c_mp)])
c_mp=norm(exp(log(a42))-a42);disp(   ['2.7 exp/log   ' setstr(9) num2str(c_mp)])
c_mp=norm(sqrt(a42.^2)-a42);disp(    ['2.8 sqrt/^2   ' setstr(9) num2str(c_mp)])

%4) Catastrophic cancellation 
z=sqrt(117)-sqrt(116);zExact=1/(sqrt(117)+sqrt(116));
disp('4.1 Improvement in the catastrophic cancellation of sqrt(117)-sqrt(116)')
disp([setstr(9) 'Standard double precision:' num2str(abs(z/zExact-1)) ])
for precision=300:100:1000
 zmp=sqrt(mp(117,precision))-sqrt(mp(116,precision));zmpExact=1/(sqrt(mp(117,precision))+sqrt(mp(116,precision)));
 disp([setstr(9) 'Multiple precision = ' num2str(precision) ':'  num2str(abs((zmp/zmpExact-1)))])
end

disp('4.2 Accuracy of tan(pi/4)-1')
for precision=300:100:1000
 zmp=mp('pi',precision)/4;
 disp([setstr(9) 'Multiple precision = ' num2str(precision) ':'  num2str(((tan(zmp)-1)))])
end
disp('4.3 Accuracy of 4*atan2(-1,1)+pi')
for precision=300:100:1000
 zmp=mp('pi',2*precision);%Request a higher precision pi in order to compare
 one=mp(1,precision);
 disp([setstr(9) 'Multiple precision = ' num2str(precision) ':'  ...
       num2str(((atan2(-one,one)*4+zmp)))])
end

%5) Test matrix; we will only test that the accuracy 
%of an exact inverse times the matrix is closer to the identity in mp rather than in double
n=14;
disp(['5.1 Hilbert matrix and its exact inverse.'])
disp(['    norm in double: ' num2str([norm(hilb(n)*invhilb(n)-eye(n))])])
for precision=300:100:1000
 mp_set_defaults(precision);
 %5.1 Hilbert
 one=mp(1);
 
 J = 1:n;
 J = J(ones(n,1),:);
 I = J';
 E = mp(ones(n,n));
 mpHilb = E./(I+J-one);
 
 %Now the inverse; this is a slightly modified version of invhilb.m to produce mp values
 p = n;
 H = mp(zeros(n,n));
 for k = 1:n
  i=mp(k);
  if k > 1, p = ((n-i+one)*p*(n+i-one))/(k-one)^2; end
  r = p*p;
  H(k,k) = r/(2*i-one);
  for j = i+1:n
   %             r = -((n-j+one)*r*(n+j-one))/(j-one)^2;
   num = -((n-j+one)*r*(n+j-one));
   den= (j-one)^2;
   r = num/den;
   H(k,j) = r/(i+j-one);
   H(j,k) = r/(i+j-one);
  end
 end
 disp(['precision=' num2str(precision) ':' setstr(9) num2str(norm(H*mpHilb-eye(n)))]);
end
%check also some auxiliary functions (unrelated with precision!)
X = mp([2 8 4;7 3 9]);   
%see "help min" for full documentation
if all(min(X,[],1) == [2 3 4]), disp('Test 6.1 passed'), else, disp('Test 6.1 failed'),end
if all(min(X,[],2) == [2;3]), disp('Test 6.2 passed'), else, disp('Test 6.2 failed'),end
if all(min(X,5)==[2 5 4;5 3 5]), disp('Test 6.3 passed'), else, disp('Test 6.3 failed'),end

if all(max(X,[],1)==[7 8 9]), disp('Test 6.4 passed'), else, disp('Test 6.4 failed'),end
if all(max(X,[],2)==[8;9]), disp('Test 6.5 passed'), else, disp('Test 6.5 failed'),end
if all(max(X,5)==[5 8 5;7 5 9]),disp('Test 6.6 passed'), else, disp('Test 6.6 failed'),end

X = mp([0 1 2;3 4 5]);
if all(sum(X,1) == [3 5 7]), disp('Test 6.7 passed'), else, disp('Test 6.7 failed'),end
if all(sum(X,2) == [ 3;12]), disp('Test 6.8 passed'), else, disp('Test 6.8 failed'),end

X = mp([3 7 5;0 4 2]);
if all(sort(X,1) == [0 4 2;3 7 5] ), disp('Test 6.9 passed'), else, disp('Test 6.9 failed'),end
if all(sort(X,2) == [3 5 7;0 2 4] ), disp('Test 6.10 passed'), else, disp('Test 6.10 failed'),end
