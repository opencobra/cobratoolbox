function model=modelMetabolitesToSDF(model,InChI)
% write out an SDF which is effectively a set of mol files concatenated 
% in a flat file with extra data headers
%
% SDF format spec http://www.symyx.com/downloads/public/ctfile/ctfile.jsp
%
% INPUT
% model     model structure
%
% OPTIONAL INPUT
% InChI     m x 2 cell array of InChI strings for each metabolite 
%           InChI{i,1} is a metabolite abbreviation (no compartment)
%           InChi{i,2} is a metabolite InChI string
%
% OPTIONAL OUTPUT
% model.mets(m).InChI           InChI mapped to model if provided as imput
% model.met(m).formulaInChI     Chemical formula as given in InChI
% Ronan M.T. Fleming

compartments=[];
biomassRxnAbbr=[];
thermoAdjustmentToS=0;
model=convertToCobraV2(model,compartments,biomassRxnAbbr,thermoAdjustmentToS);

if exist('InChI')
    [nInChI,nlt]=size(InChI);
    
    %may have to parse InChI if it is not a proper cell array.
    if nlt==1
        %This is a temporary workaround to deal with data from spreadsheet
        InChICell=cell(nInChI,3);
        for x=1:nInChI
            tmp=textscan(InChI{x,1},'%s%s%s%s\n',1,'Delimiter','"');
            %convert metabolite abbreviation from SBML to COBRA format
            % convert string like M_1mpyr_c to 1mpyr[c]
            metAbbr=tmp{2};
            %need to replace _DASH_ with -
            metAbbr = strrep(metAbbr{1}, '_DASH_', '-');
            %remove extras around sides
            %compart=metAbbr(end);
            %metAbbr=[metAbbr(3:end-2) '[' compart ']'];
            metAbbr=metAbbr(3:end-2);
            InChICell{x,1} = metAbbr;
            
            % InChI
            metInChI=tmp{4};
            metInChI=metInChI{1};
            InChICell{x,2} = metInChI;
            
            % extract formula from InChI
            InChICell{x,3}=getFormulaFromInChI(InChICell{x,2});
        end
    else
        InChICell=cell(nInChI,3);
        for x=1:nInChI
            InChICell{x,1}=InChI{x,1};
            InChICell{x,1}=InChI{x,2};
            InChICell{x,3}=getFormulaFromInChI(InChICell{x,2});
        end     
    end
    %map the InChI to the model
    [nMet,nRxn]=size(model.S);
    numNoInChI=0;
    for m=1:nMet
        metAbbr=model.mets{m};
        metAbbr=metAbbr(1:end-3);
        ind=find(strcmp(metAbbr,InChICell(:,1)));
        if isempty(ind)
            fprintf('%s\n',['No InChI for: ' metAbbr]);
            numNoInChI = numNoInChI+1;
            model.met(m).InChI = NaN;
            model.met(m).formulaInChI = NaN;
        else
            model.met(m).InChI = InChICell{ind(1),2};
            model.met(m).formulaInChI = InChICell{ind(1),3};
        end
    end
    fprintf('%s\n',[num2str(((nMet-numNoInChI)/nMet)*100) '% of metabolites with InChI']);
else
    if ~isfield(model.met,'InChI')
        error('No InChI found');
    end
end

%check that babel is installed and working on the current unix machine
[status, result] = system('babel -V');
if status~=0 || ~isunix
    error('Babel must be installed and it is assumed this is a *nix machine');
end
%todo - add support for babel on windows

%preallocate cell array of already printed metabolites
printedMetAbbr=cell(nMet,1);
% allMetAbbr=cell(nMet,1);
% for m=1:nMet
%     metAbbr=model.met(m);
%     allMetAbbr{m,1}=metAbbr(1:end-2);
% end

%create the water mol file from the inchi string
fid2=fopen('water.inchi','w');
fprintf(fid2,'%s\n','InChI=1/H2O/h1H2');
fclose(fid2);
[status, result] = system('babel --title  water -iinchi water.inchi -omol mater.mol');

%exact mass for H
HexactMass=1.0078250321;

%create the sdf file
sdfFilename=[model.description '.sdf'];
fid=fopen(sdfFilename,'w');
fclose(fid);

%create a file with problematic InChI for babel
fidBabel=fopen('InChI_Babel_NoMol.txt','w');
fclose(fidBabel);

