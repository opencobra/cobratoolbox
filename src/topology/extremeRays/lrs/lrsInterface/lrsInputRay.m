function lrsInput_ray(Q,filename)
%from a set of extreme rays, a V-representation (vertex/ray), use lrs to
%compute a H-representation, via facet enumeration
%INPUT
% Q   Each column is a different extreme ray 
%     & each row is a different monomial.

[nMonomial,nRay]=size(Q);
fprintf('%s\n',['Assuming ' int2str(nRay) ' rays']);

%lrs wants each row to be a ray so transpose
Q=Q';

filenameFull=[filename '.ext'];
fid=fopen(filenameFull,'w');
fprintf(fid,'%s\n%s\n',filename,'V-representation');

fprintf(fid,'%s\n','begin');
fprintf(fid,'%s\n',[int2str(nRay+1) ' ' int2str(nMonomial+1) ' integer']);

for r=1:nRay+1
    if r==1
        for d=1:nMonomial+1 
            if d==1
                fprintf(fid,'%s',[int2str(1)]);
            else
                fprintf(fid,'%s',[' ' int2str(0)]);
            end
        end
    else
        for d=1:nMonomial+1 
            if d==1
                fprintf(fid,'%s',[int2str(0)]);
            else
                fprintf(fid,'%s',[' ' int2str(Q(r-1,d-1))]);
            end
        end
    end
    fprintf(fid,'\n');
end
fprintf(fid,'%s\n','end');
fclose(fid);
                