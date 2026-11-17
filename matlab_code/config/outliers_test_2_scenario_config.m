function cfg = outliers_test_2_scenario_config()
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
cfg.scenarioName = 'outliers_test_2';

% Location of this file
configDir = fileparts(mfilename('fullpath'));

% Project root (one level above)
cfg.paths.root = fileparts(configDir);

% Data directories
cfg.paths.gnssData     = fullfile(cfg.paths.root, 'data');
cfg.paths.results     = fullfile(cfg.paths.root, 'results');
cfg.paths.figures     = fullfile(cfg.paths.results, 'figures');
cfg.paths.scenario  = fullfile(cfg.paths.figures, cfg.scenarioName);

% Data filenames
cfg.filename.gnssData.satellitePositions = 'opensky_2022_neustrelitz_satellite_positions_enu';
cfg.filename.gnssData.satelliteInfo = 'opensky_SatelliteInformation';

%% Simulation

cfg.simulation.randomSeed = 42;
cfg.simulation.dt       = 1;       % [s]
cfg.simulation.nEpochs  = 1000;       % [-]
cfg.simulation.nCons    = 2; % Number of GNSS constellations
cfg.simulation.enableGPS = 1; % Enable GPS constellation
cfg.simulation.enableGAL = 1; % Enable Galileo constellation

%% Monte Carlo

cfg.monteCarlo.numRuns = 20;
cfg.monteCarlo.baseSeed = 1000;
cfg.monteCarlo.showProgress = true;

%% Ground truth trajectory

cfg.trajectory.type = "constant_velocity";
cfg.trajectory.initialDate=[2022 12 13 9 0 0];     % Insert initial time [year month day 
% hour minutes seconds]
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


%% Observations noise and fault configuration
cfg.noisemodel.type = "gaussian"; % nominal noise model ("gaussian", "laplacian", "student-t")
cfg.noisemodel.std = 1;     % standard deviation of nominal noise for pseudorange measurements [m]

cfg.noisemodel.outliers.enabled = true;
cfg.noisemodel.outliers.times = [300 500; 600 700]; 
cfg.noisemodel.outliers.type = "gaussian"; % outlier noise model ("gaussian", "laplacian", "student-t")
cfg.noisemodel.outliers.epsilon = [0.10; 0.30]; % contamination ratio (fraction of outliers)
cfg.noisemodel.outliers.mu = [5; 5]; % unifrnd(5,10);
cfg.noisemodel.outliers.alpha = [10; 10]; % 10 % variance inflation factor for outliers
cfg.noisemodel.outliers.dof = 5; % degrees of freedom (for Student-t)

%% Navigation filters

cfg.filters.enabled = { ...
    'EKF', ...
    'Huber', ...
    'ConsensusEKF'};

cfg.filters.initPosSigma = 30;      % m
cfg.filters.initVelSigma = 2;       % m/s 
cfg.filters.initClkSigma = 10^5;    % m (initial std for the clk offset (equal across all GNSS constellations)

cfg.filters.initialPosition = cfg.trajectory.initialPosition(:) + cfg.filters.initPosSigma*randn(3,1); 
cfg.filters.initialVelocity = cfg.trajectory.initialVelocity(:) + cfg.filters.initVelSigma*randn(3,1);
cfg.filters.initialClkOffest = zeros(cfg.simulation.nCons, 1);

cfg.filters.trajectory.type = "constant_velocity";

% Process-noise standard deviations
cfg.filters.velSigma = [0.1;0.1;0.1]; % expressed in the ENU frame, in [m/s/s]
cfg.filters.clkSigma = 1; % in [m/s] Random Walk description for the evolution of the clock offsets (equal for all GNSS constellations)

% Robust tuning constants
cfg.filters.rkf.cHuber        = 1.345;
cfg.filters.rkf.cTukey        = 4.6851;

% Robust EKF
cfg.filters.rkf.maxIter      = 20;
cfg.filters.rkf.stateTol        = 1e-7;

% Consensus-EKF
cfg.filters.cekf.maxIter    = 500; % Maximum number of RANSAC iterations, default: 200
cfg.filters.cekf.probConfidence = 0.99;
cfg.filters.cekf.priorProbOutlier = 0.5;
cfg.filters.cekf.minSubsetSize = 5;
cfg.filters.cekf.inlierThreshold = 3; % Maximum absolute normalized residual, default: 3.0 (three standard deviations)
cfg.filters.cekf.ransacRefinement = 1;

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

cfg.plot.saveFigures = false;
cfg.plot.outputFolder = "figures";

%% Saving

cfg.save.enabled = 1;
cfg.save.printPlotProgress = true;
cfg.save.exportPDF = true;
cfg.save.keepFiguresOpen = true; % Keep all figures visible after exporting
cfg.save.pngResolution = 180;

end