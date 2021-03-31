function metList = molFilesToCDFfile(model, cdfFileName)
% Concatenates all the mol files in current folder into a cdf file.
%
% Creates a cdf file, named  cdfFileNam, out of all the mol files in the
% current folder. The cdf file can then be used with the web based
% implementation of the group contribution method to estimate the Standard
% Gibbs energy of formation for a batch of metabolite species
% The web-based implementation of this new group contribution method is
% available free at http://sparta.chem-eng.northwestern.edu/cgi-bin/GCM/WebGCM.cgi.
% The code checks for a .mol file with the filename prefix given by the
% abbreviation in the model, therefore, you should name your own mol files
% accordingly.
%
% USAGE:
%
%    metList = molFilesToCDFfile(model, cdfFileName)
%
% INPUT:
%    model:              structure with fields:
%
%                          * model.mets - cell array of metabolite abbreviations corresponding to the mol files
%    cdfFileName:        name of cdf file
%
% OUTPUT:
%    metList:
%    cdfFileName.cdf:    cdf file with all the mol files in order of the model metabolite abbreviations
%
% .. Author: - Ronan M.T. Fleming

mets = model.mets;
nMet = length(mets);
noMolFileCount = 0;
% doneMets = {};
metList = {};
first = true;

fid0=fopen([cdfFileName '.cdf'],'w');
for m=1:nMet
    metAbbr=mets{m};
    metAbbr=metAbbr(1:end-3);

    %     if ~any(strcmp(metAbbr,doneMets))
    %         doneMets = [doneMets; {metAbbr}];

    fid = fopen([metAbbr '.mol'],'r');
    if fid~=-1
        metList = [metList; mets(m)]; % [metList; {metAbbr}];
        if first
            while 1
                tline = fgetl(fid);
                if ~ischar(tline)
                    break
                end
                fprintf(fid0,'%s\n',tline);
            end
            fclose(fid);
            first = false;
        else
            fprintf(fid0,'%s\n','$$$$');
            while 1
                tline = fgetl(fid);
                if ~ischar(tline)
                    break
                end
                fprintf(fid0,'%s\n',tline);
            end
            fclose(fid);
            %             model.met(m).molFile=1;
        end
    else
        fprintf('%s\n',['No mol file for ' mets{m}]);
        %             model.met(m).molFile=0;
        noMolFileCount=noMolFileCount+1;
    end
    %     end
end
fprintf('%s\n',['Percentage of metabolites without mol files: ' num2str(noMolFileCount/nMet)]);
fclose(fid0);
