function [taskReport essentialRxns taskStructure] = checkMetabolicTasks(model,inputFile,printOutput,printOnlyFailed,getEssential,taskStructure)
% Performs a set of simulations as defined in a task file
% to check if the model is able to pass a list of metabolic tasks.
% A metabolic task is defined as the capacity of producing a list of
% output products when ONLY a defined list of inputs substrates are
% available. In other words, a model successfuly pass a metabolic task if it is
% still a solvable LP problem when ONLY exchange reactions related to
% the inputs substrates and outputs products are allowed to carry fluxes
%
% USAGE:
%
%    [taskReport essentialReactions taskStructure] = checkMetabolicTasks(model, inputFile, printOutput, printOnlyFailed, getEssential, taskStructure)
%
% INPUTS:
%    model:              a model structure
%    inputFile:          a task list in Excel format. See the function
%                        parseTaskList for details (opt if taskStructure is
%                        supplied)
%
% OPTIONAL INPUTS:
%    printOutput:        true if the results of the test should be displayed
%                        (default - true)
%    printOnlyFailed:    true if only tasks that failed should be displayed
%                        (default - false)
%    getEssential:       true if the minimal number of reactions that need to be
%                        active to pass the task need to be computed
%                        (default - false)
%    taskStructure:      structure with the tasks, as from `parseTaskList`. If
%                        this is supplied then inputFile is ignored
%
% OUTPUTS:
%    taskReport:         structure with the results:
%
%                          * firstcolumn - id - cell array with the id of the task
%                          * secondcolumn - description - cell array with the description of the task
%                          * thirdcolumn - ok - boolean array with true if the task was successful
%
%    essentialRxns:      cell array containing the essential reactions required
%                        to pass a task
%
%    taskStructure:      structure with the tasks, as from `parseTaskList`.
%
% .. Authors:
%       - Originally written for RAVEN toolbox by Rasmus Agren, 2013-11-17
%       - Adapted for cobratoolbox and modified to rely only on flux constraints by Richelle Anne, 2017-05-18

if nargin < 3 || isempty(printOutput)
    printOutput=true;
end
if nargin < 4 || isempty(printOnlyFailed)
    printOnlyFailed=false;
end
if nargin < 5 || isempty(getEssential)
    getEssential=false;
end
% Generate a task structure from a list of task in excell format
if nargin < 6 || isempty(taskStructure)
  taskStructure=generateTaskStructure(inputFile);
end


%CHECK the format of the model
if size(model.rxns,2)>size(model.rxns,1)
    model.rxns=model.rxns';
end
if size(model.rxnNames,2)>size(model.rxnNames,1)
    model.rxnNames=model.rxnNames';
end
if size(model.rules,2)>size(model.rules,1)
    model.rules=model.rules';
end

if isfield(model,'grRules') && size(model.grRules,2)>size(model.grRules,1)
    model.grRules=model.grRules';
end

%Find all exchange/demand/sink reactions
Exchange = {};
for k=1:length(model.rxns)
    if sum(abs(model.S(:,k))) == 1
        Exchange(end+1) = model.rxns(k);
    end
end
Exchange=unique(Exchange);

%Close all exchange reactions
model.lb(findRxnIDs(model,Exchange))=0;
model.ub(findRxnIDs(model,Exchange))=0;


