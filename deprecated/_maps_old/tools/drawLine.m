function drawLine(node1,node2,map,edgeColor,edgeArrowColor,edgeWeight,nodeWeight,rxnDir,rxnDirMultiplier)
%drawLine
%
% drawLine(node1,node2,map,edgeColor,edgeArrowColor,edgeWeight,nodeWeight)
%
%INPUTS
% node1             start node
% node2             end node
% map               COBRA map structure
% edgeColor         Line color
% edgeArrowColor    Arrowhead color
% edgeWeight        Line width
%
%OPTIONAL INPUT
% nodeWeight        Node size
% rxnDir
% rxnDirMultiplier
%
%

if nargin < 9
    rxnDirMultiplier = 2;
end

if nargin < 8
    rxnDir = 0;
end

if (nargin < 7)
    rad = 20;
else
    index1 = find(map.molIndex(:) == node1);
    index2 = find(map.molIndex(:) == node2);
    if length(index1) == 1
        rad = nodeWeight(index1);
    elseif length(index2) == 1
        rad = nodeWeight(index2);
    else
        rad = 20;
    end
end

if isnan(node1) || isnan(node2)
    return;
end

[type1, nodePos(:,1)] = getType(node1, map);
[type2, nodePos(:,2)] = getType(node2, map);
p1 = nodePos(:,1);
p2 = nodePos(:,2);

if type1 == 1 && type2 == 1
    drawVector(nodePos(:,1),nodePos(:,2),edgeColor,edgeWeight);
    
elseif type1 == 1 && type2 == 2
    %drawCircle(p2, 3, 'r');
    index1 = find(map.connection(:,1) == node2);
    index2 = find(map.connection(:,2) == node2);
    isend = 0;
    if map.connectionReversible(index1) == 1
        isend = 1;
    end
    if length(index1) == 1 && length(index2) == 1 % case metabolite to center reaction.
        [point1,dir] = c2p(nodePos(:,1),nodePos(:,2),rad);
        drawVector(point1, nodePos(:,2),edgeColor,edgeWeight);
        if isend
            if rxnDir > 0, rad = rad*rxnDirMultiplier; end
			%if rxnDir < 0, rad = rad*rxnDirMultiplier; end - Ines version
            drawArrowhead(point1,dir,rad,edgeArrowColor);
        end
    elseif length(index1) > 1 && length(index2) == 1
        display('blah'); % for some reason this doesn't happen. (metabolite node cannot have more than one point)
    elseif length(index1) == 1 && length(index2) > 1
        othernode = map.connection(index1,2);
        [t3,p3] = getType(othernode, map);
        %%%p3 = p3';
        direction = p2-p3;
        %direction = p3-p2;
        if any(direction~=0)
            dirnorm = direction/(norm(direction));
        else
            dirnorm = zeros(size(direction));
        end
        multiplier = dirnorm' * (p1-p2);
        multiplier = max([.3*norm(p2-p1), multiplier]);
        ptemp = p2 + multiplier*dirnorm;
        distance = norm(ptemp-p1);
        if distance < multiplier
            multiplier = mean([multiplier, distance]);
        end
        ptemp = p2 + multiplier*dirnorm;
        %drawCircle(ptemp,5,'m');
        %drawCircle(p3,5,'g');
        [p1,dir] = c2p(p1,ptemp,rad);
        drawBezier([p2,ptemp,p1],edgeColor,edgeWeight);
        if isend
            if rxnDir > 0, rad = rad*rxnDirMultiplier; end
            drawArrowhead(p1,dir,rad,edgeArrowColor)
        end
    else
        display('oops');
    end
    
elseif type1 == 2 && type2 == 1
    %drawCircle(p1, 3, 'y');
    index1 = find(map.connection(:,1) == node1);
    index2 = find(map.connection(:,2) == node1);
    %         if length(index1) == 1 && length(index2) == 1 % case metabolite to center reaction.
    %             [point2,dir] = c2p(nodePos(:,2),nodePos(:,1),rad);
    %             drawVector(nodePos(:,1), point2,edgeColor,edgeWeight);
    %             drawArrowhead(point2,dir,rad,edgeArrowColor);
    %         elseif length(index1) > 1 && length(index2) == 1
    othernode = map.connection(index2,1);
    [t3,p3] = getType(othernode, map);
    %%%p3 = p3';
    direction = p1-p3;
    if any(direction~=0)
        dirnorm = direction/(norm(direction));
    else
        dirnorm = zeros(size(direction));
    end
    multiplier = dirnorm' * (p2-p1);
    multiplier = max([ .3*norm(p2-p1), multiplier]);
    ptemp = p1 + multiplier*dirnorm;
    distance = norm(ptemp-p2);
    if distance < multiplier
        multiplier = mean([multiplier, distance]);
    end
    ptemp = p1 + multiplier*dirnorm;
    %drawCircle(ptemp,5,'m');
    %drawCircle(p3,5,'g');
    [p2,dir] = c2p(p2,ptemp,rad);
    drawBezier([p1,ptemp,p2],edgeColor,edgeWeight);
    if rxnDir < 0, rad = rad*rxnDirMultiplier; end
    drawArrowhead(p2,dir,rad,edgeArrowColor);
    %         elseif length(index1) == 1 && length(index2) > 1
    %             display('blah2');% for some reason this doesn't happen.
    %         else
    %             display('oops');
    %         end
    
elseif type1 ==2 && type2 == 2
    drawVector(nodePos(:,1),nodePos(:,2),edgeColor,edgeWeight);
else
    display('oops');
    pause;
end
%         % display the reaction label in case of a midpoint
%     if rxnTextWeight ~= 0
%         if type1 == 2
%             index1 = find(map.rxnIndex == node1);
%             if map.rxnLabelPosition(1,index1)~= 0
%                 index2 = find(map.connection(:,1) == node1);
%                 drawText(map.rxnLabelPosition(1,index1),map.rxnLabelPosition(2,index1),map.connectionAbb(index2),rxnTextWeight,'italic;');
%             end
%         end
%         if type2 == 2
%             index1 = find(map.rxnIndex == node1);
%             if map.rxnLabelPosition(1,index1)~= 0
%                 index2 = find(map.connection(:,2) == node2);
%                 drawText(map.rxnLabelPosition(1,index1),map.rxnLabelPosition(2,index1),map.connectionAbb(index2),rxnTextWeight,'italic');
%             end
%         end
%     end

end


function [type, position] = getType(node, map) % you could also have it output a third value which could be the index of the preceding node.
molIndex = find(map.molIndex == node);
rxnIndex = find(map.rxnIndex == node);
if ~isempty(molIndex)
    type = 1; %molecule
    position = map.molPosition(:,molIndex);
elseif ~isempty(rxnIndex)
    type = 2; % reaction.
    position = map.rxnPosition(:,rxnIndex);
    %Add more code here to figure out subtype of reaction node.
else % should never get here, but go ahead and scan for errors.
    display('errorXYZ in drawLine.m');
    %         pause;
end
if numel(molIndex) > 1 || numel(rxnIndex) > 1 % this means that it is not unique.
    display('error2');
    %         pause;
end
end
% move p1 from the center of the circle to the pyrimid of the circle in the
% direction of p2
function [point,dir] = c2p(p1,p2,rad)
dir = p2-p1;
point = p1+rad*(dir/sqrt(dir(1)^2+dir(2)^2));

end

