
% this callback is attached by demopanelD

function demopanel_callback(data)

disp('---- ENTER CALLBACK ----')

% all the information is in this structure.
data
context = data.context
userdata = data.userdata

% the "context" field provides rendering data, particularly
% the "size_in_mm" is the size of the rendering surface (the
% figure window, or an image file) whilst the "rect" is the
% rectangle assigned to this panel. therefore, we can work
% out the rendered (physical) size of this panel (and
% therefore, usually, the object it manages) with the
% following calculation.
size = data.context.size_in_mm .* data.context.rect(3:4)

disp('---- EXIT CALLBACK ----')



