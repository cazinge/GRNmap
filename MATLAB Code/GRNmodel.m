% Allows user to choose an .xls or .xlsx file. If unsupported file is chosen
% the program is aborted.
GRNstruct.inputFile = uigetfile({'*.xls';'*.xlsx'},'Select Input Worksheet for Simulation.');
if GRNstruct.inputFile == 0
    msgbox('Select An .xls or .xlsx File To Run Simulation.','Empty Input Error');
    return
end
[p,n,ext] = fileparts( GRNstruct.inputFile );
if ~strcmp(ext,'.xls') && ~strcmp(ext,'.xlsx')
    msgbox('Select An .xls or .xlsx File To Run Simulation.','Invalid Input Error');
    return
end

figHandles  = findobj('Type','figure');
nfig        = max(figHandles);

% Back Simulation
tic
% Populates the structur as well as the global variables
GRNstruct = readInputSheet(GRNstruct); % We've called Parameters
GRNstruct = lse(GRNstruct);
GRNstruct = output(GRNstruct);

% LSE
% toc
% Graphs;
% Output;
