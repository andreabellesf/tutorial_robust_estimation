% CONFIGURATION FILE
%
% This is a configuration file for the main script
% MULTI_GNSS_Simulation_tool. It allows to set all the variables and
% parameters to perform the simulation.

load currentWorkspace.mat

useGps = 1;
useGalileo = 1;
useBeidou = 1;
useGlonass = 1;

Insert_data=initialDate;     % Insert initial simulation [year month day hour minutes seconds]
el_mask=elevationMask;                         % [Deg]
location=xRefLlh;  % [Lat Long_est h] 
download_last_rinex = 0;            % Download last available rinex of the day
in_path = rinexFile;     %Insert the name of the rinex file   BRDM00DLR_S_20223470000_01D_MN
Constellation=[useGps,useGlonass,useBeidou,useGalileo];             % [GPS,GLonass,Beidou,Galileo] choose 1 to activate system
simulation_time=nEpochs;                  % [s]
step_sim=freqGnss;                        % [sec]

% constellations = goGNSS.initConstellation(useGps,useGlonass,useGalileo,useBeidou,0,0); % GPS_flag, GLO_flag, GAL_flag, BDS_flag, QZS_flag, SBS_flag
% nConstellations = useGps + useGlonass + useGalileo + useBeidou; % total number of constellations
% nSatTot        = constellations.nEnabledSat;


%% Loading the input
load_eph = 0;           % Load the ephemeris if already exist (after first run). If 0 the rinex file will be used.
                        % They can be find in "input\eph.mat"

%% Save output
save_raw_orbits = 0;    % Save the computed position for the full set of satellites. It can be find in "input\satRawPos.m"
save_vis_orbits = 1;    % Save the visible satellites position. It can be fin in "output\satVisPos.m"
load_raw_orbits = 0;    % Load raw orbits for all satellites (available after saving raw_orbits)
load_vis_orbits = 0;    % Load visible satellites (available after saveing vis_orbits)
