function mcs= em_mcs4(st, irr, targets, use_efmtool)
if nargin < 4
  use_efmtool= false;
end
[m, n]= size(st);
irr= irr ~= 0;
ind= 1:n;
ind= [ind(irr == 0), ind(irr)]; %A# place irreversible reactions at the end (appears more efficient)
% ind= [ind(irr), ind(irr == 0)]; %A# place reversible reactions at the end
irr_wkr= irr(ind);
% [kn, wkr, irrev, pivcol]= mcs_kernel4c(st(:, ind), irr_wkr, targets(ind));
[kn, wkr, irrev, pivcol]= mcs_kernel4(st(:, ind), irr_wkr, targets(ind));

% % das geht so nicht:
% irr_wkr= find(irr_wkr);
% irr_wkr= irr_wkr(:)';
% for i= irr_wkr
%   wkr(i, wkr(i, :) < 0)= 0;
% end

w_row= n + 1;
if ismember(w_row, pivcol)
  error('w is in id part');
end
start_time= cputime;
I_part= 1:n;
I_part_id= intersect(pivcol, I_part);
I_not_id= setdiff(I_part, I_part_id);
% if any(I_not_id < 3)
%   error('Cannot use elmo single column mode');
% end
st_trans_id= pivcol(pivcol > w_row);
if ~isempty(st_trans_id)
  wkr(:, any(wkr(st_trans_id, :), 1))= []; %A# delete associated columns
end

ind= [ind, w_row];
ind2= [I_part_id, I_not_id, w_row];
%   unperm(ind)= 1:w_row;
%   kn= kn([ind, w_row+1:w_row+m], :); st_trans_id
wkr= wkr(ind2, :); % also cuts off the st' rows at the bottom of wkr
irrev= irrev(ind2);
ind= ind(ind2);
irr_wkr= irr_wkr(ind2(1:end-1));

