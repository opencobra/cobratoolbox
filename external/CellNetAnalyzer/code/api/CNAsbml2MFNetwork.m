function [cnap, errval]= CNAsbml2MFNetwork(fname)
%
% CellNetAnalyzer API function 'CNAsbml2MFNetwork
%
% Usage:  [cnap, errval] = CNAsbml2MFNetwork(fname)
%
% Input:  fname is the filename of the SBML file that is to be
%         converted. if no file name is specified, a dialog box occurs.
%
% Output: the mass-flow project variable cnap (which can afterwards be saved
%         via CNAsaveMFNetwork) and errval indicating
%         whether some error occured during conversion (1: error;
%         0: no error). For the type of error check the console output.
%

cnap=[];
errval=0;

if nargin<1 || isempty(fname)
  [fname, fpath]=uigetfile('*.xml','SBML Source File');
  if(fname==0) 
    return; 
  end
  lfi=fopen([fpath,fname],'r');
else
  lfi=fopen(fname,'r');
end
if(lfi==-1)
  disp(['Error loading file:  ',fname]);
   errval=1;
  return;
end

currow=0;

%%%%%%%%%%%%%%%%%Compartments %%%%%%%%%%%%%%%%%%%%%%%%

disp('Reading the compartments ...');

%%% Searching ListOfCompartments
while(1)
  currow=currow+1;
  rem=fgets(lfi);
  idx=mstrfind(rem,' ');
  rem(idx)=[];
  if(rem==-1)
    frewind(lfi)
    ready=1;
    break;
  end
  idx=mstrfind(upper(rem),upper('<listOfCompartments>'));
  if(~isempty(idx))
    rem=rem(idx(1)+20:end);
    ready=0;
    break;
  end
end

compartments='';
tofind=[];
tofind.str=[];
tofind.pos=[];
tofind(1).str='<compartmentid="';
tofind(1).pos=16;
tofindstr(2).str='<annotation';
tofind(2).pos=11;
tofindstr(3).str='</annotation>';
tofind(3).pos=13;
tofind(4).str='/>';
tofind(4).pos=2;
tofind(5).str='</listOfCompartments>';
tofind(5).pos=21;
tofind(6).str='</compartment>';
tofind(6).pos=14;
tofindnr=[1 2 5];
newread=0;
comp=0;

while(~ready)
	if(newread)
		currow=currow+1;
		rem=fgets(lfi);
		idx=mstrfind(rem,' ');
		rem(idx)=[];
		
       		if(rem==-1) 
			disp(['Error in line ',num2str(currow),': Unexpected end of file.']);
			fclose(lfi);
			errval=1;
			return;
		end
	end
	newread=0;

	i=0;notfound=1;
	ltofindnr=length(tofindnr);
	while(i<ltofindnr & notfound)
		i=i+1;
		curnr=tofindnr(i);
		switch(curnr)
			case 1 %% new Compaertment
				idx=mstrfind(rem,tofind(curnr).str);
				if(~isempty(idx))
					idx=idx(1);
					rem=rem(idx+tofind(curnr).pos:end);
					idx=mstrfind(rem,'"');
					if(isempty(idx))
						disp(['Error in line ',num2str(currow),': Could not find "']);
						fclose(lfi);
						errval=1;
               		        		return;
					end
					curstr=rem(1:idx(1)-1);
					rem=rem(idx(1):end);
					comp=comp+1;
					if(comp==1)
                               			compartments=curstr;
					else
                               			compartments=char(compartments,curstr);
					end
                                 	tofindnr=[4,6];
					notfound=0;
				end

			case 2  %  Annotation
				idx=mstrfind(rem,tofind(curnr).str);
				if(~isempty(idx))
					idx=idx(1);
					rem=rem(idx+tofind(curnr).pos:end);
					notfound=0;
					lasttofind=tofindnr;
					tofindnr=[3];
               			end

			 case 3   %  End of Annotation
				idx=mstrfind(rem,tofind(curnr).str);
				if(~isempty(idx))
					idx=idx(1);
					rem=rem(idx+tofind(curnr).pos:end);
					notfound=0;
					lasttofind=tofindnr;
					tofindnr=lasttofind;
               			end

			case 4  %% end of compartment 
                                idx=mstrfind(rem,tofind(curnr).str);
                                if(~isempty(idx))
                                        idx=idx(1);
                                        rem=rem(idx+tofind(curnr).pos:end);
                                        tofindnr=[1 2 5];
                                        notfound=0;
                                end

			case 5  %% end of compartment list
                                idx=mstrfind(rem,tofind(curnr).str);
                                if(~isempty(idx))
                                        idx=idx(1);
                                        rem=rem(idx+tofind(curnr).pos:end);
                                        tofindnr=[];
					ready=1;
                                        notfound=0;
                                end

			case 6  %% end of compartment 
                                idx=mstrfind(rem,tofind(curnr).str);
                                if(~isempty(idx))
                                        idx=idx(1);
                                        rem=rem(idx+tofind(curnr).pos:end);
                                        tofindnr=[1 2 5];
                                        notfound=0;
                                end

		end
	end	
	newread=notfound;
