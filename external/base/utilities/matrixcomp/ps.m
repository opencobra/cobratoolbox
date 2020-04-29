function y = ps(A, m, tol, rl, marksize)
%PS     Dot plot of a pseudospectrum.
%       PS(A, M, TOL, RL) plots an approximation to a pseudospectrum
%       of the square matrix A, using M random perturbations of size TOL.
%       M defaults to a SIZE(A)-dependent value and TOL to 1E-3.
%       RL defines the type of perturbation:
%         RL =  0 (default): absolute complex perturbations of 2-norm TOL.
%         RL =  1:           absolute real perturbations of 2-norm TOL.
%         RL = -1:           componentwise real perturbations of size TOL.
%       The eigenvalues of A are plotted as crosses `x'.
%       PS(A, M, TOL, RL, MARKSIZE) uses the specified marker size instead
%       of a size that depends on the figure size, the matrix order, and M.
%       If MARKSIZE < 0, the plot is suppressed and the plot data is returned
%       as an output argument.
%       PS(A, 0) plots just the eigenvalues of A.

%       For a given TOL, the pseudospectrum of A is the set of
%       pseudo-eigenvalues of A, that is, the set
%       { e : e is an eigenvalue of A+E, for some E with NORM(E) <= TOL }.
%
%       References:
%       L. N. Trefethen, Computation of pseudospectra, Acta Numerica,
%          8:247-295, 1999.
%       L. N. Trefethen, Spectra and pseudospectra, in The Graduate
%          Student's Guide to Numerical Analysis '98, M. Ainsworth,
%          J. Levesley, and M. Marletta, eds., Springer-Verlag, Berlin,
%          1999, pp. 217-250.

if diff(size(A)), error('Matrix must be square.'), end
n = length(A);

if nargin < 5, marksize = 0; end
if nargin < 4, rl = 0; end
if nargin < 3, tol = 1e-3; end
if nargin < 2 | isempty(m), m = 5*max(1, round( 25*exp(-0.047*n) )); end

if m == 0
   e = eig(A);
   ax = cpltaxes(e);
   plot(real(e), imag(e), 'x')
   axis(ax), axis('square')
   return
end

x = zeros(m*n,1);
i = sqrt(-1);

for j = 1:m
   if rl == -1     % Componentwise.
      dA = -ones(n) + 2*rand(n);   % Uniform random numbers on [-1,1].
      dA = tol * A .* dA;
   else
      if rl == 0   % Complex absolute.
         dA = randn(n) + i*randn(n);
      else         % Real absolute.
         dA = randn(n);
      end
      dA = tol/norm(dA)*dA;
   end
   x((j-1)*n+1:j*n) = eig(A + dA);
end

if marksize >= 0

   ax = cpltaxes(x);
   h = plot(real(x),imag(x),'.');
   axis(ax), axis('square')

   % Next block adapted from SPY.M.
   if marksize == 0
      units = get(gca,'units');
      set(gca,'units','points');
      pos = get(gca,'position');
      nps = 2.4*sqrt(n*m);  % Factor based on number of pseudo-ei'vals plotted.
      myguess = round(3*min(pos(3:4))/nps);
      marksize = max(1,myguess);
      set(gca,'units',units);
   end

   hold on
   e = eig(A);
   plot(real(e),imag(e),'x');
   set(h,'markersize',marksize);
   hold off

else

  y = x;

end
