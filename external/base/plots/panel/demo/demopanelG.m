
% One panel can manage multiple axes/graphics objects.
%
% 19/07/12 This example, and the multi-object functionality,
% was added with release 2.5, and was suggested by user
% "Brendan" on Matlab Central.
%
% (a) Create a layout.
% (b) Create two user axes.
% (c) Have them both managed by a panel.



%% (a)

% create
clf
p = panel();
p.pack(2, 2);

% select sample data into some of them
p(1,1).select('data');
p(1,2).select('data');
p(2,1).select('data');



%% (b)

% create two axes, one overlaying the other to provide
% separate tick labelling at top and right.

% main axis
ax1 = axes();

% transparent axis for extra axis labelling
ax2 = axes('Color', 'none', 'XAxisLocation', 'top','YAxisLocation', 'Right');

% set up the fancy labelling (due to Brendan)
OppTickLabels = {'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k'};
set(ax2, 'XLim', get(ax1, 'XLim'), 'YLim', get(ax1, 'YLim'));
set(ax2, 'XTick', get(ax1, 'XTick'), 'YTick', get(ax1, 'YTick'));
set(ax2, 'XTickLabel', OppTickLabels, 'YTickLabel', OppTickLabels);



%% (c)

% hand both axes to panel for position management
p(2,2).select([ax1 ax2]);
