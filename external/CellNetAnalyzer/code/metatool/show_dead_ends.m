%% Copyright (C) 2005 Axel von Kamp
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 2 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; if not, write to the Free Software
%% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function show_dead_ends(st, irr)
  stirr= st(:, find(irr));
  strev= st(:, find(~irr));
  irp= any(stirr' > 0);
  irn= any(stirr' < 0);
  rev= sum(strev' ~=  0);
  only_prod= irp & ~irn & ~rev; % these are only produced
  only_cons= irn & ~irp & ~rev; % these are only consumed
  only_once= (rev == 1) & ~irp & ~irn; % these take part in only one reversible reaction
  unused= ~irp & ~irn & ~rev;
  fprintf('%d metabolites are only produced, %d are only consumed;\n%d metabolites take part in only one reversible reaction; %d are unused.\n', sum(only_prod), sum(only_cons), sum(only_once), sum(unused));
