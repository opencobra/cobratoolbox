%% Uniform sampling
%% Author(s): *Hulda S. Haraldsd?ttir and German A. Preciat Gonzalez, *Systems Biochemistry Group, University of Luxembourg.
%% Reviewer(s): Almut Heinken, Molecular Systems Physiology Group, University of Luxembourg.
%% INTRODUCTION
% The flux space $<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi>&ohm;</mi></mrow></math>$ 
% for a given set of biochemical and physiologic constraints is represented by: 
% 
% $$\Omega = \{v \mid Sv=b; l \leq v\leq u\}$$
% 
% where $<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi 
% mathvariant="italic">v</mi></mrow></math>$ represents feasible flux vectors,  
% $S\in\mathcal{Z}^{m\times n}$ the stoichiometric matrix, while $<math xmlns="http://www.w3.org/1998/Math/MathML" 
% display="inline"><mrow><mi mathvariant="italic">l</mi></mrow></math>$ and $<math 
% xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi mathvariant="italic">u</mi></mrow></math>$ 
% are lower and upper bounds on fluxes. These criteria still allow a wide range 
% of admissible flux distributions which, in FBA are commonly further restricted 
% by introducing an objective to optimise, transforming the question of admissible 
% fluxes into an FBA problem$<math xmlns="http://www.w3.org/1998/Math/MathML" 
% display="inline"><mrow><msup><mrow><mtext>?</mtext></mrow><mrow><mn>1</mn></mrow></msup></mrow></math>$ 
% of the form
% 
% $$\begin{array}{ll}\min\limits _{v} & c^{T}v\\\text{s.t.} & Sv=b,\\ & l\leq 
% v\leq u,\end{array}$$
% 
% where $<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi 
% mathvariant="italic">c</mi></mrow></math>$ is a linear biological objective 
% function (biomass, ATP consumption, HEME production, etc.). Even under these 
% conditions there is commonly a range of optimal flux distributions, which can 
% be investigated using flux variability analysis. If the general capabilities 
% of the model are of interest, however, uniform sampling of the entire flux space 
% $<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi>&ohm;</mi></mrow></math>$ 
% is able to provide an unbiased characterization, and therefore, can be used 
% to investigate the biochemical networks. It requires collecting a statistically 
% meaningful number of flux distributions uniformly spread throughout the whole 
% flux space and then analysing their properties. There are three basic steps 
% to perform a uniform sampling for a set of feasible fluxes:
% 
% * Define the flux space to be sampled from physical and biochemical constraints
% * Randomly sample the defined flux space based on uniform statistical criteria
% * If is necessary, section the flux space according to post-sampling.
% 
% In COBRA v3 there are three different sampling algorithms: coordinate hit-and-run 
% with rounding (CHRR), artificial centring hit-and-run (ACHR) and the minimum 
% free energy (MFE). In this tutorial, we will use the CHRR algorithm$<math xmlns="http://www.w3.org/1998/Math/MathML" 
% display="inline"><mrow><msup><mrow><mtext>?</mtext></mrow><mrow><mn>2</mn></mrow></msup></mrow></math>$ 
% to uniformly sample a high dimensionally constraint-based model of the differentiation 
% of induced pluripotent stem cells to dopaminergic neurons (iPSC_dopa). The algorithm 
% consists of rounding the anisotropic flux space  ? using a maximum volume ellipsoid 
% algorithm$<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><msup><mrow><mtext>?
% </mtext></mrow><mrow><mn>3</mn></mrow></msup></mrow></math>$ and then performs 
% a uniform sampling based on the provably efficient hit-and-run random walk$<math 
% xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><msup><mrow><mtext>?
% </mtext></mrow><mrow><mn>4</mn></mrow></msup></mrow></math>$. Below is a high-level 
% illustration of the process to uniformly sample a random metabolic flux vector 
% $<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi 
% mathvariant="italic">v</mi></mrow></math>$ from the set $<math xmlns="http://www.w3.org/1998/Math/MathML" 
% display="inline"><mrow><mi>&ohm;</mi></mrow></math>$ of all feasible metabolic 
% fluxes (grey). *1)* Apply a rounding transformation $<math xmlns="http://www.w3.org/1998/Math/MathML" 
% display="inline"><mrow><mi mathvariant="italic">T</mi></mrow></math>$ to $<math 
% xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi>&ohm;</mi></mrow></math>$. 
% The transformed set $<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi>&ohm;</mi><mo>&prime;</mo><mo>=</mo><mi 
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
%% Equipment setup
% Please note that some of the plotting options in the tutorial require Matlab 
% 2016a or higher. Moreover, the tutorial requires a working installation of the 
% Parallel Computing Toolbox.
% 
% Please set a solver, e.g., gurobi. Note that the solver ibm_cplex is required 
% for the function fastFVA. For a guide how to install solvers, please refer to 
% the <https://github.com/opencobra/cobratoolbox/blob/master/docs/source/installation/solvers.md 
% opencobra documentation>.
% 
% In this tutorial, we will perform FVA using the function |fluxVariability|. 
% Change the variable |options.useFastFVA = 1| to use |fastFVA|.
%% Modelling
% We will investigate ATP energy production with limited and unlimited oxygen 
% uptake, following closely the flux balance analysis (FBA) tutorial published 
% with$<math xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><msup><mrow><mtext>?
% </mtext></mrow><mrow><mn>1</mn></mrow></msup></mrow></math>$.
% 
% We start by loading the model with its flux bounds and the objective function 
% (ATP demand reaction). We set the maximum glucose uptake rate to 18.5 mmol/gDW/hr. 
% To explore the entire space of feasible steady state fluxes we also remove the 
% cellular objective.

