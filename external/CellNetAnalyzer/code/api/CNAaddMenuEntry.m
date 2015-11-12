function [menhandles] = CNAaddMenuEntry(cnap, menuname,funcname)
% CellNetAnalyzer API function 'CNAaddMenuEntry'
%
% Usage: [menhandles] = CNAaddMenuEntry(cnap, menuname,funcname)
%
% cnap is a signal- or mass-flow project variable. This function adds a new
% entry to the CNA pulldown menu. mname and fname are strings defining the
% name of the menu entry and the associated callback function,
% respectively. The added menu item will read:
%     “User function: <mname>” 
% and is appended to the CNA menu in all interactive maps associated with
% the project. If the inserted menu entry is selected, the (user-created)
% function fname will be called. fname will usually correspond to a m- or
% MEX-file. Note that the extensions (.m, .dll,  .mexglx and so on) must
% not be contained in fname.
% The function returns the handles of the created menu entries (if your
% network project consists of w network maps, then w handles will be
% returned). The handles may be used to delete inserted menu entries at a
% later stage. Arbitrary menu entries can be inserted by the user. The
% project variable cnap is not returned as it remains unchanged.

for i=1:cnap.nummaps
	menhandles(i)=uimenu(cnap.figmenu(i),'Label',['User function: ',menuname],'Callback',funcname,'Separator','on');
end