end

disp(['Found ',num2str(comp),' compartments']);
disp(' ');
if(comp>0)
	ready=0;
	while(~ready)
		disp('Do you think that one of the compartments listed below serves as container for external species (in the sense of stoichiometric network studies)? If so please give the number of this compartment (or choose 0 for "None")');
		disp('	0 = None');
		for i=1:comp
			disp(['	',num2str(i),' = ',deblank(compartments(i,:))]);
		end
		zw=input('Select number of compartment for external species>> ','s');
		excomp=str2num(zw);
		if(isempty(excomp))
			disp('Wrong input');
			disp(' ');
		else
			if(excomp==0)
				excomp=[];
				ready=1;
			elseif(excomp>0 & excomp<=comp)
				excomp=deblank(compartments(excomp,:));
				ready=1;
			else
				disp('Wrong input');
                        	disp(' ');
			end
		end
	end
else
	excomp=[];
end
	

%%%%%%%%%%%%%%%%%% Species  %%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Searching ListOfSpecies
while(1)
	currow=currow+1;
	rem=fgets(lfi);
	idx=mstrfind(rem,' ');
	rem(idx)=[];
        if(rem==-1)
		disp(['Error in line ',num2str(currow),': Unexpected end of file. No species were defined at all.']);
		fclose(lfi);
                errval=1;
		return;
	end
	idx=mstrfind(upper(rem),upper('<listOfSpecies>'));
	if(~isempty(idx))
		rem=rem(idx(1)+15:end);
		break;
	end
end


metabolites=[];
met_longname=[];
extmet=[];
anz_stoffe=0;
disp(' ');
disp('Reading the species ...');
tofind=[];
tofind.str=[];
tofind.pos=[];
tofind(1).str='<speciesid="';
tofind(1).pos=12;
tofind(2).str='name="';
tofind(2).pos=6;
tofind(3).str='boundaryCondition="';
tofind(3).pos=19;
tofindstr(4).str='<annotation';
tofind(4).pos=11;
tofindstr(5).str='</annotation>';
tofind(5).pos=13;
tofind(6).str='/>';
tofind(6).pos=2;
tofind(7).str='</listOfSpecies>';
tofind(7).pos=16;
tofind(8).str='compartment="';
tofind(8).pos=13;
tofind(9).str='</species>';
tofind(9).pos=10;
tofindnr=[1 7 4];
newread=0;
ready=0;

