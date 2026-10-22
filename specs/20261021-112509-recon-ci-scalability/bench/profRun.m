function profRun(stage, inFile, outTxt)
profile clear; profile on
stageRun(stage, '/home/farid/Projects/cobratoolbox-f-develop/src', inFile, '', [tempname '.csv']);
profile off
p = profile('info'); T = p.FunctionTable;
[~, ix] = sort([T.TotalTime], 'descend'); fid = fopen(outTxt,'w');
fprintf(fid,'%-70s %9s %9s %9s %10s\n','function','total_s','self_s','calls','peakMemMB');
selfT = arrayfun(@(f) f.TotalTime - sum([f.Children.TotalTime]), T);
for k = ix(1:min(40,numel(ix)))
  fprintf(fid,'%-70s %9.1f %9.1f %9d %10.1f\n', T(k).FunctionName(1:min(70,end)), T(k).TotalTime, selfT(k), T(k).NumCalls, 0);
end
fclose(fid);
end
