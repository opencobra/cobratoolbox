%% Uniform sampling
% *Hulda S. Haraldsdóttir*
% 
% In this tutorial we will use Coordinate Hit-and-Run with Rounding (CHRR) 
% [1] to uniformly sample a constraint-based model of the core metabolic network 
% of _E. coli_ [2].
% 
% A constraint-based metabolic model consists of a set of equalities and 
% inequalities that define a convex polytope $<math xmlns="http://www.w3.org/1998/Math/MathML" 
% display="inline"><mrow><mi>&ohm;</mi></mrow></math>$ of feasible flux vectors 
% $<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi 
% mathvariant="italic">v</mi></mrow></math>$,
% 
% $$<math xmlns="http://www.w3.org/1998/Math/MathML" display="block"><mrow><mi>&ohm;</mi><mo 
% stretchy="false">=</mo><mrow><mo>{</mo><mrow><mi mathvariant="italic">v</mi><mo 
% stretchy="false">&mid;</mo><mi mathvariant="normal">Sv</mi><mo>=</mo><mn>0</mn><mo>,</mo><mtext>?
% </mtext><mi mathvariant="italic">l</mi><mo stretchy="false">&leq;</mo><mi mathvariant="italic">v</mi><mo 
% stretchy="false">&leq;</mo><mi mathvariant="italic">u</mi><mo stretchy="false">,</mo><msup><mrow><mi 
% mathvariant="italic">c</mi></mrow><mrow><mi mathvariant="italic">T</mi></mrow></msup><mi 
% mathvariant="italic">v</mi><mo stretchy="false">=</mo><mi>&alpha;</mi><mtext>?
% </mtext></mrow><mo>}</mo></mrow><mo stretchy="false">,</mo></mrow></math>$$
% 
% where $<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi 
% mathvariant="italic">S</mi></mrow></math>$ is the $<math xmlns="http://www.w3.org/1998/Math/MathML" 
% display="inline"><mrow><mi mathvariant="italic">m</mi><mo>&times;</mo><mi mathvariant="italic">n</mi></mrow></math>$ 
% stoichiometric matrix, $<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi 
% mathvariant="italic">l</mi></mrow></math>$ and $<math xmlns="http://www.w3.org/1998/Math/MathML" 
% display="inline"><mrow><mi mathvariant="italic">u</mi></mrow></math>$ are lower 
% and upper bounds on fluxes, $<math xmlns="http://www.w3.org/1998/Math/MathML" 
% display="inline"><mrow><mi mathvariant="italic">c</mi></mrow></math>$ is a linear 
% objective and $<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi>&alpha;</mi></mrow></math>$ 
% is the solution to a flux balance analysis (FBA) problem [3].
% 
% CHRR consists of rounding followed by sampling. To round an anisotropic 
% polytope, we use a maximum volume ellipsoid algorithm [4]. The rounded polytyope 
% is then sampled with a coordinate hit-and-run algorithm [5].
% 
% Below is a high-level illustration of the process to uniformly sample a 
% random metabolic flux vector $<math xmlns="http://www.w3.org/1998/Math/MathML" 
% display="inline"><mrow><mi mathvariant="italic">v</mi></mrow></math>$ from the 
% set $<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi>&ohm;</mi></mrow></math>$ 
% of all feasible metabolic fluxes (grey). *1)* Apply a rounding transformation 
% $<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi 
% mathvariant="italic">T</mi></mrow></math>$ to $<math xmlns="http://www.w3.org/1998/Math/MathML" 
% display="inline"><mrow><mi>&ohm;</mi></mrow></math>$. The transformed set $<math 
% xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi>&ohm;</mi><mo>&prime;</mo><mo>=</mo><mi 
% mathvariant="italic">T</mi><mi>&ohm;</mi><mtext>?</mtext></mrow></math>$ is 
% such that its maximal inscribed ellipsoid (blue) approximates a unit ball. *2)* 
% Take $<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi 
% mathvariant="italic">q</mi></mrow></math>$ steps of coordinate hit-and-run. 
% At each step, i) pick a random coordinate direction $<math xmlns="http://www.w3.org/1998/Math/MathML" 
% display="inline"><mrow><msub><mrow><mi mathvariant="italic">e</mi></mrow><mrow><mi 
% mathvariant="italic">i</mi></mrow></msub></mrow></math>$, and ii) move from 
% current point $<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi 
% mathvariant="italic">v</mi><msub><mrow><mo>&prime;</mo></mrow><mrow><mi mathvariant="italic">k</mi></mrow></msub><mo>&isinv;</mo><mi>&ohm;</mi><mo>&prime;</mo></mrow></math>$ 
% to a random point $<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi 
% mathvariant="italic">v</mi><msub><mrow><mo stretchy="false">&prime;</mo></mrow><mrow><mi 
% mathvariant="italic">k</mi><mo>+</mo><mn>1</mn></mrow></msub><mo stretchy="false">&isinv;</mo><mi>&ohm;</mi><mo 
% stretchy="false">&prime;</mo></mrow></math>$ along $<math xmlns="http://www.w3.org/1998/Math/MathML" 
% display="inline"><mrow><mi mathvariant="italic">v</mi><msub><mrow><mo>&prime;</mo></mrow><mrow><mi 
% mathvariant="italic">k</mi></mrow></msub><mo>+</mo><mi>&alpha;</mi><msub><mrow><mi 
% mathvariant="italic">e</mi></mrow><mrow><mi mathvariant="italic">i</mi></mrow></msub><mo>&cap;</mo><mi>&ohm;</mi><mo>&prime;</mo></mrow></math>$. 
% *3)* Map samples back to the original space by applying the inverse transformation, 
% e.g., $<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><msub><mrow><mi 
% mathvariant="italic">v</mi></mrow><mrow><mi mathvariant="italic">k</mi></mrow></msub><mo>=</mo><msup><mrow><mi 
% mathvariant="italic">T</mi></mrow><mrow><mo>&minus;</mo><mn>1</mn></mrow></msup><mi 
% mathvariant="italic">v</mi><msub><mrow><mo>&prime;</mo></mrow><mrow><mi mathvariant="italic">k</mi></mrow></msub></mrow></math>$.
% 
% 

