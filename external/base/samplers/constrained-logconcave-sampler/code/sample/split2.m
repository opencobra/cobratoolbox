function [x,y] = split2(xy)
%[x,y] = split2(xy)
%Split an even length vector xy into a vector x and a vector y.

dim = length(xy)/2;
x = xy(1:dim);
y = xy((dim+1):(2*dim));
end