function drawCircle(p,radius,color)
%drawCircle draw a circle in a figure
%
% drawCircle(p,radius,color)
%
%INPUTS
% p             Coordinates
% radius        Radius of the circle
% color         Color of the circle
%
%
global CB_MAP_OUTPUT
global mapHandle
%p = center
%radius = radius
%color 


if strcmp(CB_MAP_OUTPUT, 'matlab')
    i = 0:pi/100:2*pi;
    x = radius*cos(i)+p(1);
    y = radius*sin(i)-p(2);
    if find(color>1)
        color = color/255;
    end
    fill(x,y,color);
elseif strcmp(CB_MAP_OUTPUT, 'java')
    %draw circle via java.
    % center = p; radius = radius
    setDataCircle(mapHandle,p(1,1),p(2,1));
elseif strcmp(CB_MAP_OUTPUT, 'svg')
    met = strcat('<g id="',...
        'x',...
        '" style="fill: rgb(',...
        num2str(color(1)),', ',...
        num2str(color(2)),', ',...
        num2str(color(3)),');">\n<circle cx="',...
        num2str(p(1)),'" cy="',...
        num2str(p(2)),...
        '" r="',num2str(radius),...
        '"/>\n</g>\n');
    fprintf(mapHandle, met);
%         met = strcat('<g id="',...
%         'x',...
%         '" style="fill: rgb(255, 160, 128); stroke: rgb(64, 0, 0); stroke-width: 1;">\n<circle cx="',...
%         num2str(p(1)),'" cy="',...
%         num2str(-p(2)),...
%         '" r="',num2str(radius),...
%         '"/>\n</g>\n');
%     fprintf(mapHandle, met);
else
    display('error');
end
