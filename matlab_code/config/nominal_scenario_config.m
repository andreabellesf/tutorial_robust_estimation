function cfg = nominal_scenario_config()
% CONFIG Configuration for the GNSS navigation tutorial.
%
%   cfg = CONFIG() returns all parameters required for:
%
%       - scenario generation
%       - GNSS measurement generation
%       - navigation filters
%       - Monte Carlo simulation
%       - metrics
%       - plotting

%% File names and directories
% Location of this file
configDir = fileparts(mfilename('fullpath'));

% Project root (one level above)
cfg.paths.root = fileparts(configDir);

% Data directories
cfg.paths.gnssData     = fullfile(cfg.paths.root, 'data');
cfg.paths.results     = fullfile(cfg.paths.root, 'results');
cfg.paths.figures     = fullfile(cfg.paths.results, 'figures');

% Data filenames
cfg.filename.gnssData.ecef = 'opensky_2022_neustrelitz_satellite_positions';
cfg.filename.gnssData.enu = 'opensky_2022_neustrelitz_satellite_positions_enu';
cfg.filename.gnssData.satelliteInformation = 'opensky_SatelliteInformation';


%% Simulation

cfg.simulation.randomSeed = 42;
cfg.simulation.dt       = 1;       % [s]
cfg.simulation.nFreq    = 1; % Number of frequencies
cfg.simulation.nEpochs  = 1000;       % [-]
cfg.simulation.nCons    = 1; % Number of GNSS constellations



%% Monte Carlo

cfg.monteCarlo.numRuns = 20;
cfg.monteCarlo.baseSeed = 1000;
cfg.monteCarlo.showProgress = true;

%% Ground truth trajectory

cfg.trajectory.type = "constant_velocity";
cfg.trajectory.initialDate=[2022 12 13 9 0 0];     % Insert initial time [year month day 
% hour minutes seconds]
cfg.trajectory.initialPositionLLH = [53.3295056 13.0717511 10]; % Receiver location for the skyplot [deg; deg; m]
cfg.trajectory.initialPosition = [0 0 0]; % [53.3295056 13.0717511 10];  % Initial location in 
% latitude, longitude and height [deg; deg; m]
cfg.trajectory.initialVelocity = [0 0 0];  % initial velocity in ENU frame [m/s; m/s; m/s]

% Parameters for the random initialization of the state parameters
cfg.trajectory.initPosSigma = 30;      % m
cfg.trajectory.initVelSigma = 2;       % m/s 
cfg.trajectory.initClkSigma = 10^5;    % m (initial std for the clk offset (equal across all GNSS constellations)

% Standard deviation for dynamical movement parameters
cfg.trajectory.velocitySigma = [0.1;0.1;0.1]; % Standard deviation for the velocity, expressed in the ENU frame, in [m/s/s]
cfg.trajectory.clkSigma = 1; % in [m/s] Random Walk description for the evolution of the clock offsets (equal for all GNSS constellations)

%% GNSS constellations
cfg.gnss.enabledGPS       = true;
cfg.gnss.enabledGAL       = true;
cfg.gnss.elevationMask    = 5;       % degrees


%% Observations noise and fault configuration
cfg.noisemodel.type = "gaussian";
cfg.noisemodel.pseudorangeSigma = 1;     % std for pseudorange measurements [m]

cfg.noisemodel.faultsEnabled = false;
cfg.noisemodel.faultsTimes = [300 500; 600 700];
cfg.noisemodel.faultsType = "gaussian";
cfg.noisemodel.fractionOutlier = [0.25; 0.50]; % fraction of satellites

%% Outliers / faults profile (see configOutliersProfile_test_*.m)
cfg.outliers.enabled            = false;
cfg.outliers.profileFilename    = "configOutliersProfile_test_0";

%% Navigation filters

cfg.filters.enabled = { ...
    'EKF', ...
    'Huber'};
    % 'Consensus-EKF' disabled until RANSAC_ranges.m is finished

cfg.filters.initPosSigma = 30;      % m
cfg.filters.initVelSigma = 2;       % m/s 
cfg.filters.initClkSigma = 10^5;    % m (initial std for the clk offset (equal across all GNSS constellations)

cfg.filters.initialPosition = cfg.trajectory.initialPosition(:) + cfg.filters.initPosSigma*randn(3,1); 
cfg.filters.initialVelocity = cfg.trajectory.initialVelocity(:) + cfg.filters.initVelSigma*randn(3,1);
cfg.filters.initialClkOffest = zeros(cfg.simulation.nCons, 1);

cfg.filters.trajectory.type = "constant_velocity";

cfg.filters.nCons = cfg.simulation.nCons;
% Process-noise standard deviations
cfg.filters.velSigma = [0.1;0.1;0.1]; % expressed in the ENU frame, in [m/s/s]
cfg.filters.clkSigma = 1; % in [m/s] Random Walk description for the evolution of the clock offsets (equal for all GNSS constellations)

% Robust tuning constants
cfg.filters.tuning.Huber        = 1.345;
cfg.filters.tuning.Tukey        = 4.6851;

% Robust EKF
cfg.filters.nIterRKF      = 20;
cfg.filters.stateTol      = 1e-7;


%% Metrics

cfg.metrics.computeRMSE = true;
cfg.metrics.computeNEES = true;
cfg.metrics.alpha    = 0.05;      % 95% consistency interval


%% Plotting

cfg.plot.scenario   = true;
cfg.plot.verifyScenario   = false;
cfg.plot.monteCarlo = false;
cfg.plot.metrics    = true;

cfg.plot.position   = true;
cfg.plot.velocity   = true;
cfg.plot.residuals  = true;

cfg.plot.selectedMc = 1;

cfg.plot.saveFigures = false;
cfg.plot.outputFolder = "figures";

end