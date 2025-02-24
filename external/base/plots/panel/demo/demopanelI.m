
% Panel can fix dotted/dashed lines on export.
%
% NB: Matlab's difficulty with dotted/dashed lines on export
% seems to be fixed in R2014b, so if using this version or a
% later one, this functionality of panel will be of no
% interest. Text below was from pre R2014b.
%
% Dashed and dotted and chained lines do not render properly
% when exported to image files from Matlab, many users find.
% There are a number of solutions to this posted at file
% exchange, some of which should be compatible with Panel.
% However, for simplicity, Panel offers its own integrated
% solution, "fixdash()". Just call fixdash() with the
% handles to any lines that aren't getting rendered
% correctly at export, and cross your fingers. If you find
% conditions under which this does the wrong thing, please
% let me know.
%
% (a) Create layout.
% (b) Create a standard plot with dashed lines.
% (c) Create a similar plot and call fixdash() on the lines.
% (d) Export.
%
% RESTRICTIONS:
%
% * Does not currently work with 3D lines. This should be
%   possible, but needs a bit of thought, so it'll come
%   along later - nudge me at file exchange if you need it.
%
% * Currently does something a bit dumb with log plots. I
%   should really fix that...



%% (a)

% create a column of 2 panels (packed relative)
clf
p = panel();
p.pack(2);
p.margin = [10 10 2 10];
p.de.margin = 15;




%% (b/c)

% create a circle
th = linspace(0, 2*pi, 13);
x = cos(th) * 0.4 + 0.5;
y = sin(th) * 0.4 + 0.5;
mt = '.';
ms = 15;
lw = 1.5;

% for each
for pind = 1:2

	% plot
	p(pind).select();
	plot(x, y, 'k-');
	hold on
	plot(x+1, y, 'r--');
	plot(x+2, y, 'g-.');
	plot(x+3, y, 'b:');
	plot(x, y+1, ['k' mt '-'], 'markersize', ms);
	plot(x+1, y+1, ['r' mt '--'], 'markersize', ms);
	plot(x+2, y+1, ['g' mt '-.'], 'markersize', ms);
	plot(x+3, y+1, ['b' mt ':'], 'markersize', ms);

	% finalise
	set(allchild(gca), 'linewidth', lw);
	axis([0 5 0 2]);

	% legend
	h_leg = legend('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h');

	% finalise
	if pind == 2
		title('with fixdash()');
		p.fixdash([allchild(gca); allchild(h_leg)]);
	else
		title('without fixdash()');
	end

end



%% (d)

% export
p.export('demopanelI.png', '-w120', '-h120', '-rp');



