function spyc(sA, cmap, pb, newFig);

% SPYC Visualize sparsity pattern with color-coded scale.
%   SPYC(S) plots the color-coded sparsity pattern of the matrix S.
%
%   SPYC(S,CMAP) plots the sparsity pattern of the matrix S USING
%                    COLORMAP CMAP.
%
%   SPYC(S,CMAP,PB) allows turning off the display of a colorbar by passing
%                   flag PB=0
%

if nargin < 4
    newFig = true;
end

if nargin < 1 | nargin > 3 && ~isempty(cmap)
    error('spyc:InvalidNumArg', 'spyc takes one to three inputs')
    return
end

if isempty(sA)
    error('spyc:InvalidArg', 'sparse matrix is empty')
    return
end

if nargin > 1 && ~isempty(cmap)
    % colorspy does not check whether your colormap is valid!
    if ~isnumeric(cmap)
        cmap = colormap(cmap);
    end
else
    cmap = flipud(colormap('autumn'));
end

if nargin < 3 || isempty(pb)
    pb = 1;
end

indx = find(sA);
[Nx Ny] = size(sA);
sA = full(sA(indx));
ns = length(indx);
[ix iy] = ind2sub([Nx Ny], indx);

imap = round((sA - min(sA)) / (max(sA) - min(sA))) + 1;

if newFig
    h = figure;
    hold on;
end
colormap(cmap)
scatter(iy, ix, [], sA, 'Marker', '.', 'SizeData', 0.4 * 1e3 * (abs(sA) / max(max(abs(sA)))))
set(gca, 'ydir', 'reverse')
set(gca, 'FontSize', 6);
axis equal;
xlabel({'Number of columns/reactions'; ['(' num2str(ns) ' nonzero elements)']});
ylabel(['Number of rows/metabolites']);
axis([0 Ny 0 Nx])
box on

if pb
    colorbar
end

c = colorbar;
set(c, 'FontSize', 12);
