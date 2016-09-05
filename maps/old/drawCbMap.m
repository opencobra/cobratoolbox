function options = drawCbMap(map,options,varargin)
%Draws a map with the specified optional parameters
%
% drawCbMap(map,options)
%
%INPUTS
% map                       COBRA map structure
%
%OPTIONAL INPUTS
% options                  Structure containing optional parameters
%   nodeWeight              Size of primary metabolite nodes  
%   nodeWeightSecondary     Size of secondary metabolite nodes
%   nodeColor               Color of metabolite nodes
%   edgeColor               Color of reaction arrows2
%   edgeArrowColor          Color of reaction arrowheads
%   edgeWeight              Width of reaction arrows
%   textSize                Font size of metabolite text
%   textColor               Text color for metaboltes
%   rxnTextSize             Font size of reaction text
%   rxnTextColor            Text color for reactions
%   otherTextColor          Color of other text
%   fileName                Name of output file
%
% varargin                  optional parameter name / parameter value pairs
%
%OUTPUT
% Displays map in a matlab figure ('matlab') or target.svg ('svg') file
% depending on value of CB_MAP_OUTPUT.
% options                  Structure containing optional parameters
%
%
% Turner Conrad     6/12/12     Added rxnTextSize default (8) to fix error 
%                               in writing reaction texts to .svg

global mapHandle
global CB_MAP_OUTPUT

%check for render output
if ~exist('CB_MAP_OUTPUT', 'var') || isempty(CB_MAP_OUTPUT)
    error('No render target specified.  Call changeCbMapOutput(outputFormat)');
end


if (nargin < 2)
    options = [];
end

if mod(length(varargin),2)==0
    for i=1:2:length(varargin)-1
        switch lower(varargin{i})
            case 'nodeweight', options.nodeWeight = cell2mat(varargin(i+1));
            case 'nodecolor', options.nodeColor = cell2mat(varargin(i+1));
            case 'edgeweight', options.edgeWeight = cell2mat(varargin(i+1));
            case 'edgecolor', options.edgeColor = cell2mat(varargin(i+1));
            case 'edgearrowcolor', options.edgeArrowColor = cell2mat(varargin(i+1));
            case 'textsize', options.textSize = cell2mat(varargin(i+1));
            case 'textcolor', options.textColor = cell2mat(varargin(i+1));
            case 'othertextsize', options.otherTextSize = cell2mat(varargin(i+1));
            case 'othertextcolor', options.otherTextColor = cell2mat(varargin(i+1));
            case 'filename', options.fileName = varargin{i+1};
            otherwise, options.(varargin{i}) = varargin{i+1};
        end
    end
else
    error('Invalid number of parameters/values');
end

%%%% Compelete the missing parts of the option
nNodes = size(map.molName,1);
nEdges = size(map.connection,1);
%Node size
if ~isfield(options,'nodeWeight')
    options.nodeWeight = ones(nNodes,1)*15;
    if strcmp(CB_MAP_OUTPUT,'svg')
        options.nodeWeight = ones(nNodes,1)*25;
    end
end

if ~isfield(options,'nodeWeightSecondary')
    options.nodeWeightSecondary = ones(nNodes,1)*10;
    if strcmp(CB_MAP_OUTPUT,'svg')
        options.nodeWeightSecondary = ones(nNodes,1)*15;
    end
end
%Node color
if ~isfield(options,'nodeColor')
    options.nodeColor = repmat([255,160,128],nNodes,1);
end
%Edge color
if ~isfield(options,'edgeColor')
    options.edgeColor = repmat([0,191,255],nEdges,1);
end
%Arrowhead color
if ~isfield(options,'edgeArrowColor')
    options.edgeArrowColor = repmat([0,0,255],nEdges,1);
end
%Edge thickness
if ~isfield(options,'edgeWeight')
    options.edgeWeight = ones(nEdges,1)*2;
    if strcmp(CB_MAP_OUTPUT,'svg')
        options.edgeWeight = ones(nEdges,1)*4;
    end
end
%Font Size
if ~isfield(options,'textSize')
    options.textSize = ones(max(nNodes,nEdges),1)*12;
    if strcmp(CB_MAP_OUTPUT,'svg')
        options.textSize = ones(max(nNodes,nEdges),1)*6;
    end
end
%Font Color
if ~isfield(options,'textColor')
    options.textColor = zeros(nNodes,3);
end

% if ~isfield(options,'otherTextSize')
%     options.otherTextSize = ones(size(map.text,1),1)*12;
%     if strcmp(CB_MAP_OUTPUT,'svg')
%         options.otherTextSize = ones(size(map.text,1),1)*135;
%     end
% end

if ~isfield(options,'otherTextColor')
    options.otherTextColor= zeros(size(map.text,1),3);
end

nodeWeight = options.nodeWeightSecondary;
nodeWeight(strcmp(map.molPrime,'Y')) = options.nodeWeight(strcmp(map.molPrime,'Y'));

if ~isfield(options,'fileName')
    options.fileName = 'target.svg';
end

