function err = CNAMFNetwork2sbml(cnap,fname,macromol)
%
% CellNetAnalyzer API function 'CNAMFNetwork2sbml'
% -----------------------------------------------
% --> exports CNA mass-flow project to SBML file
%
% Usage: err = CNAMFNetwork2sbml(cnap,fname,macromol)
%
% Inputs:
%	- cnap (mandatory): a CNA mass-flow project
%	- fname (optional): the name of the SBML file to be generated
%		if fname is not defined or empty a dialog box will appear
%	- macromol (optional): vector containing the macromolecule values 
%              	(concentrations); can be empty when cnap.mue or 
%		cnap.macroComposition is empty (default: cnap.macroDefault)
%
% Ouputs: 
%	- err: whether an error occurred (err>0) or not (err=0).
%

global cnan;

err=0;

if nargin<3
    macromol=cnap.macroDefault;
end
if nargin<2 || isempty(fname)
	cd(cnap.path);
	[ldat, fpath]=uiputfile('*.xml','Export model in SBML format');
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


smat=initsmat(cnap.stoichMat,cnap.mue,cnap.macroComposition,macromol,1:cnap.nums);

%A# process IDs to make sure they conform to SBML type SId
spec_id= regexprep(cellstr(cnap.specID), '[^a-z_A-Z0-9]','_'); %A# replace invalid characters with _
reac_id= regexprep(cellstr(cnap.reacID), '[^a-z_A-Z0-9]','_');
spec_name= regexprep(cellstr(cnap.specLongName), {'&', '''', '"'}, {'&amp', '&apos', '&quot'});

if ~isempty(cnap.mue)
  reac_id{cnap.mue}= 'BiomassSynthesis';
end
%A# to make sure all IDs are unique and all begin with a letter prefixes
%A# are added to the IDs
%for i= 1:length(spec_id)
%  spec_id{i}= sprintf('S%d_%s', i, spec_id{i});
%end
%for i= 1:length(reac_id)
%  reac_id{i}= sprintf('R%d_%s', i, reac_id{i});
%end

disp('Saving ...');

fprintf(sfi, '<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(sfi,'<sbml xmlns="http://www.sbml.org/sbml/level2" level="2" version="1">\n');
if ~isfield(cnap,'netnum') || isnan(cnap.netnum) %A# not a network from the networks file
  str=['   <model id="CNA_stoichiometric_model" name= CNA_stoichiometric_model">\n'];
else
  str=['   <model id="CNA_',regexprep(cnan.net(cnap.netnum).name, '[^a-z_A-Z0-9]','_'),'" name="',cnan.net(cnap.netnum).name,'">\n'];
end
fprintf(sfi,str);
fprintf(sfi,'      <listOfCompartments>\n');
if(sum(cnap.specExternal)>0)
	fprintf(sfi,'         <compartment id="External_Species"/>\n');
end
fprintf(sfi,'         <compartment id="Internal_Species"/>\n'); 
fprintf(sfi,'      </listOfCompartments>\n');
fprintf(sfi,'      <listOfSpecies>\n'); 
for i=1:cnap.nums
	if(cnap.specExternal(i))
		str=['         <species id="',spec_id{i},'" name="',spec_name{i},'" boundaryCondition="true" compartment="External_Species"/>\n'];
	else
		str=['         <species id="',spec_id{i},'" name="',spec_name{i},'" boundaryCondition="false" compartment="Internal_Species"/>\n'];
	end
	fprintf(sfi,str);
end
fprintf(sfi,'      </listOfSpecies>\n'); 

fprintf(sfi,'      <listOfReactions>\n'); 
for i=1:cnap.numr
  if i == cnap.mue
    reacname= 'biomass synthesis';
  else
    reacname= deblank(cnap.reacID(i, :));
  end;
	if(cnap.reacMin(i)<0)
		str=['         <reaction id="',reac_id{i},'" name="', reacname, '" reversible="true">\n'];
	else
		str=['         <reaction id="',reac_id{i},'" name="', reacname, '" reversible="false">\n'];
	end
	fprintf(sfi,str);
	zw=find(smat(:,i)<0);
	if(length(zw))
		fprintf(sfi,'            <listOfReactants>\n'); 
		for j=1:length(zw)
			str=['               <speciesReference species="',spec_id{zw(j)},'" stoichiometry="',num2str(-smat(zw(j),i)),'"/>\n'];
			fprintf(sfi,str);
		end
		fprintf(sfi,'            </listOfReactants>\n'); 
	end
	
	zw=find(smat(:,i)>0);
	if(length(zw))
		fprintf(sfi,'            <listOfProducts>\n'); 
		for j=1:length(zw)
			str=['               <speciesReference species="',spec_id{zw(j)},'" stoichiometry="',num2str(smat(zw(j),i)),'"/>\n'];
			fprintf(sfi,str);
		end
		fprintf(sfi,'            </listOfProducts>\n'); 
	end
	fprintf(sfi,'         </reaction>\n'); 
end
fprintf(sfi,'      </listOfReactions>\n'); 
fprintf(sfi,'   </model>\n'); 
fprintf(sfi,'</sbml>\n'); 
fclose(sfi);
		
disp('... Ready');