%A# (hopefully) performance-improving permutation
[dummy, perm]= sort(sum(wkr(I_not_id, :) ~= 0, 2));
%   [dummy, perm]= sort(sum(wkr(I_irr_not_id, :) < 0, 2) .* sum(wkr(I_irr_not_id, :) > 0, 2));
wkr(I_not_id, :)= wkr(I_not_id(perm), :);
irrev(I_not_id)= irrev(I_not_id(perm)); %A# are currently all reversible anyway
irr_wkr(I_not_id)= irr_wkr(I_not_id(perm));
ind(I_not_id)= ind(I_not_id(perm)); %A# keep track of the permutation
irr_wkr= irr_wkr(:);
irr_wkr_ind= find(irr_wkr');

unperm(ind)= 1:w_row;
%A# ersatz_rd should be a symbolic result as wkr contains the identity
%A# matrix at the beginning
wkr= double(wkr);
[ersatz_rd, subsys_rows]= kernel(wkr');
ersatz_rd= ersatz_rd';

if isempty(I_not_id)
  error('fixme');
  % die w_row ~= 0 ausw?hlen; Vorzeichen beachten
else
  final_mcs= zeros(n, 0);
  if use_efmtool
    sys.stoich= ersatz_rd;
    sys.reversibilities= irrev == 0;
    if sum(targets) == 1
      % if the target is a single reaction then the trvial MCS with just this
      % target reaction is missing in the result; the corresponding EM is not in
      % the efmtool result either
      % this is due to the enforced reaction which in this special case is a
      % partially parallel reaction to a regular reaction
      % therefore in this case the w_row in not enforced but instead the
      % efmtool result is filtered afterwards
      mnet= CalculateFluxModes(sys, CreateFluxModeOpts(...
        'arithmetic', 'double', 'precision', -1, 'zero', 1e-10));
      if ischar(mnet) %A# an error has occured
        disp(mnet);
        error('efmtool error');
      end
      rd_ems= mnet.efms(:, mnet.efms(w_row, :) > 0);
    else
      sys.rnames= default_names('R', size(ersatz_rd, 2), true);
      mnet= CalculateFluxModes(sys, CreateFluxModeOpts('enforce', sys.rnames{end},...
        'arithmetic', 'double', 'precision', -1, 'zero', 1e-10));
      if ischar(mnet) %A# an error has occured
        disp(mnet);
        error('efmtool error');
      end
      rd_ems= mnet.efms;
    end
  else
    I_not_id_begin= w_row - length(I_not_id);
    if I_not_id_begin < 3
      error('Cannot use elmo single column mode');
    end
    rd_ems= wkr;
%     rem_irr= [irr_wkr(:) ~= 0; false]; %A# false for w_row
%     prev_irr= rem_irr;
%     prev_irr(I_not_id_begin:end)= false;
%     rem_irr(1:I_not_id_begin-1)= false;
    rem_I_part= false(n, 1);
    for i= 1:length(I_not_id)-1
      [rd_ems, err]= elmo(rd_ems, irrev, 0, -(I_not_id_begin+i-2), ersatz_rd, subsys_rows, 0, 1);
      if err
        error('elmo error');
      end
%       continue; %A# switch off magic
      cr= I_not_id_begin + i - 1; %A# the row in rd_ems that has just been processed
      rem_I_part(:)= false;
      rem_I_part(cr+1:end)= true;
      useless= all(rd_ems(cr+1:end, :) == 0, 1);
      fprintf('Deleted %d useless preliminary cutsets\n', sum(useless));
      rd_ems(:, useless)= [];
      if ~isempty(rem_I_part) %irr_wkr(cr)
%         rem_irr(cr)= false;
        w_neg= rd_ems(w_row, :) < 0;
        rd_ems(:, w_neg)= -rd_ems(:, w_neg); %A# simplification
        w_pos= rd_ems(w_row, :) > 0;
%         rem_leqz= all(rd_ems(rem_irr, :) <= 0, 1);
        rem_leqz= all(rd_ems(find(irr_wkr & rem_I_part), :) <= 0, 1)...
          & all(rd_ems(find(~irr_wkr & rem_I_part), :) == 0, 1); %#ok
        new_final_mcs= rd_ems(I_part, w_pos & rem_leqz);
%         x= rd_ems(w_row, w_pos & rem_leqz);
        if ~isempty(new_final_mcs)
          for r= irr_wkr_ind;
            new_final_mcs(r, new_final_mcs(r, :) < 0)= 0;
          end
          %A# the final mcs are not in the nullspace of the original system
          %A# any more
          %A# select is necessary, there are not just dupilcates
          old_final= final_mcs;
          [final_mcs, keep]= select_minimal_columns([final_mcs, new_final_mcs]);
          % die neuen final_mcs koennen auch direkt aus rd_ems entfernt werden
          % anstatt das indirekt von independent_columns erledigen zu lassen
          el_count= sum(final_mcs ~= 0, 1);
          fprintf('So far %d final mcs with %d to %d elements\n', size(final_mcs, 2), min(el_count), max(el_count));
        end
        prev_num= size(rd_ems, 2);
        rd_ems= rd_ems(:, independent_columns(rd_ems(I_part, :), final_mcs));
        % geht das einfacher? in den abgearbeiteten Zeilen sind doch alle unabh?ngig
        % und die final_mcs sind in den restlichen Zeilen alle 0
        % allerdings erhalten die final_mcs zus?tzliche Nullen
        fprintf('Removed %d dependent preliminary cutsets\n', prev_num - size(rd_ems, 2));
%         prev_irr(cr)= true;
      end
      
%       final_mcs= [rd_ems(I_part, w_pos), -rd_ems(I_part, w_neg)];
%       for r= irr_wkr_ind;
%         final_mcs(r, final_mcs(r, :) < 0)= 0;
%       end
%       [dummy, keep]= select_minimal_columns(final_mcs(1:cr, :));
%       sel= w_pos | w_neg;
%       sel_ind= find(sel);
%       prev_num= size(rd_ems, 2);
% %       rd_ems= [rd_ems(:, ~sel), rd_ems(:, sel_ind(keep))];
%       fprintf('Removed %d preliminary cutsets\n', prev_num - size(rd_ems, 2));
%       final_mcs= final_mcs(:, keep);
%       clear dummy keep;
%       disp(size(final_mcs, 2));
      
%       if 0%irr_wkr(cr)
%         rem_irr(cr)= false;
%         prev_geqz= all(rd_ems(prev_irr, :) >= 0, 1);
%         prev_leqz= all(rd_ems(prev_irr, :) <= 0, 1);
%         sel= prev_geqz & rd_ems(cr, :) < 0 & rd_ems(w_row, :) >= 0;
%         rd_ems(cr, sel)= 0;
%         sum(sel)
%         sel= prev_leqz & rd_ems(cr, :) > 0 & rd_ems(w_row, :) <= 0;
%         rd_ems(cr, sel)= 0;
%         sum(sel)
% %         sel= (rd_ems(cr, :) & rd_ems(w_row, :) & (sign(rd_ems(cr, :)) ~= sign(rd_ems(w_row, :))));
% %         % noch auf 0 setzen
% %         % was ist mir vorherigen wkr_irr? Die darf ich nicht wieder negativ
% %         % machen
% %         if any(sel)
% %           prev_num= size(rd_ems, 2);
% %           rd_ems= [rd_ems(:, sel), rd_ems(:, independent_columns(rd_ems(1:cr, ~sel), rd_ems(1:cr, sel)))];
% %           fprintf('Removed %d dependent preliminary cutsets\n', prev_num - size(rd_ems, 2));
% %         end
%         prev_irr(cr)= true;
%       end
      %     rem_I_block= I_not_id_begin+i:w_row-1;
      %     if ~isempty(rem_I_block)
      %       pred_zero= ~any(rd_ems(n+1:rem_I_block(1)-1, :), 1);
      %       non_neg= ~any(rd_ems(rem_I_block, :) < 0, 1);
      %       non_pos= ~any(rd_ems(rem_I_block, :) > 0, 1);
      %       final= (rd_ems(w_row, :) > 0 & non_neg) | (rd_ems(w_row, :) < 0 & non_pos & pred_zero);
      %       %       final= all(rd_ems(n+1:w_row-1, :) >= 0, 1) & rd_ems(w_row, :) > 0; %A# conservative
      %       if any(final) %A# avoid unnecessary overhead
      %         final_mcs= select_minimal_columns([final_mcs, rd_ems(I_part, final)]);
      %         fprintf('So far %d final mcs\n', size(final_mcs, 2));
      %         rd_ems(:, final)= [];
      %       end
      %       useless= all(rd_ems([rem_I_block, w_row], :) < 0, 1); %A# <= here is incorrect (SmallExample2)
      % %       useless= all(rd_ems(rem_I_block, :) < 0, 1) & (rd_ems(w_row, :) <= 0); is incorrect (SmallExample2)
      % %       useless= all(rd_ems(rem_I_block, :) <= 0, 1) & (rd_ems(w_row, :) < 0); %A# works, but correct?
      %       fprintf('Deleted %d useless preliminary cutsets\n', sum(useless));
      %       rd_ems(:, useless)= [];
      %       prev_num= size(rd_ems, 2);
      %       rd_ems= rd_ems(:, independent_columns(rd_ems(I_part, :), final_mcs));
      %       fprintf('Removed %d dependent preliminary cutsets\n', prev_num - size(rd_ems, 2));
      %     end
    end
    [rd_ems, err]= elmo(rd_ems, irrev, 0, -(w_row - 2), ersatz_rd, subsys_rows, 1, 1);
    if err
      error('elmo error');
    end
  end % if use_efmtool
%   rd_ems= rd_ems(unperm, :);
  mcs= rd_ems(I_part, :); %[cell2mat(final_mcs), rd_ems(I_part, :)]; %A# "raw" mcs
%   irr= find(irr);
  for i= irr_wkr_ind; %i= irr'; %A# make row vector
    mcs(i, mcs(i, :) < 0)= 0;
  end
  mcs= select_minimal_columns([final_mcs, mcs]); %A# remove non-minimal mcs
%   mcs= select_minimal_columns(mcs); %A# remove non-minimal mcs
end % if isempty(I_not_id)
mcs= mcs(unperm(1:end-1), :);
fprintf('Total computation time: %g seconds\n', (cputime - start_time));
