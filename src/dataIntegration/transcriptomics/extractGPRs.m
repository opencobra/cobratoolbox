function [parsedGPR,corrRxn] = extractGPRs(model)
%Maps the GPR rules of the model to a specified format that is used by the 
%model extraction methods 
%
%INPUTS
%
%   model           input model (COBRA model structure)
%
%OUTPUTS
%
%   parsedGPR       cell array describing the possible combination of gene needed for each
%                   reactions in the model without using "AND" and "OR" logical rule
%
%   corrRxn         cell array containg the reaction names associated to parsedGPR
%
%
% originally written in createTissueSpecificModel.m
% annotated and modified by A. Richelle May 2017

    warning off all

    parsedGPR = [];
    corrRxn = [];
    cnt = 1;

    for i = 1:length(model.rxns)           
        if length(model.rules{i}) > 1
            % Parsing each reactions GPR containing "OR" rule

            [parsing{1,1},parsing{2,1}] = strtok(model.rules{i},'|');           
            for j = 2:1000
                [parsing{j,1},parsing{j+1,1}] = strtok(parsing{j,1},'|');
                if isempty(parsing{j+1,1})==1
                    break
                end
            end
                
            % Parsing each reactions GPR containing "AND" rule
            for j = 1:length(parsing)
                for k = 1:1000
                    [parsing{j,k},parsing{j,k+1}] = strtok(parsing{j,k},'&');
                    if isempty(parsing{j,k+1})==1
                        break
                    end
                end
            end
            
            %Get rid of bracket and spacing
            for j = 1:size(parsing,1)-1
                for k = 1:size(parsing,2)
                    if length(parsing{j,k}) == 0
                        parsing{j,k} = '';                    
                    else
                        parsing{j,k} = strrep(parsing{j,k},'(','');
                        parsing{j,k} = strrep(parsing{j,k},')','');
                        parsing{j,k} = strrep(parsing{j,k},' ','');
                        parsing{j,k} = strrep(parsing{j,k},'x','');
                    end
                end
            end

            for j = 1:size(parsing,1)-1
                newparsing(j,:) = parsing(j,1:length(parsing(j,:))-1);
            end
            parsing = newparsing;         
            
            %create the parsedGPR variable by creating a new potential gene combination for 
            %each reaction containing "OR" rule and  by adding a gene to an existing combination 
            %for each reaction  containing "AND" rule
            for j = 1: size(parsing,1)
                sizeP = length(parsing(j,:));
                if sizeP > size(parsedGPR,2)
                    for k = 1:size(parsedGPR,1)
                        parsedGPR{k,sizeP} = {''};
                    end
                end

                for l = 1:sizeP          
                parsedGPR{cnt,l} = model.genes(parsing(j,l));
                %to check difference between recon1 and recon2
                %nID=parsing{j,l}
                %parsedGPR{cnt,l} = model.genes{nID};
                end           
                cnt = cnt+1;
                corrRxn = [corrRxn;model.rxns(i)];
            end
            clear parsing newparsing
        end
    end
    
    %Cleaning of parsedGPR and corrRxn variables by removing empty cell array 
    %that were created in the previous loops    
    for i = 1:size(parsedGPR,1)
        for j = 1:size(parsedGPR,2)
            if isempty(parsedGPR{i,j}) == 1
                parsedGPR{i,j} = {''};
            end
        end
    end

    i =1 ;
    sizeP = size(parsedGPR,1);
    while i <= sizeP
        if strcmp(parsedGPR{i,1},{''}) == 1
            parsedGPR = [parsedGPR(1:i-1,:);parsedGPR(i+1:end,:)];
            corrRxn = [corrRxn(1:i-1,:);corrRxn(i+1:end,:)];
            sizeP = sizeP-1;        
            i=i-1;
        end
        i = i+1;
    end

    for i = 1:size(parsedGPR,1)
        for j= 1:size(parsedGPR,2)
            parsedGPR2(i,j) = cellstr(parsedGPR{i,j});
        end
    end
    parsedGPR = parsedGPR2;

end