function see(A, k)
%SEE    Pictures of a matrix.
%       SEE(A) displays MESH(A), SEMILOGY(SVD(A),'o'),
%       and (if A is square) PS(A) and FV(A) in four subplot windows.
%       SEE(A, 1) plots MESH(PINV(A)) in the
%       third window instead of the 1e-3-pseudospectrum.
%       SEE(A, -1) plots only the eigenvalues in the third/fourth window,
%       which is much quicker than PS or FV.
%       If A is complex, only real parts are used for the mesh plots.
%       If A is sparse, just SPY(A) is shown.

if nargin < 2, k = 0; end
[m, n] = size(A);
square = (m == n);
clf

if issparse(A)

   spy(A);

else

   B = pinv(A);
   s = svd(A);
   zs = (s == zeros(size(s)));
   if any( zs )
      s( zs ) = [];  % Remove zero singular values for semilogy plot.
   end

   subplot(2,2,1)
   mesh(real(A)), axis('ij'),  drawnow
   subplot(2,2,2)
   semilogy(s, 'o')
   hold on, semilogy(s, '-'), hold off, drawnow
   if any(zs), title('Zero(s) omitted'), end

   subplot(2,2,3)
   if ~square
      axis off
      text(0,0,'Matrix not square.')
      return
   end

   if k == -1
      ps(A, 0);
   elseif k == 1
      mesh(real(B)), axis('ij'), drawnow
   else
      ps(A);
   end

   subplot(2,2,4)
   fv(A);

end
