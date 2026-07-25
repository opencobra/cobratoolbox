function plotyy_eFBA(model, objective, C_max, N, d)
% This function plots entropicFBA in a plotyy way:
% flux through the objective function (solution.v) as a function of C_value
% on axis 1, and the non-linear/linear part of the objective function as a
% function of C_value on axis 2. The maximum value of the objective function
% is also plotted, obtained through FBA.
%
% USAGE:
%
%    plotyy_eFBA(model, objective, C_max, N, d)
%
% INPUTS:
%    model:        a metabolic model that contains the required fields to
%                  perform entropicFluxBalanceAnalysis, with fields:
%
%                    * .c - `n x 1` linear objective coefficient vector
%                    * .rxns - `n x 1` cell array of reaction identifiers
%    objective:    char, the name of the reaction whose flux is plotted
%                  (as it appears in `model.rxns`)
%    C_max:        an estimation for the maximum value of C_value (for a
%                  larger number the variables do not change)
%    N:            the number of C_value points to sample (since the model
%                  may be infeasible for some values of C, the plotted
%                  figure will have fewer numbers on the x axis)
%    d:            a value to set the axis in a way that the whole plot is
%                  visible
%
% NOTE:
%    If you cannot see the green plot (related to FBAsolution.v) increase `d`.
%
% EXAMPLE:
%
%    plotyy_eFBA(model, 'biomass reaction', 1500, 100, 10)
%
% .. Author: - Samira Ranjbar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initCobraToolbox
model = changeObjective(model,objective);
FBAsolution = optimizeCbModel(model,'max');

param.solver = 'mosek';
param.printLevel = 0;
if strcmp(param.solver,'mosek')
    %set default mosek parameters for this type of problem
    param = mosekParamSetEFBA(param);
end

m = rand(1,N);
j = 1;

for i = 1:length(m)
    model.c(model.c ~= 0) = m(i)*C_max;
    [solution,~] = entropicFluxBalanceAnalysis(model,param);
    if solution.stat == 1
        C(j)= m(i)*C_max;
        j=j+1;
    else
        m(i);
    end
end

C = [1, sort(C)];
solution_vals = ones(length (C),4);
param.printLevel = 0;

for nr = 1:length(C)
    model.c(model.c ~= 0) = C(nr);
    [solution,~] = entropicFluxBalanceAnalysis(model,param);
    solution_vals(nr,1) = solution.v(ismember(model.rxns, objective));
    solution_vals(nr,2) = solution.obj;
    solution_vals(nr,3) = solution.objEntropy;
    solution_vals(nr,4) = solution.objLinear; 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Renderer', 'painters', 'Position', [10 10 1200 800])
h1 = plot(C, solution_vals(:,2));
hold on
h2 = plot(C, solution_vals(:,3));
hold on
h3 = plot(C, solution_vals(:,4));

set(h1, 'LineStyle', '-', 'Marker', 'o', 'Color', 'b', 'LineWidth',2);
set(h2, 'LineStyle', '--', 'Marker', 's', 'Color', 'r', 'LineWidth',2); 
set(h3, 'LineStyle', '--', 'Marker', 'diamond', 'Color', 'g', 'LineWidth',2);

title('Effect of increasing c on objective function')
set(gca, 'FontSize',14)
legend('solution.obj', 'solution.objEntropy',' solution.objLinear' , 'FontWeight','bold')
xlabel('C-value', "FontSize",14, "FontWeight","bold")
xlim([0 max(C)])


%%%%%%%%%%      solution.v  & solution.obj      %%%%%%%%%%%%%%%%%%%
figure('Renderer', 'painters', 'Position', [10 10 1200 800])

[ax, h1, h2] = plotyy(C, solution_vals(:,1), C, solution_vals(:,2));

ylabel(ax(1), 'Objective function Flux (eFBA)', "FontSize",14, "FontWeight","bold");
ylabel(ax(2), 'Objective function (eFBA)', "FontSize",14, "FontWeight","bold");
xlabel('C-value', "FontSize",14, "FontWeight","bold")

set(ax(1),'YLim',[min(solution_vals(:,1))-2  max(solution_vals(:,1))+2+d])
set(ax(2),'YLim',[min(solution_vals(:,2))-2 max(solution_vals(:,2))+2])

grid on
grid minor

