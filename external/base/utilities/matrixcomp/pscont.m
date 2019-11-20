function [x, y, z, m] = pscont(A, k, npts, ax, levels)
%PSCONT   Contours and colour pictures of pseudospectra.
%         PSCONT(A, K, NPTS, AX, LEVELS) plots LOG10(1/NORM(R(z))),
%         where R(z) = INV(z*I-A) is the resolvent of the square matrix A,
%         over an NPTS-by-NPTS grid.
%         NPTS defaults to a SIZE(A)-dependent value.
%         The limits are AX(1) and AX(2) on the x-axis and
%                        AX(3) and AX(4) on the y-axis.
%         If AX is omitted, suitable limits are guessed based on the
%         eigenvalues of A.
%         The eigenvalues of A are plotted as crosses `x'.
%         K determines the type of plot:
%             K = 0 (default) PCOLOR and CONTOUR
%             K = 1           PCOLOR only
%             K = 2           SURFC (SURF and CONTOUR)
%             K = 3           SURF only
%             K = 4           CONTOUR only
%         The contours levels are specified by the vector LEVELS, which
%         defaults to -10:-1 (recall we are plotting log10 of the data).
%         Thus, by default, the contour lines trace out the boundaries of
%         the epsilon pseudospectra for epsilon = 1e-10, ..., 1e-1.
%         [X, Y, Z, NPTS] = PSCONT(A, ...) returns the plot data X, Y, Z
%         and the value of NPTS used.
%
%         After calling this function you may want to change the
%         color map (e.g., type COLORMAP HOT - see HELP COLOR) and the
%         shading (e.g., type SHADING INTERP - see HELP INTERP).
%         For an explanation of the term `pseudospectra', and references,
%         see PS.M.
%         When A is real and the grid is symmetric about the x-axis, this
%         routine exploits symmetry to halve the computational work.

%         Colour pseduospectral pictures of this type are referred to as
%         `spectral portraits' by Godunov, Kostin, and colleagues.
%         References: see PS.

if diff(size(A)), error('Matrix must be square.'), end
n = length(A);
Areal = ~any(imag(A));

if nargin < 5, levels = -10:-1; end
e = eig(A);
if nargin < 4 | isempty(ax)
   ax = cpltaxes(e);
   if Areal, ax(3) = -ax(4); end  % Make sure region symmetric about x-axis.
end
if nargin < 3 | isempty(npts)
   npts = 3*round( min(max(5, sqrt(20^2*10^3/n^3) ), 30));
end
if nargin < 2 | isempty(k), k = 0; end

nptsx = npts; nptsy = npts;
Ysymmetry = (Areal & ax(3) == -ax(4));

x = linspace(ax(1), ax(2), npts);
y = linspace(ax(3), ax(4), npts);
if Ysymmetry                    % Exploit symmetry about x-axis.
   nptsy = ceil(npts/2);
   y1 = y;
   y = y(1:nptsy);
end

[xx, yy] = meshgrid(x,y);
z = xx + sqrt(-1)*yy;
I = eye(n);
Smin = zeros(nptsy, nptsx);

for j=1:nptsx
    for i=1:nptsy
        Smin(i,j) = min( svd( z(i,j)*I-A ) );
    end
end

z = log10( Smin + eps );
if Ysymmetry
   z = [z; z(nptsy-rem(npts,2):-1:1,:)];
   y = y1;
end

if k == 0 | k == 1
   pcolor(x, y, z); hold on
elseif k == 2
   surfc(x, y, z); hold on
elseif k == 3
   surf(x, y, z); hold on
end

if k == 0
   contour(x, y, z, levels,'-k'); hold on
elseif k == 4
   contour(x, y, z, levels); hold on
end

if k ~= 2 & k ~= 3
   if k == 0 | k == 1
      s = 'w';   % White.
   else
      s = 'k';   % Black.
   end
   plot(real(e),imag(e),['x' s]);
end

axis('square')
hold off
