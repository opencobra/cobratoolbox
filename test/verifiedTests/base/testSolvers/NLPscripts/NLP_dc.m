function dc = NLP_dc(x, Prob)
% dc = NLP_dc(x, Prob)
% From tomlab quickguide

% One row for each constraint, one column for each variable.

dc = [-2 * x(1), -1];
