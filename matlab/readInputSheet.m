function GRNstruct = readInputSheet( GRNstruct )

global adjacency_mat alpha b degrate fix_b fix_P is_forced log2FC num_genes num_times prorate Sigmoid Strain wtmat time

alpha = 0;
% If we do multiple runs in a row the Strain variable should be cleared
% before each run.
Strain = [];

input_file = GRNstruct.inputFile;

[parms0,parmnames0] = xlsread(input_file,'optimization_parameters');
[numRows,numCols] = size(parmnames0);

% This part of the code reads the optimization parameter sheet and creates
% variables for the parameters.

for currentRow = 2:numRows
    % Gives us the indexes of the numerical values in the row.
    indexVec = find(isnan(parms0(currentRow-1,:))==0);
    
    % If the parameter in the sheet has numerical values in its row,
    % create a row vector with that paramter's name and whose values are
    % the numerical entries in that row
    if ~isempty(indexVec)
        eval([parmnames0{currentRow,1} '= [' num2str(parms0(currentRow-1,indexVec)) '];']);
 
    % If the parameter in the sheet has strings in its row, we create a
    % cell array with that parameter's name and whose values are the
    % strings in that row.
    else
        currentCol = 2;
        % If we are at the end of the row or if there is no string at the
        % current column, we're done. Otherwise, add string to cell array.
        while currentCol <= numCols
           parmstr = parmnames0{currentRow,currentCol};
           if isempty(parmstr)
               break
           end
           eval([parmnames0{currentRow,1} '{currentCol - 1}= parmstr;']);
           currentCol = currentCol + 1; 
        end
    end
end



% This reads the microarray data for each strain.
for index = 1:length(Strain)
    currentStrain = Strain{index};
    [GRNstruct.microData(index).data,GRNstruct.labels.TX1] = xlsread(input_file,currentStrain);
    GRNstruct.microData(index).Strain = currentStrain;
    log2FC(index).data = GRNstruct.microData(index).data;
end

% Populate the structure
[GRNstruct.degRates,GRNstruct.labels.TX0]                = xlsread(input_file,'degradation_rates');
[GRNstruct.GRNParams.wtmat,GRNstruct.labels.TX2]         = xlsread(input_file,'network_weights');
[GRNstruct.GRNParams.adjacency_mat,GRNstruct.labels.TX3] = xlsread(input_file,'network');
[GRNstruct.GRNParams.prorate,GRNstruct.labels.TX5]       = xlsread(input_file,'production_rates');

GRNstruct.GRNParams.num_edges        = sum(GRNstruct.GRNParams.adjacency_mat(:));
GRNstruct.GRNParams.num_genes        = size(GRNstruct.GRNParams.adjacency_mat,2);
GRNstruct.GRNParams.active           = 1:GRNstruct.GRNParams.num_genes;
GRNstruct.GRNParams.alpha            = alpha;
GRNstruct.GRNParams.time             = time;
GRNstruct.GRNParams.num_times        = length(time);

% This sets the control paramenters
GRNstruct.controlParams.simtime        = simtime;
GRNstruct.controlParams.kk_max         = kk_max;
GRNstruct.controlParams.MaxIter        = MaxIter;
GRNstruct.controlParams.MaxFunEval     = MaxFunEval;
GRNstruct.controlParams.TolFun         = TolFun;
GRNstruct.controlParams.TolX           = TolX;
GRNstruct.controlParams.estimateParams = estimateParams;
GRNstruct.controlParams.makeGraphs     = makeGraphs;
GRNstruct.controlParams.Sigmoid        = Sigmoid;
GRNstruct.controlParams.fix_b          = fix_b;
GRNstruct.controlParams.fix_P          = fix_P;


% Populate the global variables

if GRNstruct.controlParams.Sigmoid
    [GRNstruct.GRNParams.b,GRNstruct.labels.TX6] = xlsread(input_file,'threshold_b');
    b = GRNstruct.GRNParams.b;
