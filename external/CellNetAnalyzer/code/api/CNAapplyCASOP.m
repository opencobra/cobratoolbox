function [ReacWeightMatrix, RatingMatrix]= CNAapplyCASOP(cnap, gamma_vec, k_vec, product_name, molm_product, uptake_reaction_names,...
    rating_boundaries_vec, plot_reaction_ids, legendID, EMoptions, BMreaction, BMmetabolite)
%
%   CellNetAnalyzer API function 'CNAapplyCASOP'
%   ---------------------------------------------
%   --> CASOP method: calculation of reaction weights and reaction ranking for
%   identification of knockout or overexpression candidates for synthesizing 
%   a product with high productivity
%  
% Usage: [ReacWeightMatrix, RatingMatrix] = CNAapplyCASOP(cnap, gamma_vec, k_vec, ...
% 			product_name, molm_product, uptake_reaction_names, rating_boundaries_vec,... 
% 			plot_reaction_ids, legendID, EMoptions, BMreaction, BMmetabolite)
% 
% Arguments (see also manual and CASOP publication):
%
%    The following parameters are mandatory:
% 	  
% 	  cnap: CellNetAnalyzer (mass-flow) project variable
% 	
% 	  The function accesses the following fields of cnap (see also manual):
% 	    cnap.stoichmat: the stoichiometric matrix of the network
% 	    cnap.numr = number of reactions (columns in cnap.stoichMat)
% 	    cnap.mue: index of the biosynthesis reaction; can be empty
% 	    cnap.macroComposition: matrix defining the stoichiometry of the
% 	    cnap.specInternal: vector with the indices of the internal species
% 	    cnap.reacID: names of the columns (reactions) in cnap.stoichMat
% 	    cnap.specID: names of the rows (species) in cnap.stoichMat
% 	    cnap.specInternal: array of indices of internal species
% 	    cnap.specExternal: (1 x n) vector indicating which species are external (1) an which not (0)
% 	    cnap.nums: number of species in the network
% 	    cnap.numis: number of internal species
% 	    cnap.macroID:  names of the macromolecules
% 	    cnap.macroDefault: default concentrations of the macromolecules
% 	    cnap.reacMin: lower boundaries of reaction rates
%                (if reacMin(i)=0 --> reaction i is irreversible)
% 	    cnap.reacMax: upper boundaries of reaction rates
% 	    cnap.epsilon : smallest number greater than zero (for numerical purposes)
% 	
% 	gamma_vec: vector with proportions of product at container V
%
% 	k_vec: vector with exponents for quantitative weighting (see CASOP publication for details)
%
% 	product_name: string with name of target metabolite (must be an external metabolite)
%
% 	molm_product: molar mass of the product 
%
% 	uptake_reaction_names: cell array with names of (substrate) uptake reactions 
%				(each row gives one name = string)
%			--> these reactions characterize the (limited) ressources
%		            required for synthesizing the product and they serve
%			    as normalization factor when computing the yield 
%
% 	rating_boundaries_vec: 	
%		either one value (which must be an element of gamma_vec) 
%			--> then rating type 1 ( = importance at this gamma) is applied
%               or a vector with two values (both must be elements in gamma_vec), 
%                       --> then rating type 2 ( = difference of importances between upper 
%			    and lower gamma value) is applied
%
% 
%    The other arguments are optional:  
% 
% 	plot_reaction_ids: cell array with strings of names of those reactions whose importances
%			 are to be plotted (each row gives one name = string)
%			(default: empty array - plot nothing)
%
% 	legendID: plot with (1, default) or without (0) legend
%
% 	EMoptions: structure with fields containing optional arguments for EM computation 
%              (for details see CNAcomputeEFM), default:
% 	                  EMoptions.constraints=[]
% 	                  EMoptions.mexversion=4
% 	                  EMoptions.irrev_flag=1
% 	                  EMoptions.convbasis_flag=0
% 	                  EMoptions.iso_flag=0
% 	                  EMoptions.c_macro=cnap.macroDefault;
% 	                  EMoptions.display='None'
%
% 	BMreaction: string with name of biomass synthesis reaction 
%		    (to be used if 'mue" is not used as standard biomass reaction)
%
% 	BMmetabolite: string with name of biomass metabolite which must be external
%		      and be a product within the BMreaction
%		    (to be used if 'mue" is not used as standard biomass reaction)
% 
% Results:
% 	ReacWeightMatrix: cell array where ReacWeightMatrix{i,j} holds the vector with reaction importances 
%                     for the i-th value in gamma_vec and j-th value in k_vec.
% 	RatingMatrix:  cell array where RatingMatrix(i,j) holds the rating value for the i-th reaction 
%			in cnap.reacID and the j-th value in k_vec
%


ReacWeightMatrix={};
RatingMatrix={};

% check number of arguments and set default values
switch nargin
    case 7
        plot_reaction_ids={};
        legendID=1;
        EMoptions.constraints= cnap.reacDefault;
        EMoptions.mexversion= 4;
        EMoptions.irrev_flag= 1;
        EMoptions.convbasis_flag= 0;
        EMoptions.iso_flag= 0;        
        EMoptions.c_makro= cnap.macroDefault;        
        EMoptions.display= 'None';                
        BMreaction=[];
        BMmetabolite=[];
    case 8
        legendID=1;
        EMoptions.constraints= cnap.reacDefault;
        EMoptions.mexversion= 4;
        EMoptions.irrev_flag= 1;
        EMoptions.convbasis_flag= 0;
        EMoptions.iso_flag= 0;        
        EMoptions.c_makro= cnap.macroDefault;        
        EMoptions.display= 'None';                
        BMreaction=[];
        BMmetabolite=[];
    case 9
        % if EMoptions are only partially defined set default values for
        % undefined fields
        definedEMoptions=isfield(EMoptions,{'constraints','mexversion','irrev_flag','convbasis_flag','iso_flag','c_makro','display'});
        if definedEMoptions(1)==0
            EMoptions.constraints= cnap.reacDefault;
        end
        if definedEMoptions(2)==0
            EMoptions.mexversion= 4;
        end
        if definedEMoptions(3)==0
            EMoptions.irrev_flag= 1;
        end
        if definedEMoptions(4)==0
            EMoptions.convbasis_flag= 0;
        end
        if definedEMoptions(5)==0
            EMoptions.iso_flag= 0;
        end
        if definedEMoptions(6)==0
            EMoptions.c_makro= cnap.macroDefault;
        end
        if definedEMoptions(7)==0
            EMoptions.display= 'None';
        end
            
        BMreaction=[];
        BMmetabolite=[];
    case 10
        % if EMoptions are only partially defined set default values for
        % undefined fields
        definedEMoptions=isfield(EMoptions,{'constraints','mexversion','irrev_flag','convbasis_flag','iso_flag','c_makro','display'});
        if definedEMoptions(1)==0
            EMoptions.constraints= cnap.reacDefault;
        end
        if definedEMoptions(2)==0
            EMoptions.mexversion= 4;
        end
        if definedEMoptions(3)==0
            EMoptions.irrev_flag= 1;
        end
        if definedEMoptions(4)==0
            EMoptions.convbasis_flag= 0;
        end
        if definedEMoptions(5)==0
            EMoptions.iso_flag= 0;
        end
        if definedEMoptions(6)==0
            EMoptions.c_makro= cnap.macroDefault;
        end
        if definedEMoptions(7)==0
            EMoptions.display= 'None';
        end
        
        BMreaction=[];
        BMmetabolite=[];
    case 11
        display('Please set BMreaction and BMmetabolite!'); 
    case 12 % all arguments available

        % if EMoptions are only partially defined set default values for
        % undefined fields
        definedEMoptions=isfield(EMoptions,{'constraints','mexversion','irrev_flag','convbasis_flag','iso_flag','c_makro','display'});
        if definedEMoptions(1)==0
            EMoptions.constraints= cnap.reacDefault;
        end
        if definedEMoptions(2)==0
            EMoptions.mexversion= 4;
        end
        if definedEMoptions(3)==0
            EMoptions.irrev_flag= 1;
        end
        if definedEMoptions(4)==0
            EMoptions.convbasis_flag= 0;
        end
        if definedEMoptions(5)==0
            EMoptions.iso_flag= 0;
        end
        if definedEMoptions(6)==0
            EMoptions.c_makro= cnap.macroDefault;
        end
        if definedEMoptions(7)==0
            EMoptions.display= 'None';
        end
        
	% if EMoptions are only partially defined set default values for undefined fields
        definedEMoptions=isfield(EMoptions,{'constraints','mexversion','irrev_flag','convbasis_flag','iso_flag','c_makro','display'});
        if definedEMoptions(1)==0
            EMoptions.constraints= cnap.reacDefault;
        end
        if definedEMoptions(2)==0
            EMoptions.mexversion= 4;
        end
        if definedEMoptions(3)==0
            EMoptions.irrev_flag= 1;
        end
        if definedEMoptions(4)==0
            EMoptions.convbasis_flag= 0;
        end
        if definedEMoptions(5)==0
            EMoptions.iso_flag= 0;
        end
        if definedEMoptions(6)==0
            EMoptions.c_makro= cnap.macroDefault;
        end
        if definedEMoptions(7)==0
            EMoptions.display= 'None';
        end

    otherwise
        display('Wrong number of arguments!');
        return;
end


% check product name
product_id=mfindstr(cnap.specID,product_name);
if(product_id==0)
    display('ERROR - Product name not found!')
    return;
elseif(cnap.specExternal(product_id)==0)
    display('ERROR - Product must be defined as external metabolite!')
    return;
end

% check synthesis reaction
product_synth_reac=find(cnap.stoichMat(product_id,:)>0);
if (numel(product_synth_reac)>1)
    display('ERROR - Only one product synthesis reaction allowed!')
    return;
end


% convert text arguments to cell strings
uptake_reaction_names=cellstr(uptake_reaction_names);
plot_reaction_ids=cellstr(plot_reaction_ids);

% check substrate uptake names
for k=1:size(uptake_reaction_names,1)
    norm_reac_id(k)=mfindstr(cnap.reacID,uptake_reaction_names(k));
    if(norm_reac_id(k)==0)
        display(['ERROR - Substrate uptake reaction ',uptake_reaction_names(k),' not found!']);
	return;
    end
end

% check length of constraints
if length(EMoptions.constraints)~=cnap.numr
    display('Length of constraints must equal number of reactions! (NaN for no constraints/ 0 for exclusion/ >0 enforced rections)')
    return;
end



% check network definition and set BM as internal metabolite!
if (cnap.mue~=0)  % BM defined by means of macromolecule definitions
    
    mue_reac_index=cnap.mue;  
    cnap.mue=[];
        
    % define BM 
    cnap.specID=char(cnap.specID,'BM');

    % increment number of metabolites
    cnap.nums= cnap.nums+1;
    cnap.numis= cnap.numis+1;
    % set BM as internal metabolite 
    cnap.specInternal(end+1)= cnap.nums; 
    % update list of external metabolites
    cnap.specExternal(end+1)=0;
    
    % update stoichMat
    cnap.stoichMat(:,mue_reac_index)= -cnap.macroComposition*EMoptions.c_makro;
    cnap.stoichMat(end+1,:)= zeros(1,length(cnap.stoichMat(1,:)));
    cnap.stoichMat(end, mue_reac_index) =1;
    
    bm_id= cnap.nums;

else    % BM defined without use of macromolecules

 % check BMreaction name
    mue_reac_index=mfindstr(cnap.reacID,BMreaction);
    if(mue_reac_index==0)
        display('ERROR - Biomass reaction name not found!')
	return;
    end

    % check BMmetabolite name
    bm_id=mfindstr(cnap.specID,BMmetabolite);
    if(bm_id==0)
        display('ERROR - Biomass metabolite name not found!')
	return;
    elseif(cnap.specExternal(bm_id)==0)
        display('ERROR - Biomass metabolite must be configured as external metabolite!')
	return;
    end

    % update list of external and internal metabolites
    cnap.specInternal(end+1)= bm_id;  
    cnap.numis=cnap.numis+1;
    cnap.specExternal(bm_id)=0; 
    
end        
   
% Set product as internal metabolite and update lists of internal and external metabolites
cnap.specInternal(end+1)= product_id;
cnap.numis=cnap.numis+1;
cnap.specExternal(product_id)= 0; 

% convert molar mass to alpha [mmol per gram]
alpha=1000/molm_product;

% Define new external Container V and update specID, specExternal and stoichMat    
cnap.specID=char(cnap.specID,'V_new');
cnap.nums=cnap.nums+1;
cnap.specExternal(end+1)=1;
cnap.specInternal=sort(cnap.specInternal);

% update stoichMat
cnap.stoichMat(:,end+1)= zeros(cnap.nums-1,1);
cnap.stoichMat(end+1,:)= zeros(1,cnap.numr+1);
cnap.stoichMat(end, end) =1;   % produce 1 V, educt stoichiometries will be set in gamma-loop


% set new reaction to network structure
cnap.numr=cnap.numr+1;
cnap.reacMin(end+1)=0;
cnap.reacMax(end+1)=Inf;
cnap.local.c_makro=[];
cnap.macroComposition=[];
cnap.reacID=char(cnap.reacID,'Vsynth_new');


v_reac_index=cnap.numr; 

% assign cell array for reaction weights
for i=1:length(k_vec)
    for j=1:length(gamma_vec)
        ReacWeightMatrix{i,j}= zeros(cnap.numr,1);
    end
end
RatingMatrix=[];

% set values for all in constraints excluded reactions to NaN
set_to_NaN= find(EMoptions.constraints==0);
for i=1:length(k_vec)
    for j=1:length(gamma_vec)
        ReacWeightMatrix{i,j}(set_to_NaN)= NaN;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                      Gamma-Loop                      %%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
emsfound=0;
for h=1:length(gamma_vec)

    % set V synthesis column stoichiometries
    cnap.stoichMat(product_id,end)= -1*alpha*gamma_vec(h);
    cnap.stoichMat(bm_id,end)= -1*(1-gamma_vec(h));
    
    display(['Computing EMs for current gamma: ',num2str(gamma_vec(h))])
    
    % compute EM
    [aux1_EM,aux2,aux3_reacID]= CNAcomputeEFM(cnap, EMoptions.constraints, EMoptions.mexversion, EMoptions.irrev_flag, EMoptions.convbasis_flag, EMoptions.iso_flag, EMoptions.c_makro, EMoptions.display);
    
    ReactionMapping{h}=aux3_reacID;
    % take only EMs with V_synthesis > 0
    aux1_EM= aux1_EM((aux1_EM(:,find(aux3_reacID==v_reac_index))>0),:);
        
    % if no EMs occur - display warning
    if isempty(aux1_EM) 
        display(['No elementary modes exist for gamma= ', num2str(gamma_vec(h))]);
        if(emsfound)
            display('Exit');
            return;
        end
    end
    
    % Do only if EMs exist
    if ~isempty(aux1_EM)
        emsfound=1;
        for k=1:length(norm_reac_id)
            if any(aux3_reacID==norm_reac_id(k))
                post_em_norm_reac_id(k)=find(aux3_reacID==norm_reac_id(k));
            else 
                display(['Normalization reaction ',cnap.reacID(norm_reac_id(k),:),' was zero for all EM!']);
                post_em_norm_reac_id(k)=0;
            end
        end
    
        % check if normalization reactions exists and normalize
        if any(post_em_norm_reac_id)
            post_em_norm_reac_id = post_em_norm_reac_id(post_em_norm_reac_id~=0);
    
            % normalize EM
            for i=1:size(aux1_EM,1)
                if(sum(aux1_EM(i,post_em_norm_reac_id))>0)
                    aux1_EM(i,:) =  aux1_EM(i,:) / sum(aux1_EM(i,post_em_norm_reac_id));
                else
                    disp(' ');
            		display(['Exit: sum of normalization reactions is not positive in mode ',num2str(i),'!']);
            		display(['(Product/Biomass can be produced without using substrate uptake reaction)!']);
                    disp(' ');
            		return;
                end
            end
        else
            display(['All normalization reactions are zero for all EMs!']);
            return;
        end
    
        % check if all reactions occur at least ones in any EM
        if size(aux1_EM,2)<cnap.numr
            display(['At least one reaction did not occur in any EM for gamma= ', num2str(gamma_vec(h))])
        
            for i=1:cnap.numr
                if ~any(i==aux3_reacID) 
                    display(['Reaction ',deblank(cnap.reacID(i,:)),' is not involved in any EM.'])
                end
            end
        end
  
        clear post_em_norm_reac_id;
        display(['EMs for gamma=', num2str(gamma_vec(h)),' normalized']);
  
        expo_index= 0;
        for i=1:length(k_vec)
            expo=k_vec(i); 
            ReacWeightMatrix_prae{i,h}= reacWeight(aux1_EM,find(aux3_reacID==v_reac_index), expo);
        end

        display(['Reaction weights for step ',int2str(h),' of ',int2str(length(gamma_vec)),' ready.']);
        display([int2str(length(aux1_EM(:,1))), ' EM used.']);
        display(['   ']);
        display(['   ']);
        display(['   ']);
        clear aux1_EM;
    end
 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% If no EMs exist, set reaction weights to NaN
for i=1:size(ReacWeightMatrix_prae,2)
    for j=1:size(ReacWeightMatrix_prae,1)
     if isempty(ReacWeightMatrix_prae{j,i})
        ReacWeightMatrix{j,i}=nan(cnap.numr,1);   
     end
    end
end


% resize to full length of reactions 
for i=1:length(k_vec)
    for j=1:length(gamma_vec)
        ReacWeightMatrix{i,j}(ReactionMapping{j})= ReacWeightMatrix_prae{i,j};
    end
end


% if reactions are to be plotted - plot them
if length(plot_reaction_ids)
	CNAplotWeights(cnap, plot_reaction_ids, gamma_vec, k_vec, ReacWeightMatrix, legendID)
end

% check which rating is to be performed
if (length(rating_boundaries_vec)==1 || rating_boundaries_vec(1)==rating_boundaries_vec(2))
    % allocate rating matrix
    % RatingMatrix=zeros(length(cnap.reacID),length(k_vec));
    % set excluded reactions to NaN
    % RatingMatrix(set_to_NaN,:)=NaN;
    % Rating 1
    column_number= find(gamma_vec==rating_boundaries_vec(1));
    if column_number<1 display('Rating not possible - gamma not found!'); end

    [RatingMatrix]=rating1(ReacWeightMatrix, column_number);
    
    
elseif (length(rating_boundaries_vec)==2 && rating_boundaries_vec(1)<rating_boundaries_vec(2))
    % allocate rating matrix
    RatingMatrix=zeros(length(cnap.reacID),length(k_vec));

    
    % define interval borders
    interval(1)= sum(find(gamma_vec==rating_boundaries_vec(1)));
    interval(2)= sum(find(gamma_vec==rating_boundaries_vec(2)));    
    
    if (interval(1) == 0 || interval(2) == 0) display('Rating not possible - interval borders not found!'); return; end
    
    [RatingMatrix]=rating2(ReacWeightMatrix, interval);
    

else
    display('No rating performed. Wrong interval boundaries!')
end
    
end
%%



%%
function [reac_weight]= reacWeight(EM_matrix, v_reac_index, expo, delta_vec)
% computes a vector(column) of reaction weights
% default for delta_vec= ones (Column!)
% edited 25.11.08

if nargin==3
    delta_vec=ones(length(EM_matrix(:,1)),1);
end

vcol=EM_matrix(:,v_reac_index);
mue_sum = sum(vcol.^expo'*delta_vec);

weight_per_mode =(vcol.^expo).*delta_vec/mue_sum;

reac_weight=zeros(length(EM_matrix(1,:)),1);

for i = 1:length(EM_matrix(1,:))
       reac_weight(i)= sum(weight_per_mode( find(EM_matrix(:,i)) ));
end
 
end
%%




%%
function CNAplotWeights(cnap, reaction_names, gamma_vec, k_vec, weight_matrix, legend_id )
% reaction_names - cell array with Reaction IDs
% reaction_mapping - from names to indices
% weight_matrix - Cell array with k as rows and gamma as columns
% legend_id - plot legend (1) or not (0)

% Set maximum number of subplots per figure to constant value - 25
% this implies subplot dimensions of max 5x5
number_of_subplots=25;

number_of_figures= ceil(size(reaction_names,1)/number_of_subplots);

if number_of_figures > 1
    for k=1:(number_of_figures-1)
        subplot_dimensions(k,1:2)=sqrt(number_of_subplots);
    end
        subplot_dimensions(number_of_figures,:)=ceil(sqrt(mod(numel(reaction_names),25)));
else
     subplot_dimensions(1,1:2)=ceil(sqrt(numel(reaction_names)));
end

if legend_id
  legend_names= cell(1, length(k_vec));
  for j=1:length(k_vec)
    legend_names{j}= sprintf('k= %d', k_vec(j));
  end
end
legend_names= char(legend_names); %A# for Matlab 6.5

for k=1:number_of_figures

  figure;
  hold on;
  for r=1:number_of_subplots
    if ((k-1)*25+r)<=numel(reaction_names)
      subplot(subplot_dimensions(k,1),subplot_dimensions(k,2),r);

      for i=1:length(gamma_vec)
        % check if reaction is part of the set of EMs
        index=mfindstr(cnap.reacID,reaction_names((25*(k-1)+r)));
	if(index==0)
		disp('ERROR: could not find name of reaction to plot');
		return;
	end	

        % set NaN values if reaction is not contained in EMs
        for j=1:length(k_vec)
          plot_value(j,i)= weight_matrix{j,i}(index);
        end

      end

      line(gamma_vec, plot_value);

      ylim([0, 1.1]);
      xlim([-0.1, gamma_vec(end)+0.1]);
      title(reaction_names((25*(k-1)+r)),'Interpreter','none');

      if (legend_id && r == 1) %A# one legend per figure
        lh= legend(char(legend_names));
        try get(lh, 'OuterPosition'); %A# works from Matlab 7 onwards
          set(lh, 'Location', 'NorthEast', 'Orientation', 'horizontal');
          pos= get(lh, 'OuterPosition');
          sz= get(lh, 'Position');
          pos(1)= (1 - sz(3))/2; %A# normalized units
          pos(2)= 0;
          set(lh, 'OuterPosition', pos);
        catch
          ; %A# can't do much in Matlab 6.5
        end
      end

    end
  end

  hold off;
end

end

%%

%%
function[rating_value]= rating1(Reac_weight_matrix, column_number)
% computes the ranking as importance at given gamma
% Reac_weight_matrix with ractions in rows and different 
% exponents in colums
% use only Reac_weight_matrix with columns from reference point
% edited 25.11.08


for i=1:size(Reac_weight_matrix,1)
    rating_value(:,i)=Reac_weight_matrix{i,column_number};
end

end
%%

%%
function[rating_value]= rating2(Reac_weight_matrix, interval)
% computes the ranking with simple difference as measure
% Reac_weight_matrix is cell array with k-exponents in rows and gamma in colums
% use only Reac_weight_matrix with columns from reference point
% edited 25.11.08

    for i=1:size(Reac_weight_matrix,1)
        rating_value(:,i) = Reac_weight_matrix{i,interval(2)} - Reac_weight_matrix{i,interval(1)};
    end
    
end
%%

%%