options.useFastFVA = false; % to use fluxVariability
global CBTDIR
load([CBTDIR filesep 'tutorials' filesep  'analysis' filesep 'uniformSampling'...
    filesep 'data' filesep 'iPSC_DA.mat'], 'modelUptClosed') % Load the model
model = modelUptClosed;
model = changeRxnBounds(model, 'EX_glc(e)', -18.5, 'l');
model.c = 0 * model.c; % clear the objective
%% 
% We allow unlimited and limited oxygen uptake in the models creating two 
% distinct models based on the input model.

unlimitedOx = changeRxnBounds(model, 'EX_o2(e)', -1000, 'l');
limitedOx = changeRxnBounds(model, 'EX_o2(e)', -4, 'l');
%% Flux variability analysis
% Flux variability analysis (FVA) returns the minimum and maximum possible flux 
% through every reaction in a model.

if options.useFastFVA
    [minUn, maxUn] = fastFVA(unlimitedOx, 100);
    [minLim, maxLim] = fastFVA(limitedOx, 100);
else
    [minUn, maxUn] = fluxVariability(unlimitedOx);
    [minLim, maxLim] = fluxVariability(limitedOx);
end
%% 
% FVA predicts faster maximal ATP production with unlimited than with limited 
% oxygen uptake conditions.

ATP = 'DM_atp_c_';  % Identifier of the ATP demand reaction
ibm = find(ismember(model.rxns, ATP));  % column index of the ATP demand reaction
fprintf('Max. ATP energy production with an unlimited oxygen uptake: %.4f/h.\n', maxUn(ibm));
fprintf('Max. ATP energy production with a limited oxygen uptake: %.4f/h.\n\n', maxLim(ibm));
%% 
% An overall comparison of the FVA results can be obtained by computing 
% the <https://en.wikipedia.org/wiki/Jaccard_index Jaccard index> for each reaction. 
% The Jaccard index is here defined as the ratio between the intersection and 
% union of the flux ranges in the unlimitedOx and limitedOx models. A Jaccard 
% index of 0 indicates completely disjoint flux ranges and a Jaccard index of 
% 1 indicates completely overlapping flux ranges. The mean Jaccard index gives 
% an indication of the overall similarity between the models.

J = fvaJaccardIndex([minUn, minLim], [maxUn, maxLim]);
fprintf('Mean Jaccard index = %.4f.\n', mean(J));
%% 
% To visualise the FVA results, we plot the flux ranges as errorbars, with 
% reactions sorted by the Jaccard index.

E = [(maxUn - minUn)/2 (maxLim - minLim)/2];
Y = [minUn minLim] + E;
X = [(1:length(Y)) - 0.1; (1:length(Y)) + 0.1]';

[~, xj] = sort(J);

f1 = figure;
if strcmp(version('-release'), '2016b')
    errorbar(X, Y(xj, :), E(xj, :), 'linestyle', 'none', 'linewidth', 2, 'capsize', 0);
