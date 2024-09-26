
% Panel can build complex layouts rapidly (HINTS on MARGINS!).
%
% (a) Build the layout from demopanel1, with annotation
% (b) Add the content, so we can see what we're aiming for
% (c) Show labelling of axis groups
% (d) Add appropriate margins for this layout



%% (a)

% create panel
p = panel();

% let's start with two columns, one third and two thirds
p.pack('h', {1/3 2/3})

% then let's pack two rows into the first column, with the
% top row pretty big so we've room for some sub-panels
p(1).pack({2/3 []});

% now let's pack in those sub-panels
p(1,1).pack(3, 2);

% finally, let's pack a grid of sub-panels into the right
% hand side too
p(2).pack(6, 2);



%% (b)

% now, let's populate those panels with axes full of data...

% data set 1
for m = 1:3
	for n = 1:2
		
		% prepare sample data
		t = (0:99) / 100;
		s1 = sin(t * 2 * pi * m);
		s2 = sin(t * 2 * pi * n * 2);
		
		% select axis
		p(1,1,m,n).select();
		
		% NB: an alternative way of accessing
		% q = p(1, 1);
		% q(m, n).select();
		
		% plot
		plot(t, s1, 'r', 'linewidth', 1);
		hold on
		plot(t, s2, 'b', 'linewidth', 1);
		plot(t, s1+s2, 'k', 'linewidth', 1);
		
		% finalise axis
		axis([0 1 -2.2 2.2]);
		set(gca, 'xtick', [], 'ytick', []);
		
	end
end

% data set 2
source = 'XYZXYZ';

for m = 1:6
	for n = 1:2
		
		% select axis
		p(2,m,n).select();

		% prepare sample data
		data = randn(100, 1) * 0.4;
		
		% do stats
		stats = [];
		stats.source = source(m);
		stats.binrange = [-1 1];
		stats.xtick = [-0.8:0.4:0.8];
		stats.ytick = [0 20 40];
		stats.bincens = -0.9:0.2:0.9;
		stats.values = data;
		stats.freq = hist(data, stats.bincens);
		stats.percfreq = stats.freq / length(data) * 100;
		stats.percpeak = 30;
		
		% plot
		demopanel_minihist(stats, m == 6, n == 1);
		
	end
end

% data set 3
p(1, 2).select();

% prepare sample data
r1 = rand(100, 1);
r2 = randn(100, 1);

% plot
plot(r1, r1+0.2*r2, 'k.')
hold on
plot([0 1], [0 1], 'r-')

% finalise axis
xlabel('our predictions');
ylabel('actual measurements')



%% (c)

% we can label parent panels (or, "axis groups") just like
% labelling axis panels, except we have to use the method
% from panel, rather than the matlab call xlabel().

% label axis group
p(1,1).xlabel('time (unitless)');
p(1,1).ylabel('example data series');

% we can also get a handle back to the label object, so
% that we can access its properties.

% label axis group
h = p(2).xlabel('data value (furlongs per fortnight)');
p(2).ylabel('normalised frequency (%)');

% access properties
% get(h, ...



%% (d)

% wow, those default margins suck for this figure. let's see
% if we can do better...
disp('These are the default margins - press any key to continue...');
pause



%%%% STEP 1 : TIGHT INTERNAL MARGINS

% tighten up all internal margins to the smallest margin
% we'll use anywhere (between the un-labelled sub-grids).
% this is usually a good starting point for any layout.
p.de.margin = 2;

% notice that we set the margin of all descendants of p, but
% the margin of p is not changed (p.de does not include p
% itself), so there is still a margin from the root panel,
% p, to the figure edge. we can display this value:
disp(sprintf('p.margin is [ %i %i %i %i ]', p.margin));

% the set p.fa (family) _does_ include p, so p.fa is equal
% to {p.de and p}. if you see what I mean. check help
% panel/family and help panel/descendants! you could also
% have used the line, p.fa.margin = 2, it would have worked
% just fine.

% pause
disp('We''ve tightened internal margins - press any key to continue...');
pause



%%%% STEP 2 : INCREASE INTERNAL MARGINS AS REQUIRED

% now, let's space out the places we want spaced out -
% remember that you can use p.identify() to get a nice
% indication of how to reference individual panels.
p(1,1).marginbottom = 12;
p(2).marginleft = 20;

% pause
disp('We''ve increased two internal margins - press any key to continue...');
pause



%%%% STEP 3 : FINALISE MARGINS WITH FIGURE EDGES

% finally, let's sail as close to the wind as we dare for
% the final product, by trimming the root margin to the
% bone. eliminating any wasted whitespace like this is
% particularly helpful in exported image files.
p.margin = [13 10 2 2];

% and let's set the global font properties, also. we can do
% this at any point, it doesn't have to be here.
p.fontsize = 8;

% report
disp('We''ve now adjusted the figure edge margins (and reduced the fontsize), so we''re done.');





