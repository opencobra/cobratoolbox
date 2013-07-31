% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted.
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
classdef rBioNet
    % rBioNet class directs traffic between Matlab and Java rBioNet
    % extension. rBioNet scripts are being moved to the method group
    % static. Most scripts will be executed from this object.
    properties
        Server = false;     % Server mode
        r;                  % rBioNet java extension, server connection
        GUIs = [];          % Registered GUIs for online mode. 
    end
    
    methods (Access = public)   
        function obj = Connect(obj)
            rBioNet = rConnect;
            if ~isempty(rBioNet)
                obj.r = rBioNet;
                obj.Server = true;
                obj.Server_mode('on');
            end
        end % Specify server, username and password and test connection
        function obj = Disconnect(obj)
            obj.Server = false;
            obj.r = [];
            obj.Server_mode('off');
        end % Cancel server mode
        
        % Show server mode
        function Server_mode(obj,OnOff)
            for i = 1:length(obj.GUIs)
                handles = guidata(obj.GUIs(i));
                set(handles.server,'Visible',OnOff);
                guidata(obj.GUIs(i),handles);
            end
        end % Set server mode on/off on all GUIs
        function obj = Register(obj,hObject)
            obj.GUIs = unique([obj.GUIs hObject]); % Same gui might register more than once. 
            if obj.Server
                obj.Server_mode('on');
            end
        end % Register GUI for online mode
        function obj = Unregister(obj,hObject)
            k = 0;
            for i = 1:length(obj.GUIs);
                if hObject == obj.GUIs(i-k)
                    obj.GUIs(i-k) = '';
                    k = k + 1;
                end
            end
        end % Removes registered GUI

        % Save, load & search
        function output = saveRxn(obj,rxns)
            % 
            if obj.Server
                % All checks or done in java
                
                output = obj.r.insert_rxns(obj.rxnArray(rxns));
                if ~output
                    disp(obj.missing_mets);
                    disp(obj.rxns_not_inserted);
                    disp(obj.rxns_already_exists);
                end
                % For big models I might consider disabling this to see
                % what reactions where not inserted...
                % disp(obj.rxns_inserted);
            else
                h = waitbar(0/size(rxns,1),'Checking reactions...');
                output = true;
                for i=1:size(rxns,1)
                    tosave = true;
                    Abbreviation = obj.AbbreviationExists(rxns{i,1},'rxn');
                     waitbar(i/size(rxns,1))
                    if ~isempty(Abbreviation)
                        %Abbreviation exists
                        disp(obj.AbbreviationMessage(rxns{i,1}));
                        output = false;
                        continue;
                    end
                    %Metabolites exist
                    mets = unique(formula2mets(rxns{i,3}));
                    for k = 1:length(mets)
                        if isempty(obj.AbbreviationExists(mets{k},'met'))
                            disp(['Metabolite ' mets{k} ' is not in database.']);
                            tosave = false;
                            output = false;
                        end
                    end
                    if ~tosave
                        continue;
                    end
                    Formula = obj.rxnFormulaExists(rxns{i,3});
                    if ~isempty(Formula)
                        %Formula exists
                        disp(obj.FormulaMessage(Formula,rxns{i,1}));
                        output = false;
                        tosave = false;
                        continue;
                    end
                    % Save reaction
                    if tosave
                        obj.saveRxnMatlab(rxns(i,:));
                    end
                end
                if h
                    close(h);
                end
            end
        end % Save reaction to database.
        function output = saveMet(obj,mets)
            output = true;
            if obj.Server
                
                output = obj.r.insert_mets(obj.metArray(mets));
                if ~output
                    disp(obj.mets_not_inserted);
                    disp(obj.mets_already_exists);
                end
                % disp(obj.mets_inserted);
            else
                % Matlab checks
                % Check Abbreviation
                
                for i = 1:size(mets,1)
                    tosave = true;
                    Abbreviation = obj.AbbreviationExists(mets{i,1},'met');
                     if ~isempty(Abbreviation)
                        %Abbreviation exists
                        disp(obj.AbbreviationMessage(mets{i,1}));
                        tosave = false;
                        output = false;
                        continue;
                     end
                     % Save metabolite
                    if tosave 
                        obj.saveMetMatlab(mets(i,:));
                    end
                end
            end % Save metabolite to database.
        end % Save metabolite to database.
        function output = Database(obj,type)
            % INPUT: type - 'rxn' or 'met'
            if obj.Server
                output = obj.Search(type,'','','',false);
            else
                output = rBioNetSaveLoad('load',type);
            end
        end % Load entire database (met or rxn)
        function output = Search(obj,type,column,columnName,str,exact)
            % INPUT:
            %   type - search for reaction or metabolite, "rxn" or "met"
            %   column - number of column (used in matlab search)
            %   columnName - name of column (used on server)
            %   str - search phrase, true or false
            %
            % OUTPUT:
            %   output - search results
            if obj.Server
                %Server search
                if obj.r.Search(java.lang.String(type),java.lang.String(str),java.lang.String(columnName),java.lang.Boolean(exact))
                    output = cell(obj.r.last_result);
                    if isempty(output)
                        output = cell(1);
                    else
                        output(:,1) = '';
                    end
                else
                    output = {'query failed...'};
                end
            else
                %Matlab search
                output = rBioNet_search(type,column,str,exact);
            end
        end
        
                   
        % Similarities & balance
        function output = metSimilarities(obj,met) % Find all charge formulas that are the same. 
            if obj.Server
                if obj.r.metSimilarities(obj.newMetObject(met))
                    mets = cell(obj.r.last_result());% Similar mets
                    if size(mets,1) == 0
                        mets = [];
                    else
                        mets = mets(:,2:end);% Skip metabolite ids
                    end
                else
                    mets = [];
                end
            else
                metab = rBioNetSaveLoad('load','met');
                mets = metab((strcmp(met{1,4},metab(:,4))),:);
            end
            
            if ~isempty(mets)
                output = obj.showSimilarMets(mets);
            else
                output = true;
            end
        end
        function output = rxnSimilarities(obj,formula) % Find all reaction similarity
            % INPUT:
            %   formula - reaction formula
            %
            % OUTPUT:
            %   List of similar reactions (numbers that reference data).
            %   Empty if no reactions where found.
            
            if obj.Server
                %Perform test on server
            else
                
                rxns = rBioNetSaveLoad('load','rxn');
                sims = similarity(formula,rxns(:,3));
                if  ~isempty(sims)
                    output = rxns(sims,:);
                else
                    output = sims;
                end
            end
        end
        function [mets, present, rev] = rxn2mets(obj,rxn) % Break down reaction formula
            % [mets rev] = rxn2mets(obj,rxn)
            %
            % INPUT:
            %   rxn - reaction formula, "atp[d] <=> adp[d] + h[d]"
            %
            % OUTPUT:
            %   mets -  Nx5 table with metabolite data (N = number of metabolites)
            %           [Abbreviation, Coefficient, Compartment, Charge Formula*, Charge*]
            %   * - data must be acquired from database
            %   rev - is reaction reversible, true or false
            %   present - are there any metabolites not present in the
            %             database, true if all metabolites are present else false
            
            [metComp, coe, rev] = parseRxnFormula(rxn);
            
            % Create mets table
            mets = cell(size(metComp,2),5);
            
            % Break up metabolite and compartment
            present = true;
            for i = 1:size(mets,1)
                [met, comp] = metCompartment(metComp{i});
                mets{i,1} = met;
                mets{i,2} = coe(i);
                mets{i,3} = comp;
                % Get charged formula and charge from database
                
                metabolite = obj.AbbreviationExists(met,'met',true);
                if ~isempty(metabolite)
                    mets{i,4} = metabolite{4}; % ChargedFormula
                    mets{i,5} = str2double(metabolite{5}); % Charge
                else
                    present = false;
                end
                
            end
        end
        function output = AbbreviationExists(obj,Abbreviation,type,returnData) % Check if reaction abbreviation exists
            % INPUT
            %   Abbreviation - abbreviation to check for
            %   type - check for 'rxn' or 'met'
            %
            % INPUT OPTIONAL:
            %   returnData - true or false, [false] 
            %
            % OUTPUT
            %   output - line number or empty if abbreviation is not found
            %            If returnData = true, data is returned instead of
            %            line
            if nargin < 4
                returnData = false;
            end
            
            if obj.Server
                
                output = obj.Search(type,1,'Abbreviation',Abbreviation,true);
                if isempty(output{1})
                    output = [];
                end
            else
                data = rBioNetSaveLoad('load',type);
                
                output = find(strcmp(Abbreviation,data(:,1)));
                if returnData && ~isempty(output)
                    output = data(output,:);
                end
            end
        end
        function output = ModelCheckAbbreviation(obj,model,type)
            % INPUT:
            %   model - reconstruction model
            %   type - search for reaction or metabolite, "rxn" or "met"
            %
            % OUTPUT:
            %   output - List of abbreviations that are not in database. 
            if ~obj.Server
                output = 'Only for Server mode';
                return;
            end
            if ~isfield(model,[type 's'])
                output = ['Field ' type ' is not recognized in the model. Correct model should use mets & rxns.\n'
                    ' For this function use met & rxn.'];
                return;
            end
            
            values = getfield(model,[type 's']);
            output = '';
            h = waitbar(0,'Checking for abbreviations....');
            for i=1:length(values)
                waitbar(i/length(values),h);
                if isempty(obj.AbbreviationExists(values{i},type))
                    output = [output ' ' values{i} ','];
                end
            end
            close(h);
        end % Check if all mets/rxns from model are in database
        
        
        % Reconstructions on server
        
        % save a rxn (if exists, then update instead)
        % reaction fyrir recon tharf ad hafa
        % rxn, Model_id, lb, ub, cs, gpr, subsystem, ref, notes
        
        
        function output = reconSaveRxn(obj,abbr,lb,ub,cs,gpr,subsystem,ref,notes)
            if ~obj.Server
                msgbox('You must be connected to a server');
                output = false;
                return;
            end
            output = obj.r.saveReconRxn(...
                java.lang.String(abbr),...
                java.lang.String(obj.NumericString(lb)),...
                java.lang.String(obj.NumericString(ub)),...
                java.lang.String(obj.NumericString(cs)),...
                java.lang.String(gpr),...
                java.lang.String(subsystem),...
                java.lang.String(ref),...
                java.lang.String(notes)...
            ); 
            if ~output
                disp(obj.r.last_error)
            end
            
        end
        
        % save all reactions
        % save reconstruction info and get id. 
        function output = saveReconInfo(obj,recon)
            % INPUT - recon struct object from rCreatorServerSave.m
            % OUTPUT - true or false
            if ~obj.Server
                msgbox('You must be connected to a server');
                output = false;
                return ;
            end
            data = cell2java({recon.Name,recon.Organism,recon.Author,recon.Notes, recon.GeneIndexInfo},1);
            output = obj.r.newRecon(data);
            if ~output
                msgbox('Unable to save model','error','error');
                disp(obj.r.last_error);
            end
            
        end
        
        % remove rxn
        % clear reconstruction
        
        
        % Support functions for Java
        function output = newRxnObject(obj,rxn)
            % NOTE:
            %   date value is assigned on database entry
            
            output = obj.r.new_rxn(cell2java(rxn(1:9)),cell2java(formula2array(rxn{3}),2));
        end % Create a new rxn object (Java)
        function output = newMetObject(obj,met)
            output = obj.r.new_met(cell2java(met));
        end % Create a new met object (Java)
        function output = rxnArray(obj,rxns)
            % NOTE:
            %   maximum reactions at ones are 500 (might change)
            output = javaArray('rbionet.Reaction',size(rxns,1));
            for i=1:size(rxns,1)
                output(i) = obj.newRxnObject(rxns(i,:));
            end
        end % Create a array of rxn objects (Java)
        function output = metArray(obj,mets)
            output = javaArray('rbionet.Metabolite',size(mets,1));
            for i=1:size(mets,1)
                output(i) = obj.newMetObject(mets(i,:));
            end
        end % Create a array of met objects (Java)
        
        % Reaction and metabolite status variables from Java
        function status = rxns_inserted(obj)
            status = obj.r.rxns_inserted();
        end
        function status = rxns_not_inserted(obj)
            status = obj.r.rxns_not_inserted();
        end
        function status = rxns_already_exists(obj)
            status = obj.r.rxns_already_exists();
        end
        function status = missing_mets(obj)
            status = obj.r.missing_mets();
        end
        function status = mets_not_inserted(obj)
            status = obj.r.mets_not_inserted();
        end
        function status = mets_already_exists(obj)
            status = obj.r.mets_already_exists();
        end
        function status = mets_inserted(obj)
            status = obj.r.mets_inserted();
        end
    end
    
    methods (Static, Access = private)
        function saveRxnMatlab(rxn)
            rxn{1,10} = datestr(clock,'yyyy-mm-dd HH:MM:SS');
            data = rBioNetSaveLoad('load','rxn');
            data(end+1,:) = rxn(1,1:size(data,2));
            data = sortrows(data,1);
            rBioNetSaveLoad('save','rxn',data);
        end %Add reaction to matlab database
        function saveMetMatlab(met)
            data = rBioNetSaveLoad('load','met');
            met{1,12} = datestr(clock,'yyyy-mm-dd HH:MM:SS');
            data(end+1,:) = met(1,1:size(data,2));
            data = sortrows(data,1);
            rBioNetSaveLoad('save','met',data);
        end %Add metabolite to matlab database
    end
    
    methods (Static) %Matlab scripts
        % rBioNet functions
        function balance = RxnBalanceCheck(metabolites)
            % INPUT:
            %   metabolites - table of metabolites and there properties
            %   [Abbreviation, Coefficient, Compartment, Charge Formula*, Charge*]              
            %   Mor information att the rxn2mets function
            %
            % OUTPUT:
            %   
            
            S = size(metabolites);
            Elements = {'C', 'H', 'O', 'P', 'S', 'N', 'Mg','X','Fe','Zn','Co','R'};
            m = size(Elements,2);
            sub  = zeros(1,m+1); % Plus 1 for charge
            prod = zeros(1,m+1);% Plus 1 for charge
            
            % Count Elements
            for i = 1:S(1)
                if metabolites{i,2} < 0 % Substrate
                    for k = 1:length(Elements)
                        element = numAtomsOfElementInFormula(metabolites{i,4},Elements{k});
                        sub(k) = sub(k) + abs(metabolites{i,2})*element;
                    end
                    sub(m+1) = sub(m+1) + abs(metabolites{i,2})*metabolites{i,5};
                else                    % Product
                    for k = 1:length(Elements)
                        element = numAtomsOfElementInFormula(metabolites{i,4},Elements{k});
                        prod(k) = prod(k) + abs(metabolites{i,2})*element;
                    end
                    prod(m+1) = prod(m+1) + abs(metabolites{i,2})*metabolites{i,5};
                end
            end
            
            if any(~(prod == sub))
                Elements{end+1} = 'Charge'; % Add charge here
                unbalanced(1,:) = Elements;
                unbalanced(2,:) = num2cell(sub);
                unbalanced(3,:) = num2cell(prod);
                balance = unbalanced;
            else
                balance = [];
            end
            
            
        end
        function output = rxnFormulaExists(formula) % Does reaction formula exist in database
            % INPUT
            %   formula - reaction formula
            % OUTPUT
            %   output - reaction abbreviation if it exists else empty
            rxns = rBioNetSaveLoad('load','rxn');
            output = ReactionEq(formula,rxns,true);
        end
        function output = showSimilarMets(mets)
            % INPUT: list of metabolites to show
            % OUTPUT: 1 - user wishes to continue, else 0
            output = true;
            sim_general(mets)
            uiwait;
            save_met = questdlg('Are you sure you want to save?', ...
                'Save Data', ...
                'Yes', 'No', 'Yes');
            switch save_met
                case 'Yes'
                    %No change
                otherwise
                    output = false;
            end
        end % shows similar 
        
        % Messages
        function text = AbbreviationMessage(Abbreviation)
            text = strcat(['Abbreviation ' Abbreviation ' already exist in database.']);
        end
        function text = FormulaMessage(Abbreviation,Reaction)
            text = strcat(['Reaction ' Reaction ' exist under the abbreviation ' Abbreviation '.']);
        end
        function text = MissingMetabolite(Reaction,Metabolite)
            text = strcat(['Reaction: ' Reaction ' has a metabolite that is not present in the database, ' Metabolite]);
        end
        
        
        function output = NumericString(number)
            % Makes sure number string is in string format
            % INPUT - string or number
            % OUTPUT - string
            % Any other input will result in an error. 
            if isempty(number)
                output = '0';
            elseif ischar(number)
                output = number;
            else
                output = num2str(number);
            end
        end
        
        % NOTE: Extra information is hard to add later on to metabolites
        % and reactions (like external db ids). Going to test using
        % structure more. So att one place the structure is defined. Makes
        % future changes easier. 
        
        % Standard reaction structure object parhaps used in future. 
        function output = rxnStruct(abb,desc,form,rev,lb,ub,cs,...
                subsystem,ref,notes,ec,kegg,id)
            if nargin < 13
                id = [];
            end
            output = struct(...
                'Abbreviation', abb,...
                'Description', desc,...
                'Formula', form,...
                'Reversible',rev,...
                'lb',lb,...
                'ub',ub,...
                'cs',cs,...
                'Subsystem',subsystem,...
                'References',ref,...
                'Notes',notes,...
                'ECNumber',ec,...
                'KeggID',kegg,...
                'ID',id...
                );
        end
        
    end
    
end

