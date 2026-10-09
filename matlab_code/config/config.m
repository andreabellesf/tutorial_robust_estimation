function cfg = config()
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
cfg.simulation.freqGnss = 1; 
cfg.simulation.dt       = 1/cfg.simulation.freqGnss;       % [s]
cfg.simulation.nEpochs  = 60;       % [-]
cfg.simulation.nFreq    = 1; % Do not change

%% Monte Carlo

cfg.monteCarlo.numRuns = 1;
cfg.monteCarlo.baseSeed = 1000;
cfg.monteCarlo.showProgress = true;

%% Ground truth trajectory

cfg.trajectory.type = "constant_velocity";
cfg.trajectory.initialDate=[2022 12 13 9 0 0];     % Insert initial time [year month day 
% hour minutes seconds]
cfg.trajectory.initialPosition.ENU = [0 0 0]; 
cfg.trajectory.initialPosition.LLH = [53.3295056 13.0717511 10]; % Initial location in 
% latitude, longitude and height [deg; deg; m]
cfg.trajectory.initialVelocity.ENU = [0 0 0];  % initial velocity in ENU frame [m/s; m/s; m/s]

% Standard deviation for dynamical movement parameters
cfg.trajectory.velocitySigma = [0.1;0.1;0.1]; % Standard deviation for the 
% velocity, expressed in the ENU frame, in [m/s/s]


%% GNSS measurement model

cfg.gnss.enabledGPS       = true;
cfg.gnss.enabledGAL       = true;
cfg.gnss.pseudorangeSigma = 0.3;     % [m]
cfg.gnss.elevationMask    = 5;       % degrees (°)

%% Navigation filters

cfg.filters.enabled = { ...
    'EKF', ...
    'Huber'};

cfg.filters.initialPosition = cfg.trajectory.initialPosition.ENU(:) + [20; 30; 10];
cfg.filters.initialVelocity = cfg.trajectory.initialVelocity.ENU(:); % + [1; -1; 0.5];

cfg.filters.initPosSigma = 30;      % m
cfg.filters.initVelSigma = 2;       % m/s

cfg.filters.trajectory.type = "constant_velocity";

% Process-noise standard deviations
cfg.filters.accSigmaEnu = [0.1;0.1;0.1];
cfg.filters.velSigmaEnu = [0.1;0.1;0.1]; % expressed in the ENU frame, in [m/s/s]

% Robust tuning constants
cfg.filters.tuning.Huber        = 1.345;
cfg.filters.tuning.Tukey        = 4.6851;

% Robust EKF
cfg.filters.nIterRKF      = 20;
cfg.filters.stateTol      = 1e-7;

%% Outliers / faults profile
cfg.outliers.enabled            = true;
cfg.outliers.profileFilename    = "configOutliersProfile_test_3";

%% Metrics

cfg.metrics.computeRMSE = true;
cfg.metrics.computeNEES = true;
cfg.metrics.alpha    = 0.05;      % 95% consistency interval

%% Plotting

cfg.plot.scenario   = true;
cfg.plot.verifyScenario   = false;
cfg.plot.monteCarlo = true;
cfg.plot.metrics    = true;

cfg.plot.position   = true;
cfg.plot.velocity   = true;
cfg.plot.residuals  = true;

cfg.plot.selectedMc    = 1;

cfg.plot.saveFigures = false;
cfg.plot.outputFolder = "figures";

end