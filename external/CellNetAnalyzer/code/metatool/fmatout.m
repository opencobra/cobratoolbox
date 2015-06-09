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

function fmatout(fid, mat, descr, irr)
  if fid == -1
    return;
  end
  %pid= fork;
  %if pid > 0
  %  return;
  %end
  %fdisp(fid, descr);
  fprintf(fid, '\n%s\n\n matrix dimension r%d x c%d\n', descr, size(mat, 1), size(mat, 2));
  %fprintf(fid, '\n');
  %fdisp(fid, mat);
  for i= 1:size(mat, 1)
    fprintf(fid, '%g ', mat(i, :));
    fprintf(fid, '\n');
  end
  if nargin > 3
    fprintf(fid, 'The following line indicates reversible (0) and irreversible reactions (1)\n');
    %fdisp(fid, irr);
    fprintf(fid, '%d ', irr);
    fprintf(fid, '\n');
  end
  fprintf(fid, '\n');
  %fflush(fid);
  %exit;