if ~isfield(options,'rxnDir')
    options.rxnDir = zeros(size(map.connectionAbb,1),1);
end

if ~isfield(options,'rxnDirMultiplier')
    options.rxnDirMultiplier = 2;
end

%%%%%%%% initialization
if strcmp(CB_MAP_OUTPUT,'matlab')    % use matlab to draw the map
    clf; % this was in line 41 before
    % setting the color bar
    figure(1);colormap(cool(100))
    colorbar('location','southoutside');
    axis equal;
    hold on
elseif strcmp(CB_MAP_OUTPUT, 'java')
    % use Java/OpenGL to draw the map
    plotcbmap;
    % send the transformation coordinates
    R=map.molPosition';
    R=sort(R);
    a=max(R);
    b=min(R);
    xmax=a(1,1);
    xmin=b(1,1);
    ymax=a(1,2);
    ymin=b(1,2);
    settrans(mapHandle,xmax,xmin,ymax,ymin);
elseif strcmp(CB_MAP_OUTPUT, 'svg')
    %check fileName extension
    if isempty(regexp(lower(options.fileName),'.svg$'))
        options.fileName = strcat(options.fileName,'.svg');
    end
    textPos = (map.textPos);
    x1 = min(map.molPosition(1,:));
    if min(textPos(:,1))<x1
        x1 = min(textPos(:,1));
    end
    y1 = min(map.molPosition(2,:));
    if min(textPos(:,2))<y1
        y1 = min(textPos(:,2));
    end
    x2 = max(map.molPosition(1,:));
    if max(textPos(:,1))>x2
        x2 = max(textPos(:,1));
    end
    y2 = max(map.molPosition(2,:));
    if max(textPos(:,2))>y2
        y2 = max(textPos(:,2));
    end
    if isfield(options,'colorScale')
        numColorBins = size(options.colorScale,1);
        colorScaleWidth = 0.25*(x2-x1);
        binWidth = colorScaleWidth/numColorBins;
        colorScaleHeight = 0.05*colorScaleWidth;
        colorScaleBuffer = colorScaleHeight*1.5;
        y2 = y2+colorScaleBuffer; %add buffer for scale
    end
    if isfield(options,'fluxVarColor')
        colorScaleHeight = 0.0125*(x2-x1);
        colorScaleBuffer = colorScaleHeight*1.5;
        colorWidth = 0.025*(x2-x1);
        y2 = y2+colorScaleBuffer;
    end
    [x1,y1,x2,y2] = deal(x1-200, y1-200, x2+200, y2+200); % add buffer
    SF = .25;
    mapHandle = fopen(options.fileName, 'w');
    fprintf(mapHandle, '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n');
    fprintf(mapHandle,'<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN" "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">\n');
    fprintf(mapHandle,'<svg height="%+.2f" width="%+.2f" viewBox="%+.2f %+.2f %+.2f %+.2f" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">\n',(y2-y1+20)*SF,(x2-x1+20)*SF,(x1-10)*SF,(y1-10)*SF,(x2-x1+0)*SF,(y2-y1+20)*SF);
    fprintf(mapHandle,'<g transform="scale(%5.3f)">\n',SF);
   
    %Add Scale
    if isfield(options,'overlayType')
        for i=1:numColorBins
            color = strcat('rgb(',num2str(options.colorScale(i,1)),',',num2str(options.colorScale(i,2)),',',num2str(options.colorScale(i,3)),')');
            fprintf(mapHandle,'<g style="stroke-linecap: round; stroke-linejoin: round; stroke-miterlimit: 20; fill: %s; ">\n',color);
            fprintf(mapHandle,'<rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" />\n</g>\n',x2-colorScaleWidth-200*2+(binWidth*(i-1)),y2-colorScaleHeight*1.25,binWidth,colorScaleHeight);
        end
        fprintf(mapHandle, '<g style="font-family: sans; stroke: none; text-anchor:end">\n');
        fprintf(mapHandle,'<text style="fill: rgb(0,0,0); text-rendering: optimizeLegibility;" x="%.2f" y="%.2f" font-size="%dpx">%s</text>\n</g>\n',x2-colorScaleWidth-200*2-0.25*colorScaleHeight,y2-colorScaleHeight*.4,colorScaleHeight,['Scale: ' options.scaleTypeLabel '    ' options.overlayType ': ' options.overlayLB]); 
        fprintf(mapHandle, '<g style="font-family: sans; stroke: none; text-anchor:start">\n');
        fprintf(mapHandle,'<text style="fill: rgb(0,0,0); text-rendering: optimizeLegibility;" x="%.2f" y="%.2f" font-size="%dpx">%s</text>\n</g>\n',x2-200*2+0.25*colorScaleHeight,y2-colorScaleHeight*.4,colorScaleHeight,[options.overlayUB]); 
    end
    if isfield(options,'fluxVarColor')
        colorTextLabel = {'Bidirectional / reversible:', 'Unidirectional / reversible forward:', 'Unidirectional / reversible reverse:', 'Unidirectional / irreversible:'};
        color{1} = strcat('rgb(',num2str(options.fluxVarColor.biDirColor(1)),',',num2str(options.fluxVarColor.biDirColor(2)),',',num2str(options.fluxVarColor.biDirColor(3)),')');
        color{2} = strcat('rgb(',num2str(options.fluxVarColor.uniDirFwdColor(1)),',',num2str(options.fluxVarColor.uniDirFwdColor(2)),',',num2str(options.fluxVarColor.uniDirFwdColor(3)),')');
        color{3} = strcat('rgb(',num2str(options.fluxVarColor.uniDirRevColor(1)),',',num2str(options.fluxVarColor.uniDirRevColor(2)),',',num2str(options.fluxVarColor.uniDirRevColor(3)),')');
        color{4} = strcat('rgb(',num2str(options.fluxVarColor.uniDirIrrColor(1)),',',num2str(options.fluxVarColor.uniDirIrrColor(2)),',',num2str(options.fluxVarColor.uniDirIrrColor(3)),')');
        for i=2:3:11
            fprintf(mapHandle, '<g style="font-family: sans; stroke: none; text-anchor:end">\n');
            fprintf(mapHandle,'<text style="fill: rgb(0,0,0); text-rendering: optimizeLegibility;" x="%.2f" y="%.2f" font-size="%dpx">%s</text>\n</g>\n',i*(x2-x1)/12,y2-colorScaleHeight*.4,colorScaleHeight,colorTextLabel{ceil(i/3)});            
            fprintf(mapHandle,'<g style="stroke-linecap: round; stroke-linejoin: round; stroke-miterlimit: 20; fill: %s; ">\n',color{ceil(i/3)});
            fprintf(mapHandle,'<rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" />\n</g>\n',i*(x2-x1)/12,y2-colorScaleHeight*1.25,colorWidth,colorScaleHeight);
        end
    end
