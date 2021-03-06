%% Function: checkParamsAndSetDefaults_FlexibleTwoPoint
%%
%% Description: Check validity of input parameters and set defaults for unspecified parameters
%%
%% Input:
%%   - imDataParams: TEs, images and field strength
%%   - algoParams: algorithm parameters
%%
%% Output:
%%   - validParams: binary variable (0 if parameters are not valid for this algorithm)
%%   - algoParams2: "completed" algorithm parameter structure (after inserting defaults for unspecified parameters)
%%   - imDataParams2: "completed" image parameter structure (after inserting defaults for unspecified parameters)
%% 
%%
%% Author: Johan Berglund
%% Date created: November 17, 2011
%% Date last modified: November 18, 2011
%%

function [validParams,imDataParams2,algoParams2] = checkParamsAndSetDefaults_FlexibleTwoPoint( imDataParams,algoParams )

imDataParams2 = imDataParams;
algoParams2 = algoParams;
validParams = 1;

%% Check if two echoes
if length(imDataParams.TE) < 2 || size(imDataParams.images,5) < 2
  disp('ERROR: 2 point recon -- please use a different recon for acquisitions with fewer than 2 TEs')
  validParams = 0;
else
    if length(imDataParams.TE) > 2 || size(imDataParams.images,5) > 2
        disp('WARNING: 2 point recon -- using first 2 TEs only in reconstruction')
    end
end

%% Check if single precision
if ~strcmp(class(imDataParams.images),'single')
    imDataParams2.images=single(imDataParams.images);
    disp('WARNING: image data converted to single precision')
end

%%   Assign default voxelSize if none in given
try
  imDataParams2.voxelSize = imDataParams.voxelSize;
catch 
  imDataParams2.voxelSize = [1.5 1.5 1.5];
end

%%   Chemical shifts of water and fat resonances in ppm.
%%   Default chemical shifts and relative amplitudes taken from:
%%   Hamilton et al. NMR Biomed 2011; 24:784-790.
try
  algoParams2.species(1) = algoParams.species(1);
catch 
  algoParams2.species(1).name = 'water';
  algoParams2.species(1).frequency = 4.70;
  algoParams2.species(1).relAmps = 1;
end

try
  algoParams2.species(2) = algoParams.species(2);
catch 
  algoParams2.species(2).name = 'fat';
  algoParams2.species(2).frequency = [0.90, 1.30, 1.60, 2.02, 2.24, 2.75, 4.20, 5.19, 5.29];
  algoParams2.species(2).relAmps = [88 642 58 62 58 6 39 10 37];
end

%%   For each species: check if frequency and relAmps have equal length,
%%   and normalize relAmps
for m = 1:length(algoParams2.species)
    if length(algoParams.species(m).frequency) ~= length(algoParams.species(m).relAmps)
      disp('ERROR: algoParams.species(m).frequency and algoParams.species(m).relAmps must have equal length')
      validParams = 0;
    end

    algoParams2.species(m).relAmps=algoParams.species(m).relAmps/sum(algoParams.species(m).relAmps);
end