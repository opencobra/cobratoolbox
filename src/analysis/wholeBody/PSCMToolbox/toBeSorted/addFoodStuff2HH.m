function modelHM2 = addFoodStuff2HH(modelHM, modelFood)

% combine food with harvey
[Coeff,Food,raw]=xlsread('food_table.xlsx');

if ~exist('modelFood','var')
    
    modelFood = createModel();
    modelFood.csense='';
    r = 1;
    c = 1;
    % add diet reactions
%     for i = 1 :1%length(Food(2:end,1))
%         FoodItem= strcat(Food(i+1,1),'[d]');
%         CompItems = strcat(Food(1,2:end),'[d]');
%         modelFood = addReaction(modelFood,strcat('Food_tr_',Food{i+1,1}),[FoodItem CompItems],[-1 1000*Coeff(i+1,:)]); %to get it into the right unit
%         modelFood.lb(r) = 0;
%         modelFood.ub(r) = 1000;% only uptake
%         r = r+1;
%         modelFood = addReaction(modelFood,strcat('Food_EX_',Food{i+1,1}),[FoodItem],[-1]);
%         modelFood.lb(r) = -10;% all items are given per 100g % maximally a kilo per item can be taken up
%         modelFood.ub(r) = 0;% only uptake
%         r = r+1;
%     end
%  
%     for i = 1 : length(modelFood.mets)
%         modelFood.csense(i)='E';
%     end
    for i = 1 :length(Food(2:end,1))
        FoodItem= strcat(Food(i+1,1),'[d]');
        CompItems = strcat(Food(1,2:end),'[d]');
        modelHM2 = addReaction(modelHM2,strcat('Food_tr_',Food{i+1,1}),[FoodItem CompItems],[-1 1000*Coeff(i+1,:)]); %to get it into the right unit
        modelHM2.lb(end) = 0;
        modelHM2.ub(end) = 1000000;% only uptake
        modelHM2 = addReaction(modelHM2,strcat('Food_EX_',Food{i+1,1}),[FoodItem],[-1]);
        modelHM2.lb(end) = -10;% all items are given per 100g % maximally a kilo per item can be taken up
        modelHM2.ub(end) = 0;% only uptake
    end
    for i = 496057:512177
        modelHM2.csense(i)='E';
    end
end

if length(modelHM.subSystems) < length(modelHM.rxns)
    modelHM.subSystems{end+1} = 'X'; % there seemed to be a missing row
end

if length(modelHM.rxnNames) < length(modelHM.rxns)
    modelHM.rxnNames{end+1} = 'X';
end
% remove all diet exchanges from input model
IDs = strmatch('Diet_EX_',modelHM.rxns);
% only remove those reactions that have replacement in the food stuff
Ex = strcat('Diet_EX_',Food(1,2:end),'[d]');
modelHM2 = removeRxns(modelHM,Ex);


modelHM2.A = modelHM2.S;
[modelHM2] = mergeTwoModels(modelHM2,modelFood,1,0);
modelHM2.A = modelHM2.S;


% lets try if I can get 50000 muscle atp
modelHM2 = changeObjective(modelHM2,'Whole_body_objective_rxn');
modelHM2 = changeRxnBounds(modelHM2,'Muscle_DM_atp_c_',50000,'b');
modelHM2 = changeRxnBounds(modelHM2,'Muscle_DM_atp_c_',0,'l');
modelHM2 = changeRxnBounds(modelHM2,'Muscle_DM_atp_c_',100000,'u');
% is this generally feasible?
tic;[solution,LPProblem]=solveCobraLPCPLEX(modelHM2,1,0,0,[],0,'tomlab_cplex');toc
if solution.stats ==5 || solution.stats ==1
    % minimize the sum of fluxes over the Food_EX
    IDs = strmatch('Food_EX',modelHM2.rxns);
    modelHM2 = changeObjective(modelHM2,modelHM2.rxns(IDs),ones(length(IDs),1));
    modelHM2.osense = -1; % maximize --> minimal food uptake
    tic;[solution,LPProblem]=solveCobraLPCPLEX(modelHM2,1,0,0,[],0,'tomlab_cplex');toc
end


