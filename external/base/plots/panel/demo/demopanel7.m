
% Panel gives you figure-wide control over text properties.
%
% (a) Create a grid of panels.
% (b) Change some text properties.



%% (a)

% create a grid
p = panel();
p.pack(2, 2);

% select all
p.select('all');





%% (b)

% if we set the properties on the root panel, they affect
% all its children and grandchildren.
p.fontname = 'Courier New';
p.fontsize = 10;
p.fontweight = 'normal'; % this is the default, anyway

% however, any child can override them, and the changes
% affect just that child (and its descendants).
p(2,2).fontsize = 14;



