function out=rem(x,y)
if isempty(x),out=x;return;end
if isempty(y),out=y;return;end
if prod(size(y))==1, y=repmat(y,size(x)); end
if prod(size(x))==1, x=repmat(x,size(y)); end
n=repmat(NaN+x(1)+y(1),size(y));%A NaN of type mp
q=find(y);%Zero values of y will produce a remainder equal to NaN (by definition)
n(q) = fix(x(q)./y(q));
out = x - n.*y;

