function out=colon(x,y,z)

x=double(x);
y=double(y);

if nargin==2
 out=mp(x:y);
elseif nargin==3
 z=double(z);
 out=mp(x:y:z);
end
