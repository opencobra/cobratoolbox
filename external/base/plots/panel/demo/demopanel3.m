
% You can nest Panels as much as you like.
%
% (a) Create a grid of panels.
% (b) Plot into three of the sub-panels.
% (c) Create another grid in the fourth.
% (d) Plot into each of these.



%% (a)

% create a panel in gcf.
%
% "p" is called the "root panel", which is the special panel
% whose parent is the figure window (usually), rather than
% another panel.
p = panel();

% pack a 2x2 grid of panels into it.
p.pack(2, 2);



%% (b)

% plot into the first three panels
for m = 1:2
	for n = 1:2
		
		% skip the 2,2 panel
		if m == 2 && n == 2
			break
		end
		
		% select the panel (create an axis, and make that axis
		% current)
		p(m, n).select();
		
		% plot some stuff
		plot(randn(100,1));
		xlabel('sample number');
		ylabel('data');
		axis([0 100 -3 3]);
		
	end
end



%% (c)

% pack a further grid into p(2, 2)
%
% all panels start as "uncommitted panels" (even the root
% panel). the first time we "select()" one, we commit it as
% an "axis panel". the first time we "pack()" one, we commit
% it as a "parent panel". once committed, it can't change
% into the other sort.
%
% this call commits p(2,2) as a parent panel - the six
% children it creates all start as uncommitted panels.
p(2, 2).pack(2, 3);



%% (d)

% plot into the six new sub-sub-panels
for m = 1:2
	for n = 1:3
		
		% select the panel - this commits it as an axis panel
		p(2, 2, m, n).select();
		
		% plot some stuff
		plot(randn(100,1));
		xlabel('sample number');
		ylabel('data');
		axis([0 100 -3 3]);
		
	end
end

% note this alternative, equivalent, way to reference a
% sub-panel
p_22 = p(2, 2);

% plot another bit of data into the six sub-sub-panels
for m = 1:2
	for n = 1:3
		
		% select the panel
		p_22(m, n).select();
		
		% plot more stuff
		hold on
		plot(randn(100,1)*0.3, 'r');
		
	end
end