initCobraToolbox
%% Modelling
% We will model growth on glucose under aerobic and anaerobic conditions, following 
% closely the flux balance analysis (FBA) tutorial published with [3].
% 
% We start by loading the model with published flux bounds and objective 
% function (the biomass reaction). We set the maximum glucose uptake rate to 18.5 
% mmol/gDW/hr. To explore the entire space of feasible steady state fluxes we 
% also remove the cellular objective.

load('ecoli_core_model.mat', 'model');
[m,n] = size(model.S);
model = changeRxnBounds(model, 'EX_glc(e)', -18.5, 'l');
model.c = 0 * model.c;  % linear objective
%% 
% We allow unlimited oxygen uptake in the aerobic model and no oxygen uptake 
% in the anaerobic model.

aerobic = changeRxnBounds(model, 'EX_o2(e)', -1000, 'l');
anaerobic = changeRxnBounds(model, 'EX_o2(e)', 0, 'l');
%% Flux variability analysis
% Flux variability analysis (FVA) returns the minimum and maximum possible flux 
% through every reaction in a model.

try
    startup  % set user preferred LP solver etc.
catch ME
    changeCobraSolver('gurobi7');
end
[minAer, maxAer] = fluxVariability(aerobic)
[minAna, maxAna] = fluxVariability(anaerobic)
%% 
% FVA predicts faster maximal growth under aerobic than anaerobic conditions.

bm = 'Biomass_Ecoli_core_w_GAM';  % biomass reaction identifier
ibm = find(ismember(model.rxns, bm));  % colunn index of biomass reaction
fprintf('Max. aerobic growth: %.4f/h.\n', maxAer(ibm));
fprintf('Max. anaerobic growth: %.4f/h.\n\n', maxAna(ibm));
%% 
% An overall comparison of the FVA results can be obtained by computing 
% the <https://en.wikipedia.org/wiki/Jaccard_index Jaccard index> for each reaction. 
% The Jaccard index is here defined as the ratio between the intersection and 
% union of the flux ranges in the aerobic and anaerobic models. A Jaccard index 
% of 0 indicates completely disjoint flux ranges and a Jaccard index of 1 indicates 
% completely overlapping flux ranges. The mean Jaccard index gives an indication 
% of the overall similarity between the models.

J = fvaJaccardIndex([minAer, minAna],[maxAer, maxAna]);
fprintf('Mean Jaccard index = %.4f.\n', mean(J));
%% 
% To visualise the FVA results, we plot the flux ranges as errorbars, with 
% reactions sorted by the Jaccard index.

