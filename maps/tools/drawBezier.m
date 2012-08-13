function drawBezier(p,color,weight)
%drawBezier Draw a bezier curve in a figure
%
% drawBezier(p,color,weight)
%
%INPUT
% p         Coordinates
% color     Color of bezier curve
% weight    Weight of bezier curve
%
global CB_MAP_OUTPUT
global mapHandle
if nargin < 2
    color = [0 0 255];
    display('No color specified');
end
numpoints = 50;
%a = zeros(2,numpoints);
%b = zeros(2,numpoints);
%c = zeros(2,numpoints);
i = 0:numpoints;
a = (p(:,1)* i + p(:,2)*(numpoints-i))/numpoints;
b = (p(:,2)* i + p(:,3)*(numpoints-i))/numpoints;
c = (a .* (ones(2,1)* i) + b .*(ones(2,1)  *(numpoints-i)))  /numpoints;
if strcmp(CB_MAP_OUTPUT, 'matlab')
    if find(color>1)
        color = color/255;
    end
    line(c(1,:), -c(2,:),'Color',color,'LineWidth',weight);
elseif strcmp(CB_MAP_OUTPUT, 'java')
    %line(c(1,:), c(2,:),'Color',color,'LineWidth',weight);
    % fill in code
     setDataBezier(mapHandle,c(1,:),c(2,:));
elseif strcmp(CB_MAP_OUTPUT, 'svg')    
    %determine type of color input
    if ischar(color)
        colorStroke = color;
    else if isvector(color)
            colorStroke = strcat('rgb(',num2str(color(1)),',',num2str(color(2)),',',num2str(color(3)),')');
        end
    end
    fprintf(mapHandle,'<g id="" stroke="%s" stroke-width="%d" stroke-linecap="round">\n',colorStroke,ceil(weight));
%     fprintf(mapHandle,'<g id="" stroke="deepskyblue" stroke-width="6" stroke-linecap="round">\n');
    %fprintf(mapHandle,'<path style="fill: none;" d="M%8.2f %8.2f C%8.2f %8.2f %8.2f %8.2f %8.2f %8.2f"/>\n',p2(1),-p2(2),p2(1),-p2(2),ptemp(1),-ptemp(2),p1(1),-p1(2));
    fprintf(mapHandle,'<path style="fill: none;" d="M%8.2f %8.2f C%8.2f %8.2f %8.2f %8.2f %8.2f %8.2f"/>\n',p(1,3),p(2,3) ,p(1,3),p(2,3),p(1,2),p(2,2),p(1,1),p(2,1));
    fprintf(mapHandle,'</g>\n');
else
    display('error CB_MAP_OUTPUT in bezier');
end

