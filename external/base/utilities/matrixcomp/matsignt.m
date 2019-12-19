function S = matsignt(T)
%MATSIGNT    Matrix sign function of a triangular matrix.
%            S = MATSIGN(T) computes the matrix sign function S of the
%            upper triangular matrix T using a recurrence.

%            Called by SIGNM.

if ~isequal(T,triu(T)), error('Matrix must be upper triangular.'), end

n = length(T);

S = diag( sign( diag(real(T)) ) );
for p = 1:n-1
   for i = 1:n-p

      j = i+p;
      d = T(j,j) - T(i,i);

      if S(i,i) ~= -S(j,j)  % Solve via S^2 = I if we can.

         % Get S(i,j) from S^2 = I.
         k = i+1:j-1;
         S(i,j) = -S(i,k)*S(k,j) / (S(i,i)+S(j,j));

      else

         % Get S(i,j) from S*T = T*S.
         s = T(i,j)*(S(j,j)-S(i,i));
         if p > 1
            k = i+1:j-1;
            s = s + T(i,k)*S(k,j) - S(i,k)*T(k,j);
         end
         S(i,j) = s/d;

      end

   end
end