else
    GRNstruct.controlParams.fix_b = 1;
    fix_b = 1;
    GRNstruct.GRNParams.b = zeros(length(degrate),1);
    b = GRNstruct.GRNParams.b;
end

%TX1 contains both the systemic and standard names
%TX11 is the list of standard (common) names
%%Revision to old way of computing TX11
for ii = 1:length(GRNstruct.microData(1).data(:,1));
    GRNstruct.labels.TX11{ii,1} = GRNstruct.labels.TX1{ii,2};
end

% To be read by the program correctly, prorate and degrate need to be row
% vectors instead of column vectors, so we use the transpose of the array
% obtained from the datafile
% prorate         = prorate';
GRNstruct.degRates = GRNstruct.degRates';

% We use variables wherever we would need numbers that might change if we
% are using a different network.

for i = 1:length(Strain)
    % The first row of the GRNstruct.microData data indicating all of the replicate timepoints
    reps = (GRNstruct.microData(i).data(1,:));
    % Finds the indices in reps that correspond to each timepoint in tspan.
    for jj = 1:length(time)
        log2FC(i).t(jj).indx = find(reps == time(jj));
        log2FC(i).t(jj).t    = time(jj); 
        GRNstruct.microData(i).t(jj).indx = log2FC(i).t(jj).indx;
        GRNstruct.microData(i).t(jj).t    =  time(jj);
    end
    % GRNstruct.microData data for all strains
    % GRNstruct.microData(i).data  = (GRNstruct.microData(i).d(2:end,:));

    % The average GRNstruct.microData for each timepoint for each gene.
    for iT = 1:GRNstruct.GRNParams.num_times
        data = GRNstruct.microData(i).data(2:end,GRNstruct.microData(i).t(iT).indx);
        % Preallocate these arrays. Should probably be done somewhere else
        GRNstruct.microData(i).avg = zeros(size(data,1),1);
        GRNstruct.microData(i).stdev = zeros(size(data,1),1);
        log2FC(i).avg = zeros(size(data,1),1);
        log2FC(i).stdev = zeros(size(data,1),1);
        
        GRNstruct.microData(i).avg(:,iT) = mean(data,2);
        GRNstruct.microData(i).stdev(:,iT) =  std(data,0,2);
        log2FC(i).avg(:,iT) = mean(data,2);
        log2FC(i).stdev(:,iT) = std(data,0,2);
    end

    log2FC(i).deletion  = Deletion(i);
    log2FC(i).strain    = Strain(i);
    GRNstruct.microData(i).deletion = Deletion(i);
end

% # of interactions between controlling and affected TF's
% sum each row of matrix adjacency_mat (network)
num_controlling_genes = sum(GRNstruct.GRNParams.adjacency_mat,2);

% Whether or not genes are affected T(1)/F(0)
is_controlled = num_controlling_genes > 0;
GRNstruct.GRNParams.no_inputs  = find(is_controlled == 0);
GRNstruct.GRNParams.is_forced  = find(is_controlled == 1);
GRNstruct.GRNParams.num_forced = sum(is_controlled);

% Where the edges are in the network
% rows corresponds to row (genes affected)
% columns correspond to column (genes controlling)
% Positions gives us ordered pair of genes in the form of
% (aff_gene, contr_gene), where the first gene is controlled
% by the second gene.
[rows,columns] = find(GRNstruct.GRNParams.adjacency_mat == 1);
GRNstruct.GRNParams.positions = sortrows([rows,columns],1);


GRNstruct.GRNParams.x0 = ones(GRNstruct.GRNParams.num_genes,1);

% Populating the globals
is_forced     = GRNstruct.GRNParams.is_forced;
num_genes     = GRNstruct.GRNParams.num_genes;
num_times     = GRNstruct.GRNParams.num_times;
degrate       = GRNstruct.degRates;
adjacency_mat = GRNstruct.GRNParams.adjacency_mat;
prorate       = GRNstruct.GRNParams.prorate;
wtmat         = GRNstruct.GRNParams.wtmat;

end