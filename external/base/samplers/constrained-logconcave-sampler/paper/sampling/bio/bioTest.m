%test some netlib polytopes
numSamples = 2e2;
lo_dim = 1.8e3;
hi_dim = 1e7;
%
files = dir('..\data\bio\*.mat');
count = 0;
flags = zeros(length(files),1);
max_dim = 1;
for k = 1:length(files)
    fprintf('%d/%d\n', k, length(files));
    path = strcat('..\data\bio\',files(k).name);
    
    Problem = load(path); P = Problem.Problem;
    max_dim = max(max_dim,length(P.lb));
    if length(P.lb)>=lo_dim && length(P.lb)<=hi_dim
        %         count = count+1;
        %         fprintf(files(k).name);
        %     fprintf('\n');
     
    flags(k) = 1;
%         unbounded = 0;
%     opt = [];
%     opt.Display = 'off';
%     for i=1:length(P.lb)
%         f = P.c;
%         if P.lb(i)==-Inf
%             
%             f(i) = 1;
%             [x,~,ef] = linprog(f,[],[],P.Aeq,P.beq,P.lb,P.ub,opt);
%             if ef~=1
%                unbounded = 1; 
%                break;
%             end
%         end
%         if P.ub(i)==Inf
%             
%             f(i) = -1;
%             [x,~,ef] = linprog(f,[],[],P.Aeq,P.beq,P.lb,P.ub,opt);
%             if ef~=1
%                 unbounded = 1;
%                 break;
%             end
%         end
%     end
%     if unbounded==0
%         flags(k)=1;
%     end
    end
end
%
% dim_range = 10:10:30;
K = sum(flags)
samples = cell(K,1);
mt = zeros(K,1);
times = zeros(K,1);
scaleCounts = zeros(K,1);
conv = cell(K,1);
p_vals = zeros(K,1);
unif_pvals = zeros(K,1);

for k=1:length(flags)
    tic;
   
    path = strcat('..\data\bio\',files(k).name);
    
    Problem = load(path); P = Problem.Problem;
    if flags(k)==0
        continue;
    end
    
    Q = P;
    P = [];
    P.Aeq = Q.A;
    P.beq = Q.b;
    P.c = Q.c;
    P.lb = Q.lb;
    P.ub = Q.ub;
    
    P.c = 0*P.c;

    options = [];
    options.numSamples = 2e2;
    options.JL_dim = 5;
    try
        [samples{k},P_prep] = sample(P,options);
    catch
        fprintf('Sampler failed\n');
        samples{k} = [];
        times(k) = -1;
        continue;
    end
    times(k) = toc;
    
    mt(k) = halfspaceTest(samples{k});
    
    s_i = samples{k};
    m_i = ceil(mt(k));
    s_i_thinned = s_i(:,m_i:m_i:end);
    first_half = s_i_thinned(:,1:floor(end/2));
    second_half = s_i_thinned(:,floor(end/2)+1:end);
    conv{k} = compareSamples(first_half,second_half);
    p_vals(k) = conv{k}.p;
    
    
    N = size(s_i_thinned,2);
    scaleCounts(k) = unifScaleTest(s_i_thinned,P_prep,P);
    p_tmp = min(1-binocdf(scaleCounts(k)-1,N,0.5),binocdf(scaleCounts(k),N,0.5));
    unif_pvals(k) = 2*p_tmp;
end

col_headers = cell(5,1);
col_headers{1} = 'Emp MT';
col_headers{2} = 'Time/step';
col_headers{3} = 'Time/sample';
col_headers{4} = 'Comp. p-val';
col_headers{5} = 'Unif. p-val';
row_headers = cell(K,1);
model_count = 0;
for i=1:length(files)
    if flags(i)==0
        continue;
    end
    model_count = model_count+1;
    row_headers{model_count} = strcat(files(i).name,', dim=',num2str(size(samples{i},1)));
end

table_text = makeLatexTable(col_headers,row_headers,[mt(mt>0) times(times>0)/numSamples times(times>0).*mt(mt>0)/numSamples p_vals(p_vals>0) unif_pvals(unif_pvals>0)],'Sampling results for netlib polytopes','tab:netlib-exp');
fprintf(table_text);