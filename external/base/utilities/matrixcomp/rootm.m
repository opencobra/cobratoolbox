function [X, arg2] = rootm(A,p)
%ROOTM   Pth root of a matrix.
%        X = ROOTM(A,P) computes a Pth root X of a square matrix A.
%        This function computes the Schur decomposition A = Q*T*Q' and then
%        finds a Pth root U of T by a recursive  formula, giving X = Q*U*Q'.
%
%        X is the unique pth root for which every eigenvalue has nonnegative
%        real part.  If A has any eigenvalues with negative real parts then a
%        complex result is produced.  If A is singular then A may not have a
%        pth root.  A warning is printed if exact singularity is detected.
%
%        With two output arguments, [X, RESNORM] = ROOTM(A) does not print any
%        warning, and returns the residual, norm(A-X^2,'fro')/norm(A,'fro').

%        Reference:
%        M. I. Smith,  A Schur Algorithm for Computing Matrix pth Roots,
%        Numerical Analysis Report No. 392, Manchester Centre for
%        Computational Mathematics, Manchester, UK, 2001; to appear in
%        SIAM J. Matrix Anal. Appl.

%        Original function by Matthew Smith.

n = length(A);

[Q,T] = schur(A,'complex');

U = zeros(n);
R = zeros(n,(p-2)*n);

for i = 1:n
    U(i,i) = T(i,i)^(1/p);
        for a = 1:p-2
            R(i,(a-1)*n+i) = U(i,i)^(a+1);
        end
end

warns = warning;
warning('off');

for c = 1:n-1
    for i = 1:n-c
        sum1 = 0;
        for d = 1:p-2
	    sum2 = 0;
	    for k = i+1:i+c-1
                sum2 = sum2 + U(i,k)*R(k,(d-1)*n + i+c);
            end
            sum1 = sum1 + U(i,i)^(p-2-d)*sum2;
        end 	
	sum3 = 0;
        for k = i+1:i+c-1
            sum3 = sum3 + U(i,k)*U(k,i+c);
        end
        sum1 = sum1 + U(i,i)^(p-2)*sum3;
        sum4 = 0;
        for j = 0:p-1
            sum4 = sum4 + U(i,i)^j*U(i+c,i+c)^(p-1-j);
        end	

    U(i,i+c) = (T(i,i+c) - sum1)/(sum4);

   for q = 1:p-2
       sum5 = 0;
       for g = 0:q
           sum5 = sum5 + U(i,i )^g*U(i+c,i+c)^(q-g);
       end
       sum6 = 0;
       for h = 1:q-1
           sum7 = 0;
	   for w=i+1:i+c-1
	       sum7 = sum7 + U(i,w)*R(w,(h-1)*n +i+c);
           end
           sum6 = sum6 + U(i,i)^(q-1-h)*sum7;
       end
       sum = sum6 + U(i,i)^(q-1)*sum3;

       R(i,(q-1)*n +i+c) = U(i,i+c)*sum5 + sum;
   end
  end
end

X = Q*U*Q';
warning(warns);

nzeig = any(diag(T)==0);

if nzeig & (nargout ~= 2)
    warning('Matrix is singular and may not have a square root.')
end

if nargout == 2
    arg2 = norm(X^p-A,'fro')/norm(A,'fro');
end