for m=1:nMet
    %only print out each metabolite once, ignoring compartments
    metAbbr=model.mets{m};
    metAbbr=metAbbr(1:end-3);
    if isnan(model.met(m).InChI)
        %use formula and charge given by model
        if ~any(strcmp(metAbbr,printedMetAbbr))
            if checkFormulaValidty(model.met(m).formula)
                %store this metbolite abbreivation so its not printed twice
                printedMetAbbr{m,1}=metAbbr;
                
                %use water as the mol file
                %append mol to existing sdf
                sysCall2=['cat water.mol >> ' sdfFilename];
                [status, result] = system(sysCall2);
                %add annotation appended to sdf
                fid=fopen(sdfFilename,'a');
                fprintf(fid,'%s\n','> <PUBCHEM_SUBSTANCE_URL>');
                fprintf(fid,'%s\n\n','http://pubchem.ncbi.nlm.nih.gov/summary/summary.cgi?sid=7849722');
                fprintf(fid,'%s\n','> <LIPID_MAPS_CMPD_URL>');
                fprintf(fid,'%s\n\n','http://www.lipidmaps.org/data/get_lm_lipids_dbgif.php?LM_ID=LMFA01020030');
                fprintf(fid,'%s\n','> <LM_ID>');
                fprintf(fid,'%s\n\n','LMFA0123456');
                fprintf(fid,'%s\n','> <COMMON_NAME>');
                fprintf(fid,'%s\n\n',model.metNames{m});
                fprintf(fid,'%s\n','> <SYSTEMATIC_NAME>');
                fprintf(fid,'%s\n\n',metAbbr);
                fprintf(fid,'%s\n','> <SYNONYMS>');
                fprintf(fid,'%s\n\n','dummy');
                fprintf(fid,'%s\n','> <CATEGORY>');
                fprintf(fid,'%s\n\n','dummy');
                fprintf(fid,'%s\n','> <MAIN_CLASS>');
                fprintf(fid,'%s\n\n','dummy');
                fprintf(fid,'%s\n','> <SUB_CLASS>');
                fprintf(fid,'%s\n\n','dummy');
                fprintf(fid,'%s\n','> <EXACT_MASS>');
                %uses reconstruction formula
                M = getMolecularMass(model.met(m).formula,1);
                charge = model.met(m).charge;
                %use mass for neutral metabolite
                M = M - charge*HexactMass;
                
                fprintf(fid,'%10.7f\n\n',M);
                fprintf(fid,'%s\n','> <FORMULA>');
                fprintf(fid,'%s\n\n',model.met(m).formula);
                fprintf(fid,'%s\n','> <LIPIDBANK_ID>');
                fprintf(fid,'%s\n\n','NaN');
                fprintf(fid,'%s\n','> <PUBCHEM_SID>');
                fprintf(fid,'%s\n\n','NaN');
                fprintf(fid,'%s\n','$$$$');
                fclose(fid);
            end
        end
    else
        if ~any(strcmp(metAbbr,printedMetAbbr))
            %store this metbolite abbreivation so its not printed twice
            printedMetAbbr{m,1}=metAbbr;
            
            %create the mol file from the inchi string
            fid2=fopen('tmp.inchi','w');
            fprintf(fid2,'%s\n',model.met(m).InChI);
            fclose(fid2);
            %better to use mol output since no $$$$ at the end
            sysCall1=['babel --title ' metAbbr ' -iinchi tmp.inchi -omol ' metAbbr '.mol'];
            [status, result] = system(sysCall1);
            
            %check size of mol file, leave it out if zero bytes
            data=dir([metAbbr '.mol']);
            if data.bytes >= 1
                %append mol to existing sdf
                sysCall2=['cat ' metAbbr '.mol >> ' sdfFilename];
                [status, result] = system(sysCall2);

                %add annotation appended to sdf
                fid=fopen(sdfFilename,'a');
                fprintf(fid,'%s\n','> <PUBCHEM_SUBSTANCE_URL>');
                fprintf(fid,'%s\n\n','http://pubchem.ncbi.nlm.nih.gov/summary/summary.cgi?sid=7849722');
                fprintf(fid,'%s\n','> <LIPID_MAPS_CMPD_URL>');
                fprintf(fid,'%s\n\n','http://www.lipidmaps.org/data/get_lm_lipids_dbgif.php?LM_ID=LMFA01020030');
                fprintf(fid,'%s\n','> <LM_ID>');
                fprintf(fid,'%s\n\n','LMFA0123456');
                fprintf(fid,'%s\n','> <COMMON_NAME>');
                fprintf(fid,'%s\n\n',model.metNames{m});
                fprintf(fid,'%s\n','> <SYSTEMATIC_NAME>');
                fprintf(fid,'%s\n\n',metAbbr);
                fprintf(fid,'%s\n','> <SYNONYMS>');
                fprintf(fid,'%s\n\n','dummy');
                fprintf(fid,'%s\n','> <CATEGORY>');
                fprintf(fid,'%s\n\n','dummy');
                fprintf(fid,'%s\n','> <MAIN_CLASS>');
                fprintf(fid,'%s\n\n','dummy');
                fprintf(fid,'%s\n','> <SUB_CLASS>');
                fprintf(fid,'%s\n\n','dummy');
                fprintf(fid,'%s\n','> <EXACT_MASS>');
                
                M = getMolecularMass(model.met(m).formulaInChI,1);
                charge = getChargeFromInChI(model.met(m).InChI);
                %use mass for neutral metabolite
                M = M - charge*HexactMass;
                
                fprintf(fid,'%10.7f\n\n',M);
                fprintf(fid,'%s\n','> <FORMULA>');
                fprintf(fid,'%s\n\n',model.met(m).formulaInChI);
                fprintf(fid,'%s\n','> <LIPIDBANK_ID>');
                fprintf(fid,'%s\n\n','NaN');
                fprintf(fid,'%s\n','> <PUBCHEM_SID>');
                fprintf(fid,'%s\n\n','NaN');
                fprintf(fid,'%s\n','$$$$');
                fclose(fid);
            else
                fprintf('%s\n',[model.metNames{m} '  :InChI to mol conversion by Babel produced no output.']);
                
                fidBabel=fopen('InChI_Babel_NoMol.txt','a');
                fprintf(fidBabel,'%s\n',model.met(m).InChI);
                fclose(fidBabel);
                
                %use water as the mol file
                %append mol to existing sdf
                sysCall2=['cat water.mol >> ' sdfFilename];
                [status, result] = system(sysCall2);
                %add annotation appended to sdf
                fid=fopen(sdfFilename,'a');
                fprintf(fid,'%s\n','> <PUBCHEM_SUBSTANCE_URL>');
                fprintf(fid,'%s\n\n','http://pubchem.ncbi.nlm.nih.gov/summary/summary.cgi?sid=7849722');
                fprintf(fid,'%s\n','> <LIPID_MAPS_CMPD_URL>');
                fprintf(fid,'%s\n\n','http://www.lipidmaps.org/data/get_lm_lipids_dbgif.php?LM_ID=LMFA01020030');
                fprintf(fid,'%s\n','> <LM_ID>');
                fprintf(fid,'%s\n\n','LMFA0123456');
                fprintf(fid,'%s\n','> <COMMON_NAME>');
                fprintf(fid,'%s\n\n',model.metNames{m});
                fprintf(fid,'%s\n','> <SYSTEMATIC_NAME>');
                fprintf(fid,'%s\n\n',metAbbr);
                fprintf(fid,'%s\n','> <SYNONYMS>');
                fprintf(fid,'%s\n\n','dummy');
                fprintf(fid,'%s\n','> <CATEGORY>');
                fprintf(fid,'%s\n\n','dummy');
                fprintf(fid,'%s\n','> <MAIN_CLASS>');
                fprintf(fid,'%s\n\n','dummy');
                fprintf(fid,'%s\n','> <SUB_CLASS>');
                fprintf(fid,'%s\n\n','dummy');
                fprintf(fid,'%s\n','> <EXACT_MASS>');
                
                M = getMolecularMass(model.met(m).formulaInChI,1);
                charge = getChargeFromInChI(model.met(m).InChI);
                %use mass for neutral metabolite
                M = M - charge*HexactMass;
                
                fprintf(fid,'%10.7f\n\n',M);
                fprintf(fid,'%s\n','> <FORMULA>');
                fprintf(fid,'%s\n\n',model.met(m).formulaInChI);
                fprintf(fid,'%s\n','> <LIPIDBANK_ID>');
                fprintf(fid,'%s\n\n','NaN');
                fprintf(fid,'%s\n','> <PUBCHEM_SID>');
                fprintf(fid,'%s\n\n','NaN');
                fprintf(fid,'%s\n','$$$$');
                fclose(fid);
            end
        end
    end
    if mod(m,100)==0
        disp(m);
    end
end

        
        
        
       
