
% this function is used by some of the demos to display data

function demopanel_minihist(stats, show_xtick, show_ytick)

% color
col = histcol(stats.source);

% plot
b = bar(stats.bincens, stats.percfreq, 0.9);
set(b, 'facecolor', palecol(col), 'edgecolor', col, 'showbaseline', 'off');
hold on

% mean
x = mean(stats.values) * [1 1];
y = [0 100];
plot(x, y, 'k-', 'linewidth', 1);

% label
set(gca, 'ytick', stats.ytick);
if ~show_ytick
	set(gca, 'yticklabel', {});
end

% label
set(gca, 'xtick', stats.xtick);
if ~show_xtick
	set(gca, 'xticklabel', {});
end

% finalise axis
axis([stats.binrange 0 stats.percpeak]);
grid on

% overflows
N = sum(stats.values > max(stats.binrange));
if N
	y = stats.percpeak * 0.8;
	x = stats.binrange(1) + [0.98] * diff(stats.binrange);
	text(x, y, [int2str(N) '>'], 'hori', 'right', 'fontsize', 8);
end

% overflows
N = sum(stats.values < min(stats.binrange));
if N
	y = stats.percpeak * 0.8;
	x = stats.binrange(1) + [0.02] * diff(stats.binrange);
	text(x, y, ['<' int2str(N)], 'hori', 'left', 'fontsize', 8);
end




 
function col = histcol(source)

switch source
	
	case 'X'
		col = [1 0 0];
		
	case 'Y'
		col = [0 0.5 0];
	
	case 'Z'
		col = [0 0 1];
		
end



 

function c = palecol(c)

t = [1 1 1];
d = t - c;
c = c + (d * 0.5);


