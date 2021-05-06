function gscatter3b(x,y,z,group,clr,sym,siz,doleg,xnam,ynam,znam)
%GSCATTER3B  3D Scatter plot with grouping variable
%   gscatter3(x,y,z,group,clr,sym,siz,doleg,xnam,ynam,znam)   
%   Designed to work in the exactly same fashion as statistics toolbox's
%   gscatter. Differently from GSCATTER3, this function requires the
%   statistics toolbox installed.
%   
%
%   See also GSCATTER, GSCATTER3
%
%   Copyright 2017 Gustavo Ferraz Trinade.


% Set number of groups 
cgroups = unique(group);

cmap = lines(size(cgroups,1));

% Input variables
if (nargin < 5),  clr = lines(max(size(cgroups))); end
if (nargin < 6) || isempty(sym), sym = '.'; end
if (nargin < 7),  siz = 20;           end
if (nargin < 8),  doleg = 'on';        end
if (nargin < 9),  xnam = inputname(1); end
if (nargin < 10), ynam = inputname(2); end
if (nargin < 11), znam = inputname(3); end

% Get current axes
a = gca;
hold(a,'on')

% call GSCATTER and capture output argument (handles to lines)
h = gscatter(x, y, group,clr,sym,siz,doleg,xnam,ynam);


for i = 1:max(size(cgroups))
        if iscell(cgroups) || ischar(cgroups)
            gi = find(strcmp(group,cgroups(i)));
        else
            gi = find(group == cgroups(i));
        end
    
        set(h(i), 'ZData', z( gi ));
end
zlabel(a,znam);    
view(3)

    
    
end
