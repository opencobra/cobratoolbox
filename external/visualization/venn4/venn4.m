function vennfig = venn4(n,varargin)
%% Draw venn diagram with two to four sets with optional text labels.
% User can specify the number of sets to draw (maximum four) and label each
% set and the intersectional regions between sets.
% Man Ho Wong (2022).
%
% Input : n [positive integer]
%           Number of sets to draw
%         sets [string | char | cellstr | numeric]
%              An array of set names in left-to-right order
%         labels [string | char | cellstr | numeric]
%                An array of label names for labeling each section;
%                Elements in the array must follow the following order:
%                For diagram with Set A and B, labels for 3 sections are
%                A, B and A&B.
%                For diagram with Set A, B and C, labels for 7 sections are
%                A, B, C, A&B, A&C, B&C and A&B&C.
%                For diagram with Set A, B, C and D, labels for 15 sections
%                are A, B, C, D, A&B, A&C, A&D, B&C, B&D, C&D, A&B&C, A&B&D
%                , A&C&D, B&C&D, A&B&C&D.
%                Any extra labels will be ignored.
%         colors [rows of RGB triplet]
%                Color map for fill colors in left-to-right order.
%                e.g. [1 0 0; 0 1 0; 0 0 1] represents red, green, blue;
%                If number of colors is less than n, colors will be
%                repeated.
%         alpha [0 to 1]
%               Fill color alpha; 0 = fully transparent.
%         edgeC [RGB triplet]
%               Edge color (only effective when 'edgeW' is > 0).
%         edgeW [positive number]
%               Edge width (By default, there is no edge)
%         labelC [RGB triplet]
%                Color of section labels.
%         fontSize [positive number]
%                Font size for the text (default is adjusted based on number of sets).
%
% Output : A Veenn diagram will be drawn on a new figure.
%          vennfig (optional): A handle to the figure.
%
% Examples: see README.md

% default set names
s = repmat(" ",4,1);   % white space as spaceholder
% default labels
v = repmat(" ",15,1);  % white space as spaceholder
cmap = lines(4);  % color map

% validation functions
validColor = @(x) ~isempty(validatecolor(x));
validColors = @(x) ~isempty(validatecolor(x,'multiple')) || validColor;
validNum = @(x) isnumeric(x) && isscalar(x);
validPosNum = @(x) validNum(x) && (x>0);
validPosFrc = @(x) validNum(x) && (x>=0) && (x<=1);

% Build input parser
p = inputParser;
addParameter(p,'sets',s);
addParameter(p,'labels',v);
addParameter(p,'colors',cmap,validColors);
addParameter(p,'alpha', 0.3, validPosFrc);
addParameter(p,'edgeC', 'w', validColor);
addParameter(p,'edgeW', [], validPosNum);
addParameter(p,'labelC', 'k', validColor);
addParameter(p,'fontSize', [], validPosNum); % Optional fontSize input

% Parse input
parse(p,varargin{:});
sets = p.Results.sets;
labels = p.Results.labels;
colors = p.Results.colors;
alpha = p.Results.alpha;
edgeC = p.Results.edgeC;
edgeW = p.Results.edgeW;
labelC = p.Results.labelC;
fontSize = p.Results.fontSize;

% Default font sizes based on the number of sets
if isempty(fontSize)
    switch n
        case 2
            fontSizeSets = 28;
            fontSizeIntersections = 24;
        case 3
            fontSizeSets = 26;
            fontSizeIntersections = 22;
        case 4
            fontSizeSets = 24;
            fontSizeIntersections = 20;
        otherwise
            error('n must be an integer between 2 and 4.');
    end
else
    % If user provides a fontSize, use it for both sets and intersections, scaled appropriately
    fontSizeSets = fontSize + 2;  % Slightly larger for set labels
    fontSizeIntersections = fontSize;
end

% repeat colors if number of colors given is less than n
if height(colors) < n
    colors = repmat(colors,n/height(colors),1);
end

% replace spaceholders in f and v with user inputs
%   if user didn't provide enough labels, spaceholders will remain
%   if user provided more labels than needed, extra labels will be ignored
%   thus, the function accepts any number of inputs without causing errors
fRange = min([4 length(sets)]);
for i = 1:fRange
    s(i) = string(sets(i));
end
vRange = min([15 length(labels)]);
for i = 1:vRange
    v(i) = string(labels(i));
end

