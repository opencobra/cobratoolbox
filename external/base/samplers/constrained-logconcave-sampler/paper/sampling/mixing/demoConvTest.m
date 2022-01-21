[mt_corr, mt_cond, step_time] = convTest(makeBody('cube',1e2),'HMC')

[mt_corr, mt_cond, step_time] = convTest(makeBody('simplex',1e2),'HMC')

[mt_corr, mt_cond, step_time] = convTest(makeBody('simplex',1e2),'CHAR')

[mt_corr, mt_cond, step_time] = convTest(makeBody('cube',1e2),'CHAR')