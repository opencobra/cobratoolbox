
% Recovering a Panel from a Figure.
%
% (a) Create a grid of panels, and show something in them.
% (b) Recover the root panel from the Figure.



%% (a)

% create a 2x2 grid in gcf.
clf
p = panel();
p.pack(2, 2);

% show dummy content
p.select('data');



%% (b)

% say we returned from a function and didn't have a handle
% to panel - during development, it might be nice to be able
% to recover the panel from the Figure handle. we can, like
% this. if we don't pass an argument, gcf is assumed.
q = panel.recover();

% note that "p" and "q" now refer to the same thing - it's
% not two root panels, it's two references to the same one.
if p == q
	disp('panels are identical')
end

