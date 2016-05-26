function mcs= mcs_dual_csm(st, irr, targets)
% prototype for MCS calculation with the dual network approach
% st is the stoichiometric matrix, irr and targets are logical vectors
% marking irreversible and target reactions respectively

targets= logical(targets(:)');

if any(targets & ~irr)
  error('Can only select irreversible reactions as targets');
end

[rd, ir, rx]= compressSMat(st, irr, find(targets), 1e-10, 0);
rd_targets= any(rx(targets, :), 1);

mcs= em_mcs4(rd, ir, rd_targets);
fprintf('%d MCS in the compressed system\n', size(mcs, 2));

t= cputime;
mcs= mcs ~= 0;
rx= rx ~= 0;
ri= find(sum(rx, 2) > 1)'; % reactions participating in more than one lump
lr= any(rx(ri, :), 1); % proper lumps
sel= any(mcs(lr, :), 1);
mcsl= mcs(:, sel);
mcs= mcs(:, ~sel);

% resolve lumps separetly before subset expansion so that the independence
% test needs to be run only on relatively few cut sets
for r= ri
  lr= rx(r, :);
  rx(r, :)= 0;
  rx(r, end+1)= 1;
  sel= any(mcsl(lr, :), 1);
  mcsl_no_lr= mcsl(:, sel);
  mcsl_no_lr(lr, :)= 0;
  mcsl= [[mcsl, mcsl_no_lr];
         [zeros(1, size(mcsl, 2)), ones(1, size(mcsl_no_lr, 2))]];
end
mcsl= select_minimal_columns(mcsl);
mcs= [[mcs; zeros(length(ri), size(mcs, 2))], mcsl]; % merge cut sets
mcs= expand_mcs(mcs ~= 0, rx');
disp(cputime-t);
