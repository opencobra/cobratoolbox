function runTest(testName, srcFile, outFile)
% initialise COBRA from the clone, run a test script, report executed lines of srcFile
cobra = '/home/farid/Projects/cobratoolbox-f-develop';
cd(cobra); initCobraToolbox(false); changeCobraSolver('gurobi','all',0); warning('off','all'); warning('on','all');
profile clear; profile on
try, run(which(testName)); st = 'PASS'; catch ME, st = ['FAIL: ' ME.message]; fprintf('%s\n', getReport(ME)); end
profile off
p = profile('info'); T = p.FunctionTable; k = find(strcmp({T.FileName}, srcFile));
exe = []; for kk = k(:)', if ~isempty(T(kk).ExecutedLines), exe = [exe; T(kk).ExecutedLines(:,1)]; end, end; exe = unique(exe)';
fid = fopen(outFile,'w'); fprintf(fid,'%s\n%s\n', st, mat2str(exe)); fclose(fid);
end