else
    errorbar(X, Y(xj, :), E(xj, :), 'linestyle', 'none', 'linewidth', 2);
end
set(gca, 'xlim', [0, length(Y) + 1])
legend('Unlimited oxygen uptake', 'Limited oxygen uptake', 'location', 'northoutside', ...
       'orientation', 'horizontal')
xlabel('Reaction')
ylabel('Flux range (mmol/gDW/h)')

yyaxis right
plot(J(xj))
ylabel('Jaccard index')
%% Sampling
% CHRR can be called via the function |sampleCbModel|. The main inputs to |sampleCbModel| 
% are a COBRA model structure, the name of the selected sampler and a parameter 
% struct that controls properties of the sampler used. In the instance of CHRR, 
% two parameters are important: the sampling density (|nStepsPerPoint)| and the 
% number of samples (|nPointsReturned). |The total length of the random walk is 
% |nStepsPerPoint*nPointsReturned|. The time it takes to run the sampler depends 
% on the total length of the random walk and the size of the model$<math xmlns="http://www.w3.org/1998/Math/MathML" 
% display="inline"><mrow><msup><mrow><mtext>?</mtext></mrow><mrow><mn>2</mn></mrow></msup></mrow></math>$. 
% However, using sampling parameters that are too small will lead to invalid sampling 
% distributions, e.g.,

options.nStepsPerPoint = 1;
options.nPointsReturned = 500;
%% 
% An additional on/off parameter (|toRound|) controls whether or not the 
% polytope is rounded. Rounding large models can be slow but is strongly recommended 
% for the first round of sampling. Below we show how to get around this step in 
% subsequent rounds. 

options.toRound = 1;
%% 
% The method outputs two results. First, the model used for sampling (in 
% case of |toRound = 1| this would be the rounded model), and second, the samples 
% generated. To sample the unlimitedOx and limitedOx iPSC_dopa models, run,

[P_un, X1_un] =  sampleCbModel(unlimitedOx, [], [], options);
[P_lim, X1_lim] = sampleCbModel(limitedOx, [], [], options);
%% 
% The sampler outputs the sampled flux distributions (X_un and X_lim) and 
% the rounded polytope (P_un and P_lim). Histograms of sampled ATP synthase show 
% that the models are severely undersampled, as evidenced by the presence of multiple 
% sharp peaks.

nbins = 20;
[yUn, xUn] = hist(X1_un(ibm, :), nbins);
[yLim, xLim] = hist(X1_lim(ibm, :), nbins);

f2 = figure;
plot(xUn, yUn, xLim, yLim);
legend('Unlimited oxygen uptake', 'Limited oxygen uptake')
xlabel('Flux (mmol/gDW/h)')
ylabel('# samples')
%% 
% Undersampling results from selecting too small sampling parameters. The 
% appropriate parameter values depend on the dimension of the polytope ?? defined 
% by the model constraints (see intro). One rule of thumb says to set  $<math 
% xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><mi mathvariant="normal">nSkip</mi><mo>=</mo><mn>8</mn><mo>*</mo><msup><mrow><mi 
% mathvariant="normal">dim</mi><mrow><mo>(</mo><mrow><mi>&ohm;</mi></mrow><mo>)</mo></mrow></mrow><mrow><mn>2</mn></mrow></msup></mrow></math>$ 
% to ensure the statistical independence of samples. The random walk should be 
% long enough to ensure convergence to a stationary sampling distribution$<math 
% xmlns="http://www.w3.org/1998/Math/MathML" display="inline"><mrow><msup><mrow><mtext>?
% </mtext></mrow><mrow><mn>2</mn></mrow></msup></mrow></math>$.

options.nStepsPerPoint = 8 * size(P_lim.A, 2);
options.nPointsReturned = 1000;
%% 
% This time, we can avoid the rounding step by inputting the rounded polytope 
% from the previous round of sampling.

options.toRound = 0;
[~, X2_un] = sampleCbModel(unlimitedOx, [], [], options, P_un);
[~, X2_lim] = sampleCbModel(limitedOx, [], [], options, P_lim);
%% 
% The converged sampling distributions for the ATP synthase reaction are 
% much smoother, with a single peak at zero flux.

