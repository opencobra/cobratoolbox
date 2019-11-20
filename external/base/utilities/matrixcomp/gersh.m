function  [G, e] = gersh(A, noplot)
%GERSH    Gershgorin disks.
%         GERSH(A) draws the Gershgorin disks for the square matrix A.
%         The eigenvalues are plotted as crosses `x'.
%         Alternative usage: [G, E] = GERSH(A, 1) suppresses the plot
%         and returns the data in G, with A's eigenvalues in E.
%
%         Try GERSH(GALLERY('LESP',N)) and GERSH(GALLERY('SMOKE',N)).

if diff(size(A)), error('Matrix must be square.'), end

n = length(A);
m = 40;
G = zeros(m,n);

d = diag(A);
r = sum( abs( A-diag(d) )' )';
e = eig(A);

radvec = exp(i * linspace(0,2*pi,m)');

for j=1:n
    G(:,j) = d(j)*ones(m,1) + r(j)*radvec;
end

if nargin < 2

   ax = cpltaxes(G(:));
   for j=1:n
       plot(real(G(:,j)), imag(G(:,j)),'-')      % Plot the disks.
       hold on
   end
   plot(real(e), imag(e), 'x')    % Plot the eigenvalues too.
   axis(ax)
   axis('square')
   hold off

end
