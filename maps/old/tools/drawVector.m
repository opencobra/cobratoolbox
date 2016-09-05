function drawVector(begPt,endPt, color, weight)
%drawVector
%
% drawVector(begPt,endPt, color, weight)
%
%INPUTS
% begPt     Start point for vector
% endPt     End point for vector
%
%OPTIONAL INPUTS
% color     Color of vector (Default = [0 191 255])
% weight    Width of vector (Default = 2 (.fig) or 4 (.svg))
%
global CB_MAP_OUTPUT
global mapHandle
if nargin < 3
    color = [0 191 255];
    display('No color specified. Color set to [0 191 255].');
end
if nargin < 4
    weight = 2;
    if strcmp(CB_MAP_OUTPUT,'svg')
        weight = 4;
    end
end
if strcmp(CB_MAP_OUTPUT, 'matlab')
%     if find(color)>1
        color = color/255;
%     end
    line([begPt(1,1),endPt(1,1)],[-begPt(2,1),-endPt(2,1)],'Color',color,'LineWidth',weight);
elseif strcmp(CB_MAP_OUTPUT, 'java')
    % fill in code
    
    %setData(mapHandle, 400+randn(1000,1)*130, 300+randn(1000,1)*90, rand(1000,1)*220, ones(1000,1)*80);
    %setDataVector(mapHandle,begPt(1,1),endPt(1,1),begPt(2,1),endPt(2,1),220,80);
    x1=begPt(1,1);
    x2=endPt(1,1);
    y1=begPt(2,1);
    y2=endPt(2,1);
    %setbkgrnd(mapHandle,100);
    %settrans(mapHandle,xmin,xmax,ymax,ymin);
    setDataVector(mapHandle,x1,y1,x2,y2);
 
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
    fprintf(mapHandle,'<path style="fill: none;" d="M%.2f %.2f L%.2f %.2f"/>\n',begPt(1),begPt(2),endPt(1),endPt(2));
    fprintf(mapHandle,'</g>\n');
else
    display('errorXYZ2');
end