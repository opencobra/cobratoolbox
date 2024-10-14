
% Compare performance between Panel and subplot.
%
% If you want to see whether Panel is slow or fast on your
% machine (vs. subplot), you can use this script.
%
% (a) For each approach:
%   (i) Create a grid of panels.
%   (ii) Plot into each sub-panel.
% (b) Compare performance.



% prepare for performance testing
close all
ss = get(0,'Screensize');
pp = [ss(3:4)/2 + [-599 -399] 1200 800];
figure(1)
set(gcf, 'Position', pp)
figure(2)
set(gcf, 'Position', pp)
drawnow
N = 6;
tic

% optional stuff
optional = true;



%% (a) For each approach:

for approach = [1 2]
	
	% select figure
	figure(approach)
	
	% performance
	ti(approach) = toc;
	
	
	
	%% (i)
	
	% create a NxN grid in gcf. this is only necessary for
	% panel - it is done implicitly when using subplot.
	if approach == 1
		p = panel();
		p.pack(N, N);
	end
	
	
	
	%% (ii)
	
	% plot into each panel in turn
	
	for m = 1:N
		for n = 1:N
			
			% select one of the NxN grid of sub-panels
			if approach == 1
				p(m, n).select();
			else
				subplot(N, N, m + (n-1) * N);
			end
			
			% optional, do some stuff
			if optional
				
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
	end
	
	% performance
	drawnow
	tf(approach) = toc;
	
	
	
end


%% (b) measure performance

td = tf - ti;
fprintf('Time taken using panel:   %.3f s\n', td(1));
fprintf('Time taken using subplot: %.3f s\n', td(2));



