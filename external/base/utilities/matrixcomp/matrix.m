function A = matrix(k, n)
%MATRIX  Test matrices accessed by number.
%        MATRIX(K, N) is the N-by-N instance of matrix number K in
%        a set of test matrices comprising those in MATLAB plus those
%        in the Matrix Computation Toolbox,
%        with all other parameters set to their default.
%        N.B. - Only those matrices which are full and take an arbitrary
%               dimension N are included.
%             - Some of these matrices are random.
%        MATRIX(K) is a string containing the name of the K'th matrix.
%        MATRIX(0) is the number of matrices, i.e. the upper limit for K.
%        Thus to set A to each N-by-N test matrix in turn use a loop like
%             for k=1:matrix(0)
%                 A = matrix(k, N);
%                 Aname = matrix(k);   % The name of the matrix
%             end
%        MATRIX(-1) returns the version number and date of the
%        Matrix Computation Toolbox.
%        MATRIX with no arguments lists the names and numbers of the M-files in the
%        collection.

%         References:
%         N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%            Second edition, Society for Industrial and Applied Mathematics,
%            Philadelphia, PA, 2002; sec. 20.5.

% Matrices from gallery:
matrices = [%
'cauchy  '; 'chebspec'; 'chebvand'; 'chow    ';
'circul  '; 'clement '; 'condex  ';
'cycol   '; 'dramadah'; 'fiedler ';
'forsythe'; 'frank   '; 'gearmat '; 'grcar   ';
'invhess '; 'invol   '; 'ipjfact '; 'jordbloc';
'kahan   '; 'kms     '; 'krylov  '; 'lehmer  ';
'lesp    '; 'lotkin  '; 'minij   '; 'moler   ';
'orthog  '; 'parter  '; 'pei     '; 'prolate ';
'randcolu'; 'randcorr'; 'rando   '; 'randsvd ';
'redheff '; 'riemann '; 'ris     '; 'smoke   ';
'toeppd  '; 'triw    ';];
n_gall = length(matrices);

% Other MATLAB matrices:
matrices = [matrices;
'hilb    '; 'invhilb '; 'magic   '; 'pascal  ';
'rand    '; 'randn   ';];
n_MATLAB = length(matrices);

% Matrices from Matrix Computation Toolbox:
matrices = [matrices;
'augment '; 'gfpp    '; 'magic   '; 'makejcf ';
'rschur  '; 'vand    '];
n_mats = length(matrices);

if nargin == 0

   rows = ceil(n_mats/5);
   temp = zeros(rows,5);
   temp(1:n_mats) = 1:n_mats;

   for i = 1:rows
      for j = 1:5
        if temp(i,j) == 0, continue, end
        fprintf(['%2.0f: ' sprintf('%s',matrices(temp(i,j),:)) '  '], ...
                temp(i,j))
      end
      fprintf('\n')
   end
   fprintf('Matrices 1 to %1.0f are from MATLAB\.', n_MATLAB)

elseif nargin == 1
   if k == 0
      A = length(matrices);
   elseif k > 0
      A = deblank(matrices(k,:));
   else
      % Version number and date of collection.
      A = 'Version 1.2, September 5 2002';
   end
else
   if k <= n_gall
      A = eval( ['gallery(''' deblank(matrices(k,:)) ''',n)'] );
   else
      A = eval( [deblank(matrices(k,:)) '(n)'] );
   end
end
