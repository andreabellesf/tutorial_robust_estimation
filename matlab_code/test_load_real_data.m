%% Test script to load real GNSS data

clear all; % close all; clc;

%%% Load files and functions in subdir
myFolder = fileparts(which(mfilename)); % Determine where your m-file's folder is.
addpath(genpath(myFolder)); % Add that folder plus all subfolders to the path.
% Location of this file
root = fileparts(mfilename('fullpath'));
path      = fullfile(root, 'data/real');

%% Config
filename = 'doy188_2026_COM14_broadcast_code';
% filename = 'berlin_waters_scene03_FrontLeft_broadcast_code';
nEpochs = 1000;
nCons = 2;
nSatTotal = 68;

posEstSPP = nan(3,nEpochs);
clkOffEstSPP = nan(nCons,nEpochs);
residualsSPP = cell(1,nEpochs);


%% Load data 
fileName = fullfile(path, filename);
load(fileName);

tmpCode = data.obs_code(:, :,1);
rowCode = find(sum(~isnan(tmpCode), 2) >= 5, 1, 'first');
tmpCodeCorr = data.obs_code_corrected(:, :,1);
rowCodeCorr = find(sum(~isnan(tmpCodeCorr), 2) >= 5, 1, 'first');
% rowCodeCorr = 10000; 
% [row, col] = find(tmpCodeMeas);
[rowSv, col] = find(data.svStatus);
epochInit = rowCodeCorr;
epochEnd  = rowCodeCorr+nEpochs-1;
epochs = epochInit:1:epochEnd;

nSat = nan(nEpochs,1);
nSatGnss = nan(nEpochs, nCons);

svAzim = nan(nEpochs,nSatTotal);
svElev = nan(nEpochs,nSatTotal);
svSnr = nan(nEpochs,nSatTotal);

for t = 1:nEpochs
    
    k = epochs(t);
    
    % idxSat = find(data.svStatus(k, :));
    idxSat = find(~isnan(tmpCodeCorr(k, 1:nSatTotal)));
    % idxSat = find(~isnan(data.SV_PosX(k, :)));
    idSat = data.satellite_id(idxSat);
    nSat(t) = numel(idxSat);
    nSatGnss(t,:) = [ sum(startsWith(idSat, 'G')), sum(startsWith(idSat, 'E'))];
    svId = find(~isnan(tmpCodeCorr(k,:)));

    clockMatrix = zeros(nSat(t), 2);
    clockMatrix(:,1) = startsWith(idSat, 'G');
    clockMatrix(:,2) = startsWith(idSat, 'E');

    % Detect and remove all-zero columns in case no measurements for one of
    % the two cons are are available
    validCols = any(clockMatrix ~= 0, 1);
    clockMatrix = clockMatrix(:, validCols);

    satPos = [data.SV_PosX(k, idxSat).' ...
                data.SV_PosY(k, idxSat).' ...
                data.SV_PosZ(k, idxSat).' ]; 

    
    pseudorange = tmpCodeCorr(k, idxSat);
    pseudorange = pseudorange(:);

    [pos, clkOffset, residuals, P, G, reliable] = MultiGNSS_Snapshot( pseudorange, satPos, clockMatrix);

    posEstSPP(:, t) = pos;
    clkOffEstSPP(validCols, t) = clkOffset;
    residualsSPP{t} = residuals;

    [svElev(t,svId), svAzim(t,svId)] = satelliteAzimthElevation(satPos, pos);

    svSnr(t,svId) = data.obs_snr(k,svId);

end

posErr_1 = data.receiver_spp_ecef_m(epochs,:) - data.GroundTruth(epochs, 3:end);
posErr_1 = posErr_1.';
posErrSquared_1 = sum(posErr_1.^2, 1);
rmse_1 = sqrt(mean(posErrSquared_1, 3));



%% Visualization
set(groot,'defaultFigureColor','w')
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');  
set(groot,'defaultAxesFontSize',13);
set(groot,'DefaultAxesXGrid','on')
set(groot,'DefaultAxesYGrid','on')

figure; plot(epochs, rmse_1); %grid on; 
xlabel('epochs','Interpreter','latex');
ylabel('3D position RMSE [m]','Interpreter','latex');
title(['SPP HU - GT: ' string(filename)],'Interpreter','latex', 'FontSize', 9)

posErr_2 = posEstSPP - (data.GroundTruth(epochs, 3:end).');
posErrSquared_2 = sum(posErr_2.^2, 1);
rmse_2 = sqrt(mean(posErrSquared_2, 3));

figure;  plot(epochs, rmse_2); %grid on; 
xlabel('epochs','Interpreter','latex');
ylabel('3D position RMSE [m]','Interpreter','latex');
title(['SPP AB - GT: ' string(filename)],'Interpreter','latex', 'FontSize', 9)

% save("data\real\berlin_waters_scene03.mat", 'pseudorange')

select=~isnan(svElev);

aux1=svElev(select);



% % plotGnssSkyplot(satPos, pos, satIDs, cfg)

skyPlot(svElev(select), svAzim(select), 'snr', svSnr(select))

skyPlot(svElev(t,svId), svAzim(t,svId), 'snr', svSnr(t,svId),'satelliteId',idSat, 'makenewfigure',0 )


