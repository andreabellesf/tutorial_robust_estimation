%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scenario Name and Input Folder Paths %%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.scenario_name = "opensky";    % opensky or urban
cfg.input_folder = "config\scenarios"; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scenario Configuration %%%%%%%%%%%%%%%%%%
cfg.n_epochs = 3600;
cfg.n_freq = 1; 
cfg.freq_gnss = 1; 
cfg.dt = 1/cfg.freq_gnss;
cfg.initial_date=[2022 12 13 9 0 0];     % Insert initial time [year month day 
% hour minutes seconds]
cfg.initial_position = [53.3295056 13.0717511 10];  % Initial location in 
% latitude, longitude and height [deg; deg; m]
cfg.initial_velocity = [0 0 0];  % initial velocity in ENU frame [m/s; m/s; m/s]
cfg.elevation_mask = 5; % elevation mask in degrees

% GNSS-related configuration
cfg.n_satellites = 19;
cfg.enable_gps = 1;         % 1: yes, 0: no % GPS
cfg.enablle_gal = 1;     % 1: yes, 0: no    % GALILEO
cfg.enable_bei = 0;      % 1: yes, 0: no    % BEIDOU
cfg.enable_glo = 0;     % 1: yes, 0: no     % GLONASS
cfg.nFreq = 1; 

% Standard deviation for dynamical movement parameters
cfg.std_velocity = [1, 1, 1]; % Standard deviation for the 
% velocity, expressed in the ENU frame, in [m/s/s]

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Nominal Noise Profile Configuration %%%%%%%%%%
cfg.noise.add_noise = 1; % 1: yes, 0: no
cfg.noise.std_noise_code = 1; % standard deviation of the nominal Gaussian noise for GNSS measurements

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Outlier Profile Configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.outliers.add_outliers = 1; % 1: yes, 0: no
cfg.outliers.init_time    = [500; 1500; 3000];
cfg.outliers.end_time     = [1000;2500; 3500];
cfg.outliers.fraction  = 0.2;        %[-] fraction of outliers in data
cfg.outliers.model = "gaussian"; %["gaussian", "laplacian", "student-t"] type of residual noise distribution
cfg.outliers.mean = 100; %[-] mean of the residual noise distribution
cfg.outliers.alpha = 3; %[-] variance inflation factor for outliers (σ_outlier^2 = alpha * σ^2)
cfg.outliers.student_t_nu = 3; 

%%%%%%%%%%%%%%%%%%% Estimators %%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.n_states = 6; % px, py, pz, vx, vy, vz 
cfg.n_states_pos = 3; 
cfg.n_states_vel = 3; 
cfg.init_pos = [0;0;0];
cfg.init_vel = [0;0;0];
cfg.init_pos_cov = [100;100;100];
cfg.init_vel_cov = [10;10;10];

cfg.enable_ekf = 1; % 1: yes, 0: no
