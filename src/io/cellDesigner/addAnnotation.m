function [var] = addAnnotation(fname,fname_out,infix,model,infix_type)

% Retrieve omics data from a COBRA model structure and add them to a
% CellDesginer XML file; The omics data will be shown as texts in
% CellDesigner or ReconMap online.
%
%
%INPUTS
%
% fname      An XML file to be modified to include annotations
% fanme_out  the name of the output XML file
% infix      The metabolite/reaction IDs to be used to retrieve omics data
%            in the COBRA model structure.
% model      a COBRA model structure that contains the annotations which
%            can be retrieved by using the infix as the index value.

%OPTIONAL INPUT
%
% infix_type      'name' or 'id'; 1) 'name'indicates that 'infix' contains
%                 a list of reaction names, which are normally used in a
%                 COBRA model structure. 2)'id' indicates that 'infix'
%                 contains a list of IDs used in CellDesigner such as
%                 're32'.
%
%OPTIONAL OUTPUT
%
% var        the content of the moidfied XML file with annotations
%
%
% Longfei Mao Jan/2015


if nargin<6;
    list=fieldnames(model);  % Extract all fields of the model structure.
end


if nargin<5
    prefix='name="';  % for metabolites in recon2

else
    if strcmp(infix_type, 'id');

        prefix='id="';
    elseif strcmp(infix_type,'name');
        prefix='name="';
    else
        error('the type of the list should be set ethier as "id" or "name"')
    end
end


%
if nargin<4

    model=recon2;
end


if nargin<3

    prefix='id="';
    infix='r1922';
    suffix='"';
    rxnName=[prefix,infix,suffix];

end




suffix='"';

% rxnName={};



for d=1:length(infix)
    rxnName(d)=strcat(prefix,infix(d),suffix);
end


if nargin<2 || isempty(fname_out)

    [fname_out, fpath]=uiputfile('*.xml','CellDesigner SBML Source File');
    if(fname_out==0)
        return;
    end
    f_out=fopen([fpath,fname_out],'w');
else
    f_out=fopen(fname_out,'w');
end

if nargin<1 || isempty(fname)
    [fname, fpath]=uigetfile('*.xml','CellDesigner SBML Source File');
    if(fname==0)
        return;
    end
    f_id=fopen([fpath,fname],'r');
else
    f_id=fopen(fname,'r');

end


numOfLine=0;

% rem=fgets(f_id); numOfLine=numOfLine+1;

%%% the template for CellDesginer or the online map system to recognise

preTxt(1).str='<notes>';
preTxt(2).str='<html xmlns="http://www.w3.org/1999/xhtml">';
preTxt(3).str='<head>';
preTxt(4).str='<title/>';
preTxt(5).str='</head>';
preTxt(6).str='<body>';

preTxt(7).str='</body>';
preTxt(8).str='</html>';
preTxt(9).str='</notes>';

% rem=fgets(f_id);

showprogress(0,'The annotation of the file using free-text types of data is progressing');

MainTxt={};


while ~feof(f_id);

    numOfLine=numOfLine+1;
    rem=fgets(f_id);
    %     try
    MainTxt(numOfLine,1)=cellstr(rem);

    %     catch
    %         disp(rem);
    %     end

end


total_length=length(MainTxt);

disp(total_length);

n=0;  % the line number of the code in the new file that is copied from the original file.
t=1;


for i=1:10;
    ct(i,1)=i*total_length/10;
end

% met_str='name="'

met_str='<species metaid="'  % keywords in the line describing the metabolite.

rxn_str='<reaction metaid="' % keywords in the line describing the reaction.


MainTxt_new={};



met_ind(1).str='<listOfSpecies>';
met_ind(2).str='</listOfSpecies>';

rxn_ind(1).str='<listOfReactions>';
rxn_ind(2).str='</listOfReactions>';

metKeyword=0; % the variable that stores a value determining whether the metabolite annotations need to be added.
rxnKeyword=0; % a value of zero indictates that by default the reaction annotations will not be added.


met_str='<species metaid="'

rxn_str='<reaction metaid="'

% SecKeyStr='</celldesigner:extension>'





