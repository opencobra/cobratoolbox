
% Panel can be child or parent to any graphics object.
%
% (a) Create a figure a uipanel.
% (b) Attach a panel to it.
% (c) Select another uipanel into one of the sub-panels.
% (d) Attach a callback.



%% (a)

% create the figure
clf

% create a uipanel
set(gcf, 'units', 'normalized');
u1 = uipanel('units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);



%% (b)

% create a 2x3 grid in one of the uipanels
p = panel(u1);
p.pack(2, 3);




%% (c)

% create another uipanel
u2 = uipanel();

% but let panel manage its size
p(2, 2).select(u2);

% select all other panels in the grid as axes
p.select('data')




%% (d)

% if you need a notification when u2 is resized, you can
% hook in to the resize event of u2. a demo callback
% function is used here, but of course you can supply any
% function handle.
someUserData = struct('whether_a_donkey_is_a_marine_mammal', false);
p(2, 2).addCallback(@demopanel_callback, someUserData);