nbins = 20;
[yUn, xUn] = hist(X2_un(ibm, :), nbins);
[yLim, xLim] = hist(X2_lim(ibm, :), nbins);

f3 = figure;
p1 = plot(xUn, yUn, xLim, yLim);
legend('Unlimited oxygen uptake', 'Limited oxygen uptake')
xlabel('Flux (mmol/gDW/h)')
ylabel('# samples')
%% 
% Adding the FVA results to the plot shows that the sampling distributions 
% give more detailed information about the differences between the two models. 
% In particular, we see that the flux minima and maxima are not equally probable. 
% The number of samples from both the unlimitedOx and limitedOx models peaks at 
% the minimum flux of zero, and decreases monotonically towards the maximum. It 
% decreases more slowly in the unlimitedOx model, indicating that higher ATP production 
% is more probable under unlimited oxygen uptake conditions. It is interesting 
% to see that maximum ATP production is highly improbable in both models.

ylim = get(gca, 'ylim');
cUn = get(p1(1), 'color');
cLim = get(p1(2), 'color');

hold on
p2 = plot([minUn(ibm), minUn(ibm)], ylim, '--', [maxUn(ibm), maxUn(ibm)], ylim, '--');
set(p2,'color', cUn)
p3 = plot([minLim(ibm), minLim(ibm)], ylim, '--', [maxLim(ibm), maxLim(ibm)], ylim, '--');
set(p3, 'color', cLim)
hold off
%% 
% Finally, plotting sampling distributions for six selected iPSC_dopa reactions 
% shows how oxygen availability affects a variety of metabolic pathways.

f4 = figure;
position = get(f4, 'position');
set(f4, 'units', 'centimeters', 'position', [position(1), position(2), 18, 27])

sampledRxns = {'r2139', 'GLNSERNaEx', 'HMR_9791', 'r1616', 'r1578', 'r2537'};
rxnsIdx = findRxnIDs(model, sampledRxns);

%ridx = randi(size(model.rxns,1), 1,6);

for i = rxnsIdx
    nbins = 20;
    [yUn, xUn] = hist(X2_un(i, :), nbins);
    [yLim, xLim] = hist(X2_lim(i, :), nbins);
    
    subplot(3, 2, find(rxnsIdx==i))
    h1 = plot(xUn, yUn, xLim, yLim);
    xlabel('Flux (mmol/gDW/h)')
    ylabel('# samples')
    title(sprintf('%s (%s)', model.subSystems{i}, model.rxns{i}), 'FontWeight', 'normal')
    
    if find(rxnsIdx==i)==2
        legend('Unlimited oxygen uptake', 'Limited oxygen uptake')
    end
    
    ylim = get(gca, 'ylim');
    
    hold on
    h2 = plot([minUn(i), minUn(i)], ylim, '--', [maxUn(i), maxUn(i)], ylim, '--');
    set(h2,'color',cUn)
    h3 = plot([minLim(i), minLim(i)], ylim, '--', [maxLim(i), maxLim(i)], ylim, '--');
    set(h3, 'color', cLim)
    hold off
end
%% References
% 1. Orth, J. D., Thiele I., and Palsson, B. ?. What is flux balance analysis? 
% _Nat. Biotechnol._ 28(3), 245-248 (2010).
% 
% 2. Haraldsd?ttir, H. S., Cousins, B., Thiele, I., Fleming, R.M.T., and 
% Vempala, S. CHRR: coordinate hit-and-run with rounding for uniform sampling 
% of constraint-based metabolic models. _Bioinformatics_. 33(11), 1741-1743 (2016).
% 
% 3. Zhang, Y. and Gao, L. On Numerical Solution of the Maximum Volume Ellipsoid 
% Problem. _SIAM J. Optimiz_. 14(1), 53-76 (2001).
% 
% 4. Berbee, H. C. P., Boender, C. G. E., Rinnooy Ran, A. H. G., Scheffer, 
% C. L., Smith, R. L., Telgen, J. Hit-and-run algorithms for the identification 
% of nonredundant linear inequalities. _Math. Programming_, 37(2), 184-207 (1987).
% 
% 5. Monteiro et al. Metabolic requirements of induced pluripotent stem cell 
% derived dopaminergic neurons. _Technical report_.
% 
%