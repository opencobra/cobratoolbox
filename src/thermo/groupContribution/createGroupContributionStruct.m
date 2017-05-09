function metGroupCont=createGroupContributionStruct(primaryFile,pH,secondaryFile)
% Generates a matlab structure out of the tab delimited group contribuion data
%
% The matlab structure with the group contibution data for each
% metabolite uses the primaryFile file in preference to the secondaryFile file but
% these can be any first and second preference files as long as they are
% in the correct format see webCGMtoTabDelimitedFile.m
%
%INPUT
% primaryFile    tab delimited text file with group contribution data 
%                (Janowski et al Biophysical Journal 95:1487-1499 (2008))
%                i.e. output such as webCGM.txt from
%                webCGMtoTabDelimitedFile.m
%
%OPTIONAL INPUT
% pH             ph at which group contribution data given for, default=7
%
% secondaryFile  tab delimited text file with group contribution data 
%                (Janowski et al Biophysical Journal 95:1487-1499 (2008))
%                i.e. output such as webCGM.txt from
%                webCGMtoTabDelimitedFile.m
%                If the same metabolite abbreviation occurs in both files,
%                then the data in the primary file takes precedence.
%
%
%INPUT FILE FORMAT
% the first two text columns in both files should correspond to:
% abbreviation   
% formulaMarvin
%
% the next three columns in both files should correspond to:
% delta_G_formation
% delta_G_formation_Uncertainty
% chargeMarvin
%
%OUTPUT
% metGroupCont(m).abbreviation                      metabolite abbreviation
% metGroupCont(m).formulaMarvin                     metabolite formula (Marvin)
% metGroupCont(m).delta_G_formation                     
% metGroupCont(m).delta_G_formation_uncertainty
% metGroupCont(m).chargeMarvin                      metabolite charge (Marvin)
% metGroupCont(m).pH
% metGroupCont(m).file                              file data came from
%
% Ronan M. T. Fleming 9 July 2009

if ~exist('pH','var')
    pH=7;
end

fid=fopen(primaryFile,'r');
if fid==-1
    error(['Cannot open ' primaryFile]);
else
    fprintf('%s\n',['Reading primary metabolite group contribution data from: ' primaryFile]);
end
C = textscan(fid,'%s %s %f %f %f');
primaryAbbr=C{1};
C2=C{2};
C3=C{3};
C4=C{4};
C5=C{5};

%
for m=1:length(primaryAbbr)
    metGroupCont(m,1).abbreviation=primaryAbbr{m};
    metGroupCont(m,1).formulaMarvin=C2{m};
    metGroupCont(m,1).delta_G_formation=C3(m,1);
    metGroupCont(m,1).delta_G_formation_uncertainty=C4(m,1);
    metGroupCont(m,1).chargeMarvin=C5(m);
    metGroupCont(m,1).pH=pH;
    metGroupCont(m,1).file=primaryFile;
end

if exist('secondaryFile','var')
    fid=fopen(secondaryFile,'r');
    if fid==-1
        error(['Cannot open ' secondaryFile]);
    else
        fprintf('%s\n',['Reading secondary metabolite group contribution data from: ' secondaryFile]);
    end
    C = textscan(fid,'%s %s %f %f %f');
    secondaryAbbr=C{1};
    C2=C{2};
    C3=C{3};
    C4=C{4};
    C5=C{5};

    m=length(primaryAbbr)+1;
    for n=1:length(secondaryAbbr)
        ind=strcmp(secondaryAbbr{n},primaryAbbr);
        %add the data from the secondary group contribution file if missing from
        %the primary file
        if ~any(ind)
            metGroupCont(m,1).abbreviation=secondaryAbbr{n};
            metGroupCont(m,1).formulaMarvin=C2{n};
            metGroupCont(m,1).delta_G_formation=C3(n);
            metGroupCont(m,1).delta_G_formation_uncertainty=C4(n);
            metGroupCont(m,1).chargeMarvin=C5(n);
            metGroupCont(m,1).pH=pH;
            metGroupCont(m,1).file=secondaryFile;
            m=m+1;
        end
    end
end







