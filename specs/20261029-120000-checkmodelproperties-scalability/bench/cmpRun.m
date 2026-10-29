% cmpRun(cobraSrc, inFile, outPrefix [, doProfile])  checkModelProperties on one stored model, one process,
% so VmHWM is the peak of this call. Writes <outPrefix>.csv (time, peak GB), <outPrefix>_prof.txt (self time), <outPrefix>.mat.
function cmpRun(cobraSrc, inFile, outPrefix, doProfile)
if nargin < 4, doProfile = 1; end
addpath(genpath(cobraSrc));
initCobraToolbox(false); changeCobraSolver('gurobi','all',0);
warning off all
S0 = load(inFile); f = fieldnames(S0); m = S0.(f{1}); m.S = sparse(m.S);
if doProfile, profile clear; profile on; end
t = tic; status = 'ok';
try
    m = checkModelProperties(m, 0);
catch ME
    status = ['ERROR: ' ME.message];
end
sec = toc(t);
if doProfile
    profile off; p = profile('info'); ft = p.FunctionTable;
    [~, ix] = sort([ft.TotalTime], 'descend'); fid = fopen([outPrefix '_prof.txt'],'w');
    for i = ix(1:min(25,numel(ix)))
        sf = ft(i).TotalTime - sum([ft(i).Children.TotalTime]);
        fprintf(fid,'%9.1f total %9.1f self  %s\n', ft(i).TotalTime, sf, ft(i).FunctionName);
    end
    fclose(fid);
end
txt = fileread(sprintf('/proc/%d/status', feature('getpid')));
tk = regexp(txt,'VmHWM:\s+(\d+)','tokens','once'); gb = str2double(tk{1})/1048576;
fid = fopen([outPrefix '.csv'],'a'); fprintf(fid,'%s,%s,%.1f,%.2f,%d,%d,%s\n',inFile,cobraSrc,sec,gb,size(m.S,1),size(m.S,2),strrep(status,',',';')); fclose(fid);
if strcmp(status,'ok'), save([outPrefix '.mat'],'m','-v7.3'); end
end
