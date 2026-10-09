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
cfg.filename.gnssData = 'opensky_2022_neustrelitz_satellite_positions_enu';

%% Simulation

cfg.simulation.randomSeed = 42;
cfg.simulation.freqGnss = 1; 
cfg.simulation.dt       = 1/cfg.simulation.freqGnss;       % [s]
cfg.simulation.nEpochs  = 300;       % [-]
cfg.simulation.nFreq    = 1;

%% Ground truth trajectory

cfg.trajectory.type = "constant_velocity";
cfg.trajectory.initialDate=[2022 12 13 9 0 0];     % Insert initial time [year month day 
% hour minutes seconds]
cfg.trajectory.initialPosition = [0 0 0]; % [53.3295056 13.0717511 10];  % Initial location in 
% latitude, longitude and height [deg; deg; m]
cfg.trajectory.initialVelocity = [0 0 0];  % initial velocity in ENU frame [m/s; m/s; m/s]

% Standard deviation for dynamical movement parameters
cfg.trajectory.velocitySigma = [1, 1, 1]; % Standard deviation for the 
% velocity, expressed in the ENU frame, in [m/s/s]


%% GNSS measurement model

cfg.gnss.pseudorangeSigma = 0.5;     % [m]

%% Navigation filters

cfg.filters.enabled = { ...
    'EKF', ...
    'RKF'};


cfg.filters.initialPosition = [0 0 0];
cfg.filters.initialVelocity = [0 0 0];

cfg.filters.initPosSigma = 20;      % m
cfg.filters.initVelSigma = 2;       % m/s

cfg.filters.trajectory.type = "constant_velocity";

% Process-noise standard deviations
cfg.filters.accSigma = [0.1; 0.1; 0.001];
cfg.filters.velSigmaEnu  = [0.1 0.1 0.001]; % expressed in the ENU frame, in [m/s/s]


%% Monte Carlo

cfg.monteCarlo.numRuns = 1;
cfg.monteCarlo.baseSeed = 1000;
cfg.monteCarlo.showProgress = true;

%% Metrics

cfg.metrics.computeRMSE = true;
cfg.metrics.computeNEES = true;

%% Plotting

cfg.plot.scenario   = true;
cfg.plot.verifyScenario   = true;
cfg.plot.monteCarlo = true;
cfg.plot.metrics    = true;

cfg.plot.position   = true;
cfg.plot.velocity   = true;
cfg.plot.residuals  = true;

cfg.plot.saveFigures = false;
cfg.plot.outputFolder = "figures";

end