E = [(maxAer - minAer)/2 (maxAna - minAna)/2];
Y = [minAer minAna] + E;
X = [(1:length(Y)) - 0.1; (1:length(Y)) + 0.1]';

[~, xj] = sort(J);

f1 = figure;
errorbar(X, Y(xj, :), E(xj, :), 'linestyle', 'none', 'linewidth', 2, 'capsize', 0);
set(gca, 'xlim', [0, length(Y) + 1])
legend('Aeorobic', 'Anaerobic', 'location', 'northoutside', 'orientation', 'horizontal')
xlabel('Reaction')
ylabel('Flux range (mmol/gDW/h)')

yyaxis right
plot(J(xj))
ylabel('Jaccard index')
%% Sampling
% CHRR can be called via either the function chrrSampler, or sampleCbModel. 
% We will use the former route here. Type "|help sampleCbModel"| to learn about 
% the second route.
% 
% The main inputs to chrrSampler are a COBRA model structure and parameters 
% that control the sampling density (nSkip) and the number of samples (nSamples). 
% The total length of the random walk is nSkip*nSamples. The time it takes to 
% run the sampler depends on the total length of the random walk and the size 
% of the model [1]. However, using sampling parameters that are too small will 
% lead to invalid sampling distributions, e.g.,

nSkip = 1;
nSamples = 100;
%% 
% With these parameter settings, it should only take a few seconds to sample 
% the two E. coli core models.
% 
% An additional on/off parameter (toRound) controls whether or not the polytope 
% is rounded. Rounding large models can be slow but is strongly recommended for 
% the first round of sampling. Below we show how to get around this step in subsequent 
% rounds.

toRound = 1;
%% 
% To sample the aerobic and anaerobic E. coli core models, run,

[X1_aer, P_aer] = chrrSampler(aerobic, nSkip, nSamples, toRound);
[X1_ana, P_ana] = chrrSampler(anaerobic, nSkip, nSamples, toRound);
%% 
% The sampler outputs the sampled flux distributions (X_aer and X_ana) and 
% the rounded polytope (P_aer and P_ana). Histograms of sampled biomass reaction 
% flux show that the models are severly undersampled, as evidenced by the presence 
% of multiple sharp peaks.

nbins = 20;
[yAer, xAer] = hist(X1_aer(ibm, :), nbins);
[yAna, xAna] = hist(X1_ana(ibm, :), nbins);

f2 = figure;
plot(xAer, yAer, xAna, yAna);
legend('Aeorobic', 'Anaerobic')
xlabel('Flux (mmol/gDW/h)')
ylabel('# samples')
%% 
% Undersampling results from selecting too small sampling parameters. The 
% appropriate parameter values depend on the dimension of the polytope $<math 
% xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi>&ohm;</mi><mtext>?
% </mtext></mrow></math>$ defined by the model constraints (see intro). One rule 
% of thumb says to set $<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi 
% mathvariant="normal">nSkip</mi><mo>=</mo><mn>8</mn><mo>*</mo><msup><mrow><mi 
% mathvariant="normal">dim</mi><mrow><mo>(</mo><mrow><mi>&ohm;</mi><mtext>?</mtext></mrow><mo>)</mo></mrow></mrow><mrow><mn>2</mn></mrow></msup></mrow></math>$ 
% to ensure statistical independence of samples. The random walk should be long 
% enough to ensure convergence to a stationary sampling distribution [1].
% 
% The dimension of the polytope for E. coli core is $<math xmlns="http://www.w3.org/1998/Math/MathML" 
% display="inline"><mrow><mi mathvariant="normal">dim</mi><mrow><mo>(</mo><mrow><mi>&ohm;</mi><mtext>?
% </mtext></mrow><mo>)</mo></mrow><mo>=</mo><mn>22</mn></mrow></math>$ for the 
% aerobic model and $<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi 
% mathvariant="normal">dim</mi><mrow><mo>(</mo><mrow><mi>&ohm;</mi><mtext>?</mtext></mrow><mo>)</mo></mrow><mo 
% stretchy="false">=</mo><mn>21</mn></mrow></math>$ for the anaerobic model. A 
% good choice of sampling parameters is,

nSkip = 5e3;
nSamples = 1e3;
%% 
% With these parameter settings, it should take around 2.5 minutes to sample 
% each E. coli core model. This time, we can avoid the rounding step by inputting 
% the rounded polytope from the previous round of sampling.