while(~ready)
  if(newread)
    currow=currow+1;
    rem=fgets(lfi);
    idx=mstrfind(rem,' ');
    rem(idx)=[];

    if(rem==-1)
      disp(['Error in line ',num2str(currow),': Unexpected end of file.']);
      fclose(lfi);
      errval=1;
      return;
    end
  end
  newread=0;

  i=0;notfound=1;
  ltofindnr=length(tofindnr);
  while(i<ltofindnr & notfound)
    i=i+1;
    curnr=tofindnr(i);
    switch(curnr)
      case 1 %% new Species
        idx=mstrfind(rem,tofind(curnr).str);
        if(~isempty(idx))
          idx=idx(1);
          currem=rem(idx+tofind(curnr).pos:end);
          idx=mstrfind(currem,'"');
          if(isempty(idx))
            disp(['Error in line ',num2str(currow),': Could not find "']);
            fclose(lfi);
            errval=1;
            return;
          end
          curstr=currem(1:idx(1)-1);
          anz_stoffe=anz_stoffe+1;
          if(anz_stoffe==1)
            metabolites=curstr;
            met_longname=curstr;
          else
            metabolites=char(metabolites,curstr);
            met_longname=char(met_longname,curstr);
          end
          extmet(anz_stoffe)=0;
          tofindnr=[2 8 3 6 9];
          notfound=0;
        end

      case 2   %% name
        idx=mstrfind(rem,tofind(curnr).str);
        if(~isempty(idx))
          idx=idx(1);
          currem=rem(idx+tofind(curnr).pos:end);
          idx=mstrfind(currem,'"');
          if(isempty(idx))
            disp(['Error in line ',num2str(currow),': Could not find "']);
            fclose(lfi);
            errval=1;
            return;
          end
          curstr=currem(1:idx(1)-1);
          if(anz_stoffe>1)
            met_longname=char(met_longname(1:anz_stoffe-1,:),curstr);
          else
            met_longname=curstr;
          end
          tofindnr(find(tofindnr==2))=[];
          notfound=0;
        end

      case 3  %% boundary condition
        idx=mstrfind(rem,tofind(curnr).str);
        if(~isempty(idx))
          idx=idx(1);
          currem=rem(idx+tofind(curnr).pos:end);
          idx=mstrfind(currem,'"');
          if(isempty(idx))
            disp(['Error in line ',num2str(currow),': Could not find "']);
            fclose(lfi);
            errval=1;
            return;
          end
          curstr=currem(1:idx(1)-1);
          if(strcmp('true',lower(curstr)))
            extmet(anz_stoffe)=1;
          end
          tofindnr(find(tofindnr==3))=[];
          notfound=0;
        end

      case 4  %  Annotation
        idx=mstrfind(rem,tofind(curnr).str);
        if(~isempty(idx))
          idx=idx(1);
          rem=rem(idx+tofind(curnr).pos:end);
          notfound=0;
          lasttofind=tofindnr;
          tofindnr=[5];
        end

      case 5   %  End of Annotation
        idx=mstrfind(rem,tofind(curnr).str);
        if(~isempty(idx))
          idx=idx(1);
          rem=rem(idx+tofind(curnr).pos:end);
          notfound=0;
          lasttofind=tofindnr;
          tofindnr=lasttofind;
        end

      case {6, 9}  %% end of species
        idx=mstrfind(rem,tofind(curnr).str);
        if(~isempty(idx))
          idx=idx(1);
          rem=rem(idx+tofind(curnr).pos:end);
          tofindnr=[1 4 7];
          notfound=0;
        end

      case 7  %% end of species list
        idx=mstrfind(rem,tofind(curnr).str);
        if(~isempty(idx))
          idx=idx(1);
          rem=rem(idx+tofind(curnr).pos:end);
          tofindnr=[];
          ready=1;
          notfound=0;
        end

      case 8  %%compartment (== external ?)
        idx=mstrfind(rem,tofind(curnr).str);
        if(~isempty(idx))
          idx=idx(1);
          currem=rem(idx+tofind(curnr).pos:end);
          idx=mstrfind(currem,'"');
          if(isempty(idx))
            disp(['Error in line ',num2str(currow),': Could not find "']);
            fclose(lfi);
            errval=1;
            return;
          end
          curstr=currem(1:idx(1)-1);
          if(~isempty(excomp) & strcmp(lower(excomp),lower(curstr)))
            extmet(anz_stoffe)=1;
          end
          tofindnr(find(tofindnr==8))=[];
          notfound=0;
        end
    end
  end
  newread=notfound;
