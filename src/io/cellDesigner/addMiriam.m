function [fname_out,var] = addMiriam(fname,fname_out,infix,model,infix_type,list,miriam_path)

% Add Miriam information to CellDesigner XML file; the Miriam information
% is retrieved from a COBRA model structure using Metbolite/Reaction IDs as
% the name of entry. The omics data will be shown as texts hyperlinking to
% external databases in CellDesigner or ReconMap online.
%
%
%INPUTS
%
% fname       An XML file to be modified to include annotations.
% fanme_out   The name of an output XML file.
% infix       A list of metabolite/reaction IDs to be used to retrieve omics data
%             in the COBRA model structure.
% model       a COBRA model structure contains the annotations that can be
%             retrieved by using the infix as the index value.
% list        Column 1 stores a list of the fieldnames of the COBRA model
%             strucutres that contains MIRIAM information; Column 2 stores
%             a list of MIRIAM types corresponding to each field; column 3
%             stores a list of relations
%
%
%
%
%OPTIONAL INPUT
% infix_type      'name' or 'id'; 1) 'name'indicates that 'infix' contains
%                 a list of reaction names, which are normally used in a
%                 COBRA model structure. 2)'id' indicates that 'infix'
%                 contains a list of IDs used in CellDesigner such as
%                 're32'.
% miriam_path     the file path of the miriam registry's dataset (*.mat).
%
%
%
%OPTIONAL OUTPUT
%
% var         the content of the modified XML file with annotations
%
%
%EXAMPLE:
%
% the following example command is intended to add all MIRIAM information
% for the metabolites in the ReconMap
%
% [var]=addMiriam('ReconMap.xml','ReconMap_annotated.xml',recon2.mets(:),recon2)
%
%
%
% Longfei Mao May/2015
%
%

if nargin<7;
    if exist('MIRIAM','var')==1
        miriam=MIRIAM;
    else

    miriam_path='MIRIAM.mat';
    miriam=load(miriam_path);
    miriam=miriam.MIRIAM;
    end

end


if nargin<6;
    list=fieldnames(model);  % Extract all fields of the model structure.
end

if nargin<5||isempty(infix_type)
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


if nargin<4
    model=recon2;
end

if nargin<3
    prefix='id="';
    infix='r1922';
    suffix='"';
    rxnName=[prefix,infix,suffix];
end

% prefix='name="';  % for metabolites in recon2

% prefix='id="'; % for example file

%

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

%%% the template for online map system to recognize

listRelations={'bqmodel:is';
    'bqmodel:isDescribedBy';
    'bqbiol:is';
    'bqbiol:hasPart';
    'bqbiol:isPartOf';
    'bqbiol:isVersionOf';
    'bqbiol:hasVersion';
    'bqbiol:isHomologTo';
    'bqbiol:isDescribedBy';
    'bqbiol:isEncodedBy';
    'bqbiol:encodes';
    'bqbiol:occursIn'}

if size(list,2)<3
    list(:,3)=listRelations(randi([1,12],[size(list,1),1])) % randomaly generate a list of the relations
end


prefix_txt(1).str='<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">';
prefix_txt(2).str='<rdf:Description rdf:about="#'; % s1">'



prefix_txt(3).str='<bqmodel:is>'



prefix_txt(4).str='<rdf:Bag>';

met_ind(1).str='<listOfSpecies>';
met_ind(2).str='</listOfSpecies>';

rxn_ind(1).str='<listOfReactions>';
rxn_ind(2).str='</listOfReactions>';


% prefix(5).str='<rdf:li rdf:resource="urn:miriam:obo.chebi:CHEBI%3A12335"/>'

postfix(1).str='</rdf:Bag>';

postfix(2).str='</bqmodel:is>'; %%

% postfix(3).str='<bqmodel:is>'
% postfix(4).str='<rdf:Bag>'

postfix(3).str='</rdf:Description>';
postfix(4).str='</rdf:RDF>';
% rem=fgets(f_id);

showprogress(0,'The annotation of the file using MIRIAM registry datasets is progressing');
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

met_str='<species metaid="'

rxn_str='<reaction metaid="'

SecKeyStr='</celldesigner:extension>'

% MainTxt_new={};
time=0; % use to check if the warning dialog is displayed already.

n_old=0;
found=0; % SecKeyStr is found in the line

