function drawArrowhead(point,dir,rad,color)
%drawArrowhead Adds arrowhead to curve
%
% drawArrowhead(point,dir,rad,color)
%
%INPUTS
% point     Coordinates
% dir       Direction of arrowhead
% rad       Controls width of arrowhead
% color     Color of arrowhead
%
    global mapHandle
    global CB_MAP_OUTPUT
    angle = atan2(dir(2),dir(1));
    l = rad*.9;
    spread = pi/6*.9;
    x = [(point(1)+l*cos(angle+spread)) point(1) (point(1)+l*cos(angle-spread))];
    y = [(point(2)+l*sin(angle+spread)) point(2) (point(2)+l*sin(angle-spread))];
    if strcmp(CB_MAP_OUTPUT, 'matlab')
        if find(color>1)
            color = color/255;
        end
        fill(x,-y,color);
    elseif strcmp(CB_MAP_OUTPUT, 'java')
        %missing code
    elseif strcmp(CB_MAP_OUTPUT, 'svg')
        %determine type of color input
        if ischar(color)
            colorFill = color;
        else if isvector(color)
                colorFill = strcat('rgb(',num2str(color(1)),',',num2str(color(2)), ',',num2str(color(3)),')');
            end
        end
        colorStroke = colorFill;
        fprintf(mapHandle,'<path d="M %8.2f %8.2f L %8.2f %8.2f L %8.2f %8.2f z" fill="%s" stroke="%s"/>\n',x(1),y(1),x(2),y(2),x(3),y(3),colorFill,colorStroke);
    else
        display('no render found');
    end
end