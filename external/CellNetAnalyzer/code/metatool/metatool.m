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

%# sys can be either the input file or the struct which contains the network
%# the return value sys is the struct containing the network
%# if out_fname is given this is used as filename for ASCII output

function sys= metatool(sys, out_fname)
more off; % disables pager

if nargin == 1 && nargout == 0
  error('Either select an output file or assign return value to a variable');
end
if ischar(sys)
  sys= parse(sys);
  if sys.err
    return;
  end
elseif ~isstruct(sys)
  fprintf('Incorrect parameter\n');
  return;
end

if nargin < 2
  out_fid= -1;
else
  out_fid= fopen(out_fname, 'w');
  if out_fid ~= -1
    fprintf(out_fid, 'METATOOL OUTPUT Version 5.1\n');
  end
end

if ~(isfield(sys, 'rd') && isfield(sys, 'irrev_rd')) % skip preprocessing when reduced system is given
  freq_analysis(out_fid, sys);
  sys.all_int= all_integer(sys.st);
  %    sys.all_int= 0; % deactivate integer calculations
  if (sys.all_int)
    sys.kn= kernel_fp(sys.st, [], sys.all_int);
  else
    sys.kn= kernel(sys.st); % safer to use kernel_fp here als well?
  end
  %    if (sys.all_int) % alternative method for making an integer kernel
  %      sys.kn= make_integer_cols(sys.kn);
  %    end
  sys.crel= kernel(sys.st');
  fmatout(out_fid, sys.st, 'STOICHIOMETRIC MATRIX', sys.irrev_react);
  show_dead_ends(sys.st, sys.irrev_react);
  if out_fid ~= -1
    fmatout(out_fid, sys.kn', 'KERNEL (transposed)');
    fenzyme_output(out_fid, sys.kn, -ones(1, size(sys.kn, 2)), sys.react_name);
    foverall_output(out_fid, sys.kn, sys);
    fmatout(out_fid, sys.crel', 'CONSERVATION RELATIONS');
    fcons_rel_output(out_fid, sys.crel, sys.int_met);
  end
  [sys.sub, sys.irrev_rd, sys.blocked_react, sys.sub_irr_viol]= subsets(sys.kn, sys.irrev_react, sys.all_int);
  if out_fid ~= -1
    fmatout(out_fid, sys.sub, 'SUBSETS');
    fenzyme_output(out_fid, sys.sub', sys.irrev_rd, sys.react_name);
    if ~isempty(sys.blocked_react)
      fprintf(out_fid, 'The following enzymes do not participate in any reaction:\n');
      for i= sys.blocked_react
        fprintf(out_fid, '%s ', sys.react_name{i});
      end
      fprintf(out_fid, '\n\n');
    end
    foverall_output(out_fid, sys.sub', sys, 1);
    if ~isempty(sys.sub_irr_viol)
      fmatout(out_fid, sys.sub_irr_viol, 'subsets that are removed because they violate irreversibility constraints');
      fenzyme_output(out_fid, sys.sub_irr_viol', ones(1, size(sys.sub_irr_viol, 1)), sys.react_name);
      foverall_output(out_fid, sys.sub_irr_viol', sys, 1);
    end
  end
  %    [sys.rd, sys.rd_met, sys.irrev_rd]= reduce(sys.st, sys.sub, sys.irrev_rd); % deletes zero columns
  [sys.rd, sys.rd_met]= reduce(sys.st, sys.sub); % keeps zero columns
  fmatout(out_fid, sys.rd, 'REDUCED SYSTEM', sys.irrev_rd);
  show_dead_ends(sys.rd, sys.irrev_rd);
  if isfield(sys, 'reduce_only') && sys.reduce_only
    return;
  end
  if input('Finished preprocessing; press return to continue, \"q\" to quit\n', 's') == 'q'
    if out_fid ~= -1
      fclose(out_fid);
    end
    return;
  end
end

if ~isfield(sys, 'req_reacts') % indices of the ractions in rd that have to be used in the modes
  sys.req_reacts= [];
end

% the last three return values are just for debugging purposes
[sys.rd_ems, sys.rd_cb, sys.err, sys.wrd, sys.irrev_wrd, sys.wkr]= ...
  nsa_em(sys.rd, sys.irrev_rd, sys.req_reacts, 0);
%  sys.rd_ems= schuster(sys.rd, sys.irrev_rd);
sys.irrev_ems= any(sys.rd_ems(find(sys.irrev_rd), :), 1); %# temporary solution

if out_fid ~= -1
  sys.ems= sys.sub' * sys.rd_ems; % expand result to unreduced system
  t= cputime;
  %%%% unused experimental block for ordering the reactions in the modes
  if 0 %~isempty(sys.ext)
    %      cons_ext_metab= any(sys.ext(:, find(sys.irrev_react))' < 0) | any(sys.ext(:, find(~sys.irrev_react))' ~= 0);
    ov= sys.ext * sys.ems; % overall reaction
    ov(abs(ov) < 1E-10)= 0; % remove potential residuals
    [ov, s, ind]= sort_modes(ov);
    sys.ems= sys.ems(:, ind);
    sys.irrev_ems= sys.irrev_ems(ind);
    fmatout(out_fid, sys.ems', 'ELEMENTARY MODES (transposed)');
    eq= equal_range(s);
    for b= 1:(length(eq) - 1)
      % identify the external metabolites that can be consumed by elementary modes
      bl_range= eq(b):(eq(b + 1) - 1);
      ov_bl= ov(:, bl_range);
      irr= sys.irrev_ems(bl_range);
      cons_ext_metab= any(ov_bl(:, find(irr))' < 0) | any(ov_bl(:, find(~irr))' ~= 0);
      %fprintf('Start metabolites for ordering block %d are:', b);
      %disp(sys.ext_met(find(cons_ext_metab)));
      ext_st= [sys.ext; sys.st];
      if length(bl_range) > 1
        unused_reacts= ~any(sys.ems(:, bl_range)');
      else
        unused_reacts= ~(sys.ems(:, bl_range)');
      end
      ext_st(:, unused_reacts)= 0; % ignore unused reactions
      ord= order_reactions(ext_st, sys.irrev_react, find(cons_ext_metab), find(~cons_ext_metab), sys.ext_met, sys.react_name);
      if length(ord) < size(sys.st, 2) % unused reactions in the network
        unused_react= ones(1, size(sys.st, 2));
        unused_react(ord)= 0;
        ord= [ord, find(unused_react)];
      end
      %#disp(sys.react_name(ord));
      fenzyme_output(out_fid, sys.ems(ord, bl_range), irr, sys.react_name(ord), eq(b) - 1);
    end
    fprintf(out_fid, '\n\n');
    foverall_output(out_fid, sys.ems, sys);
  else
    fmatout(out_fid, sys.ems', 'ELEMENTARY MODES (transposed)');
    fenzyme_output(out_fid, sys.ems, sys.irrev_ems, sys.react_name);
    foverall_output(out_fid, sys.ems, sys);
  end
  disp(cputime - t);
  fclose(out_fid);
end