end

disp(['Found ',num2str(anz_stoffe),' species (thereof ',num2str(sum(extmet)),' external metabolites)']);
disp(' ');
disp('Species ID check ...');
	
i=1;
while(i<anz_stoffe)
	idx=mfindstr_casesens(metabolites(i+1:end,:),metabolites(i,:));
	if(idx)
		lidx=length(idx);
            	disp(['Species id ',deblank(metabolites(i,:)),' has been used for ',num2str(lidx+1),' species. ',num2str(lidx),' of these species will be deleted.']);
	    	metabolites(i+idx,:)=[];
	    	extmet(i+idx)=[];
	    	met_longname(i+idx,:)=[];
	    	anz_stoffe=anz_stoffe-lidx;
	end
	i=i+1;
end

disp('Species ID check done');
disp(' ');


%%%%%%%%%%%% Reactions %%%%%%%%%%%%%%%%%%%%%

disp(' ');
disp('Reading the reactions ...');
reactions=[];
CONSTRAINTS=[];
reacuis=0;
smat=[];

%%% Searching listOfReactions
ready=0;
while(1)
	currow=currow+1;
	rem=fgets(lfi);
	idx=mstrfind(rem,' ');
	rem(idx)=[];
        if(rem==-1)
		disp(['No listOfReactions entry found']);
		ready=1;
	end
	idx=mstrfind(upper(rem),upper('<listOfReactions>'));
	if(~isempty(idx))
		rem=rem(idx(1)+17:end);
		break;
	end
end

tofind=[];
tofind.str=[];
tofind.pos=[];

%tofind(1).str='<reactionid="';
%tofind(1).pos=13;
%tofind(2).str='name="';
%tofind(2).pos=6;
%%% 2 not used so far!
%tofind(3).str='reversible="';
%tofind(3).pos=12;
%tofind(4).str='<listOfReactants>';
%tofind(4).pos=17;
%tofind(5).str='<speciesReferencespecies="';
%tofind(5).pos=26;
%tofind(6).str='stoichiometry="';
%tofind(6).pos=15;
%tofind(7).str='</listOfReactants>';
%tofind(7).pos=18;
%tofind(8).str='<listOfProducts>';
%tofind(8).pos=16;
%tofind(9).str='<speciesReferencespecies="';
%tofind(9).pos=26;
%tofind(10).str='stoichiometry="';
%tofind(10).pos=15;
%tofind(11).str='</listOfProducts>';
%tofind(11).pos=17;
%tofind(12).str='</reaction>';
%tofind(12).pos=11;
%tofind(13).str='</listOfReactions>';
%tofind(13).pos=18;
%tofindstr(14).str='<annotation';
%tofind(14).pos=11;
%tofindstr(15).str='</annotation>';
%tofind(15).pos=13;


tofind(1).str='<reactionid="';
tofind(1).pos=13;
%%% 2 not used so far
tofind(2).str='>';
tofind(2).pos=1;
tofind(3).str='reversible="';
tofind(3).pos=12;
tofind(4).str='<listOfReactants>';
tofind(4).pos=17;
tofind(5).str='<speciesReference';
tofind(5).pos=17;
tofind(6).str='species="';
tofind(6).pos=9;
tofind(7).str='stoichiometry="';
tofind(7).pos=15;
tofind(8).str='</listOfReactants>';
tofind(8).pos=18;
tofind(9).str='<listOfProducts>';
tofind(9).pos=16;
tofind(10).str='</listOfProducts>';
tofind(10).pos=17;
tofind(11).str='</reaction>';
tofind(11).pos=11;
tofind(12).str='</listOfReactions>';
tofind(12).pos=18;
tofindstr(13).str='<annotation';
tofind(13).pos=11;
tofindstr(14).str='</annotation>';
tofind(14).pos=13;
tofindnr=[1,13];
newread=0;

