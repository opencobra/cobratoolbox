function [consistModel,consistMatricesSUX,BlockedRxns] = prepareFastGapFill(model,listCompartments,epsilon,filename,dictionary_file,blackList)
%% function [consistModel,consistMatricesSUX,allBlockedRxns,solvableBlockedRxns] = prepareFastGapFill(model,epsilon,filename,dictionary_file,blackList)
%
% This function is required to generate the input data for fastGapFill.
%
% This function generate the input file (consistMatricesSUX) for
% fastGapFill.m. Please refer to Thiele et al, 2013 for more details.
% 
% This function is based on the fastCORE algorithm (Vlassis et al., 2013).
%
% Requires the openCOBRA toolbox
% http://opencobra.sourceforge.net/openCOBRA/Welcome.html
% 
% Getting the Latest Code From the Subversion Repository:
% Linux:
% svn co https://opencobra.svn.sourceforge.net/svnroot/opencobra/cobra-devel
%
%
% INPUT
% model                 Model structure
% listCompartments      List of intracellular compartments in the model
%                       (optional input, default compartments to be considered: '[c]','[m]','[l]','[g]','[r]','[x]','[n]')
% epsilon               Parameter for fastCore (optional input, default:
%                       1e-4). Please refer to Vlassis et al. to get more
%                       details on this parameter.
% filename              File name containing universal database (e.g., KEGG; optional input, default: reaction.lst)
% dictionary_file       List of universal database IDs and their counterpart in the model
%                        (optional input, default: KEGG_dictionary.xls)
% blackList             List of excluded reactions from the universal database
%                       (e.g., KEGG) (optional input, default: no
%                       blacklist)
%
% OUTPUT 
% consistModel          Flux consistent subnetwork of the input model
% consistMatricesSUX    Flux consistent SUX matrix, which contains the flux
%                       consistent S matrix (model), the universal database placed in all
%                       cellular compartments along with transport reactions for each metabolite
%                       from cytosol to compartment and exchange reactions for all extracellular
%                       metabolites.
% BlockedRxns           Blocked reactions in model
%
%
% June 2013
% Ines Thiele, http://thielelab.eu

%% 

if ~exist('epsilon','var') || isempty(epsilon)
    epsilon = 1e-4;
end

if ~exist('listCompartments','var') || isempty(listCompartments)
    [~,rem] = strtok(model.mets,'\[');
    listCompartments = unique(rem);
end

if ~exist('filename','var') || isempty(filename)
    % KEGG reaction list
    filename = 'reaction.lst';
end

if ~exist('dictionary_file','var') || isempty(dictionary_file)
    % dictionary (need to make your own dictionary file for each model, I made mine in an excel file)
    % column 1: all model metabolite abbreviations (without compartments)
    % column 2: the consistMatricesSUXextendedprime ID for each metabolite
    dictionary_file = 'KEGG_dictionary.xls';    
end

if regexp(dictionary_file,'.xls$')
    [~,dictionary,~] = xlsread(dictionary_file);
elseif regexp(dictionary_file,'(.tsv)|(.txt)$')
    file_handle = fopen(dictionary_file);
    u = textscan(file_handle,'%s\t%s');
    dictionary = {};
    for i = 1:length(u{1})
        dictionary{i,1} = u{1}{i};
        dictionary{i,2} = u{2}{i};
    end
    fclose(file_handle);
end

if ~exist('blackList','var') || isempty(blackList)
    %BlackList - reactions in KEGG to be omitted from SMILEY solutions
    blackList = {};
end

% create consistent model from model input
% consistent model does not contain any BlockedRxns anymore
[consistModel, BlockedRxns] = identifyBlockedRxns(model,epsilon);

% generate SUX
MatricesSUX = generateSUXComp(consistModel,dictionary, filename,blackList,listCompartments);

%postprocessing
%test consistency of MatricesSUX
A = fastcc(MatricesSUX, epsilon);
% A contains consistent reaction indices
%consistRxnsSUX = MatricesSUX.rxns(A);

