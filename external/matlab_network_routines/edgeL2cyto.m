% Write an edgelist structure m x [node 1, node 2, link] to Cytoscape input format (.txt or any text extension works)
% In Cytoscape the column separator option is semi-colon ";". If desired, this is easy to change below in line 15.
% INPUTs: edgelist - mx3 matrix, m = number of edges, file name string
% OUTPUTs: text file in Cytoscape format with a semicolon column separator

function []=edgeL2cyto(el,filename)

nodes=unique([el(:,1)', el(:,2)']);
n=length(nodes);  % number of nodes
m = size(el,1); % number of edges

fid = fopen(filename,'wt','native');

for i=1:m
  fprintf(fid,'    %4i ;  %4i ;  %3.6f\n',el(i,1),el(i,2),el(i,3));
end

fclose(fid);