while(~ready)
	if(newread)
		currow=currow+1;
		rem=fgets(lfi);
		idx=mstrfind(rem,' ');
		rem(idx)=[];
		
       		if(rem==-1) 
			disp(['Error in line ',num2str(currow),': Unexpected end of file.']);
			fclose(lfi);
            		errval=1;
			return;
		end
	end
	newread=0;

	i=0;notfound=1;
	ltofindnr=length(tofindnr);
	while(i<ltofindnr & notfound)
		i=i+1;
		curnr=tofindnr(i);
		switch(curnr)
			case 1   % new reaction
				idx=mstrfind(rem,tofind(curnr).str);
				if(~isempty(idx))
					idx=idx(1);
					rem=rem(idx+tofind(curnr).pos:end);
					idx=mstrfind(rem,'"');
					if(isempty(idx))
						disp(['Error in line ',num2str(currow),': Could not find "']);
						fclose(lfi);
            					errval=1;
               		        		return;
					end
					curstr=rem(1:idx(1)-1);
					rem=rem(idx(1):end);
					reacuis=reacuis+1;
					if(reacuis==1)
						reactions=curstr;
					else
						reactions=char(reactions,curstr);
					end
					CONSTRAINTS(reacuis,:)=[0 0 -Inf Inf];
					smat(:,reacuis)=zeros(anz_stoffe,1);
					notfound=0;
					tofindnr=[3 2];
               			end
                        
            case 2  %  end reaction header
                idx=mstrfind(rem,tofind(curnr).str);
				if(~isempty(idx))
					idx=idx(1);
					rem=rem(idx+tofind(curnr).pos:end);
                    notfound=0;
					tofindnr=[4 9 13];  
                end
			case 3   %Reversibility
				idx=mstrfind(rem,tofind(curnr).str);
				if(~isempty(idx))
					idx=idx(1);
					rem=rem(idx+tofind(curnr).pos:end);
					idx=mstrfind(rem,'"');
					if(isempty(idx))
						disp(['Error in line ',num2str(currow),': Could not find "']);
						fclose(lfi);
						errval=1;
               		        		return;
					end
					curstr=rem(1:idx(1)-1);
					rem=rem(idx(1):end);

					if(strcmp('false',lower(curstr)))  %%% else: use default as already set
						CONSTRAINTS(reacuis,3)=0;
                    end

					notfound=0;
					tofindnr=[2];
               	end


			case 4   % List of Reactants 
				idx=mstrfind(rem,tofind(curnr).str);
				if(~isempty(idx))
					idx=idx(1);
					rem=rem(idx+tofind(curnr).pos:end);
					notfound=0;
                    reactflag=-1;
					tofindnr=[5 8 13];
               	end

			case 5   %speciesReference 
				idx=mstrfind(rem,tofind(curnr).str);
				if(~isempty(idx))
					idx=idx(1);
					rem=rem(idx+tofind(curnr).pos:end);
                    stoichcoeff=1;
					notfound=0;
					tofindnr=[6,7];
               	end
                        
          case 6   %species Reactants/Products
				idx=mstrfind(rem,tofind(curnr).str);
				if(~isempty(idx))
					idx=idx(1);
					currem=rem(idx+tofind(curnr).pos:end);
					idx=mstrfind(currem,'"');
					if(isempty(idx))
						disp(['Error in line ',num2str(currow),': Could not find "']);
						fclose(lfi);
						errval=1;
               		        		return;
					end
					curstr=currem(1:idx(1)-1);

					curmet=mfindstr_casesens(metabolites,curstr);
					if(~curmet)
						disp(['Error in line ',num2str(currow),': Species id ',curstr,' not defined']);
						fclose(lfi);
						errval=1;
       		                 		return;
       		         		end
					smat(curmet,reacuis)= smat(curmet,reacuis) + reactflag*stoichcoeff;
					notfound=0;
					tofindnr(find(tofindnr==6))=[];
                    			if(reactflag==-1)
                        			tofindnr=[5 8 13 tofindnr];
                    			else
                        			tofindnr=[5 10 13 tofindnr];
               				end
                		end

                        
			case 7   %Stoichiometry Reactants
				idx=mstrfind(rem,tofind(curnr).str);
				if(~isempty(idx))
					idx=idx(1);
					rem=rem(idx+tofind(curnr).pos:end);
					idx=mstrfind(rem,'"');
					if(isempty(idx))
						disp(['Error in line ',num2str(currow),': Could not find "']);
						fclose(lfi);
						errval=1;
               		        		return;
					end
					curstr=rem(1:idx(1)-1);
					rem=rem(idx(1):end);
					zw=str2num(curstr);

					if(isempty(zw))
						disp(['Error in line ',num2str(currow),': Could not resolve Stoichiometry']);
						fclose(lfi);
						errval=1;
       		                 		return;
			errval=1;
			return;
                                	end
                    			if(ismember(6,tofindnr)==1)
					    stoichcoeff=zw;
                    			else
                        			smat(curmet,reacuis)=reactflag*zw;
                    			end
					notfound=0;
                    			tofindnr(find(tofindnr==7))=[];
               			end

			case 8   % End List of Reactants 
				idx=mstrfind(rem,tofind(curnr).str);
				if(~isempty(idx))
					idx=idx(1);
					rem=rem(idx+tofind(curnr).pos:end);
					notfound=0;
					tofindnr=[9 11 13];
               			end

			case 9   % List of Products 
				idx=mstrfind(rem,tofind(curnr).str);
				if(~isempty(idx))
					idx=idx(1);
					rem=rem(idx+tofind(curnr).pos:end);
					notfound=0;
                    reactflag=1;
                    stoichcoeff=1;
					tofindnr=[5 10 13];
               	end
			
			case 10   % End List of Products 
				idx=mstrfind(rem,tofind(curnr).str);
				if(~isempty(idx))
					idx=idx(1);
					rem=rem(idx+tofind(curnr).pos:end);
					notfound=0;
					tofindnr=[11 13];
               	end

			case 11   % End of Reaction 
				idx=mstrfind(rem,tofind(curnr).str);
				if(~isempty(idx))
					idx=idx(1);
					rem=rem(idx+tofind(curnr).pos:end);
					notfound=0;
					tofindnr=[1 12 13];
               	end

			case 12   % End of ReactionList 
				idx=mstrfind(rem,tofind(curnr).str);
				if(~isempty(idx))
					idx=idx(1);
					rem=rem(idx+tofind(curnr).pos:end);
					notfound=0;
					ready=1;
               	end

			case 13   %  Annotation
				idx=mstrfind(rem,tofind(curnr).str);
				if(~isempty(idx))
					idx=idx(1);
					rem=rem(idx+tofind(curnr).pos:end);
					notfound=0;
					lasttofind=tofindnr;
					tofindnr=[14];
               	end

			case 14   %  End of Annotation
				idx=mstrfind(rem,tofind(curnr).str);
				if(~isempty(idx))
					idx=idx(1);
					rem=rem(idx+tofind(curnr).pos:end);
					notfound=0;
					lasttofind=tofindnr;
					tofindnr=lasttofind;
               	end

		end % switch
	end
	newread=notfound;