% for code readability, assign v to variables named by letters
switch n
    case 2
        A = v(1);
        B = v(2);
        AB = v(3);
    case 3
        A = v(1);
        B = v(2);
        C = v(3);
        AB = v(4);
        AC = v(5);
        BC = v(6);
        ABC = v(7);
    case 4
        A = v(1);
        B = v(2);
        C = v(3);
        D = v(4);

        AB = v(5);
        AC = v(6);
        AD = v(7);
        BC = v(8);
        BD = v(9);
        CD = v(10);

        ABC = v(11);
        ABD = v(12);
        ACD = v(13);
        BCD = v(14);

        ABCD = v(15);
end

% figure settings
vennfig = figure('Position',[20 20 800 450],'Color','w');
axis off
daspect([1,1,1])


% circle location and radius
X=1;
Y=1;
r=1;

% draw venn diagram based on number of sets
switch n
    case 2
        xlim([-0.5 4])
        circle(X,Y,r,colors(1,:),alpha);
        circle(X+r,Y,r,colors(2,:),alpha);
        % draw circle A edge again (so it's not covered by circle B)
        circle(X,Y,r,[0 0 0],0);

        text(1,2.2,s(1),'HorizontalAlignment','right', 'FontSize', fontSizeSets, 'FontWeight', 'bold');
        text(2,2.2,s(2),'HorizontalAlignment','left', 'FontSize', fontSizeSets, 'FontWeight', 'bold');

        text(0.5,1,A,'HorizontalAlignment','center', 'FontSize', fontSizeIntersections, 'FontWeight', 'bold');
        text(2.5,1,B,'HorizontalAlignment','center', 'FontSize', fontSizeIntersections, 'FontWeight', 'bold');
        text(1.5,1,AB,'HorizontalAlignment','center', 'FontSize', fontSizeSets, 'FontWeight', 'bold');

    case 3
        xlim([-0.5 4])
        circle(X,Y,r,colors(1,:),alpha);
        circle(X+r,Y,r,colors(2,:),alpha);
        circle(X+r/2,Y+r,r,colors(3,:),alpha);

        text(1.5,3.2,s(1),'HorizontalAlignment','center', 'FontSize', fontSizeSets, 'FontWeight', 'bold');
        text(-0.1,1,s(2),'HorizontalAlignment','right', 'FontSize', fontSizeSets, 'FontWeight', 'bold');
        text(3.1,1,s(3),'HorizontalAlignment','left', 'FontSize', fontSizeSets, 'FontWeight', 'bold');

        text(1.5,2.4,A,'HorizontalAlignment','center', 'FontSize', fontSizeIntersections, 'FontWeight', 'bold');
        text(0.5,1,B,'HorizontalAlignment','center',  'FontSize', fontSizeIntersections, 'FontWeight', 'bold');
        text(2.5,1,C,'HorizontalAlignment','center',  'FontSize', fontSizeIntersections, 'FontWeight', 'bold');

        text(1,1.75,AB,'HorizontalAlignment','center',  'FontSize', fontSizeIntersections, 'FontWeight', 'bold');
        text(1.5,0.75,BC,'HorizontalAlignment','center',  'FontSize', fontSizeIntersections, 'FontWeight', 'bold');
        text(2,1.75,AC,'HorizontalAlignment','center',  'FontSize', fontSizeIntersections, 'FontWeight', 'bold');

        text(1.5,1.4,ABC,'HorizontalAlignment','center', 'FontSize', fontSizeSets, 'FontWeight', 'bold');

    case 4

        xlim([-3.5 4])

        % Draw ellipses for the sets
        % Ellipse A and B
        [X,Y] = getEllipse(0.8,1.6,[-1.1 1]);
        patch(X,Y,colors(1,:),'FaceAlpha',alpha,'LineStyle','none');   % Set A
        patch(X+1,Y+0.5,colors(2,:),'FaceAlpha',alpha,'LineStyle','none'); % Set B

        % Ellipse C and D
        [X,Y] = getEllipse(1.6,0.8,[1.1 1]);
        patch(X-1,Y+0.5,colors(3,:),'FaceAlpha',alpha,'LineStyle','none'); % Set C
        patch(X,Y,colors(4,:),'FaceAlpha',alpha,'LineStyle','none');   % Set D

        % Draw ellipse edges separately to ensure they're not covered by others
        patch(X-1,Y+0.5,'w','FaceAlpha',0,'LineStyle','none');  % Set C edge
        patch(X,Y,'w','FaceAlpha',0,'LineStyle','none');        % Set D edge
        [X,Y] = getEllipse(0.8,1.6,[-1.1 1]);
        patch(X,Y,'w','FaceAlpha',0,'LineStyle','none');        % Set A edge
        patch(X+1,Y+0.5,'w','FaceAlpha',0,'LineStyle','none');  % Set B edge

        % Set Labels (A, B, C, D)
        text(-3,3,s(1),'HorizontalAlignment','right', 'FontSize', fontSizeSets, 'FontWeight', 'bold');  % Set A
        text(-2,3.5,s(2),'HorizontalAlignment','right', 'FontSize', fontSizeSets, 'FontWeight', 'bold'); % Set B
        text(2,3.5,s(3),'HorizontalAlignment','left', 'FontSize', fontSizeSets, 'FontWeight', 'bold');   % Set C
        text(3,3,s(4),'HorizontalAlignment','left', 'FontSize', fontSizeSets, 'FontWeight', 'bold');     % Set D

        % Intersection Labels
        text(-2,1.5,A,'HorizontalAlignment','center', 'FontSize', fontSizeIntersections, 'FontWeight', 'bold');  % A only
        text(2,1.5,D,'HorizontalAlignment','center', 'FontSize', fontSizeIntersections, 'FontWeight', 'bold');   % D only
        text(-1,2.75,B,'HorizontalAlignment','center', 'FontSize', fontSizeIntersections, 'FontWeight', 'bold'); % B only
        text(1,2.75,C,'HorizontalAlignment','center', 'FontSize', fontSizeIntersections, 'FontWeight', 'bold');  % C only

        % Pairwise Intersections
        text(-1.4,2.25,AB,'HorizontalAlignment','center', 'FontSize', fontSizeIntersections, 'FontWeight', 'bold'); % A&B
        text(1.4,2.25,CD,'HorizontalAlignment','center', 'FontSize', fontSizeIntersections, 'FontWeight', 'bold');  % C&D
        text(0,2.25,BC,'HorizontalAlignment','center', 'FontSize', fontSizeIntersections, 'FontWeight', 'bold');    % B&C
        text(-1.25,0.5,AC,'HorizontalAlignment','center', 'FontSize', fontSizeIntersections, 'FontWeight', 'bold'); % A&C
        text(1.25,0.5,BD,'HorizontalAlignment','center', 'FontSize', fontSizeIntersections, 'FontWeight', 'bold');  % B&D
        text(0,-0.4,AD,'HorizontalAlignment','center', 'FontSize', fontSizeIntersections, 'FontWeight', 'bold');    % A&D

        % Triple Intersections
        text(-0.75,1.5,ABC,'HorizontalAlignment','center', 'FontSize', fontSizeIntersections, 'FontWeight', 'bold'); % A&B&C
        text(0.75,1.5,BCD,'HorizontalAlignment','center', 'FontSize', fontSizeIntersections, 'FontWeight', 'bold');  % B&C&D
        text(-0.4,0.05,ACD,'HorizontalAlignment','center', 'FontSize', fontSizeIntersections, 'FontWeight', 'bold'); % A&C&D
        text(0.4,0.05,ABD,'HorizontalAlignment','center', 'FontSize', fontSizeIntersections, 'FontWeight', 'bold');  % A&B&D

        % Quadruple Intersection (A&B&C&D)
        text(0,0.5,ABCD,'HorizontalAlignment','center', 'FontSize', fontSizeSets, 'FontWeight', 'bold');   % A&B&C&D

    otherwise
        disp('n must be an integer between 2 and 4.')
end

% Set label color
h=vennfig.findobj('Type','text'); % Get all text objects
for i = 1:length(h)
    if ~ ismember(h(i).String,sets)
        h(i).Color = labelC;
    end
end

% Configure edges
if n > 3
    obj = 'patch';
else
    obj = 'rectangle';
end
h=vennfig.findobj('Type',obj);
set(h,'EdgeColor',edgeC);
if ~isempty(edgeW)
    set(h,'LineStyle','-');
    set(h,'LineWidth',edgeW);
end

%%
    function [x,y] = getEllipse(r1,r2,C)
        beta = linspace(0,2*pi,100);
        x = r1*cos(beta) - r2*sin(beta);
        y = r1*cos(beta) + r2*sin(beta);
        x = x + C(1,1);
        y = y + C(1,2);
    end

%%
    function circle(cX,cY,r,faceC,alpha)
        x = cX-r;
        y = cY-r;
        d = 2*r;
        h = rectangle('Position', [x y d d], 'Curvature', [1, 1], 'FaceColor', faceC, 'EdgeColor', faceC);
        % Adjust the alpha using the alpha function
        h.FaceAlpha = alpha;
        % Ensure the axes are set to equal scaling for proper aspect ratio
        axis equal;
    end

end
