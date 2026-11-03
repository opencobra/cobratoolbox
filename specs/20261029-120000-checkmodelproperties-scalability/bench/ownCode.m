addpath(genpath('/home/farid/Projects/cobratoolbox-f-develop/src')); initCobraToolbox(false); warning off all
S0=load('/home/farid/Projects/reconxkg/models/20261001/12_56/original_models/20261001T105846Z_Recon4_VMH.mat'); f=fieldnames(S0); m=S0.(f{1}); S=sparse(m.S); clear S0 m
hw=@() peakGB();
fprintf('size %d x %d nnz %d\n',size(S,1),size(S,2),nnz(S));
t=tic; F=-S; F(F<0)=0; R=S; R(R<0)=0; fprintf('F,R build %.1f s  peak %.2f GB\n',toc(t),hw());
t=tic; r1=getRankLUSOL([F R]); fprintf('rank [F R] %d  %.1f s  peak %.2f GB\n',r1,toc(t),hw());
t=tic; r2=getRankLUSOL([F;R]); fprintf('rank [F;R] %d  %.1f s  peak %.2f GB\n',r2,toc(t),hw());
t=tic; r3=getRankLUSOL(S); fprintf('rank S %d  %.1f s  peak %.2f GB\n',r3,toc(t),hw());
t=tic; a=norm(S,inf); b=min(min(abs(S))); fprintf('norm/min %.2f s  peak %.2f GB\n',toc(t),hw());

[~,p,q]=getRankLUSOL([F R]); rk=r1;
t=tic; T=[F R]; C1=T(p(1:rk),:); C2=T(p(rk+1:end),:); W0=C1'\C2'; fprintf('row branch  deficiency %d  %.1f s  peak %.2f GB\n',size(C2,1),toc(t),hw());
clear C1 C2 W0 T
[~,pp,qq]=getRankLUSOL([F;R]); rk=r2; VT=[F;R];
t=tic; VC1=VT(:,qq(1:rk)); VC2=VT(:,qq(rk+1:end)); VW0=VC1\VC2; fprintf('col branch  deficiency %d  %.1f s  peak %.2f GB\n',size(VC2,2),toc(t),hw());

function g=peakGB()
tk=regexp(fileread(sprintf('/proc/%d/status',feature('getpid'))),'VmHWM:\s+(\d+)','tokens','once'); g=str2double(tk{1})/1048576;
end
