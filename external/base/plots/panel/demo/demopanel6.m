
% Packing is very flexible - it doesn't just do grids.
%
% (a) Pack a pair of columns.
% (b) Pack a bit into one of them, and then pack some more.
% (c) Pack into the other using absolute packing mode.
% (d) Call select('all'), to show off the result.



%% (a)

% create the root panel, and pack two columns. to pack
% columns instead of rows, we just pass "h" (horizontal) to
% pack().
p = panel();
p.pack('h', 2);



%% (b)

% pack some stuff into the left column.
p(1).pack({1/6 1/6 1/6});

% oops, we didn't fill the thing. let's finish that off with
% a couple of panels that are streeeeeeeee-tchy...
p(1).pack();
p(1).pack();

% we could have also called p(1).pack(2) to do both at once,
% or one call could even have done all five if we'd passed
% enough arguments in the first place (remember we can pass
% [] to leave a panel stretchy). it would have looked like
% this:
%
%   p(1).pack({1/6 1/6 1/6 [] []});

% see help panel/pack or doc panel for more information on
% the packing possibilities.



%% (c)

% in the other column, we'll show how to do absolute mode
% packing. perhaps you're unlikely to need this, but it's
% there if you do. with absolute mode, you can even place
% the child panel outside of its parent's area. just pass a
% 4-element row vector of [left bottom width height] to do
% absolute mode packing.
p(2).pack({[-0.3 -0.01 1 0.4]});

% just to show that you can do relative and absolute
% alongside, we'll pack a relative mode panel as well.
p(2).pack();

% you can pack more than one absolute mode, of course. this
% one comes out on top of the relative mode panel, because
% it was created later, though you can mess with the
% z-orders in the usual matlab way if you need to.
p(2).pack({[0.2 0.61 0.6 0.4]});

% see help panel/pack or doc panel for more information on
% the packing possibilities.



%% (d)

% use selectAll to quickly show the layout you've achieved.
% this commits all uncommitted panels as axis panels, so
% they can't be parents anymore (i.e. they can't have more
% children pack()ed into them).
p.select('all');







