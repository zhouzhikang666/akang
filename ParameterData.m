classdef ParameterData < handle    
    properties    
%% 层推进参数         
        maxLayers       = 0;
        fullLayers      = 0;
        firstHeight     = 1e-3;
        growthRate      = 1.2;
        growthMethod    = 'geometric';
        multi_direction  = 1;
%%        
        boundaryFile
        boundaryGridTyp = 0;    %0-三角形网格，1-三角形/四边形混合网格
        useANN          = 1;   % 是否使用ANN生成网格
        mesh_type       = 2;   % 0-各向同性三角形，1-三角形网格合并成混合网格，2-直接生成三角形/四边形混合网格，3-直角三角形网格, 4-带层推进的各向异性混合网格      
        isPlotNew       = 1;   % 是否plot生成过程
        label_points    = 0;   % 是否在图中输出点的编号
        
        Sp_method       = 1;    %网格尺度控制方法：1-ANN，2-File, 3-源项，4-RBF，5-Octree     
        sampleType      = 3;    %ANN网格尺度控制： 1-nn只输入坐标，2-第二种输入，3-第三种输入输出方式，ANN尺度控制默认方式
        nn_mode_predict_tri = @net_naca0012_20201104;       %阵面推进三角形网格分类ANN
        nn_mode_predict_quad = @net_hybrid_20201130;        %阵面推进四边形网格分类ANN
        nn_step_size;
        nn_fun_alm;
        caseID;
    end
    
    methods
        function this = ParameterData(caseID, inputBoundary)
            this.caseID = caseID;
            switch caseID
                case 0
                    this.boundaryFile     = './input/quad_quad.cas';
                    this.Sp_method        = 1;
                    this.nn_step_size     = @nn_sizing_cylinder;
                    this.mesh_type        = 0;
                case 1   % case1 - cylinder
                     this.boundaryFile     = './input/inv_cylinder-20.cas';
%                    this.boundaryFile     = './input/tri.cas';
                    this.nn_step_size     = @nn_sizing_cylinder;            %网格尺度控制ANN,圆柱外形
                    this.Sp_method        = 1;
                    this.mesh_type        = 2;
                case 2  % case1 - naca0012
%                     this.boundaryFile     = './input/naca0012-tri-coarse.cas';
                    this.boundaryFile     = './input/naca0012-tri.cas';
                    this.nn_step_size     = @nn_sizing_naca1;                %网格尺度控制ANN,翼型外形
                    this.Sp_method        = 1;
                case 3
                    this.boundaryFile     = './input/anw.cas';
                    this.nn_step_size     = @nn_sizing_naca1;                %网格尺度控制ANN,翼型外形
                    this.Sp_method        = 5;
                case 4
                    this.boundaryFile     = './input/rae2822.cas';
%                     this.nn_step_size     = @nn_mesh_size_naca_3;                %网格尺度控制ANN,翼型外形
                    this.nn_step_size     = @nn_sizing_naca1;                      
                    this.Sp_method        = 5;
                case 5
                    this.boundaryFile     = './input/30p30n-small.cas';
%                     this.boundaryFile     = './input/30p30n-big.cas';
                    this.nn_step_size     = @nn_sizing_naca1;                %网格尺度控制ANN,翼型外形
                    this.Sp_method        = 1;
                case 6
                    this.boundaryFile     = './input/30p30n-fine.cas';
                    this.nn_step_size     = @nn_mesh_size_naca_3;                %网格尺度控制ANN,翼型外形
                    this.Sp_method        = 1;
                case 7
                    this.boundaryFile     = './input/inv_cylinder-50.cas';
                    this.nn_step_size     = @nn_mesh_size_cylinder_3;            %网格尺度控制ANN,圆柱外形
                    this.Sp_method        = 1;
                case 8
                    this.boundaryFile     = './input/naca0012-tri.cas';
                    this.nn_step_size     = @nn_mesh_size_naca_3;                %网格尺度控制ANN,翼型外形
                    this.Sp_method        = 1;
                case 9
                    this.boundaryFile     = './input/bump.cas';
                    this.Sp_method        = 2;                    
                case 11
                    this.boundaryFile    = './input/inv_cylinder-20.cas';
                    this.mesh_type       = 4;
                    this.maxLayers       = 10;
                    this.firstHeight     = 1e-1;
                    this.growthRate      = 1.2;
                    
%                     this.boundaryFile    = './input/inv_cylinder-50.cas';
%                     this.mesh_type       = 4;
%                     this.maxLayers       = 85;
%                     this.firstHeight     = 1e-4;
%                     this.growthRate      = 1.1;
                    this.growthMethod    = 'geometric';
                    this.multi_direction  = 1;
                    this.useANN           = 0;
                    this.Sp_method        = 5;
                    this.nn_step_size     = @nn_sizing_cylinder;
                    this.nn_fun_alm       = @nn_hybrid_0313_s1f3;
                case 12
                    this.boundaryFile     = './input/ALM/convex.cas';
%                     this.out_grid_file    = './out/convex-hybrid.vtk';
                    this.mesh_type       = 0;
                    this.maxLayers       = 20;
                    this.fullLayers      = 20;
                    this.firstHeight     = 0.01;
                    this.growthRate      = 1.2;
%                     this.maxLayers       = 85;
%                     this.fullLayers      = 85;
%                     this.firstHeight     = 0.0001;
%                     this.growthRate      = 1.1;
                    this.growthMethod    = 'geometric';
                    this.multi_direction  = 0;
                    
                    this.useANN           = 1;
                    this.Sp_method        = 1;
                    this.nn_step_size     = @nn_sizing_cylinder;
                    this.nn_fun_alm       = @nn_hybrid_0319_s1f3;
                 case 13
                    this.boundaryFile    = './input/ALM/concave.cas';
