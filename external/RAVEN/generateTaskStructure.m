function taskStruct = generateTaskStructure(inputFile)
% Generates a task structure from a Excell sheet containing a list of tasks
%
% USAGE:
%
%    taskStruct = generateTaskStructure(inputFile)
%
% INPUT:
%    inputFile:     a task list in Excel format. The file must contain a sheet
%                   named TASKS, which in turn may contain the
%                   following column headers (note, all rows starting with
%                   a non-empty cell are removed. The first row after that
%                   is considered the headers):
%
%                     * ID - the only required header. Each task must have a
%                       unique id (string or numeric). Tasks can span multiple
%                       rows, only the first row in each task should have
%                       an id
%                     * SYSTEM - definition of the system associated to the task
%                     * SUBSYSTEM - definition of the subsystem associated to the task
%                     * DESCRIPTION - description of the task
%                     * IN - allowed input(s) for the task. Metabolite names
%                       should be on the form
%                       "model.metName[model.comps]". Several inputs
%                       can be delimited by ";". If so, then the same
%                       bounds are used for all inputs. If that is not
%                       wanted, then use several rows for the task
%                     * IN LB - lower bound for the uptake of the metabolites in
%                       the row (opt, (opt, default 1e-04 which force the directionality
%                       of the fluxes associated to the inputs)
%                     * IN UB - upper bound for the uptake of the metabolites in
%                       the row (opt, default 1000 which corresponds to a
%                       maximal uptake of 1000 units)
%                     * OUT - allowed output(s) for the task (see IN)
%                     * OUT LB - lower bound for the production of the metabolites in
%                       the row (opt, default 1e-04 which force the directionality
%                       of the fluxes associated to the outputs)
%                     * OUT UB - upper bound for the production of the metabolites in
%                       the row (opt, default 1000 which corresponds to a
%                       maximal production of 1000 units)
%                     * SHOULD FAIL - 1 if the correct behavior of the model is to
%                       not have a feasible solution given the constraints
%                       (opt, default 0)
%                     * COMP - specify the compartment where occurs the task
%                       (defaut [c], cytosol)
%
% OUTPUT:
%    taskStruct:    array of structures with the following fields:
%
%                     * .id - the id of the task
%                     * .description - the description of the task
%                     * .system - definition of the system associated to the task
%                     * .subsystem - definition of the subsystem associated to the task
%                     * .shouldFail - true if the task should fail
%                     * .inputs - cell array with input metabolites (in the form metName[comps])
%                     * .LBin - array with lower bounds on inputs (default, 1e-04)
%                     * .UBin - array with upper bounds on inputs (default, 1000)
%                     * .outputs - cell array with output metabolites (in the form metName[comps])
%                     * .LBout - array with lower bounds on outputs (default, 1e-04)
%                     * .UBout - array with upper bounds on outputs (default, 1000)
%                     * .COMP - compartment where occurs the task (default [c], cytosol)
%
% NOTE:
%
%    This function is used for defining a set of tasks for a model to
%    perform. The tasks are defined by defining constraints on the exchange
%    and transport reaction fluxes associated with the inputs and the outputs,
%    and if the problem is feasible, then the task is considered successful.
%    In general, each row can contain one constraint on uptakes, one
%    constraint on outputs.
%
% .. Authors:
%    - Originally written for RAVEN toolbox by Rasmus Agren, 2013-08-01
%    - Adapted for cobratoolbox and modified to rely only on flux constraints by Richelle Anne, 2017-04-18

[crap,crap,raw]=xlsread(inputFile,'TASKS'); %Load the tasks file

%Captions of the column in the excell file
columns={'ID';'DESCRIPTION';'IN';'IN LB';'IN UB';'OUT';'OUT LB';'OUT UB';'SHOULD FAIL';'COMP';'SYSTEM';'SUBSYSTEM'};

[I colI]=ismember(columns,raw(1,1:end));
colI=colI;

%Check that the ID field is present
if I(1)==0
    dispEM('The TASKS sheet must have a column named ID');
end

%Prepare the input file a little. Put NaN for missing strings and default
%bounds where needed
for i=1:numel(colI)
    I=cellfun(@isBad,raw(:,colI(i)));
    if ~ismember(i,[4 5 7 8])
        raw(I,colI(i))={NaN};
    else
        if i==5 || i==8
            raw(I,colI(i))={1000};
        else
             raw(I,colI(i))={1e-04};
        end
    end
end

%Create an empty task structure
eTask.id='';
eTask.description='';
eTask.system='';
eTask.subsystem='';

%eTask.shouldFail=false;
eTask.shouldFail=[];
eTask.inputs={};
eTask.LBin=[];
eTask.UBin=[];
eTask.outputs={};
eTask.LBout=[];
eTask.UBout=[];
eTask.COMP='';

%Main loop
taskStruct=[];
task=eTask;
if isnumeric(raw{2,colI(1)})
    task.id=num2str(raw{2,colI(1)});
else
    task.id=raw{2,colI(1)};
end
task.description=raw{2,colI(2)};
task.shouldFail=raw{2,colI(9)};
task.COMP=raw{2,colI(10)};
task.system=raw{2,colI(11)};
task.subsystem=raw{2,colI(12)};

for i=2:size(raw,1)
    %Set the inputs
    if ischar(raw{i,colI(3)})
        inputs=regexp(raw{i,colI(3)},';','split');
        task.inputs=[task.inputs;inputs(:)];
        task.LBin=[task.LBin;ones(numel(inputs),1)*raw{i,colI(4)}];
        task.UBin=[task.UBin;ones(numel(inputs),1)*raw{i,colI(5)}];
    end
    %Set the outputs
    if ischar(raw{i,colI(6)})
        outputs=regexp(raw{i,colI(6)},';','split');
        task.outputs=[task.outputs;outputs(:)];
        task.LBout=[task.LBout;ones(numel(outputs),1)*raw{i,colI(7)}];
        task.UBout=[task.UBout;ones(numel(outputs),1)*raw{i,colI(8)}];
    end

    %Check if it should add more constraints
    if i<size(raw,1)
        if isnan(raw{i+1,colI(1)})
            continue;
        end
    end

    taskStruct=[taskStruct;task];
    task=eTask;
    if i<size(raw,1)
        if isnumeric(raw{i+1,colI(1)})
            task.id=num2str(raw{i+1,colI(1)});
        else
            task.id=raw{i+1,colI(1)};
        end
        task.description=raw{i+1,colI(2)};
        task.shouldFail=raw{i+1,colI(9)};
        task.COMP=raw{i+1,colI(10)};
        task.system=raw{i+1,colI(11)};
        task.subsystem=raw{i+1,colI(12)};

    end
end

end
function I=isBad(x)
    I=false;
    if ischar(x)
        if numel(x)==0 || all(isstrprop(x, 'wspace'))
           I=true;
        end
    else
       if isnan(x)
          I=true;
       end
    end
    if isempty(x)
        I=true;
    end
end