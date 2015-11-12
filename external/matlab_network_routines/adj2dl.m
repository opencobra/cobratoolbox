function []=adj2dl(adj,filename)

% function to convert adjacency matrix to UCINET dl format
% D Whitney Nov 29, 2010

adj=full(adj');
n=size(adj,1);
fid=fopen(filename,'w');
fprintf(fid,'dl n %1u format=fm diagonal=present \n',n');
fprintf(fid,'labels: \n');
labels=[1:n];
fprintf(fid,'%u \n',labels);
fprintf(fid,'data: \n');
b=[];
for i = 1:n
b=strcat(b,'%4u');
end
fprintf(fid,strcat(b,'\n'),adj');
fclose(fid);