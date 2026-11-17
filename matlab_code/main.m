%% Fighting the Mismatch: A Tutorial on Robust Estimation for Navigation

%**************************************************************************
% This script showcases the complete simulation workflow for the tutorial:
%
%   1. Setup configuration for the scenario and simulation 
%   2. Generate the reference scenario
%   3. Generate GNSS measurements
%   4. Run navigation filters using Monte Carlo simulation
%   5. Compute performance metrics
%   6. Plot and compare the results
%
% Implementation details are contained in the corresponding functions.
%
%--------------------------------------------------------------------------
% Date : 09-December-2026
% Author : Daniel MEDINA (daniel.ariasmedina@dlr.de)
%          Andrea BELLES FERRERES (andrea.bellesferreres@dlr.de)
%          Helena CALATRAVA (calatrava.h@northeastern.edu)
%          Paul CHAUCHAT (paul.chauchat@lis-lab.fr)
%          Pau CLOSAS (closas@ece.neu.edu)
%          Jordi VILA-VALLS (Jordi.VILA-VALLS@isae-supaero.fr) 
%
% Institute of Communications and Navigation, German Aerospace Center 
% (DLR), Neustrelitz, Germany
% Northeastern University, Boston, USA
% Aix-Marseille University, Marseille, France
% ISAE-SUPAERO, University of Toulouse, Toulouse, France
%--------------------------------------------------------------------------
%
%**************************************************************************

clear all; close all; clc;

%% Load files and functions in subdir

myFolder = fileparts(which(mfilename)); % Determine where your m-file's folder is.
addpath(genpath(myFolder)); % Add that folder plus all subfolders to the path.

%%
fprintf('\n***********************************************************************\n');
fprintf('\n***** Welcome to the Tutorial on Robust Estimation for Navigation *****\n');
fprintf('\n***********************************************************************\n');

fprintf('\nRunning Main\n');
fprintf('\n--------------------------------------\n');

%% 1. Configuration

fprintf('\nSetting up cofiguration...\n');

% cfg = nominal_scenario_config();
cfg = outliers_test_1_scenario_config();
% cfg = outliers_test_2_scenario_config();
% cfg = outliers_test_3_scenario_config();
% cfg = outliers_test_4_scenario_config();


rng(cfg.simulation.randomSeed);

if ~exist(cfg.paths.results,'dir'), mkdir(cfg.paths.results); end
if ~exist(cfg.paths.figures,'dir'), mkdir(cfg.paths.figures); end
if ~exist(cfg.paths.scenario,'dir'), mkdir(cfg.paths.scenario); end

%% 2. Generate reference scenario

fprintf('Generating scenario...\n');

scenario = generateScenario(cfg);

% "scenario" should contain:
%   scenario.time
%   scenario.truth.position
%   scenario.truth.velocity
%   scenario.truth.x
%   scenario.gnss.idealPseudorange
%   scenario.gnss.satellitePosition (ENU)
%   scenario.gnss.nSatellites

%% 2. Generate one example GNSS realization

rng(cfg.simulation.randomSeed);

% example = generateMonteCarloRealization( scenario, cfg);
example = generateNoise( scenario, cfg);

%% 3. Plot generated scenario

if cfg.plot.scenario
    plotScenario(scenario, example, cfg);
end

%%% Verify scenario
if cfg.plot.verifyScenario
    verifyScenario(scenario, cfg);
end

%% 4. Run Monte Carlo simulation

fprintf('Running Monte Carlo simulation...\n');

[mcFilterResults, mcEstimationResults, mcData, outliersLog] = runMonteCarlo(scenario, cfg);


%% 5. Compute performance metrics

fprintf('Computing performance metrics...\n');

metrics = computeMetrics(mcEstimationResults, cfg);


%% 6. Plot Monte Carlo results

if cfg.plot.monteCarlo
    plotMonteCarlo(scenario, mcData, outliersLog, cfg);
end


%% 7. Plot performance metrics

if cfg.plot.metrics
    plotMetrics(scenario, metrics, cfg);
end

%% Save results and figures

%% 8. Summary

fprintf('\nSimulation complete.\n');
fprintf('Output directory: %s\n',cfg.paths.figures);
% disp(metrics.summary);
fprintf('------------------------------------------------------------\n');






