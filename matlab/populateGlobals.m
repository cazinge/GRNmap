function populateGlobals(GRNstruct)

   global adjacency_mat alpha b degrate fix_b fix_P num_genes prorate ...
       production_function expression_timepoints is_forced strain_length ...
       log2FC
   
    adjacency_mat         = GRNstruct.GRNParams.adjacency_mat;
    alpha                 = GRNstruct.GRNParams.alpha;
    b                     = GRNstruct.GRNParams.b;
    degrate               = GRNstruct.degRates;
    expression_timepoints = GRNstruct.GRNParams.expression_timepoints;
    fix_b                 = GRNstruct.controlParams.fix_b;
    fix_P                 = GRNstruct.controlParams.fix_P;
    num_genes             = GRNstruct.GRNParams.num_genes;
    prorate               = GRNstruct.GRNParams.prorate;
    is_forced             = GRNstruct.GRNParams.is_forced;
    production_function   = GRNstruct.controlParams.production_function;
    strain_length         = length(GRNstruct.microData);
    log2FC                = GRNstruct.microData;
end