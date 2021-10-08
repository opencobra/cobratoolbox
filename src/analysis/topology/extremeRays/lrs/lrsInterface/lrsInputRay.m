function [fileNameOut, extension] = lrsInputRay(Q,fileName,vertexBool,redund)
%from a set of extreme rays, a V-representation (vertex/ray), use lrs to
%compute a H-representation, via facet enumeration
%INPUT
% Q   Each column is a different extreme ray 
%     & each row is a different monomial.

% V-representation
% 
% m is the number of input rows, each being a vertex, ray or line.
% n is the number of input columns and d=n-1 is dimension of the input.
% Each vertex is given in the form:
% 
% 1   v_1   v_1  ... v_d
% 
% Each ray is given in the form:
% 
% 0   r_1   r_2...   r_d
% 
% where  r_1  ...   r_d  is a point on the ray.
% 
% There must be at least one vertex in each file. 
% For bounded polyhedra there will be no rays entered. 
% The coefficients can be entered as integers or rationals in the format x/y. 
% An input line can be specified as a ray and then included in the linearity option (see below).

[nMonomial,nRay]=size(Q);
if ~exist('vertexBool','var')
    fprintf('%s\n',['Assuming ' int2str(nRay) ' rays']);
    vertexBool = zeros(nRay,1);
end
if ~exist('redund','var')
    redund = 1;
end
if redund ==0
    %remove all redundant halfspaces
    redund = 'redund 0 0'; 
end

%lrs wants each row to be a ray so transpose
Q=Q';

fileNameOut = fileName;
extension = '.ext';
filenameFull=[fileName extension];
fid=fopen(filenameFull,'w');
fprintf(fid,'%s\n%s\n',fileName,'V-representation');


if any(~vertexBool)
    ind = find(vertexBool);
    if length(ind)>0
        fprintf(fid,'%s%s','linearity ',int2str(nnz(vertexBool)));
        for j = 1:length(ind)
            fprintf(fid,'%s%s',' ',int2str(ind(j)));
        end
        fprintf(fid,'\n');
    end
end


fprintf(fid,'%s\n','begin');


if ~any(vertexBool)
    fprintf(fid,'%s\n',[int2str(nRay+1) ' ' int2str(nMonomial+1) ' integer']);
    %there must be at least one vertex
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
else
    fprintf(fid,'%s\n',[int2str(nRay) ' ' int2str(nMonomial+1) ' integer']);
    for r=1:nRay
        for d=1:nMonomial+1
            if d==1
                fprintf(fid,'%s',[int2str(vertexBool(r)+0)]);
            else
                fprintf(fid,'%s',[' ' int2str(Q(r,d-1))]);
            end
        end
        fprintf(fid,'\n');
    end
end

fprintf(fid,'%s\n','end');
if redund
    %remove redundant halfspaces
    fprintf(fid,'%s\n',redund);
end
fclose(fid);
                