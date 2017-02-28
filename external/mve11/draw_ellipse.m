function draw_ellipse(A,b,x0,x,E,xiter)

if size(A,2) == 2
   [xe, ye] = ellipse(x,E,1);
   plot(xe, ye, 'r-');  hold on;
   [xp, ypl, ypu] = polygon(A,b,x0);
   plot(xp, ypl, 'b-', xp, ypu, 'b-');
   plot( x(1),  x(2), '*');
   plot(x0(1), x0(2), 'o');
   if exist('xiter','var'), replay(x,xiter,0); end
%  [xe, ye] = ellipse(x,E,2); plot(xe, ye, 'r-');
   hold off
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function replay(x,xiter,t)

if ~ishold, hold on; end
for i = 1:size(xiter,2)
    plot(xiter(1,i), xiter(2,i), 'o'); 
    if t > 0, pause(t); end
    err = norm(x-xiter(:,i))/norm(x);
    if err < .002, break; end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xe, ye] = ellipse(x,E,r)

n = 1000; d = 2*pi/n; t = 0:d:2*pi-d;
ell = x(:,ones(1,n)) + r*E*[sin(t); cos(t)];
xe = ell(1,:); ye = ell(2,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xp, ypl, ypu] = polygon(A,b,x)

iz = find(A(:,2) == 0);
if ~isempty(iz), A(iz,2) = 1.e-2; end
x2   = (b-x(1)*A(:,1))./A(:,2);
iupp = find(x2 > x(2));
ilow = find(x2 < x(2));

n = 2000;
low  = x(1) - 1; high = x(1) + 1;
x1 = low : (high-low)/n : high;
x2 = diag(1./A(:,2)) * ...
     (b(:,ones(size(x1)))-A(:,1)*x1);

if length(iupp)==1
      yupp = x2(iupp,:);
else, yupp = min(x2(iupp,:));
end
if length(ilow)==1
      ylow = x2(ilow,:);
else, ylow = max(x2(ilow,:));
end

il = max(1,   min(find(yupp-ylow >= 0))-1); %#ok<*MXFND>
ir = min(n+1, max(find(yupp-ylow >= 0))+1);

xp = x1(il:ir);
ypl = ylow(il:ir);
ypu = yupp(il:ir);