for t=1:total_length   % go through each line of the SBML file.
    if ismember(t, ct)~=0||t==total_length;

        disp(t)
        showprogress(t/total_length);
    end
    n=n+1;

    MainTxt_new(n,1)=MainTxt(t);

    metKey_1=strfind(MainTxt(t),met_ind(1).str);
    metKey_2=strfind(MainTxt(t),met_ind(2).str);
    rxnKey_1=strfind(MainTxt(t),rxn_ind(1).str);
    rxnKey_2=strfind(MainTxt(t),rxn_ind(2).str);
    if (~isempty(metKey_1{1,1}))
        metKeyword=1;
        fprintf('found the metKeyword: %s',MainTxt{t});
    elseif (~isempty(metKey_2{1,1}))
        metKeyword=0;
        fprintf('found the metKeyword:  %s',MainTxt{t});
    end
    if (~isempty(rxnKey_1{1,1}))
        rxnKeyword=1;

    elseif (~isempty(rxnKey_2{1,1}))
        rxnKeyword=0;
    end

    if metKeyword==0&&rxnKeyword==0;
        continue;
    end

    % line_st_2=strfind(MainTxt(t),SecKeyStr)

   % if ~isempty(line_st_2{1})

        if ((~isempty(strfind(MainTxt(t),met_str)))||(~isempty(strfind(MainTxt(t),rxn_str))))&&(metKeyword==1||rxnKeyword==1);
            for in=1:length(rxnName);% for in=1:length(infix); go though each line of the Rxn List.

                % disp(length(rxnName));
                line_st=strfind(MainTxt(t),rxnName{in});
                if ~isempty(line_st{1})  %isempty(line_st)~=0; % the line contains the rxn keywords

                    % msgbox('reaction found');
                    disp(line_st)
                    %%%%%% preTxt (1:6)
                    for p=1:6;

                        MainTxt_new(n+p,1)=cellstr(preTxt(p).str);

                    end
                    n=n+p;
                    total_length=total_length+p;

                    %                 try
                    %                                  try

                    [rxnItems,rxnContent]=contructItems(infix(in),model,list);

                    %                                  catch
                    %
                    %                                      disp(infix(in));
                    %                                      error('stop');
                    %                                  end
                    %                 catch
                    %                     size(infix)
                    %                     disp(in)
                    %                     infix(in)
                    %                 end
                    %
                    %                 if strcmp(infix(in),'3ohodcoa[r]');
                    %                     disp('nice');
                    %                 end

                    for k=1:length(rxnItems);  %
                        %                    rxnContent is a strcuture

                        %                    rxnContent.(k)
                        %disp(n);
                        %disp(k);

                        disp(MainTxt_new(n,1));
                        disp('%%%%%%%%%%%%');
                        disp(rxnItems(k));
                        MainTxt_new(n+k,1)=rxnItems(k);

                    end
                    n=n+k;
                    total_length=total_length+k;


                    for p_e=1:3    % text after the main text

                        MainTxt_new(n+p_e,1)=cellstr(preTxt(p_e+6).str);

                    end
                    n=n+p_e;
                    total_length=total_length+p_e;

                end

            end

        end
    end

%end


var=MainTxt_new;


for ww=1:length(MainTxt_new);

    fprintf(f_out,'%s\n',char(MainTxt_new(ww)));

end

fclose(f_out);

end

% <body>
% Symbol:
% Abbreviation: ABREVIATION
% Formula: FORMULA
% MechanicalConfidenceScore: MCS
% LowerBound: LB
% UpperBound: UB
% Subsystem: SUBSYSTEM
% GeneProteinReaction: GPR (using miriam registry format, for example: &quot;(urn:miriam:ccds:CCDS8639.1) or (urn:miriam:ccds:CCDS26.1) or (urn:miriam:ccds:CCDS314.2) or (urn:miriam:ccds:CCDS314.1)&quot;)
% Synonyms:
% DESCRIPTION
% </body>


%%%%%%%%%%%%%%%%%%%%%%%%


function [finalItems,finalContent]=contructItems(index,model,list)

% rxnItems    an array of combined Keywords and Contents

% rxnContent   an array of Contents

