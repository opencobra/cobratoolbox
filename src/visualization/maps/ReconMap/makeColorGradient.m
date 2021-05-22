function [cmap] = makeColorGradient(col1, col2, ncol)
% Generates a color gradient in hex format, based on color 1 and 2
%
% USAGE:
%
%    [cmap] = makeColorGradient(col1, col2, ncol)
%
% INPUTS:
%    col1:                      First color
%    col2:                      Last color
%    ncol:                      Number of colors in between
%
% OUTPUT:
%    cmap:                      Color gradient map with the corresponding
%                               colors in hex format
%
% .. Author: - Nicolas Mendoza-Mejia May/2021

hexformat = "#%02x%02x%02x";

rgb1 = sscanf(col1, hexformat);
rgb2 = sscanf(col2, hexformat);

T = (rgb2 -rgb1)/(ncol - 1);
rgb = zeros(3, ncol);

for i=1:3
   if T(i) ~= 0
    rgb(i, :) =  rgb1(i):T(i):rgb2(i);
   end
end

rgb = round(rgb);
cmap = cell(1, ncol);
for i=1:ncol
   cmap{i} = sprintf(hexformat, rgb(1, i), rgb(2, i), rgb(3, i));
end

end