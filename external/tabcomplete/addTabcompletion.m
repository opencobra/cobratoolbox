function addTabcompletion()
try
    [~,success] = tabcomplete(1,'readSBML','FILE');
    if success
        tabcomplete(0,'readCbModel','FILE');
        tabcomplete(0,'readBooleanRegModel','VAR','FILE');
        tabcomplete(0,'xls2model','FILE');
        tabcomplete(0,'readAtomMappingFromRxnFile','FILE');
    end
    
catch ME
    disp('A Problem occured while trying to add tabcompletion properties for the Toolbox');
    warning(ME)
end