%setdiff(MatricesSUX.rxns,consistRxns)
%consistMatricesSUX = extractSubNetwork(MatricesSUX,consistRxnsSUX);
inconsistRxnsSUX = setdiff(MatricesSUX.rxns,MatricesSUX.rxns(A));
MatricesSUX = removeRxns(MatricesSUX,inconsistRxnsSUX);

% now we need to add the reactions that we are currently blocked
inconsistRxns = BlockedRxns.allRxns;
rxnFormulas = printRxnFormula(model,inconsistRxns,false);
%consistMatricesSUXextended = addReactionGEM(consistMatricesSUX,model.rxns(inconsistRxns),model.rxnNames(inconsistRxns),rxnFormulas,model.rev(inconsistRxns),model.lb(inconsistRxns),model.ub(inconsistRxns),[],model.subSystems(inconsistRxns),model.grRules(inconsistRxns),model.rules(inconsistRxns));
%consistMatricesSUXextended = consistMatricesSUX;
[a,b] = size(MatricesSUX.S);

for i = 1 : length(rxnFormulas)
    MatricesSUX = addReaction(MatricesSUX,char(inconsistRxns(i)),char(rxnFormulas(i)));
end

% eliminate deadend metabolites and associated reactions from consistMatricesSUXextended
%consistMatricesSUXextendedprime = consistMatricesSUXextended;
EliM = [];
EliR = [];

m = 0;
while m == 0
    NullMet = zeros(size(MatricesSUX.S,1),1);
    NullRxns = zeros(size(MatricesSUX.S,2),1);
    for i = a+1 : length(MatricesSUX.mets)
        M=find(MatricesSUX.S(i,:)~=0);
        if length(M)==1
            NullMet(i)=1;
            % get corresponding reaction
            NullRxns(M(1))=1;
        end
    end
    if length(find(NullMet))==0
        m =1;
    else
        MatricesSUX.S(NullMet==1,:)=[];
        EliM=[EliM; MatricesSUX.mets(NullMet==1)];
        MatricesSUX.mets(NullMet==1)=[];
        MatricesSUX.b(NullMet==1)=[];
    end
    % ditto for rxns
    for i = b+1: size(MatricesSUX.S,2)
        if isempty(find(MatricesSUX.S(:,i)~=0))
            NullRxns(i)=1;
        end
    end
    
    EliR = [EliR; MatricesSUX.rxns(NullRxns==1)];
    MatricesSUX.S(:,NullRxns==1)=[];
    MatricesSUX.rxns(NullRxns==1)=[];
    %consistMatricesSUXextendedprime.rxnNames(NullRxns==1)=[];
    %consistMatricesSUXextendedprime.rxnFormulas(NullRxns==1)=[];
    %consistMatricesSUXextendedprime.subSystems(NullRxns==1)=[];
    MatricesSUX.lb(NullRxns==1)=[];
    MatricesSUX.ub(NullRxns==1)=[];
    MatricesSUX.rev(NullRxns==1)=[];
    MatricesSUX.rules(NullRxns==1)=[];
    MatricesSUX.grRules(NullRxns==1)=[];
    MatricesSUX.c(NullRxns==1)=[];
end

% recheck flux consistency
A = fastcc(MatricesSUX, epsilon);

consistRxnsModel = MatricesSUX.rxns(A);
inconsistRxnsSUXprime = setdiff(MatricesSUX.rxns,consistRxnsModel);
MatricesSUX = removeRxns(MatricesSUX,inconsistRxnsSUXprime);

% define Core reaction set
% consistent reactions of original model
C1 = ismember(MatricesSUX.rxns,consistModel.rxns);
% and remaining blocked reactions
C1(b+1:length(MatricesSUX.rxns))=1;
BlockedRxns.solvableRxns = MatricesSUX.rxns(b+1:length(MatricesSUX.rxns));
BlockedRxns.solvableFormula = printRxnFormula(MatricesSUX,BlockedRxns.solvableRxns,false);
C1 = find(C1);
MatricesSUX.C1 = C1;
consistMatricesSUX = MatricesSUX;
clear MatricesSUX;

%% 
% next step will be to run fastGapFill.m

  