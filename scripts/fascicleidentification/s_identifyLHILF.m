function s_identifyLHILF(feFileToLoad, fname, roiDir, roiNames, roiOperations)

% This script identify the left ILF (Inferior Longitudinal Fasciculus) from fe structure using waypoint ROIs.
% In most cases, waypoint ROI can be defined using AFQ toolbox (See http://white.stanford.edu/newlm/index.php/AFQ), but for some dataset manual % % modification is necessary to get proper results (e.g. the brain which has largely different size and organization from MNI template)
%
% INPUT:
% feFileToLoad: a string of full path to .mat file containing fe structure
% fname: The string of filename for output fiber file (.pdb or .mat format)
% roiDir: A full path to the directory where ROI .mat files are stored
% roinames: The string of the name of the Waypoint ROIs
% roiOperations: The operation of ROI waypoint segmentation ('and', 'not'
% or 'endpoints'
%
% feFileToLoad = 'S1_STN96_LH_ILF_SPC_0p25_fe.mat';
% fname = 'LH_Ufiber_SPC_0p25.mat';
% roiDir = '/data/STN96/S1/S1_STN96_data/ROIs/WaypointROIs';
% roiNames = {'S1_LH_ILF_Anterior.mat','S1_LH_ILF_Posterior.mat'};
% roiOperations = {'and','and'}
% (C) Hiromasa Takemura, Stanford VISTA Lab/CiNet 2015

for iroi = 1:length(roiNames)
    rois{iroi} = fullfile(roiDir,roiNames{iroi});
end

% Load fe structure
disp('loading the LiFE structure...')
if ischar(feFileToLoad)
    fprintf('Loading %s ...\n',feFileToLoad)
    load(feFileToLoad);
else
    fe  =feFileToLoad;
    clear feFileToLoad;
end

% Extract the fiber group from the FE structure
fg = feGet(fe,'fibers acpc');
fweight = feGet(fe,'fiber weights');
fweight(fweight > 0) = 1;

% Remove fascicles with zero-weights
fgkeep = fgExtract(fg, transpose(logical(fweight)), 'keep');

% Segment fascicles based on waypoint ROIs
[fgsegment, keepFascicles] = feSegmentFascicleFromConnectome(fgkeep, rois, roiOperations, 'prob connectome');

% Exclude topological outliers using mba code
[fgsegment3, keepFascicle3] = mbaComputeFibersOutliers(fgsegment,3,3,40);

% Save files
fgWrite(fgsegment3, fname);
