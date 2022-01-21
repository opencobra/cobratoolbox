%test the birkhoff polytope using HMC
numSamples = 2e2;
dim_range = 100:100:1e3;
% dim_range = 10:10:30;
samples = cell(length(dim_range),1);
mt = zeros(length(dim_range),1);
times = zeros(length(dim_range),1);
scaleCounts = zeros(length(dim_range),1);
conv = cell(length(dim_range),1);
p_vals = zeros(length(dim_range),1);
unif_pvals = zeros(length(dim_range),1);

i = 0;
for dim=dim_range
    i = i+1;
    tic;
    P = makeBody('birkhoff',dim);
    options = [];
    options.numSamples = numSamples;
    [samples{i},P_prep] = sample(P,options);
    times(i) = toc;
    
    mt(i) = halfspaceTest(samples{i}); 
    
    s_i = samples{i};
    m_i = ceil(mt(i));
    s_i_thinned = s_i(:,m_i:m_i:end);
    first_half = s_i_thinned(:,1:floor(end/2));
    second_half = s_i_thinned(:,floor(end/2)+1:end);
    conv{i} = compareSamples(first_half,second_half);
    p_vals(i) = conv{i}.p;
    
    
    N = size(s_i_thinned,2);
    scaleCounts(i) = unifScaleTest(s_i_thinned,P_prep.p,P_prep.A,P_prep.lb,P_prep.ub);
    p_tmp = min(1-binocdf(scaleCounts(i)-1,N,0.5),binocdf(scaleCounts(i),N,0.5));
    unif_pvals(i) = 2*p_tmp;
end


save('birkhoff_data.mat','samples','times','mt');

col_headers = cell(4,1);
col_headers{1} = 'Empirical mt (halfspace)';
col_headers{2} = 'Time per step (s)';
col_headers{3} = 'Comparison p-value (median)';
col_headers{4} = 'Uniform p-value';
row_headers = cell(length(dim_range),1);
for i=1:length(dim_range)
   row_headers{i} = num2str(dim_range(i));
end

table_text = makeLatexTable(col_headers,row_headers,[mt times/numSamples p_vals unif_pvals],'Sampling results for Birkhoff polytopes','tab:birkhoff-exp');
fprintf(table_text);