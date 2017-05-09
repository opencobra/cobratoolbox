function Ainv=inv(A)
% simple inverse for mp objects.
% Gauss-Jordan elimination

Ainv=eye(mp(size(A)));
ss=size(A,1);

for ii=1:ss
 %pivot to find a nonzero value
 for kk=ii:ss-1
  if A(kk,ii)~=0
   break
  else
   %switch with kk'th row
   % save the ii'th row
   Av=A(ii,:);
   Ainvv=Ainv(ii,:);
   % assign the ii'th row to be the kk'th row
   A(ii,:)=A(kk+1,:);
   Ainv(ii,:)=Ainv(kk+1,:);
   % assign the kk'th row to be the old ii'th row
   A(kk+1,:)=Av;
   Ainv(kk+1,:)=Ainvv;
  end
 end
 % OK, now do the normalizations for this row.
 Ainv(ii,:)=Ainv(ii,:)/A(ii,ii);
 A(ii,:)=A(ii,:)/A(ii,ii);
 % now subtract off to get 0's in the rest of the column
 for jj=1:ss
  if ii~=jj
   Ainv(jj,:)=Ainv(jj,:)-A(jj,ii)*Ainv(ii,:);
   A(jj,:)=A(jj,:)-A(jj,ii)*A(ii,:);
  end
 end
end