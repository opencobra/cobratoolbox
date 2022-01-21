%test some netlib polytopes
numSamples = 5e2;
% lo_dim = 1e4;
% hi_dim = 1e5;
%
files = dir('..\data\netlib\*.mat');
% count = 0;
% flags = zeros(length(files),1);
% for k = 53:length(files)
%     fprintf('%d/%d\n', k, length(files));
%     path = strcat('..\data\netlib\',files(k).name);
%     
%     Problem = load(path); P = Problem.Problem;
%     
%     if length(P.lb)>=lo_dim && length(P.lb)<=hi_dim
%         %         count = count+1;
%         %         fprintf(files(k).name);
%         %     fprintf('\n');
%      
%        Q = P;
%     P = [];
%     P.Aeq = Q.A;
%     P.beq = Q.b;
%     P.c = Q.c;
%     P.lb = Q.lb;
%     P.ub = Q.ub;
%     
%     P.c = 0*P.c;
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
%     end
% end
%
% dim_range = 10:10:30;
% K = sum(flags)
K = 3;
samples = cell(K,1);
mt = zeros(K,1);
mt_corr = zeros(K,1);
times = zeros(K,1);
scaleCounts = zeros(K,1);
conv = cell(K,1);
p_vals = zeros(K,1);
p_vals_corr = zeros(K,1);
unif_pvals = zeros(K,1);
unif_pvals_corr = zeros(K,1);
P_prep = cell(K,1);

for i=1:length(files)
    tic;
   
    if strcmp(files(i).name,'osa_14.mat')==1
        k = 1;
    elseif strcmp(files(i).name,'osa_30.mat')==1
        k=2;
    elseif strcmp(files(i).name,'osa_60.mat')==1
        k=3;
    else
        continue;
    end
    
    path = strcat('..\data\netlib\',files(i).name);
    
    Problem = load(path); P = Problem.Problem;
    
    Q = P;
    P = [];
    P.Aeq = Q.A;
    P.beq = Q.b;
    P.c = Q.c;
    P.lb = Q.lb;
    P.ub = Q.ub;
    
    P.c = 0*P.c;

    options = [];
    options.numSamples = numSamples;
    options.JL_dim = 10;
        [samples{k},P_prep{k}] = sample(P,options);
%         continue;
%     catch
%         fprintf('Sampler failed\n');
%         samples{k} = [];
%         times(k) = -1;
%         continue;
%     end
    model_num = k;
     times(model_num) = toc;
    
    [mt_corr(model_num),~,mt(model_num),~] = halfspaceTest(samples{model_num});
%     mt(model_num) = 1;
%     mt_corr(model_num) = 1;
    s_i = samples{model_num};
    m_i = ceil(mt(model_num));
    s_i_thinned = s_i(:,m_i:m_i:end);
    first_half = s_i_thinned(:,1:floor(end/2));
    second_half = s_i_thinned(:,floor(end/2)+1:end);
    conv{model_num} = compareSamples(first_half,second_half);
    p_vals(model_num) = conv{model_num}.p;
    
    [scaleCounts(model_num),unif_pvals(model_num)] = unifScaleTest(s_i_thinned,P_prep{model_num},P);
    
    m_i = ceil(mt_corr(model_num));
    s_i_thinned = s_i(:,m_i:m_i:end);
    first_half = s_i_thinned(:,1:floor(end/2));
    second_half = s_i_thinned(:,floor(end/2)+1:end);
    cc2 = compareSamples(first_half,second_half);
    p_vals_corr(model_num) = cc2.p;
    
    [~,unif_pvals_corr(model_num)] = unifScaleTest(s_i_thinned,P_prep{model_num},P);
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
     if strcmp(files(i).name,'osa_14.mat')==1
        k = 1;
    elseif strcmp(files(i).name,'osa_30.mat')==1
        k=2;
    elseif strcmp(files(i).name,'osa_60.mat')==1
        k=3;
    else
        continue;
    end
    model_count = model_count+1;
    row_headers{k} = strcat(files(i).name,', dim=',num2str(size(samples{k},1)));
end

table_text = makeLatexTable(col_headers,row_headers,[mt(mt>0) times(times>0)/numSamples times(times>0).*mt(mt>0)/numSamples p_vals(p_vals>0) unif_pvals(unif_pvals>0)],'Sampling results for netlib polytopes','tab:netlib-exp');
fprintf(table_text);