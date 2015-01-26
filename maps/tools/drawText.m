function drawText(x,y, drawString, fontSize, fontStyle, color, font, fontWeight, flagCenter)
%drawText Draws text to figure
%
% drawText(x,y, drawString, fontSize, fontStyle, color, font, fontWeight, flagCenter)
%
%INPUTS
% x             x coordinate
% y             y coordinate
% drawString    String to draw
%
%OPTIONAL INPUTS
% fontSize      Font size (Default = 12)
% fontStyle     Font style (Default = 'normal')
% color         Font color (Default = [0 0 0])
% font          Font (Default = 'sans-serif')
% fontWeight    Font weight (Default = 'normal')
% flagCenter    Center text on coordinate (Default = false)
%
global CB_MAP_OUTPUT
global mapHandle

if nargin < 4
    fontSize = 12;
end
if nargin < 5
    fontStyle = 'normal';
end
if nargin < 6
    color = [0 0 0];
end
if nargin < 7
    font = 'sans-serif';
end
if nargin <8
    fontWeight = 'normal';
end
if nargin < 9
    flagCenter = false;
end

if length(fontSize)>1
    error('Fontsize should be a scalar')
end

if iscell(drawString)
    display ('whoops - this shouldnt happen.  drawText.m')
%     drawString
%     whos('drawString')
    drawString = drawString{1};
end
if isnan(x) | isnan(y) | isnan(fontSize)
%     display ('whoops - this shouldnt happen.  drawText.m')
    return;
end
if strcmp(CB_MAP_OUTPUT, 'matlab')
    if find(color>1)
        color = color/255;
    end
    if flagCenter
        text(x,-y,drawString, 'FontSize', fontSize/2, 'color', color,'HorizontalAlignment','center');
    else
        text(x,-y,drawString, 'FontSize', fontSize/2, 'color', color);
    end
elseif strcmp(CB_MAP_OUTPUT, 'java')
    % need to insert code
elseif strcmp(CB_MAP_OUTPUT, 'svg')  
    %determine type of color input
    if ischar(color)
        if color=='k'
            colorStroke = 'rgb(0,0,0)';
        else
            colorStroke = color;
        end
    else if isvector(color)
            colorStroke = strcat('rgb(',num2str(color(1)),',',num2str(color(2)),',',num2str(color(3)),')');
        end
    end
    drawString = regexprep(drawString,'&','&amp;');
    fprintf(mapHandle, '<g style="font-family: %s; font-style: %s; font-weight: %s; stroke: none;">\n',font,fontStyle, fontWeight);
    if flagCenter
        %fprintf('<text style="fill: %s; text-rendering: optimizeLegibility;" x="%.2f" y="%.2f" font-size="%dpx">%s</text>\n</g>\n',colorStroke,x-(length(drawString)*fontSize*1.25),y+(5*fontSize),5*fontSize,drawString);
        fprintf(mapHandle,'<text style="fill: %s; text-rendering: optimizeLegibility;" x="%.2f" y="%.2f" font-size="%dpx">%s</text>\n</g>\n',colorStroke,x-(length(drawString)*fontSize*1.25),y+(5*fontSize),5*fontSize,drawString);
    else
        %code for debugging
%         fprintf('<text style="fill: %s; text-rendering: optimizeLegibility;" x="%.2f" y="%.2f" font-size="%dpx">%s</text>\n</g>\n',colorStroke,x,y,5*fontSize,drawString);
%         fprintf('\n%s\n','----')
%         disp(colorStroke)
%         class(colorStroke)
%         fprintf('%s\n','----')
%         disp(x)
%         class(x)
%         fprintf('%s\n','----')
%         disp(y)
%         class(y)
%         fprintf('%s\n','----')
%         disp(5*fontSize)
%         class(5*fontSize)
%         fprintf('%s\n','----')
%         disp(drawString)
%         class(drawString)
        fprintf(mapHandle,'<text style="fill: %s; text-rendering: optimizeLegibility;" x="%.2f" y="%.2f" font-size="%dpx">%s</text>\n</g>\n',colorStroke,x,y,5*fontSize,drawString);
    end
%     fprintf(mapHandle,'<text style="stroke: none;" x="%8.2f" y="%8.2f">%s</text>\n',x,-y,drawString); 
else
    display('error CB_MAP_OUTPUT in drawText');
end