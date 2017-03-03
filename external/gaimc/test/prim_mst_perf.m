%% Help debug prim_mst performance
%
profile off;
if exist('prof','var') && prof, profile on; end
nrep=15; mex_fast=0; mat_fast=0; mex_std=0; mat_std=0;
comp_results=[];
szs=[1 10000];
for szi=1:length(szs)
    fprintf('\n%20s size=%-5i     ', 'mst_prim', szs(szi));
    % Matlab needs 1 iteration to compile the function
    if szi==2, mex_fast=0; mat_fast=0; mex_std=0; mat_std=0; end
    for rep=1:nrep
        fprintf('\b\b\b\b'); fprintf(' %3i', rep); 
        A=abs(sprandsym(szs(szi),25/szs(szi)));
        At=A'; 
        [rp ci ai]=sparse_to_csr(A); As.rp=rp; As.ci=ci; As.ai=ai;
        tic; [t1i t1j t1v]=prim_mst(At,struct('istrans',1,'nocheck',1));
            mex_fast=mex_fast+toc;
        tic; [t2i t2j t2v]=mst_prim2(As,0); mat_fast=mat_fast+toc;
        T1f=sparse(t1i,t1j,t1v,size(A,1),size(A,2));
        T2f=sparse(t2i,t2j,t2v,size(A,1),size(A,2));
        if ~isequal(T1f+T1f',T2f+T2f')
            warning('gaimc:mst_prim',...
                'incorrect results from mst_prim (%i,%i)', szi, rep);
            fprintf('sum diff: %g\n', full(sum(sum(T1f))-sum(sum(T2f))));
            fprintf('cmp diff: %10g %10g\n', ...
                max(scomponents(T1f+T1f')), max(scomponents(T2f+T2f')));
            keyboard
        end     
    end
    comp_results(end+1,:) = [mex_fast mat_fast];
end
fprintf('\n');
fprintf('mex time: %f\n', mex_fast);
fprintf('mat time: %f\n', mat_fast);
fprintf('\n');
if exist('prof','var') && prof, profile report; end
profile off;