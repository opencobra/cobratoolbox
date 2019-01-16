function [both, pos, neg] = visualizePathwayInEpistasis(Nall, radius, pathwayNames)
% This function creates a circular network such that all the nodes are
% arranged in a circle. The nodes represent a pathway, the color of the
% node represents whether the interactions within a pathway are none, positive,
% negative, or mixed. The size of the node represents the number of interactions.
% The edges represent which pathways are sharing which
% type of interaction. The color of the edge represents if the interactions
% are positive negative or mixed. The with of the edge represent the total number
% of interactions between any two given pathways.
%
% USAGE:
%
%     [both,pos,neg]=visualizePathwayInEpistasis(Nall,radius,pathwayNames)
%
% INPUT:
%     Nall:          a structure representing the epistatic interaction networks:
%                    Nall.pos: a square matrix representing number of positive interactions shared by any two pathways.
%                    Nall.neg: a square matrix representing number of negative interactions shared by any two pathways.
%     radius:        radius of the generic circles for clock diagram.
%     pathwayNames:  subSystem names corresponding to matrices in Nall
%                    structure
%
% OUTPUT:
%     both:          contains both positive and negative interactions
%     pos:           contains only positive interactions
%     neg:           contains only negative interactions
%
% NOTE:
%    See figures in following publication:
%    Joshi CJ and Prasad A, 2014, "Epistatic interactions among metabolic genes
%    depend upon environmental conditions", Mol. BioSyst., 10, 2578-2589.
%
% .. Authors:
%      - Chintan Joshi 10/26/2018
%      - Chintan Joshi; made modifications to label the nodes using pathway names, 10/26/2018

if nargin < 2
    radius = 40;
end

pos = Nall.pos;
neg = Nall.neg;
both = Nall.pos + Nall.neg;
indn = []; indp = []; mix_ = [];
ps = find(diag(pos) ~= 0); ns = find(diag(neg) ~= 0); nps = find(diag(both) ~= 0);
if ~isempty(nps) && ~isempty(ps)
    indp = intersect(ps, nps);
end
if ~isempty(nps) && ~isempty(ns)
    indn = intersect(ns, nps);
end
if isempty(indn)
    p_ = indp; n_ = []; mix_ = [];
elseif isempty(indp)
    p_ = []; n_ = indn; mix_ = [];
else
    p_ = setdiff(indp, indn); n_ = setdiff(indn, indp); mix_ = intersect(indp, indn);
end
% keeps only those that have both but not either type of interactions alone
c = 0;
for i = 1:length(both)
    for j = 1:length(both)
        if both(i, j) ~= 0 && pos(i, j) ~= 0 && neg(i, j) ~= 0
            c = c + 1;
            indm1(c, 1) = i;
            indm2(c, 1) = j;
        end
    end
end
% conversion to circular cordinates
theta = linspace(0, 2 * pi, length(pos) + 1);
theta = theta(1:end - 1);
[x, y] = pol2cart(theta, 1);
tx = x; ty = y;
x = x * 0.9; y = y * 0.9;
[indp1, indp2] = ind2sub(size(pos), find(pos(:)));
[indn1, indn2] = ind2sub(size(neg), find(neg(:)));
gc = [0.23 0.44 0.34];
rc = [0.58 0.39 0.39];
yc = [255 204 102] / 255;
subplot(3, 3, 5);
% plot the structure of the clock diagram
plot(x, y, '.', 'MarkerEdgeColor', [150 150 150]./255, 'markersize', 1); hold on
% label the the texts for each point in clock diagram
for i = 1:length(x)
    textAngle = (i - 1) * 360 / length(x);  % calculate the angle for text
    text(tx(i), ty(i), pathwayNames(i), 'Rotation', textAngle);
end
if ~isempty(indp1)
    arrayfun(@(p, q)line([x(p), x(q)], [y(p), y(q)], 'Color', gc, 'LineWidth', pos(p, q)), indp1, indp2);  % plot inter-pathway positive interactions
end
if ~isempty(indn1)
    arrayfun(@(p, q)line([x(p), x(q)], [y(p), y(q)], 'Color', rc, 'LineWidth', neg(p, q)), indn1, indn2);  % plot inter-pathway negative interactions
end
if exist('indm1')
    arrayfun(@(p, q)line([x(p), x(q)], [y(p), y(q)], 'Color', yc, 'LineWidth', both(p, q)), indm1, indm2);  % plot inter pathway both types of interactions
end
% plot intra-pathway interactions
plot(x, y, '.', 'MarkerEdgeColor', [150 150 150]./255, 'markersize', radius);
plot(x(p_), y(p_), '.', 'MarkerEdgeColor', gc, 'markersize', radius + length(p_) * 3);
plot(x(n_), y(n_), '.', 'MarkerEdgeColor', rc, 'markersize', radius + length(n_) * 3);
plot(x(mix_), y(mix_), '.', 'MarkerEdgeColor', yc, 'markersize', radius + length(mix_) * 3);
set(gca, 'DataAspectRatio', [1 1 1]);

axis equal off;
hold off;
