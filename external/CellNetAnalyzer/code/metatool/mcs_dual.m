function mcs= mcs_dual(st, irr, targets)
% prototype for MCS calculation with the dual network approach
% st is the stoichiometric matrix, irr and targets are logical vectors
% marking irreversible and target reactions respectively

targets= logical(targets(:)');

if any(targets & ~irr)
  error('Can only select irreversible reactions as targets');
end

sys.st= st;
sys.irrev_react= irr;
sys.reduce_only= true;
sys= metatool(sys);
rd_targets= any(sys.sub(:, targets), 2)';

mcs= em_mcs4(sys.rd, sys.irrev_rd, rd_targets);
fprintf('%d MCS in the compressed system\n', size(mcs, 2));

mcs= expand_mcs(mcs ~= 0, sys.sub);
