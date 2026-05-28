%**************************************************************************
% RUN_generateScenario
%
% % This script generates the ground truth user trajectory and GNSS ranging
% observations
%
% INPUTS: 
%   - generate_scenario_config.m
%
% OUTPUTS:
%   - DATASETNAME_scenario_config.mat: MAT-file containing the relevant
%   information for the configuration of the scenario, GNSS options,
%   process noise, etc.
%   - DATASETNAME_gnss_data.mat: MAT-file containing the ground truth
%   solution (position, velocity, ambiguities, clock offsets...) and the
%   GNSS information (noiseless code and carrier phase pseudorange
%   observations, position and clock offsets for the satellites).
%
%--------------------------------------------------------------------------
% Date : 08-May-2026
% Author : Daniel MEDINA (daniel.ariasmedina@dlr.de)
%          Andrea BELLES FERRERES (andrea.bellesferreres@dlr.de)
%          Helena CALATRAVA (calatrava.h@northeastern.edu)
%          Paul CHAUCHAT (paul.chauchat@lis-lab.fr)
%          Pau CLOSAS (closas@ece.neu.edu)
%          Jordi VILA-VALLS (Jordi.VILA-VALLS@isae-supaero.fr) 
%
% Institute of Communications and Navigation, DLR, Neustrelitz, Germany
% Northeastern University, Boston, USA
% Aix-Marseille University, Marseille, France
% ISAE-SUPAERO, University of Toulouse, Toulouse, France
%--------------------------------------------------------------------------
%
%**************************************************************************


clear; 
close all;
clc;


%% Load files and functions is subdir
myFolder = fileparts(which(mfilename)); % Determine where your m-file's folder is.
addpath(genpath(myFolder)); % Add that folder plus all subfolders to the path.


%% Loading configuration
run('scenario_config');


%% Loading GNSS ephemeris from DLR's Multi GNSS simulator Tool
% load('opensky_SatelliteInformation')
% satellite_positions = [ SatelliteInformation(1).GPS.xyz(:,1)', SatelliteInformation(1).GAL.xyz(:,1)'; ...
%     SatelliteInformation(1).GPS.xyz(:,2)', SatelliteInformation(1).GAL.xyz(:,2)'; ...
%     SatelliteInformation(1).GPS.xyz(:,3)', SatelliteInformation(1).GAL.xyz(:,3)' ];
% initialPositionEcef = ell2xyz(initialPosition(1)*pi/180,initialPosition(2)*pi/180,initialPosition(3));
% R_enu2ecef = [ rotation_ecef2enu( initialPositionEcef ) ].';
% aux = satellite_positions;
% for i=1:size(satellite_positions,2)
%     aux(:,i) = R_enu2ecef * (satellite_positions(:,i) - initialPositionEcef.');
%     [Az(i), El(i), D(i)] = topocent_custom(initialPositionEcef, satellite_positions(:,i)');
% end
% skyPlot ( El(:), Az(:)  )
% satellite_positions = aux;
% skyPlot ( varargin )
load('opensky_2022_neustrelitz_satellite_positions_enu');


%% Generate trajectory
state_reference = nan( cfg.n_states, cfg.n_epochs ); 
state_reference(:,1) = zeros(cfg.n_states,1); % Reference Solution
% Motion model matrices
F = [ eye(cfg.n_states_pos), cfg.dt*eye(cfg.n_states_vel); zeros(cfg.n_states_pos), eye(cfg.n_states_vel) ];
Fq = [ zeros(cfg.n_states_pos); cfg.dt*eye(cfg.n_states_vel) ]; % This is for a first-order integration. It is possible using the second order with Fq = [ cfg.dt^2/2*eye(3); cfg.dt*eye(3) ];
Q = diag(eye(cfg.n_states_vel) * cfg.std_velocity(:).^2);
% Time recursion
for t = 2:cfg.n_epochs
    state_reference(:,t) = F*state_reference(:,t-1) + Fq*sqrtm(Q)*randn( cfg.n_states_vel,1 ); % Reference solution
end
position_reference = state_reference(1:3,:);
velocity_reference = state_reference(4:6,:);


%% Generate GNSS observations
cfg.n_satellites = size( satellite_positions, 2 );
code_observations = nan(cfg.n_satellites, cfg.n_epochs);

for t=1:cfg.n_epochs
    code_observations(:, t) = vecnorm( satellite_positions(1:3,:) - repmat( position_reference(1:3,t), 1, cfg.n_satellites), 2, 1 ) .';
end

%%% Save copy
code_observations_clean = code_observations;

%% Verification
estimates = zeros(3,cfg.n_epochs);

for t=1:cfg.n_epochs

    xnow = estimates(1:3, t);
    for iterations=1:10
        hx = vecnorm( satellite_positions(1:cfg.n_states_pos,:) - repmat( xnow, 1, cfg.n_satellites), 2, 1 ).';
        H = - [ satellite_positions(1:cfg.n_states_pos,:) - xnow].' ./ vecnorm( satellite_positions(1:3,:) - repmat( xnow, 1, cfg.n_satellites), 2, 1 ).'; 
        xnow = xnow + inv(H.'*H)*H.'*(code_observations(:,t) - hx);
    end
    estimates(:,t) = xnow;

end

error = estimates - position_reference;
rmse = sqrt(mean(error.^2, 1));
figure; plot(rmse);

%% Inject measurement noise
% into the GNSS measurements according to the configuration
n_obs_per_epoch = cfg.n_satellites*cfg.n_freq;
[code_observations] = inject_gnss_noise(cfg, code_observations, n_obs_per_epoch);

%%% Save copy
code_observations_noisy = code_observations;

%% Inject outliers
[code_observations] = inject_outliers(cfg, code_observations, n_obs_per_epoch);

%% Estimators
%%%% Initialization and common setup
x_0 = [cfg.init_pos; cfg.init_vel];
P_0 = diag([cfg.init_pos_cov.^2;cfg.init_vel_cov.^2]);
Q = blkdiag(100*eye(3), diag(cfg.std_velocity.^2));
R = cfg.noise.std_noise_code^2 * eye(n_obs_per_epoch);
x_prev_epoch = x_0;
P_prev_epoch= P_0;

%%%% EKF %%%%%%
state_estimated_ekf = nan( cfg.n_states, cfg.n_epochs ); 
cov_state_estimated_ekf = nan( cfg.n_states, cfg.n_states, cfg.n_epochs ); 
state_estimated_ekf(:, 1) = x_0;
cov_state_estimated_ekf(:, :, 1) = P_0;

for current_epoch = 2:cfg.n_epochs
    [x_current_epoch, P_current_epoch, innov, S] = conventionalEKF(x_prev_epoch, P_prev_epoch, code_observations(:, current_epoch), satellite_positions, Q, R, cfg.dt);
    
    state_estimated_ekf(:, current_epoch) = x_current_epoch;
    cov_state_estimated_ekf(:, :, current_epoch) = P_current_epoch;

    x_prev_epoch = x_current_epoch;
    P_prev_epoch= P_current_epoch;

end

%% Compute errors
error_pos_ekf = state_estimated_ekf(1:3, :) - position_reference;
error_vel_ekf = state_estimated_ekf(4:6, :) - velocity_reference;
rmse_pos_ekf = sqrt(mean(error_pos_ekf.^2, 1));
rmse_vel_ekf = sqrt(mean(error_vel_ekf.^2, 1));


%% Plots
figure; plot(rmse_pos_ekf);
figure; plot(rmse_vel_ekf);