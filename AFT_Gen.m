clear;clc;close all;
addpath('AdFront');
addpath('AdLayers');
addpath('DataStructure');
addpath('HybridGrid');
addpath(genpath('MeshSize'));
addpath('Optimize');
addpath('PostProcess');
addpath('Utilities');
addpath(genpath('NNs'));
addpath('Timer');
global crossCount;
crossCount = 0;
%%
predefinedCaseID = 2;   %预置的一些算例
inputBoundary = '';     %如果不使用预置算例，则要指定边界网格文件

%% 建立参数对象
disp('ANN-AFT开始生成网格!')
paraObj = ParameterData(predefinedCaseID, inputBoundary);

%% 建立计时器管理对象
timeManagerObj = TimerManager();
timeManagerObj.totalTimer.ReStart();

%% 建立作图管理对象
plotObj = PlotClass(paraObj.label_points);

%% 建立边界线网格对象
boundaryDataObj = BoundaryDataClass(paraObj.boundaryFile, paraObj.boundaryGridTyp);
plotObj.PlotBoundary(paraObj, boundaryDataObj);

%% 将边界阵面往外推进
timeManagerObj.adlayerTimer.ReStart();
adlayersObj = AdLayers2(boundaryDataObj, paraObj);
adlayersObj.AdvancingLayers();
timeManagerObj.adlayerTimer.Span(0);
timeManagerObj.adlayerTimer.AccumulateTime();

%% 建立网格尺度控制对象
timeManagerObj.spTimer.ReStart();
meshSizeObj = MESHSIZE(paraObj, boundaryDataObj);
timeManagerObj.spTimer.Span(0);
timeManagerObj.spTimer.AccumulateTime();

%% 建立阵面推进对象，推进生成网格
% adfrontObj = AdFront2(paraObj, boundaryDataObj, meshSizeObj, timeManagerObj, plotObj);
adfrontObj = AdFront2Hybrid(paraObj, boundaryDataObj, adlayersObj, meshSizeObj, timeManagerObj, plotObj);
adfrontObj.InitParameters(paraObj);
switch paraObj.mesh_type
    case {0, 1, 3, 4}
        adfrontObj.AdvancingFront();
    case 2
        adfrontObj.AdvancingFront_Hybrid();
    otherwise
end

%% 将阵面推进和层推进生成的网格组装成混合网格
hybridGridObj = HybridGridClass(adlayersObj, adfrontObj);

%% 进行对角线交换和弹簧优化
switch paraObj.mesh_type
    case 0
        %% 纯三角形网格，对角线交换、光滑，然后输出
        hybridGridObj.WriteHybridGridVTK('./out/mesh_tri.vtk');
        hybridGridObj.EdgeSwap();
        hybridGridObj.LaplacianSmoothing(3);
        hybridGridObj.ReportQuality();
        hybridGridObj.WriteHybridGridVTK('./out/mesh_tri_smoothed.vtk');      
    case {1, 2}
        %% 通过合并法生成各向同性三角形/四边形混合网格，先对角线交换，光滑、然后合并、再调用mesquite优化混合网格
        hybridGridObj.WriteHybridGridVTK('./out/mesh_tri.vtk');
        hybridGridObj.EdgeSwap(); 
        hybridGridObj.LaplacianSmoothing(3);
        hybridGridObj.CombineTriangles();
        hybridGridObj.WriteHybridGridVTK('./out/mesh_hybrid_merged.vtk');
        %hybridGridObj.OptizimeIsoHybridGridByMesquite('./out/mesh_hybrid_merged.vtk');
        hybridGridObj.ReportQuality();
        hybridGridObj.WriteHybridGridVTK('./out/mesh_hybrid_merged_opt.vtk'); 
    case 3
        %% 生成直角三角形网格，只进行对角线交换，然后输出文件
        hybridGridObj.WriteHybridGridVTK('./out/mesh_tri.vtk');
        hybridGridObj.EdgeSwap();
        hybridGridObj.LaplacianSmoothing(0);
        hybridGridObj.ReportQuality();
        hybridGridObj.WriteHybridGridVTK('./out/mesh_tri_smoothed.vtk');            
    case 4
        %% 各向异性混合网格
        hybridGridObj.WriteHybridGridVTK('./out/mesh_aniso_hybrid.vtk');
        hybridGridObj.SplitQuad();
        hybridGridObj.EdgeSwap();
        hybridGridObj.LaplacianSmoothing(3);
        hybridGridObj.ReportQuality();
        hybridGridObj.WriteHybridGridVTK('./out/mesh_aniso_hybrid_opt.vtk');
    otherwise
end
%% 建立后处理对象，输出最终结果
posprocessObj = PostProcessClass(paraObj, hybridGridObj, timeManagerObj);
posprocessObj.DisplayFinalResults();
posprocessObj.DisplayHybridGridInfo();
%%
disp('ANN-AFT生成网格结束!')