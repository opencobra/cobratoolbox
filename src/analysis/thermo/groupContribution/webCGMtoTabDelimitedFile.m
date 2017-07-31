function webCGMtoTabDelimitedFile(model, webCGMoutputFile, gcmMetList)
% Parses a webCGM output file and prepare a tab delimited file with group
% contribution data mapped to the metabolite abbreviations in the given
% model.
%
% Parses webCGM output file and creates an input file for
% `createGroupContributionStruct.m`
%
% USAGE:
%
%    webCGMtoTabDelimitedFile(model, webCGMoutputFile, gcmMetList)
%
% INPUTS:
%    model:                 structure with fields:
%
%                             * model.S - `m x n`, stoichiometric matrix
%                             * model.mets - `m x 1`, cell array of metabolite abbreviations
%                             * model.metFormulas - `m x 1`, cell array of metabolite formulae
%    webCGMoutputFile:      filename of output from webCG server
%    metList:               `m x 1`, cell array of metabolite ID for metabolites
%                           in `webCGMoutputFile`. Metabolite order must be the
%                           same in `metList` and `webGCMoutputFile`.
%
% OUTPUT:
%    gc_data_webCGM.txt:    tab delimited text file with group contribution data for
%                           `createGroupContributionStruct.m`. The first two text columns in both files should correspond to: `abbreviation`, `formulaMarvin`,
%                           the next three columns in both files should correspond to: `delta_G_formation`, `delta_G_formation_Uncertainty`, `chargeMarvin`.
%
% NOTE:
%
%    By default, any group contribution data for metabolites with
%    underdefined formulae ( e.g. R group), are ignored, even if there is group
%    contribution data available for this metabolite.
%
% .. Authors:
%       - Ronan M. T. Fleming 8 July 2009
%       - Ronan M. T. Fleming 10 July 2009 - fixed bug for reactants with no GC data

[nMet,nRxn]=size(model.S);

fid=fopen(webCGMoutputFile,'r');
%header
tline = fgetl(fid);
fidout=fopen('gc_data_webGCM.txt','w');

%exclude underdefined molecular structures
%excluded metabolite abbreviation token
excludedAbbreviationToken={'trna'};
%exclude underdefined molecular formulae
excludedElementToken={'X','R'};


%counter which corresponds to the line number in webCGMoutputFile
%start at 1 to account for the header line in webCGMoutputFile
hasMolCount=1;
for m=1:nMet
    %initialise
    underDefinedMetBool=0;

    %       metAbbr=model.mets{m};
    %       metAbbr=metAbbr(1:end-3);
    %       if strcmp(metAbbr,'protrna')
    %             pause(eps)
    %       end

    % It is very, very, very important
    % that when the input cdf file for the mol file was
    % created that the metabolites appear in the same
    % order as the rows are ordered in the stoichiometric
    % matrix. This is how this parser file can map the
    % webCG output to the model.
    if ismember(model.mets(m),gcmMetList);
        hasMolCount=hasMolCount+1;
        if hasMolCount==590
            pause(eps)
        end
        tline = fgetl(fid);
        if ~ischar(tline)
            break;
        end

        %parse each line of the webCGMoutputFile
        [delta_G_formation,remain]= strtok(tline, ';');

        %if first token is NONE then theres no GC data for this reactant
        noGCDataForReactant=strcmp(delta_G_formation,'NONE');
        firstRemain=remain;

        delta_G_formation=str2num(delta_G_formation);
        [delta_G_formation_Uncertainty,remain]= strtok(remain, ';');
        delta_G_formation_Uncertainty=str2num(delta_G_formation_Uncertainty);
        [groups,remain]= strtok(remain, ';');
        rem=groups;
        %parse the groups till get to charge
        while 1
            [tok,rem]=strtok(rem, '|');
            if isempty(rem)
                chargeMarvin=str2num(tok);
                break;
            end;
        end
        [chargeMolFile,remain]= strtok(remain, ';');
        [formulaMarvin,remain]= strtok(remain, ';');

        %dont map certain group contribution data to model where metabolite
        %is underdefined structurally
        %trna in a metabolite abbreviaton indicates a macromolecule
        for eab=1:length(excludedAbbreviationToken)
            if ~isempty(strfind(model.mets{m},excludedAbbreviationToken{eab}))
                underDefinedMetBool=1;
                break;
            end
        end

        %an X or R in a metabolite formula usually means that a macromolecule
        %is involved or that it is a polymerised molecule with undefined size
        %the group contribution method is not designed for such metabolites.
        for eab=1:length(excludedElementToken)
            if ~isempty(strfind(model.metFormulas{m},excludedElementToken{eab}))
                underDefinedMetBool=1;
                break;
            end
        end

        if ~underDefinedMetBool
%             model.metFormulas{m}
%             formulaMarvin
            %double check that reconstruction formula and formula provided by
            %group contribution output are the same upto changes in the number of protons.
%             bool=checkFormulae(model.metFormulas{m},formulaMarvin,{'H'});
%             if bool
                %dont print to file unless everything is ok
                if noGCDataForReactant
                    %print out the metabolites without formation energies and the
                    %reason
                    fprintf('%s\t%s\n',metAbbr,firstRemain)
                else
                    metAbbr=model.mets{m};
%                     metAbbr=metAbbr(1:end-3);
                    %dont print out those that
                    fprintf(fidout,'%s\t%s\t%f\t%f\t%f\n',metAbbr,formulaMarvin,delta_G_formation,delta_G_formation_Uncertainty,chargeMarvin);
                end
%             else
%                 fclose(fid);
%                 fclose(fidout);
%                 error(['Failure to map group contribution data to model: '...
%                     model.mets{m} ', ' model.metNames{m} ', model Formula: ' model.metFormulas{m}...
%                     ', other Formula: ' formulaMarvin]);
%             end
        end
    end
end
fclose(fid);
fclose(fidout);
