function write4ti2(SeFull,filename,uni)
%write an input file for 4ti2
%OPTIONAL INPUT
%uni        {(0),1}, uni=1 only outputs every second reaction
%4ti2   a software package for algebraic, geometric and combinatorial
%       problems on linear spaces. www.4ti2.de

SeFull=integerizeS(SeFull);

[nMet,nRxn]=size(SeFull);

if uni==0
    %writing matrix
    filename=[filename '_Bi.4ti2in'];
    fid=fopen(filename,'w');
    fprintf(fid,'%s%s%s\n',int2str(nMet),' ',int2str(nRxn));
    for m=1:nMet
        for n=1:nRxn
            fprintf(fid,'%s%s',int2str(SeFull(m,n)),' ');
        end
        fprintf(fid,'\n');
    end
    fclose(fid);
else
    filename=[filename '_Uni.4ti2in'];
    fid=fopen(filename,'w');
    fprintf(fid,'%s%s%s\n',int2str(nMet),' ',int2str(nRxn/2));
    for m=1:nMet
        %only print out every second reaction
        for n=1:2:nRxn
            fprintf(fid,'%s%s',int2str(SeFull(m,n)),' ');
        end
        fprintf(fid,'\n');
        end
    end
    fclose(fid);
end

