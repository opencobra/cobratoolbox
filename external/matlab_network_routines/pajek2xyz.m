% Read x,y,z node coordinates from a pajek .net file - useful for plotting in Matlab
% INPUTS: filename, string format
% OUTPUTS: x,y,z coordinate vectors
% GB, Last updated: October 7, 2009

function [x,y,z]=pajek2xyz(filename)

f=fopen(filename,'r');
C = textscan(f, '%s');
c=C{1};

ind_edges=find(ismember(c, '*Edges')==1);
if isempty(ind_edges); ind_edges=find(ismember(c, '*Arcs')==1); end

% c{1}='*Vertices', n=str2num(c{2}); % number of nodes
% c{3},c{8},c{13},...c{5k+3} are node indices
% c{4},c{9},c{14},...c{5k+4} are 'vi', between them are coordinates

x=[]; y=[]; z=[]; % initialize coordinates

for cc=3:ind_edges-1
    if mod(cc,5)==4
        x=[x, str2num(c{cc+1})];
        y=[y, str2num(c{cc+2})];
        z=[z, str2num(c{cc+3})];
    end
end