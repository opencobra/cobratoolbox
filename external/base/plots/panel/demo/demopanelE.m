
% You can have as many root Panels as you like in one Figure.
%
% (a) Create a figure with two uipanel objects.
% (b) Attach a panel to one of these.
% (c) Attach another - oh, wait!



%% (a)

% create the figure
clf

% create a couple of uipanels
set(gcf, 'units', 'normalized');
u1 = uipanel('units', 'normalized', 'position', [0.1 0.1 0.35 0.8]);
u2 = uipanel('units', 'normalized', 'position', [0.55 0.1 0.35 0.8]);



%% (b)

% create a 2x2 grid in one of the uipanels
p = panel(u1);
p.pack(2, 2);
p.select('all');

% see?
pause(3)



%% (c)
 
% and, what the hell, another in the other
q = panel(u2);
q.pack(2, 2);
q.select('all');

% oh, wait, the first one's disappeared. why?
pause(3)

% by default, only one panel can be attached to any one
% figure - if an existing panel is attached when you create
% another one, the existing one is first deleted. this makes
% for ease of use, usually. if you want to attach more than
% one, you have to pass the 'add' argument to the
% constructor when you create additional panels.
p = panel(u1, 'add');
p.pack(2, 2);
p.select('all');

% see?
pause(3)

% and, of course, if we try to create a new one again, once
% again without 'add', we'll delete all existing panels, as
% before...
p = panel(u1);
p.pack(2, 2);
p.select('all');

% see?
pause(3)

% finally, let's show how to delete the first one, just for
% the craic. you shouldn't usually need to do this, but it
% works just fine.
delete(p);



