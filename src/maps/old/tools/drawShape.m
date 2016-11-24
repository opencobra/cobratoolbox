function drawShape(sType,begPt,sLength, color, thickness,sStyle,verbose)
%drawShape Draw shapes to figure
%
% drawShape(sType,begPt,sLength, color, thickness,sStyle,verbose)
% 
%INPUTS
% sType         Shape type ('rect', 'line', 'circle')
% begPt         Coordinate of start point [x y]
% sLength       Shape length [x length, y length]
% color         Shape color
% thickness     Shape edge thickness
% sStyle        Shape style
%   DASHL           Dashed edge
%   DASHM           Dashed edge
%   DASHS           Dash dot edge
%   DOTTD           Dotted edge
%   PLAIN           Solid edge
%
%OPTIONAL INPUT
% verbose       verboseFlag (Default = fasle0
% 
if ~exist('verbose','var')
    verbose = false;
end
global CB_MAP_OUTPUT
global mapHandle
if nargin < 4
    color = 'b';
    display('No color specified');
elseif strcmp(CB_MAP_OUTPUT, 'matlab')
    color = (1/255)*color;
end
if verbose
    if strcmp(sStyle,'DASHL')
        display('DASHL');
        style = '--';
        dashArray = '30, 20';
    elseif strcmp(sStyle,'DASHM')
        display('DASHM');
        style = '--';
        dashArray = '20, 20';
    elseif strcmp(sStyle,'DASHS')
        display('DASHS');
        style = '-.';
        dashArray = '10, 15';
    elseif strcmp(sStyle,'DOTTD')
        display('DOTTD');
        style = ':';
        dashArray = '0, 20';
    elseif strcmp(sStyle,'PLAIN')
        display('PLAIN');
        style = '-';
        dashArray = '';
    else
        style = '-';
        dashArray = '';
        display('Unknown Style');
    end
else
    if strcmp(sStyle,'DASHL')
        style = '--';
        dashArray = '30, 20';
    elseif strcmp(sStyle,'DASHM')
        style = '--';
        dashArray = '20, 20';
    elseif strcmp(sStyle,'DASHS')
        style = '-.';
        dashArray = '10, 15';
    elseif strcmp(sStyle,'DOTTD')
        style = ':';
        dashArray = '0, 20';
    elseif strcmp(sStyle,'PLAIN')
        style = '-';
        dashArray = '';
    else
        style = '-';
        dashArray = '';
    end
end

if strcmp(CB_MAP_OUTPUT, 'matlab')
    thickness = thickness/7;
    begPt(1,2) = -begPt(1,2);
    sLength(1,1) = -sLength(1,1);
    switch lower(sType{1})
        case 'line'
            line([begPt(1,1),(begPt(1,1)+sLength(1,2))],[begPt(1,2),(begPt(1,2)+sLength(1,1))],'Color',color,'LineWidth',thickness,'LineStyle',style);
        case {'rect', 'rectangle'}
            line([begPt(1,1),begPt(1,1)],[begPt(1,2),(begPt(1,2)+sLength(1,1))],'Color',color,'LineWidth',thickness,'LineStyle',style);
            line([begPt(1,1),(begPt(1,1)+sLength(1,2))],[begPt(1,2),begPt(1,2)],'Color',color,'LineWidth',thickness,'LineStyle',style);
            line([(begPt(1,1)+sLength(1,2)),(begPt(1,1)+sLength(1,2))],[begPt(1,2),(begPt(1,2)+sLength(1,1))],'Color',color,'LineWidth',thickness,'LineStyle',style);
            line([begPt(1,1),(begPt(1,1)+sLength(1,2))],[(begPt(1,2)+sLength(1,1)),(begPt(1,2)+sLength(1,1))],'Color',color,'LineWidth',thickness,'LineStyle',style);
        case 'circle'
            i = 0:pi/100:2*pi;
            x = .5*sLength(1,2)*cos(i)+begPt(1);
            y = .5*sLength(1,1)*sin(i)-begPt(2);
            plot(x,y,style);
        otherwise
            display('error: Unknown Shape Type');
    end
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
    if ischar(color)
        colorStroke = color;
    else if isvector(color)
            colorStroke = strcat('rgb(',num2str(color(1)),',',num2str(color(2)),',',num2str(color(3)),')');
        end
    end
    switch lower(sType{1})
        case 'line'
            fprintf(mapHandle,['<g style="stroke-linecap: round; stroke-linejoin: round; stroke-miterlimit: 20; '...
                'fill: %s; stroke: %s; stroke-width: %d; stroke-dasharray: %s;">\n'],colorStroke,colorStroke,thickness,dashArray);
            fprintf(mapHandle,'<line x1="%.2f" y1="%.2f" x2="%.2f" y2="%.2f" />\n</g>\n',begPt(1,1),begPt(1,2),begPt(1,1)+sLength(1,2),begPt(1,2)+sLength(1,1));
        case {'rect', 'rectangle'}
            fprintf(mapHandle,['<g style="stroke-linecap: round; stroke-linejoin: round; stroke-miterlimit: 20; '...
                'fill: none; stroke: %s; stroke-width: %d; stroke-dasharray: %s;">\n'],colorStroke,thickness,dashArray);
            fprintf(mapHandle,'<rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" />\n</g>\n',begPt(1,1),begPt(1,2),sLength(1,2),sLength(1,1));
        case 'circle'
            fprintf(mapHandle,['<g style="stroke-linecap: round; stroke-linejoin: round; stroke-miterlimit: 20; '...
                'fill: none; stroke: %s; stroke-width: %d; stroke-dasharray: %s;">\n'],colorStroke,thickness,dashArray);
            fprintf(mapHandle,'<ellipse cx="%.2f" cy="%.2f" rx="%.2f" ry="%.2f" />\n</g>\n',begPt(1,1)+(.5*sLength(1,2)),begPt(1,2)+(.5*sLength(1,1)),.5*sLength(1,2),.5*sLength(1,1));
        otherwise
            display('Error: Unknown Shape Type');
    end
    
else
    display('Error: Invalid Output');
end