end

if(notfound)
	disp('Error in reading reactions.');
	if(reacuis>0)
		disp(['Last reaction id in procession: ',reactions(reacuis,:)]);
	else
		disp('First reaction not found');
	end
end


%%%%%%%%%%%%%5

fclose(lfi);


disp(['Found ',num2str(reacuis),' reactions']);
disp(' ');
disp('Reaction ID check ...');
	
i=1;
while(i<reacuis)
	idx=mfindstr_casesens(reactions(i+1:end,:),reactions(i,:));
	if(idx)
		lidx=length(idx);
            	disp(['Reaction id ',deblank(reactions(i,:)),' has been used for ',num2str(lidx+1),' reactions. ',num2str(lidx),' of these reactions will be deleted.']);
	    	reactions(i+idx,:)=[];
	    	CONSTRAINTS(i+idx,:)=[];
	    	reacuis=reacuis-lidx;
	end
	i=i+1;
end

disp('Reaction ID check done');
disp(' ');


%%%%%%% Metabolites with no net consumption

zw=find(~any(smat,2));
zwl=length(zw);
if(zwl)
	ans=questdlg(['There are ',num2str(zwl),' species which are never consumed or produced (probably because they are enzymes or inhibitors). For stoichiometric studies in CellNetAnalyzer these species will have no meaning. Deleting?'],'Deleting species with no net consumption','Yes','No','Yes');
	if(strcmp(ans,'Yes'))
		smat(zw,:)=[];
		anz_stoffe=anz_stoffe-zwl;
		for i=1:length(zw)
			disp(['Deleting: ',deblank(metabolites(zw(i),:))]);
		end
		disp(' ');
		metabolites(zw,:)=[];
		met_longname(zw,:)=[];
		extmet(zw)=[];
        end
