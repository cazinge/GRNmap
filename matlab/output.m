function GRNstruct = output(GRNstruct)

global adjacency_mat alpha b degrate fix_b is_forced log2FC num_genes num_times no_inputs prorate Sigmoid Strain time wts

if GRNstruct.controlParams.makeGraphs
    GRNstruct = graphs(GRNstruct);
end

fileName   = GRNstruct.fileName;
directory  = GRNstruct.directory; 
positions  = GRNstruct.GRNParams.positions;
num_edges  = GRNstruct.GRNParams.num_edges;
num_forced = GRNstruct.GRNParams.num_forced;
simtime    = GRNstruct.controlParams.simtime;
initial_guesses = GRNstruct.locals.initial_guesses;
estimated_guesses = GRNstruct.locals.estimated_guesses;

[~,~,ext] = fileparts(GRNstruct.inputFile);
output_file = [directory fileName '_output' ext];
output_mat  = [directory fileName '_output.mat'];
copyfile(GRNstruct.inputFile, output_file);

for qq = 1:length(Strain)
    
    for ik = 1:num_genes+1
        
        outputnet{1,ik}   = GRNstruct.labels.TX2{1,ik};
        outputnet{ik,1}   = GRNstruct.labels.TX2{1,ik};
        outputcells{ik,1} = GRNstruct.labels.TX0{ik,1};
        outputcells{ik,2} = GRNstruct.labels.TX0{ik,2};
        outputdata{ik,1}  = GRNstruct.labels.TX0{ik,1};
        outputdata{ik,2}  = GRNstruct.labels.TX0{ik,2};
        outputdeg{ik,1}   = GRNstruct.labels.TX0{ik,1};
        outputdeg{ik,2}   = GRNstruct.labels.TX0{ik,2};
        outputpro{ik,1}   = GRNstruct.labels.TX0{ik,1};
        outputpro{ik,2}   = GRNstruct.labels.TX0{ik,2};
        
        if ik>=2
            for jj = 2:length(simtime)+1
                outputcells{ik,jj+1} = log2FC(qq).model(ik-1,jj-1);
            end
            for jj = 2:num_times+1
                outputdata{ik,jj+1} = log2FC(qq).data(ik,jj-1);
            end
            for jj = 2:num_genes+1
                outputnet{jj,ik} = adjacency_mat(jj-1,ik-1);
            end
            outputpro{ik,3} = prorate(ik-1);
            outputdeg{ik,3} = degrate(ik-1);
        else
            outputdeg{ik,3} = GRNstruct.labels.TX0{ik,3};
            outputpro{ik,3} = 'prorate';
            
            for jj = 2:length(simtime)+1
                outputcells{ik,jj+1} = simtime(jj-1);
            end
            for jj = 2:num_times+1
                outputdata{ik,jj+1} = time(jj-1);
                outputtimes{1,jj}   = time(jj-1);
            end
        end
    end
    
    GRNstruct.GRNOutput.d = log2FC(qq).data(2:end,:);
    xlswrite(output_file,outputcells,[Strain{qq} '_log2_optimized_expression']);
end
    
if GRNstruct.controlParams.fix_P
    xlswrite(output_file,outputpro,'out_production_rates');
end

xlswrite(output_file,outputtimes,'out_measurement_times');
xlswrite(output_file,outputnet,'out_network');

for ii = 1:num_edges
    outputnet{positions(ii,1)+1,positions(ii,2)+1} = initial_guesses(ii);
end

xlswrite(output_file,outputnet,'out_network_weights');

if Sigmoid
    outputpro{1,3} = 'b';
    if fix_b == 0
        for ii = 1:num_forced
            outputpro{is_forced(ii)+1,3} = estimated_guesses(ii+num_edges);
        end
        for ii = 1:length(no_inputs)
            outputpro{no_inputs(ii)+1,3} = 0;
        end
    else
        for ii = 1:num_forced
            outputpro{is_forced(ii)+1,3} = b(ii);
        end
        for ii = 1:length(no_inputs)
            outputpro{no_inputs(ii)+1,3} = 0;
        end
        xlswrite(output_file,outputpro,'out_network_b');
    end
end

for ii = 1:num_edges
    outputnet{positions(ii,1)+1,positions(ii,2)+1} = estimated_guesses(ii);
end

xlswrite(output_file,outputnet,'out_network_optimized_weights');


GRNstruct.GRNOutput.name          = GRNstruct.inputFile;
GRNstruct.GRNOutput.prorate       = prorate;
GRNstruct.GRNOutput.degrate       = degrate;
GRNstruct.GRNOutput.wts           = wts;
GRNstruct.GRNOutput.b             = b;
GRNstruct.GRNOutput.adjacency_mat = adjacency_mat;
GRNstruct.GRNOutput.active        = GRNstruct.GRNParams.active;
GRNstruct.GRNOutput.tspan         = time;
GRNstruct.GRNOutput.alpha         = alpha;

my_string = ['save(''' output_mat ''')'];
eval(my_string);