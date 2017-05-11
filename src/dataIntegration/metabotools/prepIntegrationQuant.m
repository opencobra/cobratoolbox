function prepIntegrationQuant(model,metData,exchanges,samples,test_max,test_min,path,tol,variation)
% This function generates individual uptake and secretion profiles from a
% data matrix (fluxes) with samples as columns and metabolites as rows.
% Negative values are interpreted as uptake and positive values are
% interpreted as secretion. The function tests based on the input model if
% uptake and secretion of all 'Exchanges' is possible. Subsequently, it
% removes from each sample the metabolite uptakes or secretions that cannot
% be realized by the model due to missing production or degradation
% pathways, or blocked reactions. If only secretion is not possible, only
% secretion is eliminated from the sample profile whereas uptake will still
% be mapped.
% The individual uptake and secretion profile for each sample is saved to
% the location specified in path using the unique sample name.
%
% USAGE:
%
%    prepIntegrationQuant(model, metData, exchanges, samples, test_max, test_min, path, tol, variation)
%
% INPUTS:
%       model:                   Prepared global model (e.g., `model_for_CORE` from `prepModel`)
%       exchanges:               Vector containing exchange reactions
%       metData:                 Fluxes of uptake (negative) and secretion(positive) flux values. The columns are the samples and the rows are the metabolites (Unit matching remaining model constraints!).
%       samples:                 Vector of sample names (no dublicate names)
%       test_max:                Minimal uptake/secretion set while testing if model can perform uptake and secretion of a metabolite (e.g., 500)
%       test_min:                Maximal uptake/secretion set while testing if model can perform uptake and secretion of a metabolite (e.g., 0.00001)
%       path:                    Path where output files should be saved (e.g. 'Y:\Studies\Data_integration\CORE\usingRecon1\models\')
%       tol:                     All fluxes below this value are considered to be zero, (e.g., 1e-6)
%       variation:               Lower and upper bound are established with this value as error range in % (e.g.,20)
%
% For every sample a file is automatically saved and contains the following variables:
%
%       * Secretion_not_possible:  Vector of metabolite (exchange reactions) that cannot be secreted by the model
%       * Uptake_not_possible:     Vector of metabolite (exchange reactions) that cannot be uptaken by the model
%       * FBA_all_secreted:        FBA results of test metabolite secretion
%       * FBA_all_secreted_names:  Name of exchange test metabolite secretion
%       * FBA_all_uptake:          FBA results of test metabolite uptake
%       * FBA_all_uptake_names:    Name of exchange test metabolite uptake
%       * uptake:                  Vector of exchange reactions that are associated with uptake in the cell line (no additional exchanges, since these reactions will not be closed)
%       * uptake_value:            Matrix of flux values, constitute the lower (column 2) and upper (column 3) limits for the model uptake
%       * secretion:               Vector of exchange reactions that are associated with secretion in the cell line (no additional exchanges, since these reactions will not be closed)
%       * secr_value:              Matrix of flux values, constitute the lower (column 2) and upper (column 3) limits for the model secretion
%
%
% .. Depends on `optimizeCbModel`, `changeRxnBounds`
%
% .. Authors:
%       - Ines Thiele
%       - Maike K. Aurich 18/02/15


 for i=1:length(exchanges)
 %% check which mets cannot be produced or consumed


 %% secretion
     model1= changeRxnBounds(model,exchanges(i,1), test_max, 'u');
     model1= changeRxnBounds(model1,exchanges(i,1), test_min, 'l');
     FBA = optimizeCbModel(model1);


    FBA_all_secreted(i,1)=FBA.f;
    FBA_all_secreted(i,2)=FBA.stat;



secretion = exchanges(i);
FBA_all_secreted_names(i,1)={secretion};
 end

 l=1;
 for i=1:length(FBA_all_secreted)
     G = FBA_all_secreted_names(find(FBA_all_secreted(i,1)==0));
     if ~isempty(G)
      Secretion_not_possible(l,1)= FBA_all_secreted_names{i};
      l=l+1;
     else
         Secretion_not_possible = {};
     end
 end


 %% uptake
 for i=1:length(exchanges)

     model1= changeRxnBounds(model,exchanges(i), -1*test_max, 'l');
     model1= changeRxnBounds(model1,exchanges(i), -1*test_min, 'u');

     FBA = optimizeCbModel(model1);



   FBA_all_uptake(i,1)=FBA.f;
     FBA_all_uptake(i,2)=FBA.stat;

 secretion = exchanges(i); % here it does not matter how its called
     FBA_all_uptake_names(i,1)={secretion};

 end
 l=1;
 for i=1:length(FBA_all_uptake)
     G = FBA_all_uptake_names(find(FBA_all_uptake(i,1)==0));
     if ~isempty(G)
      Uptake_not_possible(l,1)= FBA_all_uptake_names{i};
      l=l+1;
     end
 end


%% make vectors of uptke/secretion, whereby exchanges that are not possible
%% with the current generic model (i.e. Uptake_not_possible and Secretion_not_possible) are excluded.
for i = 1:length(samples)
    cell_line_data = metData(:,i);
    cell_line = samples(i);
    k=1;
    m=1;
    n=1;
    for j=1:length(cell_line_data)
        if cell_line_data(j)<0 && cell_line_data(j)< -tol
            Exchanges1 = exchanges(j,1);
            if find(~ismember(Exchanges1,Uptake_not_possible))
                uptake_value(k,1)= cell_line_data(j,1);
                uptake_value(k,2)= (cell_line_data(j,1))*(1+variation/100);
                uptake_value(k,3)= (cell_line_data(j,1))*(1-variation/100);
                uptake(k,1)= exchanges(j,1);
                k=k+1;
            end
        end
        if  cell_line_data(j)>0 && cell_line_data(j)> tol
            Exchanges1 = exchanges(j,1);
            if find(~ismember(Exchanges1,Secretion_not_possible))
                secr_value(m,1)= cell_line_data(j,1);
                secr_value(m,2)= (cell_line_data(j,1))*(1+variation/100);
                secr_value(m,3)= (cell_line_data(j,1))*(1-variation/100);
                secretion(m,1)= exchanges(j,1);
                m=m+1;
            end
        end

        if abs(cell_line_data(j))<= tol
            No_upt_secr(n,1)= exchanges(j,1);
            n=n+1;

        end
    end

    if ~exist('No_upt_secr')
        No_upt_secr = [];
    end

    if ~exist('uptake_value')

        uptake = {};
        uptake_value = [];
    end

     % save individual uptake and secretion profile for each sample (with sample name) to path
     savefile=char(cell_line);
     save([path filesep savefile], 'FBA_all_secreted', 'FBA_all_secreted_names' , 'FBA_all_uptake' , 'FBA_all_uptake_names', 'cell_line' , 'cell_line_data' , 'secr_value' , 'secretion' , 'uptake_value' , 'uptake', 'No_upt_secr');
     clear secretion uptake secr_value uptake_value List_upt_secr No_upt_secr
end

clear
