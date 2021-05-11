function gscatter3(x,y,z,group,clr,sym,siz,doleg,xnam,ynam,znam)
%GSCATTER3  3D Scatter plot with grouping variable
%   gscatter3(x,y,z,group,clr,sym,siz,doleg,xnam,ynam,znam)   
%   Designed to work in the exactly same fashion as statistics toolbox's gscatter
%   This function does not require the statistics toolbox installed.
%   
%
%   See also GSCATTER, GSCATTER3B
%
%   Copyright 2017 Gustavo Ferraz Trinade.


% Set number of groups 
cgroups = unique(group);

cmap = lines(size(cgroups,1));

% Input variables
if (nargin < 5),  clr = lines(max(size(cgroups))); end
if (nargin < 6) || isempty(sym), sym = 'odphs><v^odphs><v^odphs><v^odphs><v^'; end
if (nargin < 7),  siz = 100;           end
if (nargin < 8),  doleg = 'on';        end
if (nargin < 9),  xnam = inputname(1); end
if (nargin < 10), ynam = inputname(2); end
if (nargin < 11), znam = inputname(3); end

% Get current axes
a = gca;
hold(a,'on')

% Plot
for i=1:max(size(cgroups))    
    
    if iscell(cgroups) || ischar(cgroups)
        gi = find(strcmp(group,cgroups(i)));
    else
        gi = find(group == cgroups(i));
    end   
    
    scatter3(a,x(gi),y(gi),z(gi),siz,clr(i,:),'filled',sym(i)); 
end

% Axes labels and legend (this bit slows down the function)
xlabel(a,xnam);
ylabel(a,ynam);    
zlabel(a,znam);    

if strcmp(doleg,'on')
    if iscell(cgroups) || ischar(cgroups)
        legend(cgroups')
    else
        legend(num2str(cgroups'))
    end
end
    
    
end