%                     this.out_grid_file   = './out/concave-hybrid.vtk';
                    this.mesh_type       = 4;
                    this.maxLayers       = 10;
                    this.firstHeight     = 0.1;
                    this.growthRate      = 1.2;
                    this.growthMethod    = 'geometric';
                    this.multi_direction  = 0; 
                    this.useANN           = 1;
                    this.Sp_method        = 5;
                    this.nn_fun_alm       = @nn_hybrid_0319_s1f3;                    
                case 14
                    this.boundaryFile    = './input/ALM/naca0012-tri.cas';
%                     this.out_grid_file   = './out/naca0012-hybrid.vtk';
                    this.mesh_type       = 4;
                    this.maxLayers       = 40;
                    this.fullLayers      = 20;
                    this.firstHeight     = 1e-4;
                    this.growthRate      = 1.2;
                    
%                     this.maxLayers       = 40;
%                     this.fullLayers      = 40;
%                     this.firstHeight     = 1e-5;
%                     this.growthRate      = 1.1;                    
%                     this.growthMethod    = 'geometric';
%                     this.multi_direction  = 0;
                    
                    this.useANN           = 1;
                    this.Sp_method        = 5;
                    this.nn_step_size     = @nn_sizing_naca1;
                    this.nn_fun_alm       = @nn_hybrid_0313_s1f2;                  
                case 15
                    this.boundaryFile    = './input/anw-hybrid-sample.cas';%anw-new.cas';
%                     this.out_grid_file   = './out/anw-hybrid.vtk';
                    this.mesh_type       = 4;
                    this.maxLayers       = 20;
                    this.fullLayers      = 20;
                    this.firstHeight     = 0.001;
                    this.growthRate      = 1.2;
%                     this.maxLayers       = 40;
%                     this.fullLayers      = 40;
%                     this.firstHeight     = 1e-4;
%                     this.growthRate      = 1.1;
                    this.growthMethod    = 'geometric';
                    this.multi_direction  = 0;
                    
                    this.useANN           = 0;
                    this.Sp_method        = 5;
                    this.nn_step_size     = @nn_sizing_naca1;                %网格尺度控制ANN,翼型外形                    
                case 16
                    this.boundaryFile    = './input/rae2822.cas';
                    this.mesh_type       = 4;
%                     this.maxLayers       = 20;
%                     this.fullLayers      = 20;
%                     this.firstHeight     = 0.0001;
%                     this.growthRate      = 1.2;
                    this.maxLayers       = 40;
                    this.fullLayers      = 40;
                    this.firstHeight     = 0.0001;
                    this.growthRate      = 1.1;
                    
                    this.growthMethod    = 'geometric';
                    this.multi_direction  = 0;
                    this.Sp_method        = 5;
                    this.nn_step_size     = @nn_sizing_naca1;                 
                case 17
                    this.boundaryFile    = './input/30p30n-small.cas';
%                     this.out_grid_file   = './out/30p30n-hybrid.vtk';
                    this.mesh_type       = 4;
%                     this.maxLayers       = 15;
%                     this.fullLayers      = 15;
%                     this.firstHeight     = 1e-4;
%                     this.growthRate      = 1.2;
                    this.maxLayers       = 30;
                    this.fullLayers      = 30;
                    this.firstHeight     = 1e-5;
                    this.growthRate      = 1.1;
                    this.growthMethod    = 'geometric';
                    this.multi_direction  = 0;
                    this.Sp_method        = 5;
                    this.nn_step_size     = @nn_sizing_naca1;                %网格尺度控制ANN,翼型外形                  
                case 18
                    this.boundaryFile    = './input/fifth.cas';
                    this.mesh_type       = 4;
                    this.maxLayers       = 35;
                    this.fullLayers      = 35;
                    this.firstHeight     = 1e-1;
                    this.growthRate      = 1.2;
                    this.growthMethod    = 'geometric';
                    this.multi_direction  = 0;
                    
                    this.useANN           = 1;
                    this.Sp_method        = 5;
                    this.nn_fun_alm       = @nn_hybrid_20240117;     
                case 19
                    this.boundaryFile    = './input/sixth.cas';
                    this.mesh_type       = 4;
                    this.maxLayers       = 30;
                    this.fullLayers      = 30;
                    this.firstHeight     = 1e-1;
                    this.growthRate      = 1.2;
                    this.growthMethod    = 'geometric';
                    this.multi_direction  = 0;
                    
                    this.useANN           = 1;
                    this.Sp_method        = 2;
%                     this.nn_fun_alm       = @nn_hybrid_0313_s1f32;
                    this.nn_fun_alm       = @nn_hybrid_20240117;                      
                case 20
                    this.boundaryFile    =  './SampleGen/NACA4digit_FOIL/data/NACA9410.cas';
                    this.boundaryGridTyp = 1;
                    
                    this.mesh_type       = 4;
                    this.maxLayers       = 30;
                    this.fullLayers      = 30;
                    this.firstHeight     = 1e-5;
                    this.growthRate      = 1.2;
%                     this.maxLayers       = 60;
%                     this.fullLayers      = 60;
%                     this.firstHeight     = 1e-5;
%                     this.growthRate      = 1.1;
                    this.growthMethod    = 'geometric';
                    this.multi_direction  = 0;
                    
                    this.useANN           = 0;
                    this.Sp_method        = 5;
                    this.nn_fun_alm       = @nn_hybrid_20240117;
                    this.nn_step_size     = @nn_sizing_naca1;
                otherwise
                    this.boundaryFile     = inputBoundary;
                    this.nn_step_size     = @nn_mesh_size_naca_3;
            end
        end
    end
end