end

%%%%% actual map drawing code
% draw other shapes
if isfield(map,'shapeThickness')
    for i = 1:size((map.shapeThickness),1)
        drawShape(map.shapeType(i,1),map.shapePos(i,1:2),map.shapeSize(i,1:2),map.shapeColor(i,1:3),map.shapeThickness(i,1),map.shapeStyle(i,1));
    end
end
% draw the connection segments traversing through the connection matrix
for i = 1:(size((map.connection),1))
    drawLine(map.connection(i,1),map.connection(i,2),map,options.edgeColor(i,:),options.edgeArrowColor(i,:),options.edgeWeight(i),nodeWeight,options.rxnDir(i),options.rxnDirMultiplier);
end
% draw the circles representing molecules
for i = 1:size((map.molPosition),2)
    drawCircle(map.molPosition(:,i),nodeWeight(i),options.nodeColor(i,:));
end
% draw texts
for i = 1:length(map.text)
    textFont =map.textFont{i};
    if regexp(textFont,'@')
        [textFont, textSize] = strtok(textFont,'@');
        textSize = str2num(regexprep(textSize,'@',''));
    elseif(map.textSize(i) >= 60)
        textSize = 60;
    else
        textSize = map.textSize(i);
    end
    if find(regexp(textFont,'Italic'))
        textStyle = 'italic;';
    else
        textStyle = '';
    end
    %textFont
    % if find(regexp(textFont,' B')) || find(regexp(textFont(end),'B'))
    if (find(regexp(textFont,'B')))
        textWeight = 'bold';
        textFont = regexprep(textFont,' B','');
    else
        textWeight = '';
    end
    if isfield(options,'otherTextSize'), textSize = options.otherTextSize(i); end
    drawText(map.textPos(i,1),map.textPos(i,2),map.text{i,1},textSize,textStyle,options.otherTextColor(i,:),lower(textFont),textWeight,true);
end
% Write Metabolite Label
for i = 1:size((map.molPosition),2)  
    % write the labels for molecules
    if(options.textSize(i) ~= 0)
        drawText(map.molLabelPos(i,1),map.molLabelPos(i,2),map.molAbbreviation{i},options.textSize(i),'',options.textColor(i,:));
    end
end
% Write Reaction Label
for i = 1:size(map.rxnLabelPosition,2)
    if ~any(isnan(map.rxnLabelPosition(:,i)))
      if isfield(options, 'rxnTextSize')
        drawText(map.rxnLabelPosition(1,i),map.rxnLabelPosition(2,i),map.connectionAbb{find(map.rxnIndex(i)==map.connection,1)},options.rxnTextSize(i),'italic');
      else
        drawText(map.rxnLabelPosition(1,i),map.rxnLabelPosition(2,i),map.connectionAbb{find(map.rxnIndex(i)==map.connection,1)},8,'italic');
      end
    end
end

if strcmp(CB_MAP_OUTPUT,'matlab')
    hold off;
elseif strcmp(CB_MAP_OUTPUT,'java')
    
elseif strcmp(CB_MAP_OUTPUT,'svg')

    fprintf(mapHandle,'</g>\n');
    fprintf(mapHandle,'</svg>\n');
    fclose(mapHandle);
    display('Document Written')
end