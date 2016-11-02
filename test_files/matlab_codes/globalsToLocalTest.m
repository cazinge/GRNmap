classdef globalsToLocalTest < matlab.unittest.TestCase
    
    properties
        constants_dir = '\..\tests\'
        constantStruct
        GRNstruct
    end
    
    properties (ClassSetupParameter)
        test_files = {
                      struct('GRNstruct','MM_estimation_fixP0_graph','file','4-genes_6-edges_artificial-data_MM_estimation_fixP-0_graph');...
%                       struct('GRNstruct','MM_estimation_fixP0_nograph','file','4-genes_6-edges_artificial-data_MM_estimation_fixP-0_no-graph');...
%                       struct('GRNstruct','MM_forward_graph','file','4-genes_6-edges_artificial-data_MM_forward_graph');...
%                       struct('GRNstruct','MM_forward_nograph','file','4-genes_6-edges_artificial-data_MM_forward_no-graph');...
%                       struct('GRNstruct','MM_estimation_fixP1_graph','file','4-genes_6-edges_artificial-data_MM_estimation_fixP-1_graph');...
%                       struct('GRNstruct','MM_estimation_fixP1_nograph','file','4-genes_6-edges_artificial-data_MM_estimation_fixP-1_no-graph');...
%                       struct('GRNstruct','Sigmoidal_estimation_fixb0_fixP0_graph','file','4-genes_6-edges_artificial-data_Sigmoidal_estimation_fixb-0_fixP-0_graph');...
%                       struct('GRNstruct','Sigmoidal_estimation_fixb0_fixP0_nograph','file','4-genes_6-edges_artificial-data_Sigmoidal_estimation_fixb-0_fixP-0_no-graph');...                      
%                       struct('GRNstruct','Sigmoidal_estimation_fixb0_fixP1_graph','file','4-genes_6-edges_artificial-data_Sigmoidal_estimation_fixb-0_fixP-1_graph');...
%                       struct('GRNstruct','Sigmoidal_estimation_fixb0_fixP1_nograph','file','4-genes_6-edges_artificial-data_Sigmoidal_estimation_fixb-0_fixP-1_no-graph');...
%                       struct('GRNstruct','Sigmoidal_estimation_fixb1_fixP0_graph','file','4-genes_6-edges_artificial-data_Sigmoidal_estimation_fixb-1_fixP-0_graph');...
%                       struct('GRNstruct','Sigmoidal_estimation_fixb1_fixP0_nograph','file','4-genes_6-edges_artificial-data_Sigmoidal_estimation_fixb-1_fixP-0_no-graph');...
%                       struct('GRNstruct','Sigmoidal_estimation_fixb1_fixP1_graph','file','4-genes_6-edges_artificial-data_Sigmoidal_estimation_fixb-1_fixP-1_graph');...
%                       struct('GRNstruct','Sigmoidal_estimation_fixb1_fixP1_nograph','file','4-genes_6-edges_artificial-data_Sigmoidal_estimation_fixb-1_fixP-1_no-graph');...
%                       struct('GRNstruct','Sigmoidal_forward_graph','file','4-genes_6-edges_artificial-data_Sigmoidal_forward_graph');...
%                       struct('GRNstruct','Sigmoidal_forward_nograph','file','4-genes_6-edges_artificial-data_Sigmoidal_forward_no-graph');...
                     };...
    end
    
    methods(TestClassSetup)
        function makeGlobals(testCase, test_files)
            addpath([pwd '/../../matlab']);
            addpath(testCase.constants_dir)
            testCase.constantStruct = getfield(ConstantGRNstructs, test_files.GRNstruct);
            testCase.GRNstruct = globalToStruct(testCase.constantStruct);
         end
    end
    
    methods(Test)
        function testAdjacencyMatAssignedCorrectly(testCase)
            testCase.verifyEqual(testCase.GRNstruct.GRNOutput.adjacency_mat, [1 0 0 0; 0 1 0 0; 0 0 1 1; 0 0 1 1]);
        end
        
        function testAlphaAssignedCorrectly(testCase)
            testCase.verifyEqual(testCase.GRNstruct.GRNOutput.alpha, 0.001);
        end
        
        function testBAssignedCorrectly(testCase)
            testCase.verifyEqual(testCase.GRNstruct.GRNOutput.b, [0;0;0;0]);
        end
        
        function testCounterAssignedCorrectly(testCase)
            testCase.verifyEqual(testCase.GRNstruct.GRNOutput.counter, 1012);
        end
        
%         function testDeletionAssignedCorrectly(testCase)
%             testCase.verifyEqual(testCase.GRNstruct.microData(1).deletion, 'wt');
%             testCase.verifyEqual(testCase.GRNstruct.microData(2).deletion, 'dcin5');
%         end
        
        function testExpressionTimepointsAssignedCorrectly(testCase)
            testCase.verifyEqual(testCase.GRNstruct.GRNOutput.tspan, [0.4 0.8 1.2 1.6]);
        end
        
        function testProrateAssignedCorrectly(testCase)
            testCase.verifyEqual(testCase.GRNstruct.GRNOutput.prorate, [0.4 0.8 1.2 1.6]);
        end
        
%         function testDegrateAssignedCorrectly(testCase)
%            testCase.verifyEqual(testCase. 
%         end
    end
end
