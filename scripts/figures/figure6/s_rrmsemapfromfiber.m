function s_rrmsemapfromfiber(feFileToLoad, fgFile, dwiFile)

% This scripts computes the median of Rrmse on voxels along particular pathway of interest.
% 
% This script will reproduce the results on Figure 6 in
% Takemura, H., Caiafa, C., Wandell, B.A. & Pestilli, F. (in revision) Esnemble Tractography.
% 
% INPUT;
% feFileToLoad: A full path to .mat file including fe structure
% fgFile: The file storing pathway (.pdb or .mat) to test
% dwiFile: The nifti file stroing raw DWI data
%
% EXAMPLE:
% feFileToLoad = {'S1_SPC_curv0p25_fe.mat', 'S1_SPC_curv0p5_fe.mat', 'S1_SPC_curv1_fe.mat', 'S1_SPC_curv2_fe.mat', 'S1_ETC_fe.mat');
% fgFile = 'S1_LH_Ufiber_ETC.pdb';
% dwiFile = 'S1_dwi_raw_trilin.nii.gz';
% s_rrmsemapfromfiber(feFileToLoad, fgFile, dwiFile)
% 
% (C) Hiromasa Takemura, CiNet HHS/Stanford VISTA Lab

fg = fgRead(fgFile);

for i = 1:length(feFileToLoad)

% Create fe structure
fetest = feCreate;

% Get xform from raw DWI file
tempNi = niftiRead(dwiFile);
fetest = feSet(fetest, 'img2acpc xform', tempNi.qto_xyz);
fetest = feSet(fetest, 'acpc2img xform', inv(tempNi.qto_xyz));

% Covert fg into img space (LiFE coordinate is in img space)
fetest = feSet(fetest,'fg from acpc',fg);
fetest = feSet(fetest,'roi fg',[]);

% Load fe structure of connectome model
load(feFileToLoad{i}));

% Get Rrmse
rmseR{i}   = feGetRep(fe, 'vox rmse ratio',fetest.roi.coords);
rmseRsize(i) = length(rmseR{i});
end

% Compute the white matter voxel number in connectome model with highest white matter coverage
rmsemax = max(rmseRsize);
missingvoxel = rmsemax - rmseRsize;
rmseR_forstd = rmseR;

for j = 1:length(feFileToLoad)
    % Assing Inf to missing voxel   
   if missingvoxel(j) > 0
      rmseR{j}((rmseRsize(j)+1):rmsemax) = Inf;
      rmseR_forstd{j}((rmseRsize(j)+1):rmsemax) = NaN;
     else
   end

   % compute median, stanfard deviation, standard error
   rmseR_median(j) = median(rmseR{j});
   rmseR_std(j) = nanstd(rmseR_forstd{j});
    rmseR_ser(j) = rmseR_std(j)/sqrt(rmseRsize(j));
end

%% Make plots
% Set font size, y axix limits, ticks
fontSiz = 16;
h1.ylim(1) = 0.707;
h1.ylim(2) = 1;

ytick = [0.75 0.8 0.85 0.9 0.95 1];

% Plot it
bar(rmseR_median);

hold on
set(gca,'XTickLabel',{'0.25','0.5','1','2','4','ETC'},'fontsize',fontSiz');

    set(gca,'tickdir','out', ...
        'box','off', ...
        'ylim',h1.ylim)

% Plot error bar
errorbar(rmseR_median, rmseR_ser, 'r', 'linestyle','none','LineWidth',2);    
ylabel('Median RRMSE','fontsize',16);
xlabel('Connectome Models','fontsize',16');  

