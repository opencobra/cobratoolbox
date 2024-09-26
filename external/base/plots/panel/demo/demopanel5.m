
% Tools for finding your way around a layout.
%
% (a) Recreate the complex layout from demopanel1
% (b) Show three tools that help to navigate a layout



%% (a)

% create panel
p = panel();

% layout a variety of sub-panels
p.pack('h', {1/3 []})
p(1).pack({2/3 []});
p(1,1).pack(3, 2);
p(2).pack(6, 2);

% set margins
p.de.margin = 10;
p(1,1).marginbottom = 20;
p(2).marginleft = 20;
p.margin = [13 10 2 2];

% set some font properties
p.fontsize = 8;



%% (b)

% if a layout gets complex, it can be tricky to find your
% way around it. it's quite natural once you get the hang,
% but there are three tools that will help you if you get
% lost. they are display(), identify() and show().

% identify() only works on axis panels. we haven't bothered
% plotting any data, this time, so we'll use select('all')
% to commit all remaining uncommitted panels as axis panels.
p.select('all');

% display() the panel object at the prompt
%
% notice that most of the panels are called "Object" - this
% is because they are "object panels", which is the general
% name for axis panels (and that's because panels can contain
% other graphics objects as well as axes).
p

% use identify()
%
% every panel that is an axis panel has its axis wiped and
% replaced with the panel's reference. the one in the bottom
% right, for instance, is labelled "(2,6,2)", which means we
% can access it with p(2,6,2).
p.identify();

% use show()
%
% we can demonstrate this by using this tool. the selected
% panel is highlighted in red. show works on parent panels
% as well - try "p(2).show()", for instance.
p(2,6,2).show();

% just to prove the point, let's now select one of the
% panels we've identified and plot something into it.
p(2,4,1).select();
plot(randn(100, 1))
axis auto