end


%%%%%%%%%%%%%%%%%%%%% case-insensitive equivalent ids
for i=1:anz_stoffe-1
	idx=mfindstr(metabolites(i+1:end,:),metabolites(i,:));
	if(idx)
		lidx=length(idx);
            	disp(['Species id ',deblank(metabolites(i,:)),': there are ',num2str(lidx),' species ids which differ only in cases. Changing the ids as follows:']);
		for j=1:lidx
			zw=idx(j)+i;
			metn=deblank(metabolites(zw,:));
			metnnew=[metn,'_',num2str(j)];
			zw2=metabolites(zw+1:end,:);
			metabolites=char(metabolites(1:zw-1,:),metnnew);
			metabolites=char(metabolites,zw2);
			disp(['	',metn,' --> ',metnnew]);
		end
	end
end

for i=1:reacuis-1
	idx=mfindstr(reactions(i+1:end,:),reactions(i,:));
	if(idx)
		lidx=length(idx);
            	disp(['Reaction id ',deblank(reactions(i,:)),': there are ',num2str(lidx),' reaction ids which differ only in cases. Changing the ids as follows:']);
		for j=1:lidx
			zw=idx(j)+i;
			rn=deblank(reactions(zw,:));
			reacnew=[rn,'_',num2str(j)];
			zw2=reactions(zw+1:end,:);
			reactions=char(reactions(1:zw-1,:),reacnew);
			reactions=char(reactions,zw2);
			disp(['	',rn,' --> ',reacnew]);
		end
	end
end


%%%%%%%%% Transforming into CellNetAnalyzer format

cnap.reacID=reactions;
cnap.reacMin=CONSTRAINTS(:,3);
cnap.stoichMat=smat;
cnap.specID=metabolites;
cnap.specLongName=met_longname;
cnap.specExternal=extmet;
cnap.specInternal=find(extmet==0);

[cnap,errval]=CNAgenerateMFNetwork(cnap);


disp(' ');
disp('... Ready');
disp(' ');

function idx = mstrfind(str1,str2)

if(length(str1)>=length(str2))
       idx=findstr(str1,str2);
else
       idx = [];       
end
