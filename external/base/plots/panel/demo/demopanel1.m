
% What can Panel do?
%
% This demo just shows off what Panel can do. It is not
% intended as part of the tutorial - this begins in
% demopanel2.
%
% (a) It's easy to create a complex layout
% (b) You can populate it as you would a subplot layout
%
% Now, move on to demopanel2 to learn how to use panel.



%% (a)

% clf
figure(1)
clf

% create panel
p = panel();

% layout a variety of sub-panels
p.pack('h', {1/3 []})
p(1).pack({2/3 []});
p(1,1).pack(3, 2);
p(2).pack(6, 2);

% set margins
p.de.margin = 2;
p(1,1).marginbottom = 12;
p(2).marginleft = 20;
p.margin = [13 10 2 2];

% and some properties
p.fontsize = 8;



%% (b)

% data set 1
for m = 1:3
	for n = 1:2
		
		% prepare sample data
		t = (0:99) / 100;
		s1 = sin(t * 2 * pi * m);
		s2 = sin(t * 2 * pi * n * 2);
		
		% select axis - see data set 2 for an alternative way to
		% access sub-panels
		p(1,1,m,n).select();
		
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

% label axis group
p(1,1).xlabel('time (unitless)');
p(1,1).ylabel('example data series');

% data set 2
source = 'XYZXYZ';

% an alternative way to access sub-panels is to first get a
% reference to the parent...
q = p(2);

% loop
for m = 1:6
	for n = 1:2
		
		% select axis - these two lines do the same thing (see
		% above)
% 		p(2, m, n).select();
		q(m, n).select();

		% prepare sample data
		data = randn(100, 1) * 0.4;
		
		% do stats
		stats = [];
		stats.source = source(m);
		stats.binrange = [-1 1];
		stats.xtick = [-0.8:0.4:0.8];
		stats.ytick = [0 20];
		stats.bincens = -0.9:0.2:0.9;
		stats.values = data;
		stats.freq = hist(data, stats.bincens);
		stats.percfreq = stats.freq / length(data) * 100;
		stats.percpeak = 30;
		
		% plot
		demopanel_minihist(stats, m == 6, n == 1);
		
	end
end

% label axis group
p(2).xlabel('data value (furlongs per fortnight)');
p(2).ylabel('normalised frequency (%)');

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


