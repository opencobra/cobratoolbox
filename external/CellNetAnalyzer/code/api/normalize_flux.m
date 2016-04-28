function cnap = normalize_flux(cnap,reacname)

index=[];
for z = 1:cnap.numr
        if(strcmp(reacname,deblank(cnap.reacID(z,:))))
                index=z;
		break;
        end
end

if(isempty(index))
	warndlg(['Reaction name ',reacname,' does not exist'],'Error');
	return;
end

[rr,mm]=CNAreadMFNValues(cnap);

if(rr(index)==0 | isnan(rr(index)))
	warndlg('Normalization cannot be performed','Error');
	return;
end
	
rr=rr/rr(index);
colidx=ones(length(rr),1);
colidx(find(rr==0))=2;
colidx(find(rr>0))=3;
colidx(find(rr<0))=4;

cnap=CNAwriteMFNValues(cnap,rr,colidx,mm);