% list        a list of field names (it is set to be all fields of a COBRA
%             model structure

infix=index;

expr='\s\w*';
infix=regexp(infix{1},expr,'match');

if isempty(infix)||size(infix,2)>1
    infix=index
end

infix_trimed=strtrim(infix);
%infix_trimed=cellstr(infix_trimed);
%%
try
    num=find(strcmp(model.rxns(:,1),infix_trimed)); %% find the reaction number in the model.
catch
    disp(infix_trimed);
end

para='rxn';
if isempty(num)
    num=find(strcmp(model.mets(:,1),infix_trimed));
    if ~isempty(num)
        para='met';
    else
        msg=strcat(infix, ' cannot be found in both reaction and metabolite name lists');
        para='not_found';
        warndlg(msg,'Warning!');
    end
elseif ~isempty(find(strcmp(model.mets(:,1),infix_trimed), 1))        %%%%% Error! the reaction and metabolite use the same name.
    msg=strcat(infix, ' is used as a reaction name as well as a metabolite name');
    warndlg(msg,'Warning!');
end

%%%%% below should be added to addAnnotation function too

finalItems={};
listKey={};

%%%%%%


[m,r]=size(model.S);

and=': ';


ClassName={'numeric','char','cell','logical'}; % set the data types that will be recongised by the annotation function.

if strcmp(para,'met')


    % produce the prefix
    % for i=1:length(list);
    %     listKey(i,1)=strcat(list(i),and);
    % end

    % check if the field exist
    % % isfield(recon2,lower(list(8)));


    new_l=0;
    for l=1:length(list)

        for i=1:length(ClassName)


            if m==size(model.(list{l}),1);
                if isfield(model,list{l})&&~strcmp(list{l},'S');

                    type=isa(model.(list{l}),ClassName{i});


                    if type~=0;
                        new_l=new_l+1;

                        listClass(new_l)=ClassName(i)
                        % try
                        finalContent.(list{l})=model.(list{l})(num); % intialise the variables.
                        listKey(new_l,1)=strcat(list(l),{and});
                        if strcmp(ClassName{i},'numeric')||strcmp(ClassName{i},'logical')
                            finalItems(new_l)=strcat(listKey(new_l,1),num2str(finalContent.(list{l}))); % Convert the numbers into strings.
                        else
                            %                    try
                            finalItems(new_l)=strcat(listKey(new_l,1),finalContent.(list{l}));
                            %                    catch
                            %                        disp(finalContent.(list{l}))
                            %                        disp(listKey(l,1));
                            %                    end
                        end

                        % catch
                        %   disp(list{l})
                        % end

                    end
                else
                    finalContent.(list{l})='no data found in the COBRA model structure';
                    finalItems(1)=strcat(infix,' not found in both met and rxn lists');
                end
            end
        end
    end

elseif strcmp(para,'rxn');

    new_l=0;
    for l=1:length(list)

        for i=1:length(ClassName)


            if r==size(model.(list{l}),1);  %% number of elements in the array !!!
                if isfield(model,list{l})&&~strcmp(list{l},'S');

                    type=isa(model.(list{l}),ClassName{i});


                    if type~=0;
                        new_l=new_l+1;

                        listClass(new_l)=ClassName(i)

                        % try
                        finalContent.(list{l})=model.(list{l})(num); % intialise the variables.

                        finalContent.(list{l})=strrep(finalContent.(list{l}),'&',' and '); % XML these special characters in
                        finalContent.(list{l})=strrep(finalContent.(list{l}),'<','(;');
                        finalContent.(list{l})=strrep(finalContent.(list{l}),'>',')');

                        listKey(new_l,1)=strcat(list(l),{and});
                        if strcmp(ClassName{i},'numeric')||strcmp(ClassName{i},'logical')
                            finalItems(new_l)=strcat(listKey(new_l,1),num2str(finalContent.(list{l}))); % Convert the numbers into strings.
                        else
                            %                    try
                            finalItems(new_l)=strcat(listKey(new_l,1),finalContent.(list{l}));
                            %                    catch
                            %                        disp(finalContent.(list{l}))
                            %                        disp(listKey(l,1));
                            %                    end
                        end

                        % catch
                        %   disp(list{l})
                        % end

                    end
                else
                    finalContent.(list{l})='no data found in the COBRA model structure';
                    finalItems(1)=strcat(infix,' not found in both met and rxn lists');
                end
                %             else
                %                 error('The COBRA model structure doesn''t contain the sthoichometric matrix');
            end
        end
    end

elseif strcmp(para,'not_found');
    finalItems(1)=strcat(infix,' not found in both met and rxn lists');
    finalContent(1)=strcat(infix, ' not found in both met and rxn lists');
end



end


%
%
% function [finalItems,finalContent]=contructItems(index,model)
%
% % rxnItems    an array of combined Keywords and Contents
%
% % rxnContent   an array of Contents
%
%
% infix=index;
%
% expr='\s\w*';
% infix=regexp(infix{1},expr,'match');
%
% if isempty(infix)||size(infix,2)>1
%     infix=index
% end
%
% infix_trimed=strtrim(infix);
% %infix_trimed=cellstr(infix_trimed);
% %%
% try
% num=find(strcmp(model.rxns(:,1),infix_trimed)); %% find the reaction number in the model.
% catch
%     disp(infix_trimed);
% end
%
% para='rxn';
% if isempty(num)
%     num=find(strcmp(model.mets(:,1),infix_trimed));
%     if ~isempty(num)
%         para='met';
%     else
%         msg=strcat(infix, ' cannot be found in both reaction and metabolite name lists');
%         para='not_found';
%         warndlg(msg,'Warning!');
%     end
% elseif ~isempty(find(strcmp(model.mets(:,1),infix_trimed), 1))        %%%%% Error! the reaction and metabolite use the same name.
%     msg=strcat(infix, ' is used as a reaction name as well as a metabolite name');
%     warndlg(msg,'Warning!');
% end
%
% %% the annotation template for metabolites
%
% if strcmp(para,'met')
%     metKeywords={
%         'Symbol: ';
%         'Abbreviation: ';
%         'ChargedFormula: ';
%         'Charge: ';
%         'Synonyms: ';
%         'metInchiString: ';
%         'Description: '
%         };
%     %%% assign a initial value of ' ' to the list of the variables.
%
%     Symbol=' ';
%     Abbreviation=' ';
%     ChargedFormula=' ';
%     Charge=' ';
%     Synonyms=' ';
%     metInchiString=' ';
%     Description=' ';
%
%
%     if ~isempty(num)
%
%         if ~isfield(model,'Symbol');
%             Symbol=' ';
%         else
%             Symbol=model.Symbol(num);
%         end
%
%         if ~isfield(model,'Synonyms');
%             Synonyms=' ';
%         end
%         if ~isfield(model,'metInchiString')
%             metInchiString=' ';
%         else
%             metInchiString=model.metInchiString(num);
%
%         end
%
%         if ~isfield(model,'Description')
%             Description=' ';
%         else
%             Description=model.Description(num);
%         end
%
%
%
%         Abbreviation=model.mets(num);
%         ChargedFormula=model.metFormulas(num);
%         Charge=model.metCharge(num);
%         Synonyms=model.metNames(num);
%
%
%     end
%
%     if isnumeric(Charge)
%         Charge=num2str(Charge);
%     end
%
%
%
%     %%%%%%%%%%%%%%%%%%%%%%%%
%
%     metContent=[
%         Symbol(1);
%         Abbreviation(1);
%         ChargedFormula(1);
%         Charge(1);
%         Synonyms(1);
%         metInchiString(1);
%         Description(1);
%         ];
%
%     %%%%%
%
%     for f=1:length(metContent);
%
%         finalItems(f)=strcat(metKeywords(f),metContent(f));
%     end
%
%
%     finalContent=metContent;
% elseif strcmp(para,'rxn')
%
%
%
%     %% check if annotation field for reactions of the COBRA model are avaliable and use a initial value of ' ' as the default annotation.
%
%     Abbreviation=model.rxns(num);
%     Description=model.rxnNames(num);
%
%     if ~isfield(model,'MCS');
%         MCS=' ';
%     end
%
%
%     Ref=' ';
%
%     ECNumber=model.rxnECNumbers(num);
%     KeggID=model.rxnKeggID(num);
%
%     LastModified=' ';
%
%     LB=model.lb(num);
%     UB=model.ub(num);
%
%     if isnumeric(LB)|isnumeric(UB)
%         LB=num2str(LB);
%         UB=num2str(UB);
%     end
%     if ~isfield(model,'grRules');
%         grRules=' ';
%     end
%
%     if exist('CS')~=1;
%         CS=1;
%     end
%
%     if isnumeric(CS)
%         CS=num2str(CS);
%     end
%
%     GPR=model.grRules(num);
%
%     Subsystem=model.subSystems(num);
%
%     %%
%
%     % MCS-CS: Mechanical Confidence Score CS: Confidence Score - LB: Lower
%     % Bound - UB: Upper Bound MCS: Mechanical Confidence Score - GPR: Gene
%     % Protein Reaction)
%
%     %% the annotation template for metabolites
%
%
%
%     rxnKeywords={
%         'Abbreviation: ';
%         'Description: ';
%         'MCS: ';
%         'Ref: ';
%         'ECNumber: ';
%         'KeggID: ';
%         'LastModified: ';
%         'LB: ';
%         'UB: ';
%         'CS: ';
%         'GPR: ';
%         'Subsystem: '};
%
%     finalContent=[
%         Abbreviation(1);
%         Description(1);
%         MCS(1);
%         Ref(1);
%         ECNumber(1);
%         KeggID(1);
%         LastModified(1);
%         LB;
%         UB;
%         CS;
%         GPR;
%         Subsystem];
%
%     %%
%
%     for d=1:length(finalContent);
%         finalItems(d)=strcat(rxnKeywords(d),finalContent(d));
%     end
% elseif strcmp(para,'not_found');
%     finalItems(1)=strcat(infix,' not found in both met and rxn lists');
%     finalContent(1)=strcat(infix,' not found in both met and rxn lists');
% end
%
% end