metKeyword=0; % the variable that stores a value determining whether the metabolite annotations need to be added.
rxnKeyword=0; % a value of zero indictates that by default the reaction annotations will not be added.

for t=1:total_length   % go through each line of the SBML file.

    if ismember(t, ct)~=0||t==total_length; % estimiate the time interval.

        disp(t);
        showprogress(t/total_length);

    end
    n=n+1;
    %if t==1;
    MainTxt_new(n,1)=MainTxt(t);

    % t=t+1;

    %     try
    %         (~isempty(strfind(MainTxt(t),met_str)))
    %     catch
    %         disp(n);
    %         disp(t);
    %         disp(MainTxt_new(n));
    %         disp(MainTxt(t));
    %         size(MainTxt_new);
    %         size(MainTxt);
    %     end
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

    if (~isempty(strfind(MainTxt(t),met_str))||~isempty(strfind(MainTxt(t),rxn_str)))&&(metKeyword==1||rxnKeyword==1) %||(~isempty(strfind(MainTxt(t),met_str))));

        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        disp('met_str found');

        for in=1:length(rxnName);% for in=1:length(infix); go though each line of the Rxn List.

            % disp(length(rxnName));

            line_st=strfind(MainTxt(t),rxnName{in});

            if ~isempty(line_st{1})  %isempty(line_st)~=0; % the line contains the rxn keywords
                disp('%%%%%%%%%%%%%%%%% dddd%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

                str=[infix{in},'">'];

                %%%%%%%%%%%%%%%%%%%%%%%%%%
                prefix_txt(2).str='<rdf:Description rdf:about="#'; % s1">'
                %%%%%%%%%%%%%%%%%%%%%%%%%%


                prefix_txt(2).str=strcat(prefix_txt(2).str,str);

                found=1


                %
            end
        end
    end
    line_st_2=strfind(MainTxt(t),SecKeyStr)

    if ~isempty(line_st_2{1})&&found==1


        %                         break
        %

        %%% new line
        %  n=n+1;
        %  MainTxt_new(n,1)=MainTxt(t);


        % msgbox('reaction found');
        disp(line_st)

        %%%%%% preTxt (1:4)
        for p=1:2;  % two lines of codes before the main content
            MainTxt_new(n+p,1)=cellstr(prefix_txt(p).str);
        end
        n=n+p;
        total_length=total_length+p;
        [rxnItems,rxnContent,relation]=constructItems(infix(in),model,list,miriam,listRelations); %% retrieve the lines of codes
        if isempty(relation)
            if time==0;
            warndlg('No Miriam relations are defined. No Miriam information will be added to the XML file. Please check whether the correct fieldnames refering to MIRIAM information are present in the COBRA model strcuture');
            time=1;
            end

        continue;
        end
        %% relation: there are 12 types of relations
        %%%%%%%% rxnContent is a structure and the length of the variable
        %%%%%%%% is 1 .
        for k=1:length(rxnItems);
            for p=1:2;  % two another lines of codes before the main contents
                prefix_txt(3).str=relation{k,1};
                MainTxt_new(n+p,1)=cellstr(prefix_txt(p+2).str);

            end
            n=n+p;
            total_length=total_length+p;


            %             rxnContent(k)
            %             disp(n);
            %             disp(k);

            disp(MainTxt_new(n,1));
            disp('%%%%%%%%%%%%');
            disp(rxnItems(k));

            MainTxt_new(n+1,1)=rxnItems(k); % the main content

            n=n+1;
            total_length=total_length+k;

            for p_e=1:2 % two another lines of codes after the main contents
                postfix(2).str=relation{k,2};
                MainTxt_new(n+p_e,1)=cellstr(postfix(p_e).str);

            end
            n=n+p_e;
            total_length=total_length+p_e;

        end





        for p_e=1:2   % two lines of codes after the main content

            MainTxt_new(n+p_e,1)=cellstr(postfix(p_e+2).str);

        end
        n=n+p_e;
        total_length=total_length+p_e;
        disp(total_length)
        found=0;
    end
end


var=MainTxt_new;


for ww=1:length(MainTxt_new);


    %fprintf(f_out,'%s\n',char(MainTxt_new(ww)));
    fprintf(f_out,'%s\n',char(MainTxt_new{ww}));


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


function [finalItems,finalContent,relation]=constructItems(index,model,list,miriam,listRelations)

% rxnItems     an array of combined Keywords and Contents
% rxnContent   an array of Contents
% list         list of the types of the Miriam annotaitons to be added to
%              the XML
% miriam       a spreadsheet


% finalItems=[];
% finalContent=[];


keyStr='<rdf:li rdf:resource="'

relation={};

%%

% num=find(strcmp(model.rxns(:,1),infix)); %% find the reaction number in the model.
% para='rxn';
%
%
% if isempty(num)
%     num=find(strcmp(model.mets(:,1),infix));
%     para='met';
%
% elseif ~isempty(find(strcmp(model.mets(:,1),infix), 1))        %%%%% Error! the reaction and metabolite use the same name.
%
%     msg=strcat(infix, ' is used as a reaction name as well as a metabolite name');
%     warndlg(msg,'Warning!');
%
% end


infix=index;

expr='\s\w*';
infix=regexp(infix{1},expr,'match');

if isempty(infix)||size(infix,2)>1
    infix=index
end

infix_trimed=strtrim(infix);



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

% and=': ';


prefix_key_1='<'
postfix_key_1='</'

prefix_key_2={' '};
prefix_key_3='>';%%%



ClassName={'numeric','char','cell','logical'}; % set the data types that will be recongised by the annotation function.


if strcmp(para,'met')


    % produce the prefix
    % for i=1:length(list);
    %     listKey(i,1)=strcat(list(i),and);
    % end

    % check if the field exist
    % % isfield(recon2,lower(list(8)));


    new_l=0;
    for l=1:size(list,1)  % the total list

        for i=1:length(ClassName)


            if m==size(model.(list{l,1}),1);
                if isfield(model,list{l,1})&&~strcmp(list{l,1},'S');

                    type=isa(model.(list{l,1}),ClassName{i});


                    if type~=0;
                        new_l=new_l+1;

                        listClass(new_l)=ClassName(i);

                        % try
                        finalContent.(list{l,1})=model.(list{l,1})(num); % intialise the variables.
                        % listKey(new_l,1)=strcat(list(l,1),{and});

                        %% extract the URNs from the MIRIAM registry's dataset
                        ind_Mi =find(strcmp(list{l,2},miriam(:,4))) % column 2 stores namespaces of Miriam information, whereas column 4 stores the names.
                        entry=miriam{ind_Mi(1),7};   % column 7 stores the URNs of Miriam information
                        entry=[entry,':'];
                        listKey{new_l,1}=strcat(keyStr,entry); % <rdf:li rdf:resource=" + urn:miriam:chebi =<rdf:li rdf:resource="urn:miriam:chebi

                        Index_Relation=find(ismember(listRelations,list(l,3)));

                        prefix_key_2=listRelations(Index_Relation);

                        prefix_key_2_new=strcat(prefix_key_2,prefix_key_3);
                        relation{new_l,1}=strcat(prefix_key_1,prefix_key_2_new);
                        relation{new_l,2}=strcat(postfix_key_1,prefix_key_2_new);
                        %                         if strcmp(ClassName{i},'numeric')||strcmp(ClassName{i},'logical')
                        %                             finalItems(new_l)=strcat(listKey(new_l,1),num2str(finalContent.(list{l,1}))); % Convert the numbers into strings.
                        %                         else
                        %                    try
                        finalItems(new_l)=strcat(listKey(new_l,1),finalContent.(list{l,1})); %<rdf:li rdf:resource="urn:miriam:chebi
                        %                    catch
                        %                        disp(finalContent.(list{l,1}))
                        %                        disp(listKey(l,1));
                        %                    end
                        % end

                    end
                else
                    % relation(new_l)=strcat(infix,' not found in both met and rxn lists');
                    finalContent.(list{l,1})='no data found in the COBRA model structure';
                    finalItems(1)=strcat(infix,' not found in both met and rxn lists');
                end

            else

                finalContent.(list{l,1})='no suitalbe types of annotations found in the COBRA model structure';
                finalItems(1)=strcat(infix,'no suitalbe types of annotations found in the COBRA model structure');

            end
        end
    end

    postfix_key='"/>';

    for i=1:length(finalItems);
        finalItems{i}=strcat(finalItems{i},postfix_key)
    end

elseif strcmp(para,'rxn');

    new_l=0;
    for l=1:length(list)

        for i=1:length(ClassName)


            if r==size(model.(list{l,1}),1);  %% number of elements in the array !!!
                if isfield(model,list{l,1})&&~strcmp(list{l,1},'S');

                    type=isa(model.(list{l,1}),ClassName{i});


                    if type~=0;
                        new_l=new_l+1;

                        listClass(new_l)=ClassName(i)

                        % try
                        finalContent.(list{l,1})=model.(list{l,1})(num); % intialise the variables.

                        %% extract the URNs from the MIRIAM registry's dataset
                        ind_Mi =find(strcmp(list{l,2},miriam(:,4))) % column 4 stores the names of Miriam information.
                        entry=miriam{ind_Mi(1),7};   % column 7 stores the URNs of Miriam information
                        entry=[entry,':'];
                        listKey{new_l,1}=strcat(keyStr,entry); % <rdf:li rdf:resource=" + urn:miriam:chebi =<rdf:li rdf:resource="urn:miriam:chebi

                        Index_Relation=find(ismember(listRelations,list(l,3)));

                        prefix_key_2=listRelations(Index_Relation);

                        prefix_key_2_new=strcat(prefix_key_2,prefix_key_3);
                        relation{new_l,1}=strcat(prefix_key_1,prefix_key_2_new);
                        relation{new_l,2}=strcat(postfix_key_1,prefix_key_2_new);
                        %
                        %
                        %
                        %prefix_key_2={' '};
                        %prefix_key_3='>';%%%
                        %                         if strcmp(ClassName{i},'numeric')||strcmp(ClassName{i},'logical')
                        %                             finalItems(new_l)=strcat(listKey(new_l,1),num2str(finalContent.(list{l,1}))); % Convert the numbers into strings.
                        %                         else
                        %                    try
                        finalItems(new_l)=strcat(listKey(new_l,1),finalContent.(list{l,1})); %<rdf:li rdf:resource="urn:miriam:chebi
                        %                    catch
                        %                        disp(finalContent.(list{l,1}))
                        %                        disp(listKey(l,1));
                        %                    end
                        % end

                    end
                else
                    finalContent.(list{l,1})=' no data found in the COBRA model structure';
                    finalItems(1)=strcat(infix,' no data found in both met and rxn lists');
                end
                %             else
                %                 error('The COBRA model structure doesn''t contain the sthoichometric matrix');
            else
                finalContent.(list{l,1})=' no suitalbe types of annotations found in the COBRA model structure';
                finalItems(1)=strcat(infix,' no suitalbe types of annotations found in the COBRA model structure');
            end

        end
    end
    postfix_key='"/>';

    for i=1:length(finalItems);
        finalItems{i}=strcat(finalItems{i},postfix_key)
    end

elseif strcmp(para,'not_found');
    finalItems(1)=strcat(infix,' not found in both met and rxn lists');
    finalContent(1)=strcat(infix, ' not found in both met and rxn lists');
end

end



%% the annotation template for metabolites

% if strcmp(para,'met')
%
%     %%% assign a initial value of ' ' to the list of the variables.
%
%     m=[];
%
%     %% The template used here contains three types of information, namely,obo.chebi:CHEBI, hmdb and pubchem.substance.
%     %% you may have to modify this part of the codes accordingly to include more MIRIAM types.
%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     metKeywords={'obo.chebi:CHEBI%';
%         'hmdb:'
%         %'pubmed:'
%         'pubchem.substance:'
%         }
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%     for d=1:length(metKeywords);
%
%         finalContent{d}=strcat(keyStr,metKeywords(d));
%
%         %%
%     end
%
%     m{1}=model.metChEBIID(num);
%     m{2}=model.metHMDB(num);
%     m{3}=model.metPubChemID(num);
%
%     % CHEBI=model.metChEBIID;
%     % HMDB=model.metHMDB;
%     % PubChemID=model.metPubChemID;
%
%     for i=1:length(finalContent);
%         finalItems{i}=strcat(finalContent{i},m{i})
%     end
%
%
%
%
%     postfix_key='"/>';
%
%     for i=1:length(finalContent);
%         finalItems{i}=strcat(finalItems{i},postfix_key)
%     end
%
%
% end
% end
