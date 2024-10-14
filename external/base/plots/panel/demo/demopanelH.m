
% You can create an "inset" plot effect.
%
% 20/09/12 This example was inspired by the Matlab Central
% user "Ann Hickox". It uses absolute packing to lay
% multiple axes into the same parent panel, which is laid
% out as usual using relative packing.
%
% (a) Create the layout.
% (b) Display some data for illustration.


%% (a)

% create a row of 2 panels (packed relative and horizontal)
clf
p = panel();
p.pack('h', 2);

% pack two absolute-packed panels into one of them
p(2).pack({[0 0 1 1]}); % main plot (fills parent)
p(2).pack({[0.67 0.67 0.3 0.3]}); % inset plot (overlaid)

% NB: margins etc. should be applied to p(2), which is the
% parent panel of p(2, 1) (the main plot) and p(2, 2) (the
% inset).



%% (b)

% select sample data into all
p.select('data');

% tidy up
set(p(2, 2).axis, 'xtick', [], 'ytick', []);


