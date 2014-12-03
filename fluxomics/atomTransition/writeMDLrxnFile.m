function writeMDLrxnFile(model,molFilePath,rxnBool,rxnFileName)
%writes an MDL rxnfile with structural data for the reactants and products
%of a reaction in V2000 reaction file format
%
% Line 1:
% $RXN in the first position on this line identifies the file as a reaction file.
%
% Line 2:
% A line for the reaction name. If no name is available, a blank line must be present.
%
% Line 3:
% User’s initials (I), program name and version (P), date/time (M/D/Y,H:m),
%and reaction registry number (R). This line has the format:
% IIIIIIPPPPPPPPPMMDDYYYYHHmmRRRRRRR
% (FORTRAN: <-A6-><---A9--><---A12----><--I7-> )
% A blank line can be substituted for line 3.
% If the internal registry number is more than 7 digits long, it is stored in an “M REG�? line (see “Large REGNO�? on page 60).
% Note: In rxnfiles produced by earlier versions of ISIS/Host, the year occupied two digits instead of four. There are corresponding minor changes in the adjacent fields. The format of the line is:
% IIIIIIPPPPPPPPPPMMDDYYHHmmRRRRRRRR
% (FORTRAN: <-A6-><---A10--><---A10--><--I8--> )
%
% Line 4
% A line for comments. If no comment is entered, a blank line must be present.
% 
% Reactants/Products
% A line identifying the number of reactants and products, in that order. The format is:
% rrrppp
% where the variables represent:
% rrr Number of reactants
% ppp Number of products
% Molfile Blocks
% A series of blocks, each starting with $MOL as a delimiter, giving the 
% molfile for each reactant and product in turn. The molfile blocks are 
% always in the same order as the molecules in the reaction; 
% reactants first and products second.
%
%
%INPUT
% model
% molFilePath       path to the set of MDL V2000 mol files with filenames
%                   identical to the abbreviations of the metabolites 
%                   (without the compartment)
%OUTPUT
% writes the .rxn file to the current directory

[nMet,nRxn]=size(model.S);

if ~exist('rxnBool','var')
    rxnBool=ones(nRxn,1);
end

if ~exist('rxnFileName','var')
    rxnFileName='model';
end

hBool = false(size(model.mets));
hBool(strmatch('h[',model.mets)) = true;

rxnFileName=[pwd filesep rxnFileName '_MDL_V2000.rxn'];
fid=fopen(rxnFileName,'w');
fclose(fid);

for n=1:nRxn
    if rxnBool(n)
        %workaround for reactions that use 1/2 o2
        if any(abs(model.S(:,n))==0.5)
            model.S(:,n)=model.S(:,n)*2;
        end
        
        fid=fopen(rxnFileName,'a+');
        fprintf(fid,'%s\r\n','$RXN');
        rxnName = model.rxns{n};
        fprintf(fid,'%s\r\n\r\n',rxnName);
        comment = printRxnFormula(model,model.rxns{n},0);
        fprintf(fid,'%s\r\n',comment{:});
        
        %count number of non hydrogen reactants and number of products  
        nR = abs(full(sum(model.S(~hBool & model.S(:,n)<0,n))));
        nP = abs(full(sum(model.S(~hBool & model.S(:,n)>0,n))));
        %reactants first and products second
        rrrppp=[repmat(' ',1,3-length(nR)) int2str(nR) repmat(' ',1,3-length(nP)) int2str(nP)];
       
        fprintf(fid,'%s\r\n',rrrppp);
        fclose(fid);
        %reactant mol files
        for m=1:nMet
            if model.S(m,n)<0              
                if ~hBool(m)
                    for p=1:abs(model.S(m,n))
                        fid=fopen(rxnFileName,'a+');
                        fprintf(fid,'%s\r\n','$MOL');
                        fclose(fid);
                        metAbbr=model.mets{m};
                        metAbbr=metAbbr(1:end-3);
                        molFileName = [molFilePath metAbbr '.mol'];
                        if exist(molFileName,'file')==2
                            %appends the first file to the next
                            if isunix
                                command =['cat ' molFileName ' >> ' rxnFileName ];
                                if unix(command)~=0
                                    error(['Error appending mol file for: ' metAbbr]);
                                end
                            elseif ispc
                                system(['type ' rxnFileName ' > tmp']);
                                pcStatus = system(['type tmp ' molFileName ' > ' rxnFileName]);
                                if pcStatus~=0
                                    error(['Error appending mol file for: ' metAbbr]);
                                end
                            end
                        else
                            error(['Could not fine mol file for: ' metAbbr]);
                        end
                    end
                end
            end
        end
        %product mol files
        for m=1:nMet
            if model.S(m,n)>0
                if ~hBool(m)
                    for p=1:abs(model.S(m,n))
                        fid=fopen(rxnFileName,'a+');
                        fprintf(fid,'%s\r\n','$MOL');
                        fclose(fid);
                        metAbbr=model.mets{m};
                        metAbbr=metAbbr(1:end-3);
                        molFileName = [molFilePath metAbbr '.mol'];
                        if exist(molFileName,'file')==2
                            %appends the first file to the next
                            if isunix
                                command =['cat ' molFileName ' >> ' rxnFileName ];
                                if unix(command)~=0
                                    error(['Error appending mol file for: ' metAbbr]);
                                end
                            elseif ispc
                                system(['type ' rxnFileName ' > tmp']);
                                pcStatus = system(['type tmp ' molFileName ' > ' rxnFileName]);
                                if pcStatus~=0
                                    error(['Error appending mol file for: ' metAbbr]);
                                end
                            end
                        else
                            error(['Could not fine mol file for: ' metAbbr]);
                        end
                    end
                end
            end
        end
    end
end

%eof
end

