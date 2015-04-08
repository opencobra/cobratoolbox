function [fname_out,var] = addMiriam(fname,fname_out,infix,model)

% Add Miriam information to CellDesigner XML file; the Miriam information
% is retrieved from a COBRA model structure using Metbolite/Reaction IDs as
% the name of entry. The omics data will be shown as texts hyperlinking to
% external databases in CellDesigner or ReconMap online.
% 
% 
%INPUTS
% 
% fname       An XML file to be modified to include annotations. 
% fanme_out   the name of the output XML file.
% infix       The metabolite/reaction IDs to be used to retrieve omics data
%             in the COBRA model structure.
% model       a COBRA model structure contains the annotations that can be 
%             retrieved by using the infix as the index value.
%
%
%OPTIONAL OUTPUT
% 
% var         the content of the moidfied XML file with annotations
%
%
% EXAMPLE:
%
% the following example command is intended to add all MIRIAM information
% for the metabolites in the ReconMap
%
% [var]=addMiriam('ReconMap.xml','ReconMap_annotated.xml',recon2.mets(:),recon2)


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

prefix='id="'; % for example file

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


prefix_txt(1).str='<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">';
prefix_txt(2).str='<rdf:Description rdf:about="#'; % s1">'
prefix_txt(3).str='<bqmodel:is>';

prefix_txt(4).str='<rdf:Bag>';

met_ind(1).str='<listOfSpecies>';
met_ind(2).str='</listOfSpecies>';

rxn_ind(1).str='<listOfReactions>';
rxn_ind(2).str='</listOfReactions>';


% prefix(5).str='<rdf:li rdf:resource="urn:miriam:obo.chebi:CHEBI%3A12335"/>'

postfix(1).str='</rdf:Bag>';
postfix(2).str='</bqmodel:is>';

% postfix(3).str='<bqmodel:is>'
% postfix(4).str='<rdf:Bag>'

postfix(3).str='</rdf:Description>';
postfix(4).str='</rdf:RDF>';
% rem=fgets(f_id);

h = waitbar(0,'Progressing');
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

% rxn_str='<reaction metaid="'

SecKeyStr='</celldesigner:extension>'

% MainTxt_new={};

n_old=0;
found=0; % SecKeyStr is found in the line

metKeyword=0; % the variable that stores a value determining whether the metabolite annotations need to be added.
rxnKeyword=0; % a value of zero indictates that by default the reaction annotations will not be added.

for t=1:total_length   % go through each line of the SBML file.
    
    if ismember(t, ct)~=0||t==total_length; % estimiate the time interval.
        
        disp(t);
        waitbar(t/total_length,h);
        
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

    if ~isempty(strfind(MainTxt(t),met_str))&&(metKeyword==1||rxnKeyword==1) %||(~isempty(strfind(MainTxt(t),met_str))));

        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        disp('met_str found');

        for in=1:length(rxnName);% for in=1:length(infix); go though each line of the Rxn List.
            
            % disp(length(rxnName));

            line_st=strfind(MainTxt(t),rxnName{in});

            if ~isempty(line_st{1})  %isempty(line_st)~=0; % the line contains the rxn keywords
                disp('%%%%%%%%%%%%%%%%% dddd%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
                
                str=[infix{in},'">'];
                prefix_txt(2).str=strcat(prefix_txt(2).str,str);
                
                % is=isempty(strfind(MainTxt(t),SecKeyStr))
                %
                %                 while is==1
                %
                %                     n_old=n_old+1;
                % %
                %                      n=n+1;
                % %
                %                      MainTxt_new(n,1)=MainTxt(t_updated);
                % %                     %
                % %                     %                     if ~isempty(strfind(MainTxt(t+d),SecKeyStr))
                % %                     %
                % %                     %                     break
                % %                     a=t_updated;
                %                  end
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
        [rxnItems,rxnContent]=constructItems(infix(in),model); %% retrieve the lines of codes
        
        for k=1:length(rxnContent);
            for p=1:2;  % two another lines of codes before the main contents
                
                MainTxt_new(n+p,1)=cellstr(prefix_txt(p+2).str);
                
            end
            n=n+p;
            total_length=total_length+p;
            
            
            rxnContent(k)
            disp(n);
            disp(k);
            
            disp(MainTxt_new(n,1));
            disp('%%%%%%%%%%%%');
            disp(rxnItems(k));
            
            MainTxt_new(n+1,1)=rxnItems(k); % the main content
            
            n=n+1;
            total_length=total_length+k;
            
            for p_e=1:2 % two another lines of codes after the main contents
                
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


close(h);

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


function [rxnItems,rxnContent]=constructItems(index,model)

% rxnItems    an array of combined Keywords and Contents

% rxnContent   an array of Contents

infix=index;

rxnItems=[];
rxnContent=[];
keyStr='<rdf:li rdf:resource="urn:miriam:';
%%

num=find(strcmp(model.rxns(:,1),infix)); %% find the reaction number in the model.
para='rxn';


if isempty(num)
    num=find(strcmp(model.mets(:,1),infix));
    para='met';
    
elseif ~isempty(find(strcmp(model.mets(:,1),infix), 1))        %%%%% Error! the reaction and metabolite use the same name.
    
    msg=strcat(infix, ' is used as a reaction name as well as a metabolite name');
    warndlg(msg,'Warning!');
    
end

%% the annotation template for metabolites

if strcmp(para,'met')
    
    %%% assign a initial value of ' ' to the list of the variables.
    
    m=[];
    
    %% The template used here contains three types of information, namely,obo.chebi:CHEBI, hmdb and pubchem.substance. More Miriam type
    %% you may have to modify the part of the codes accordingly to include more MIRIAM types.
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    metKeywords={'obo.chebi:CHEBI%';
        'hmdb:'
        %'pubmed:'
        'pubchem.substance:'
        }
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
  
    for d=1:length(metKeywords);
        
        rxnContent{d}=strcat(keyStr,metKeywords(d));
        
        %%
    end
    
    m{1}=model.metCHEBIID(num);
    m{2}=model.metHMDB(num);
    m{3}=model.metPubChemID(num);
    
    % CHEBI=model.metCHEBIID;
    % HMDB=model.metHMDB;
    % PubChemID=model.metPubChemID;
    
    for i=1:length(rxnContent);
        rxnItems{i}=strcat(rxnContent{i},m{i})
    end
    postfix_key='"/>';
    
    for i=1:length(rxnContent);
        rxnItems{i}=strcat(rxnItems{i},postfix_key)
    end
    
    
end
end

