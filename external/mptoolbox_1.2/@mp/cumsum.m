function out=cumsum(x,dim)

if ~isempty(x)

 precision=x(1).precision;
 % can only handle up to 2 dimensions
 s=size(x);
 out=x;
 if nargin==1
  if any(s==1)
   for ii=2:numel(x)
    out(ii)=out(ii-1)+x(ii);
   end
  else
   for j=1:s(2)
    for i=2:s(1)
     out(i,j)=out(i-1,j)+x(i,j);
    end
   end
  end
 elseif nargin==2
  if dim==1
   for j=1:s(2)
    for i=2:s(1)
     out(i,j)=out(i-1,j)+x(i,j);
    end
   end
  elseif dim==2
   for j=2:s(2)
    for i=1:s(1)
     out(i,j)=out(i,j-1)+x(i,j);
    end
   end  
  else
   error('mp cumprod can only handle up to 2-D arrays (11/04)');
  end
 end

else
 out=x;
end
