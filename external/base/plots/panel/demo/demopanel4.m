
% Panels can be any size.
%
% (a) Create an asymmetrical grid of panels.
% (b) Create another.
% (c) Use select('all') to load them all with axes
% (d) Get handles to all the axes and modify them.



%% (a)

% create a 2x2 grid in gcf with different fractionally-sized
% rows and columns. a row or column sized as "[]" will
% stretch to fill the remaining unassigned space.
p = panel();
p.pack({1/3 []}, {1/3 []});



%% (b)

% pack a 2x3 grid into p(2, 2). note that we can pack by
% percentage as well as by fraction - the interpretation is
% just based on the size of the numbers we pass in (1 to
% 100 for percentage, or 0 to 1 for fraction).
p(2, 2).pack({30 70}, {20 20 []});



%% (c)

% use select('all') to quickly show the layout you've achieved.
% this commits all uncommitted panels as axis panels, so
% they can't be parents anymore (i.e. they can't have more
% children pack()ed into them).
%
% this is no use at all once you've got organised - look at
% the first three demos, which don't use it - but it may help
% you to see what you're doing as you're starting out.
p.select('all');



%% (d)

% whilst we're here, we can get all the axes within a
% particular panel like this. there are three "groups"
% associated with a panel: (fa)mily, (de)scendants, and
% (ch)ildren. see "help panel/descendants", for instance, to
% see who's in them. they're each useful in different
% circumstances. here, we use (de)scendants.
h_axes = p.de.axis;

% so then we might want to set something on them.
set(h_axes, 'color', [0 0 0]);

% yeah, real gothic.

