function err = CNAMFNetwork2metatool(cnap,fname,macromol)
%
% CellNetAnalyzer API function 'CNAMFNetwork2metatool'
% ---------------------------------------------------
% --> exports CNA mass-flow project to METATOOL-compatible file
%
% Usage: err = CNAMFNetwork2metatool(cnap,fname,macromol)
%
% Inputs:
%       - cnap (mandatory): a CNA mass-flow project
%       - fname (optional): the name of the METATOOL file to be generated
%               if fname is not defined or empty a dialog box will appear
%       - macromol (optional): vector containing the macromolecule values
%               (concentrations); can be empty when cnap.mue or
%               cnap.macroComposition is empty (default: cnap.macroDefault)
%
% Ouputs:
%       - err: whether an error occurred (err>0) or not (err=0).
%

global cnan; %#ok

err=0;

if nargin<3
    macromol=cnap.macroDefault;
end
if nargin<2 || isempty(fname)
        cd(cnap.path);
	[ldat, fpath]=uiputfile('*.dat','Export stoichiometric matrix in METATOOL format');
        cd(cnan.cnapath);
        if(ldat==0)
                err=1;
                return;
        end;

        sfi=fopen([fpath, ldat], 'w', 'n', 'UTF-8');
        if(sfi==-1)
                msgbox(['Could not open file: ',[fpath ldat]]);
                err=1;
                return;
        end
else
        sfi= fopen(fname, 'w');
        if sfi == -1
                disp(['Cannot open file: ', fname]);
                err= 2;
                return;
        end
end


stoichmat=initsmat(cnap.stoichMat,cnap.mue,cnap.macroComposition,macromol,1:cnap.nums);


%delreac=0;
%if(~isempty(cnap.local.rb))
%	delreac=questdlg('Exclude reactions whose rates are given?');
%        if(strcmp(delreac,'Yes'))
%                delreac=1;;
%        elseif(strcmp(delreac,'No'))
%                delreac=0;;
%        else
%                return;
%        end
%end

rev=[];
irrev=[];
for i=1:cnap.numr
	%if(~delreac | ~ismember(i,cnap.local.rb(:,1)))
		if(cnap.reacMin(i)<0)
			rev=[rev,deblank(cnap.reacID(i,:)),' '];
		else
			irrev=[irrev,deblank(cnap.reacID(i,:)),' '];
		end
	%end
end
fprintf(sfi,['-ENZREV \n',rev,'\n\n-ENZIRREV \n',irrev,'\n\n']);

iimet=[];
eemet=[];
%eemet=['ExtMet '];
for i=1:cnap.nums
	if(cnap.specExternal(i)==0)
		iimet=[iimet,deblank(cnap.specID(i,:)),'  '];
	else
		eemet=[eemet,deblank(cnap.specID(i,:)),'  '];
	end
end
fprintf(sfi,['-METINT \n',iimet,'\n\n-METEXT \n',eemet,'\n\n-CAT\n']);

for i=1:cnap.numr

	%if(~delreac | ~ismember(i,cnap.local.rb(:,1)))
        	first=1;
        	reaktion=[deblank(cnap.reacID(i,:)),' : '];
		cons=find(stoichmat(:,i)<0);
        	for j=1:length(cons)
               		if(first~=1)
                     		reaktion=[reaktion,' + ',num2str(-stoichmat(cons(j),i), '%.10g'),' ',deblank(cnap.specID(cons(j),:))];
                	else
                      		first=0;
                      		reaktion=[reaktion,num2str(-stoichmat(cons(j),i), '%.10g'),' ',deblank(cnap.specID(cons(j),:))];
                	end
        	end

%		if(length(cons)==0)
%			reaktion=[reaktion,'ExtMet '];
%		end

        	reaktion=[reaktion,' = '];
        	first=1;
		cons=find(stoichmat(:,i)>0);
       	 	for j=1:length(cons)
               		if(first~=1)
                      		reaktion=[reaktion,' + ',num2str(stoichmat(cons(j),i), '%.10g'),' ',deblank(cnap.specID(cons(j),:))];
               		else
                      		first=0;
                      		reaktion=[reaktion,num2str(stoichmat(cons(j),i), '%.10g'),' ',deblank(cnap.specID(cons(j),:))];
               		end
         	end
%		if(length(cons)==0)
%			reaktion=[reaktion,'ExtMet '];
%		end

		fprintf(sfi,[reaktion,'\n']);
	%end

end

fclose(sfi);
	

%A# The following variables are now strictly local and not fields of cnap.local any more:
% delreac
% first
% irrev
% reaktion
% rev
% sfi
% stoichmat
