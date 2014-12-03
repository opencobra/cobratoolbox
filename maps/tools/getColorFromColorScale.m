function color = getColorFromColorScale(value, colorScale)
%getColorFromColorScale Obtains color from color scale
%
% color = getColorFromColorScale(value, colorScale)
%
%INPUT
% value         Vector containing values
%
%OPTIONAL INPUT
% colorScale    Color scale used to dermine color for values
%               (Default = cool(100))
%
%OUTPUT
% color         n x 3 matrix containing RGB color values for each input
%               value
%
%Richard Que 12/2009
%
if ~exist('colorScale','var')
    colorScale = (cool(100));
    colorScale = round(colorScale*255);
end
color = zeros(size(value,1),3);
%normalize value
if max(value)~=0 & max(value)>1
    value = abs(value/max(value));
end
value(isinf(value))=0;
index = round(value*(size(colorScale,1)-1));
for i=1:size(value,1)
    color(i,1:3) = colorScale(index(i)+1,1:3);
end
