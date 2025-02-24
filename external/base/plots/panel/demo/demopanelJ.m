
% Panels can have fixed physical size.
%
% Panels usually have a size which is a fraction of the size
% of their parent panel (e.g. 1/3) whereas margins are of
% fixed physical size (e.g. 10mm). However, on occasion, you
% may want a panel that is of fixed physical size. This demo
% shows how to do this.
%
% (a) Create layout with one panel of fixed physical size.
% (b) Show how units affect behaviour.



%% (a)

% create a column of 2 panels (packed relative) but with
% the first one 25mm high. the fixed size is specified by
% putting the value inside {a cell array}, as in {25},
% below. it's 25mm because the current units of p are mm (mm
% are the default unit).
clf
p = panel();
p.pack({{25} []});
p.select('data');



%% (b)

% but we can change the units.
p.units = 'in';

% now, if we repack, the size is specified in the units
% we've chosen. this is hardly a resize - this changes it
% from 25mm to 25.4mm.
p(1).repack({1});