xlim(ax(1), [0 max(C)])
xlim(ax(2), [0 max(C)])

set(h1, 'LineStyle', '-', 'Marker', 'o', 'Color', 'b', 'LineWidth',2);
set(h2, 'LineStyle', '-', 'Marker', 's', 'Color', 'r', 'LineWidth',2);

title('Effect of increasing c on objective function')
set(gca, 'FontSize',14)
hold on

h3 = FBAsolution.v(findRxnIDs(model,objective))*ones(size(C));
plot(C, h3,'LineStyle', '--', 'Marker', 'diamond', 'Color', 'g', 'LineWidth',2)
hold off

legend(['solution.v(' strrep(objective, '_', '-') ')'], ['FBAsolution.v(' strrep(objective, '_', '-') ')'],' solution.obj' , 'FontWeight','bold')
legend('Location', 'best') 


%%%%%%%%%%      solution.v  & solution.objEntropy      %%%%%%%%%%%%%%%%%%%
 figure('Renderer', 'painters', 'Position', [10 10 1200 800])
 
[ax, h1, h2] = plotyy(C, solution_vals(:,1), C, solution_vals(:,3));

ylabel(ax(1), 'Objective function Flux (eFBA)', "FontSize",14, "FontWeight","bold");
ylabel(ax(2), 'Entropic part of Objective function (eFBA)', "FontSize",14, "FontWeight","bold");
xlabel('C-value', "FontSize",14, "FontWeight","bold")

set(ax(1),'YLim',[min(solution_vals(:,1))-2  max(solution_vals(:,1))+2+d])
set(ax(2),'YLim',[min(solution_vals(:,3))-2  max(solution_vals(:,3))+2])

grid on
grid minor

xlim(ax(1), [0 max(C)])
xlim(ax(2), [0 max(C)])

set(h1, 'LineStyle', '-', 'Marker', 'o', 'Color', 'b', 'LineWidth',2);
set(h2, 'LineStyle', '-', 'Marker', 's', 'Color', 'r', 'LineWidth',2);

title('Effect of increasing c on objective function')
set(gca, 'FontSize',14)

hold on

h3 = FBAsolution.v(findRxnIDs(model,objective))*ones(size(C));
plot(C, h3,'LineStyle', '--', 'Marker', 'diamond', 'Color', 'g', 'LineWidth',2)
hold off

legend(['solution.v(' strrep(objective, '_', '-') ')'], ['FBAsolution.v(' strrep(objective, '_', '-') ')'],' solution.objEntropy' , 'FontWeight','bold')
legend('Location', 'best') 


%%%%%%%%%%      solution.v  & solution.objLinear      %%%%%%%%%%%%%%%%%%%
 figure('Renderer', 'painters', 'Position', [10 10 1200 800])
[ax, h1, h2] = plotyy(C, solution_vals(:,1), C, solution_vals(:,4));

ylabel(ax(1), 'Objective function Flux (eFBA)', "FontSize",14, "FontWeight","bold");
ylabel(ax(2), 'Linear part of Objective function (eFBA)', "FontSize",14, "FontWeight","bold");
xlabel('C-value', "FontSize",14, "FontWeight","bold")

set(ax(1),'YLim',[min(solution_vals(:,1))-2  max(solution_vals(:,1))+2+d])
set(ax(2),'YLim',[min(solution_vals(:,4))-2  max(solution_vals(:,4))+2])

grid on
grid minor

xlim(ax(1), [0 max(C)])
xlim(ax(2), [0 max(C)])

set(h1, 'LineStyle', '-', 'Marker', 'o', 'Color', 'b', 'LineWidth',2);
set(h2, 'LineStyle', '-', 'Marker', 's', 'Color', 'r', 'LineWidth',2);

title('Effect of increasing c on objective function')
 hold on
set(gca, 'FontSize',14)
h3 = FBAsolution.v(findRxnIDs(model,objective))*ones(size(C));
 plot(C, h3,'LineStyle', '--', 'Marker', 'diamond', 'Color', 'g', 'LineWidth',2)
hold off

legend(['solution.v(' strrep(objective, '_', '-') ')'], ['FBAsolution.v(' strrep(objective, '_', '-') ')'],' solution.objLinear' , 'FontWeight','bold')
legend('Location', 'best') 

end