score=0;
totalTask=0;
notPresent=0;
taskReport={numel(taskStructure),3};
essentialRxns={numel(taskStructure)};
for i=1:numel(taskStructure)

    clear tModel
    tModel=model;
    modelMets=upper(tModel.mets);

    %%SETUP of the input model
    %suppress objective function if any
    tModel.c(tModel.c==1)=0;
    tModel.csense(1:length(model.b),1) = 'E';

    taskReport{i,1}=taskStructure(i).id;
    taskReport{i,2}=taskStructure(i).description;

    %Set the inputs
    if ~isempty(taskStructure(i).inputs)

        rxn_Subs={};
        for n=1:length(taskStructure(i).inputs)
            INPUT=taskStructure(i).inputs(n);
            INPUT=INPUT{1};
            match_INPUTS = strncmpi(INPUT,modelMets,length(INPUT(1:end-3)));
            match_INPUTS = modelMets(match_INPUTS==1);

            compSymbol={};
            for k=1:length(match_INPUTS)
                [tokens] = regexp(match_INPUTS{k},'(.+)\[(.+)\]','tokens');
                Symb = tokens{1}{2};
                compSymbol{end+1} = Symb;
            end

            % Set the exchange reactions for the inputs
            % If the metabolites already exist extracellularly
            AddExchange=0;
            if ismember('E',compSymbol)==1
                Tsp_ID=findRxnIDs(tModel,findRxnsFromMets(tModel,INPUT));
                Tsp_rxn = full(tModel.S(:,Tsp_ID));
                Nb_React=sum(abs(Tsp_rxn),1);

                % If an exchange reaction already exist
                if isempty(Nb_React==1)==0
                    ID_exc=find(Nb_React==1);
                    % Remove the existing exchange reaction
                    tModel=removeRxns(tModel,tModel.rxns(Tsp_ID(ID_exc)));
                    AddExchange=1;
                else
                    AddExchange=1;
                end
            else
            	AddExchange=1;
            end

            % Add a temporary exchange reaction that allows the import of
            % the metabolite
            if AddExchange==1
                % If the input is also member of the outputs, let the exchange reversible
                warning off
                if ismember(INPUT,taskStructure(i).outputs)==1
                	[tModel]=addReaction(tModel,['temporary_exchange_',INPUT(1:end-3)],[' <=> ',INPUT],[],[],-1000,1000,[], [], [], [], [], [],0);
                else
                	[tModel]=addReaction(tModel,['temporary_exchange_',INPUT(1:end-3)],[' => ',INPUT],[],[],taskStructure(i).LBin(n),taskStructure(i).UBin(n),[], [], [], [], [], [],0);
                end
                warning on
                rxn_Subs(end+1) = {['temporary_exchange_',INPUT(1:end-3)]};
            end

            % Definition of the compartment for the transport reaction
            if ischar(taskStructure(i).COMP)==1
                comp_used=taskStructure(i).COMP;
                if strcmpi(comp_used,'[e]')==1
                    continue
                end
            elseif ismember('C',compSymbol)==1
                comp_used='[c]';
            elseif ismember('M',compSymbol)==1
                comp_used='[m]';
            elseif ismember('N',compSymbol)==1
                comp_used='[n]';
            elseif ismember('X',compSymbol)==1
                comp_used='[x]';
            elseif ismember('L',compSymbol)==1
                comp_used='[l]';
            elseif ismember('R',compSymbol)==1
                comp_used='[R]';
            end

            % Set the transport reactions for the inputs
            % Find existing transporters associated with the input
            AddTransport=0;
            Tsp_ID=findRxnIDs(tModel,findRxnsFromMets(tModel,INPUT));
            Tsp_rxn = full(tModel.S(:,Tsp_ID));
            Nb_React=sum(abs(Tsp_rxn),1);

            % If free diffusion exist
            if isempty(Nb_React==2)==0
                Tsp_ID2=Tsp_ID(Nb_React==2);

                % Choose the transport reaction related to the defined
                % compartment (comp_used)
                Tsp_ID=Tsp_ID2(tModel.S((strcmpi(tModel.mets,([INPUT(1:end-3),comp_used]))==1),Tsp_ID2)~=0);
                if isempty(Tsp_ID)==0
                    % Remove the existing transport reaction
                    tModel=removeRxns(tModel,tModel.rxns(Tsp_ID));
                    AddTransport=1;
                else
                    AddTransport=1;
                end
            else
                AddTransport=1;
            end

            %Create a transport reaction
            if AddTransport==1
                warning off
                if ismember(INPUT,taskStructure(i).outputs)==1
                        %if the input is also output make the reaction
                        %reversible
                        [tModel]=addReaction(tModel,['temporary_trsp_',INPUT(1:end-3)],[INPUT,' <=> ',INPUT(1:end-3),comp_used],[],[],-1000,1000,[], [], [], [], [], [],0);
                else
                        [tModel]=addReaction(tModel,['temporary_trsp_',INPUT(1:end-3)],[INPUT,' => ',INPUT(1:end-3),comp_used],[],[],taskStructure(i).LBin(n),taskStructure(i).UBin(n),[], [], [], [], [], [],0);

                end
                warning on
                rxn_Subs(end+1) = {['temporary_trsp_',INPUT(1:end-3)]};
            end

        end
    end

    modelMets=upper(tModel.mets);
    [I J]=ismember(upper(taskStructure(i).inputs),modelMets);
    J=J(I);
    %Check that all metabolites are either real metabolites
    if ~all(I)
        fprintf(['ERROR: Could not find all inputs in "[' taskStructure(i).id '] ' taskStructure(i).description '"\n']);
    	taskReport{i,3}='Could not find all inputs';
    	notPresent=notPresent+1;
    end
    if numel(J)~=numel(unique(J))
    	dispEM(['The constraints on some input(s) in "[' taskStructure(i).id '] ' taskStructure(i).description '" are defined more than one time']);
    end

    %Set the outputs
    if ~isempty(taskStructure(i).outputs)

        rxn_Prod={};
        for n=1:length(taskStructure(i).outputs)
            OUTPUT=taskStructure(i).outputs(n);
        	OUTPUT=OUTPUT{1};

        	%skip the setup if output is also input as it has already been
        	%setup
            if ismember(upper(OUTPUT),upper(taskStructure(i).inputs))==1
            	continue
            end

            match_OUTPUTS = strncmpi(OUTPUT,modelMets,length(OUTPUT(1:end-3)));
            match_OUTPUTS = modelMets(match_OUTPUTS==1);
            compSymbol={};
            for k=1:length(match_OUTPUTS)
                [tokens] = regexp(match_OUTPUTS{k},'(.+)\[(.+)\]','tokens');
            	Symb = tokens{1}{2};
            	compSymbol{end+1} = Symb;
            end

            % Set the exchange reactions for the outputs
            % If the metabolites already exist extracellularly
            AddExchange=0;
            if ismember('E',compSymbol)==1
            	Tsp_ID=findRxnIDs(tModel,findRxnsFromMets(tModel,OUTPUT));
                Tsp_rxn = full(tModel.S(:,Tsp_ID));
                Nb_React=sum(abs(Tsp_rxn),1);
                % If an exchange reaction already exist
                if isempty(Nb_React==1)==0
                	ID_exc=find(Nb_React==1);
                    % Remove the existing exchange reaction
                    tModel=removeRxns(tModel,tModel.rxns(Tsp_ID(ID_exc)));
                    AddExchange=1;
                else
                    AddExchange=1;
                end
            else
                AddExchange=1;
            end

            % Add a temporary exchange reaction that allows the export of
            % the metabolite
            if AddExchange==1
                warning off
            	[tModel]=addReaction(tModel,['temporary_exchange_',OUTPUT(1:end-3)],[OUTPUT,' => '],[],[],taskStructure(i).LBout(n),taskStructure(i).UBout(n),[], [], [], [], [], [],0);
                warning on
                rxn_Prod(end+1) = {['temporary_exchange_',OUTPUT(1:end-3)]};
            end

            % Definition of the compartment for the transport reaction
            if ischar(taskStructure(i).COMP)==1
            	comp_used=taskStructure(i).COMP;
                if strcmpi(comp_used,'[e]')==1
                	continue
                end
            elseif ismember('C',compSymbol)==1
            	comp_used='[c]';
            elseif ismember('M',compSymbol)==1
            	comp_used='[m]';
            elseif ismember('N',compSymbol)==1
            	comp_used='[n]';
           	elseif ismember('X',compSymbol)==1
                comp_used='[x]';
            elseif ismember('L',compSymbol)==1
             	comp_used='[l]';
            elseif ismember('R',compSymbol)==1
                comp_used='[R]';
            end

            % Set the transport reactions for the outputs
            % Find existing transporters associated with the ouput
            AddTransport=0;
            Tsp_ID=findRxnIDs(tModel,findRxnsFromMets(tModel,OUTPUT));
            Tsp_rxn = full(tModel.S(:,Tsp_ID));
            Nb_React=sum(abs(Tsp_rxn),1);

            % If free diffusion exist
            if isempty(Nb_React==2)==0
                Tsp_ID2=Tsp_ID(Nb_React==2);

                % Choose the transport reaction related to the defined
                % compartment (comp_used)
                Tsp_ID=Tsp_ID2(tModel.S((strcmpi(tModel.mets,([OUTPUT(1:end-3),comp_used]))==1),Tsp_ID2)~=0);
                if isempty(Tsp_ID)==0
                    % Remove the existing transport reaction
                    tModel=removeRxns(tModel,tModel.rxns(Tsp_ID));
                    AddTransport=1;
                else
                    AddTransport=1;
                end
            else
                AddTransport=1;
            end

            %Create a transport reaction
            if AddTransport==1
                warning off
            	[tModel]=addReaction(tModel,['temporary_trsp_',OUTPUT(1:end-3)],[OUTPUT(1:end-3),comp_used,' => ',OUTPUT],[],[],taskStructure(i).LBout(n),taskStructure(i).UBout(n),[], [], [], [], [], [],0);
                warning on
                rxn_Prod(end+1) = {['temporary_trsp_',OUTPUT(1:end-3)]};
            end
        end
    end

    modelMets=upper(tModel.mets);
    [I J]=ismember(upper(taskStructure(i).outputs),modelMets);
    J=J(I);

    %Check that all metabolites are either real metabolites
    if ~all(I)
        fprintf(['ERROR: Could not find all outputs in "[' taskStructure(i).id '] ' taskStructure(i).description '"\n']);
        taskReport{i,3}='Could not find all outputs';
        notPresent=notPresent+1;
    end
    if numel(J)~=numel(unique(J))
        dispEM(['The constraints on some output(s) in "[' taskStructure(i).id '] ' taskStructure(i).description '" are defined more than one time']);
    end


	%Solve the constrained problem
	tModel.csense(1:length(tModel.mets),1) = 'E';
	tModel.osense = -1;
	tModel.A=tModel.S;
	sol=solveCobraLP(tModel);

    if ~isempty(sol.full)
        if sum(abs(sol.full))~=0
            if taskStructure(i).shouldFail==0
                taskReport{i,3}='true';
                if printOnlyFailed==false && printOutput==true
                    fprintf(['PASS: [' taskStructure(i).id '] ' taskStructure(i).description '\n']);
                    score=score+1;
                end
                %Calculate the minimal number of reactions to pass the task
                if getEssential==true
                    [Rxns_taskEssential]=essentialRxnsTasks(tModel);
                    essentialRxns{i}= Rxns_taskEssential';

                end
            else
                taskReport{i,3}='PASS (should fail)';
                if printOutput==true
                    fprintf(['PASS (should fail): [' taskStructure(i).id '] ' taskStructure(i).description '\n']);
                end
            end
        else
            if taskStructure(i).shouldFail==0
                taskReport{i,3}='FAIL (should NOT fail)';
                if printOutput==true
                    fprintf(['FAIL: [' taskStructure(i).id '] ' taskStructure(i).description '\n']);
                end
            else
                taskReport{i,3}='FAIL (should fail)';
                if printOnlyFailed==false && printOutput==true
                    fprintf(['FAIL (should fail): [' taskStructure(i).id '] ' taskStructure(i).description '\n']);
                    score=score+1;
                end
            end
        end
    else
        if taskStructure(i).shouldFail==0
            taskReport{i,3}='FAIL (should NOT fail)';
            if printOutput==true
                fprintf(['FAIL: [' taskStructure(i).id '] ' taskStructure(i).description '\n']);
            end
        else
            taskReport{i,3}='FAIL (should fail)';
            if printOnlyFailed==false && printOutput==true
                fprintf(['FAIL (should fail): [' taskStructure(i).id '] ' taskStructure(i).description '\n']);
                score=score+1;
            end
        end
    end
totalTask=totalTask+1;
end

fprintf(['Pass ',num2str(score),' over ',num2str(totalTask),' metabolic tasks tested','\n']);
fprintf([num2str(notPresent),' failed metabolic task are due to absence of metabolites in the model','\n']);
taskReport{end+1,1}='Final Score';
taskReport{end,3}=[num2str(score),'/',num2str(i)];
taskReport{end+1,1}='Not present in the model';
taskReport{end,3}=num2str(notPresent);