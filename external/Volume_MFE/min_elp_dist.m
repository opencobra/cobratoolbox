function [dist, lambda] = min_elp_dist(y, A, options)
% this code is from http://videoprocessing.ucsd.edu/~stanleychan/publication/unpublished/Ellipse.pdf

% [dist, lambda] = min_elp_dist(y)
% computes the minimum distance from a point y to an ellipsoid x’Ax<= 1 by
% solving
%
% minimize ||x - y||
% subject to x’ A x <= 1.
%
% Input: y - a vector
% Output: dist - distance to the ellipse
% lambda - the associated lagrange multiplier
%
% Global: A - Ellipse parameter
% D - Diagonal matrix storing eigenvalues of A
% A = V’ D V;
% d - eigenvalues stored in a vector (same as D)
% q - premultiplied vector V*y, where V is the
% eigenvector of A
%
% option: display - Set ’true’ if display iteration
% interval_search - Set ’true’ if bisection interval estimation is
% needed. This option is not recommended unless the point y is
% likely to cause singularity.
%
% Algorithm: The algorithm is based on bisection interval search and secant
% method. Interval search provides a good initial guess. Secant search find
% a zeros based on first derivative approximation. [1]
%
% [1] David Kincaid, Ward Cheney, "Numerical Anlaysis", 3rd Edition.
%
% Stanley Chan
% Department of Electrical and Computer Engineering
% UC San Diego
%
% 8 Mar, 2008

max_itn = 50;
Infty = 1e16;
[V,D] = eig(A);
V = V';
d = diag(D);
q = V*y;
d_mean = mean(d);
y_norm = norm(y);
x0 = (sqrt(d_mean*y_norm^2)-1)/d_mean;
if options.interval_search
    %% Interval Search
    % Bisection for *Rough* interval estimation
    a = 0;
    b = 2*x0;
    c = a + (b-a)/2;
    Fa = myfun(a);
    Fc = myfun(c);
    Fb = myfun(b);
    itn = 1;
    TOL = 1e2;
    if options.display
        fprintf('Searching acceptable interval: \n');
        fprintf('itn a c b \n');
    end
    while ( itn < max_itn )&&(( abs(Fa - Fc) > TOL )||( abs(Fb - Fc) > TOL ))
        c = a + (b-a)/2;
        Fa = myfun(a);
        Fc = myfun(c);
        Fb = myfun(b);
        if sign(Fa)~=sign(Fc)
            b = c;
        else
            a = c;
        end
        if options.display
            fprintf('%3d %3f %3f %3f \n', itn, a, c, b);
        end
        itn = itn + 1;
    end
    if options.display
        fprintf('Interval found! \n');
        fprintf('Interval = [%3f %3f %3f]\n\n', a, c, b);
    end
else
    c = x0;
end
%% Secant Method
% Secant search for zeros
x = [c-10*sqrt(eps) c+10*sqrt(eps)];
err = Infty;
k = 2;
TOL = 1e-5;
if options.display
    fprintf('Searching lambda within interval: \n');
    fprintf('itn x err\n');
end
tic
while ( k < max_itn )&&( err > TOL )
    deltaF = (myfun(x(k),q,d)-myfun(x(k-1),q,d));
    if abs(deltaF)<=1e-10 % Stop if derivative too small!
        error('Derivative almost zero! Impossible for Secant. Try fzero.');
    else
        x(k+1) = x(k) - myfun(x(k),q,d)*(x(k)-x(k-1))/(deltaF); % Secant update
        err = abs(x(k) - x(k-1)).^2;
        if options.display
            fprintf('%3d %3d %3d \n', k, x(k), err);
        end
    end
    k = k + 1;
end
toc
lambda = x(k);
if options.display
    fprintf('Lambda found! \n');
    fprintf('Lambda = %3f \n\n', lambda);
end
%% Find distance
z = (eye(size(A)) + lambda*A)\y;
dist = norm(z-y);
%% myfun.m
function F = myfun(x,q,d)
F = -sum((q.*q).*(d./((1+d*x).^2)))+1;