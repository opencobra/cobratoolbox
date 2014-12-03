function []=edgelist2dl(edgelistt,filename)

% function to convert two-way edgelist to UCINET dl format
% D Whitney Nov 29, 2010
% example filename is 'filename.txt'

numnodes=max(max(edgelistt))
n=numnodes;
fid=fopen(filename,'w');
fprintf(fid,'dl n %1u format=el1 \n',n);
fprintf(fid,'labels: \n');
labels=[1:n];
fprintf(fid,'%u \n',labels);
fprintf(fid,'data: \n');
fprintf(fid,'%3u %3u \n', edgelistt);
fclose(fid);