toRound = 0;
X2_aer = chrrSampler(aerobic, nSkip, nSamples, toRound, P_aer);
X2_ana = chrrSampler(anaerobic, nSkip, nSamples, toRound, P_ana);
%% 
% The converged sampling distributions for the biomass reaction are much 
% smoother, with a single peak at zero flux.

nbins = 20;
[yAer, xAer] = hist(X2_aer(ibm, :), nbins);
[yAna, xAna] = hist(X2_ana(ibm, :), nbins);

f3 = figure;
p1 = plot(xAer, yAer, xAna, yAna);
legend('Aeorobic', 'Anaerobic')
xlabel('Flux (mmol/gDW/h)')
ylabel('# samples')
%% 
% Adding the FVA results to the plot shows that the sampling distributions 
% give more detailed information about the differences between the two models. 
% In particular we see that the flux minima and maxima are not equally probable. 
% The number of samples from both the aerobic and anaerobic models peaks at the 
% minum flux of zero, and decreases monotonically towards the maximum. It decreases 
% more slowly in the aerobic model, indicating that higher biomass flux is more 
% probable under aerobic conditions. It is interesting to see that maximum growth 
% is highly improbable in both models.

ylim = get(gca, 'ylim');
cAer = get(p1(1), 'color');
cAna = get(p1(2), 'color');

hold on
p2 = plot([minAer(ibm), minAer(ibm)], ylim, '--', [maxAer(ibm), maxAer(ibm)], ylim, '--');
set(p2,'color', cAer)
p3 = plot([minAna(ibm), minAna(ibm)], ylim, '--', [maxAna(ibm), maxAna(ibm)], ylim, '--');
set(p3, 'color', cAna)
hold off
%% 
% Finally, plotting sampling distributions for six randomly selected E. 
% coli core reactions shows how oxygen availability affects a variety of metabolic 
% pathways.

f4 = figure;
position = get(f4, 'position');
set(f4, 'units', 'centimeters', 'position', [position(1), position(2), 18, 27])

ridx = randi(n, 1,6);

for i = ridx
    nbins = 20;
    [yAer, xAer] = hist(X2_aer(i, :), nbins);
    [yAna, xAna] = hist(X2_ana(i, :), nbins);
    
    subplot(3, 2, find(ridx==i))
    h1 = plot(xAer, yAer, xAna, yAna);
    xlabel('Flux (mmol/gDW/h)')
    ylabel('# samples')
    title(sprintf('%s (%s)', model.subSystems{i}, model.rxns{i}), 'FontWeight', 'normal')
    
    if find(ridx==i)==1
        legend('Aeorobic','Anaerobic')
    end
    
    ylim = get(gca, 'ylim');
    
    hold on
    h2 = plot([minAer(i), minAer(i)], ylim, '--', [maxAer(i), maxAer(i)], ylim, '--');
    set(h2,'color',cAer)
    h3 = plot([minAna(i), minAna(i)], ylim, '--', [maxAna(i), maxAna(i)], ylim, '--');
    set(h3, 'color', cAna)
    hold off
end
%% References
% [1] Haraldsdóttir, H. S., Cousins, B., Thiele, I., Fleming, R.M.T., and Vempala, 
% S. (2016). CHRR: coordinate hit-and-run with rounding for uniform sampling of 
% constraint-based metabolic models. Submitted.
% 
% [2] Orth, J. D., Palsson, B. Ø., and Fleming, R. M. T. (2010). Reconstruction 
% and use of microbial metabolic networks: the core Escherichia coli metabolic 
% model as an educational guide. EcoSal Plus, 1(10).
% 
% [3] Orth, J. D., Thiele I., and Palsson, B. Ø. (2010). What is flux balance 
% analysis? Nat. Biotechnol., 28(3), 245-248.
% 
% [4]  Zhang, Y. and Gao, L. (2001). On Numerical Solution of the Maximum 
% Volume Ellipsoid Problem. SIAM J. Optimiz., 14(1), 53-76.
% 
% [5] Berbee, H. C. P., Boender, C. G. E., Rinnooy Ran, A. H. G., Scheffer, 
% C. L., Smith, R. L., Telgen, J. (1987). Hit-and-run algorithms for the identification 
% of nonredundant linear inequalities. Math. Programming, 37(2), 184-207.
% 
%