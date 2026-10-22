% stageRun(stage, cobraSrc, inFile, outFile, resultFile)  one stage per process, so VmHWM is per-stage.
function stageRun(stage, cobraSrc, inFile, outFile, resultFile)
addpath(genpath('/home/farid/Projects/reconxkg/ReconXKGtoCobra'));
addpath(genpath(cobraSrc));
initCobraToolbox(false); changeCobraSolver('gurobi','all',0);
warning off all
S0 = load(inFile); f = fieldnames(S0); m = S0.(f{1}); m.S = sparse(m.S);
fp.epsilon=1e-4; fp.modeFlag=0; fp.method='null_fastcc';
lp.epsilon=1e-4; lp.eta=getCobraSolverParams('LP','feasTol')*100; lp.method='dc';
t=tic; status='ok';
try
 switch stage
  case 'trivialDupS'
   m = removeTrivialStoichiometry(m);
   [~, r] = checkDuplicateRxn(m,'S',0,0);
   if ~isempty(r), m.lb(r) = -m.ub(r); m = removeRxns(m, m.rxns(r),0,1); end
  case 'dupFR'
   mH=m; pb = strncmp(mH.mets,'h',1) & cellfun(@length,mH.mets)==4; mH.S(pb,:)=0;
   [~, r] = checkDuplicateRxn(mH,'FR',0,0);
   if ~isempty(r), m = removeRxns(m, m.rxns(r),0,0); end
  case 'fluxConsistent'
   m = findSExRxnInd(m,[],0);
   m.lb(~m.SIntRxnBool)=-1000; m.ub(~m.SIntRxnBool)=1000;
   [~,~,~,bad,m] = findFluxConsistentSubset(m,fp,0);
   if any(bad), m = removeRxns(m, m.rxns(bad),0,1); m = findSExRxnInd(m,[],0); end
  case 'leaks'
   findMassLeaksAndSiphons(m, m.SIntMetBool, m.SIntRxnBool, false, lp, 0);
  case 'stoich'
   [~,~,~,~,~,~,m] = findStoichConsistentSubset(m,true,0);
  case 'feasibility'
   c = checkFeasibilityConditions(m); disp(c);
 end
catch ME, status = ['ERROR: ' ME.message]; end
sec = toc(t);
txt = fileread(sprintf('/proc/%d/status', feature('getpid')));
tk = regexp(txt,'VmHWM:\s+(\d+)','tokens','once'); gb = str2double(tk{1})/1048576;
if ~isempty(outFile) && strcmp(status,'ok'), mod = m; save(outFile,'mod'); end
fid=fopen(resultFile,'a'); fprintf(fid,'%s,%s,%.1f,%.2f,%d,%d,%s\n',stage,cobraSrc,sec,gb,size(m.S,1),size(m.S,2),strrep(status,',',';')); fclose(fid);
end
