
% You can repack Panels from the command line.
%
% (a) Create a grid of panels, and show something in them.
% (b) Repack some of them, as if at the command line.



%% (a)

% create a 2x2 grid in gcf.
p = panel();
p.pack(2, 2);

% have a look at p - all the child panels are currently
% uncommitted
p

% commit all the uncommitted panels as axis panels
p.select('all');



%% (b)

% during development of a layout, you might find repack()
% useful.

% repack one of the rows in the root panel
p(1).repack(0.3);

% repack one of the columns in one of the rows
p(1, 1).repack(0.3);

% remember, you can always get a summary of the layout by
% looking at the root panel in the command window
p



