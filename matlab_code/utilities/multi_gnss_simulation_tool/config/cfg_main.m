% CONFIGURATION FILE
%
% This is a configuration file for the main script
% MULTI_GNSS_Simulation_tool. It allows to set all the variables and
% parameters to perform the simulation.


Insert_data=[2022 12 13 9 0 0];     % Insert initial simulation [year month day hour minutes seconds]
el_mask=10;                         % [Deg]
location=[45.067828,7.690724,239];  % [Lat Long_est h] 
download_last_rinex = 0;            % Download last available rinex of the day
in_path = 'BRDM00DLR_S_20223470000_01D_MN.rnx';     %Insert the name of the rinex file
Costellation=[1,1,1,1];             % [GPS,GLonass,Beidou,Galileo] chose 1 to activate system
simulation_time=2;                  % [hour]
step_sim=30;                        % [sec]

%% PDOP Simulation
enable_pdop = 1;            % Enable PDOP analysis

%% Skyplot Input
enable_skyplot = 1;         % Enable skyplot 1=True, 0=False
Skyplot_time=[0];         % To plot a specific time instant insert the number of hours after the strart time. For an interval insert a vector of hours like [0,2]
Skyplot_costellation=5;     % 1=GPS 2=GLONASS 3=BEIDOU 4=GALILEO 5=Multi Costellation
skyplot_downsample = 10;    % Downsample skyplot plotting [s] 

%% Input for Urban Environment simulation
enable_urban_sim = 0;       % Enable urban simulation 1=True, 0=False
enable_urban_skyplot=0;     % Enable skyplot 1=True, 0=False
dir_az=312;                 % [Deg] direction of road 0°=N
width=8;                    % Width of the road  [m] 
height=12;                  % Height of building [m]

%% Loading the input
load_eph = 1;           % Load the ephemeris if already exist (after first run). If 0 the rinex file will be used.
                        % Thei can be find in "input\eph.mat"
%% Save output
save_raw_orbits = 1;    % Save the computed position for the full set of satellites. It can be find in "input\satRawPos.m"
save_vis_orbits = 1;    % Save the visible satellites position. It can be fin in "output\satVisPos.m"
load_raw_orbits = 0;    % Load raw orbits for all satellites (available after saving raw_orbits)
load_vis_orbits = 0;    % Load visible satellites (available after saveing vis_orbits)
