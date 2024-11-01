
% Basic use. Panel is just like subplot.
%
% (a) Create a grid of panels.
% (b) Plot into each sub-panel.



%% (a)

% create a NxN grid in gcf (this will create a figure, if
% none is open).
%
% you can pass the figure handle to the constructor if you
% need to attach the panel to a particular figure, as:
%
%   p = panel(h_figure)
%
% NB: you can use this code to compare using panel() with
% using subplot(). you should find they do much the same
% thing in this case, but with a slightly different layout.

N = 2;
use_panel = 1;
clf

% PREPARE
if use_panel
	p = panel();
	p.pack(N, N);
end



%% (b)

% plot into each panel in turn

for m = 1:N
	for n = 1:N
		
		% select one of the NxN grid of sub-panels
		if use_panel
	 		p(m, n).select();
		else
			subplot(N, N, m + (n-1) * N);
		end
		
		% plot some data
		plot(randn(100,1));
		
		% you can use all the usual calls
		xlabel('sample number');
		ylabel('data');
		
		% and so on - generally, you can treat the axis panel
		% like any other axis
		axis([0 100 -3 3]);
		
	end
end



