function SatelliteInformation = MULTI_GNSS_Simulation_Tool_Compact( configuration, trajectory )
% MULTI GNSS SIMULATION TOOL
% Path: MULTI_GNSS_Simulation_Tool_Compact.m
%
% The tool provides functionalities to perform orbits computation starting
% from the broadcasted ephemerides parameters in brdc rinex files for GNSS
% satellites. The compatible sytems are GPS, Galileo, Beidu, and Glonass.
% Additionally, analysis of position diulition of precision (PDOP) is also
% possible, assessing the availablility of a particular system in a
% specific location and time. The tool can be used as initial module  for a
% GNSS software simulator as well.
% After configuring all the parameters in the file "cfg_main.m" located in
% the folder "config", the script can be lunched.
%
% INPUT:
% - configuration --> different options such as...
% - trajectory --> provided in [latitude (deg), longitude (deg), height (m)] format
% 
% External dependencies: 
% - (@src/utilities/constellations) goGPS software for reading RINEX files, computing satellite
%   positions and estimate ionospheric and tropospheric corrections.
%
% Author: Filippo Giacomo, Rizzi; Medina, Daniel
% Email: filippo.rizzi@dlr.de; daniel.ariasmedina@dlr.de
% Matlab ver.: Tested on 7 (R2022a)
% Created: 2023-09-11
%--------------------------------------------------------------------------
% TODO %
% TODO %
%--------------------------------------------------------------------------

% clear all
% close all
% clc

disp('*******************************************************************')
disp('**************     MULTI GNSS SIMULATION TOOL   *******************')
disp('*******************************************************************')


%% Load files and functions is subdir
myFolder = fileparts(which(mfilename)); % Determine where your m-file's folder is.
addpath(genpath(myFolder)); % Add that folder plus all subfolders to the path.


%% Import config parameters
% Check inputs:

% Which GNSS to use?
useGps = configuration.useGps;
useGlonass = configuration.useGlonass;
useGalileo = configuration.useGalileo;
useBeidou = configuration.useBeidou;

% Parameters for the trajectory
Insert_data=configuration.initialDate;     % Insert initial simulation [year month day hour minutes seconds]
el_mask=configuration.elevationMask;                         % [Deg]
location=trajectory;  % [Lat Long_est h]
download_last_rinex = 0;            % Download last available rinex of the day
in_path = configuration.rinexFile;     %Insert the name of the rinex file   BRDM00DLR_S_20223470000_01D_MN
simulation_time=configuration.nEpochs;                  % [s]
step_sim=1/(configuration.dt);                        % [sec]

% Loading the input
load_old_eph = 1;           % Load the ephemeris if already exist (after first run). If 0 the rinex file will be used.


% GNSS-related parameters
global constellations
constellations = goGNSS.initConstellation(useGps,useGlonass,useGalileo,useBeidou,0,0);  % GPS_flag, GLO_flag, GAL_flag, BDS_flag, QZS_flag, SBS_flag

% Miscellanea parameters
el_mask=deg2rad( el_mask );
phi=deg2rad( location(:,1) );   %lat
lambda=deg2rad( location(:,2) );%long
h=location(:,3);              %position height
[JD,tetaG0,tetaG]=juliandata(Insert_data(1,1),Insert_data(1,2),Insert_data(1,3),0);%JD and tetaG0 at GMST
initial_time=Insert_data(1,4)*3600+Insert_data(1,5)*60+Insert_data(1,6);



%% Load ephemeris
disp('Reading navigation data...')
% Loading the input
name_eph = append(configuration.rinexFile,'_eph.mat');
if load_old_eph && exist(name_eph,'file') == 2
    load(name_eph);               %To load the saved ephemeris
else
    eph=import_rinex(in_path);     %import the rinex
    file_to_save = strcat(myFolder,'\input\', name_eph);
    save(file_to_save,'eph')
end
[indexG,indexR,indexC,indexE]=find_last_eph(eph,configuration.initialDate);



%% SATELLITES POSITION CALCULATION
disp('Computing satellites orbits...')
kk=1;
for Time_index=initial_time:step_sim:initial_time+simulation_time-1
    if useGps
        [SatGPS_all]=orbitGPS(eph,indexG,Time_index);
        Sat(kk).GPS_all=SatGPS_all;
    end

    if useGlonass
        [SatGLO_all]=orbitGLO(eph,indexR,Time_index,tetaG0);
        Sat(kk).GLO_all=SatGLO_all;
    end

    if useBeidou
        [SatBEI_all]=orbitBEI(eph,indexC,Time_index);
        Sat(kk).BEI_all=SatBEI_all;
    end

    if useGalileo
        [SatGAL_all]=orbitGAL(eph,indexE,Time_index);
        Sat(kk).GAL_all=SatGAL_all;
    end

    kk=kk+1;
end



%% Visible Satellites calculation
kk=1;
for Time_index=initial_time:step_sim:initial_time+simulation_time-1

    if useGps
        [Absolute_SatPosGPS, elGPS,azGPS,PRN,svId]=visible_satGPS(phi(kk),lambda(kk),h(kk),Sat(kk).GPS_all,el_mask);
        out(kk).GPS.xyz = Absolute_SatPosGPS;
        out(kk).GPS.el=elGPS;
        out(kk).GPS.az=azGPS;
        out(kk).GPS.PRN=PRN;
        out(kk).GPS.indexes=svId;
        out(kk).indexes = svId;
        out(kk).GPS.time=Time_index;
        out(kk).GPS.date=time_fun(Time_index,Insert_data);
        [out(kk).GPS.PDOP,out(kk).GPS.H]=DOP(Absolute_SatPosGPS.');
    end

    if useGlonass
        [Absolute_SatPosGLO,elGLO,azGLO,PRN, svId]=visible_satGLO(phi(kk),lambda(kk),h(kk),Sat(kk).GLO_all,el_mask);
        out(kk).GLO.xyz = Absolute_SatPosGLO;
        out(kk).GLO.el=elGLO;
        out(kk).GLO.az=azGLO;
        out(kk).GLO.PRN=PRN;
        out(kk).GLO.indexes=svId;
%         out(kk).GLO.svId=svId;
        out(kk).indexes = [ out(kk).indexes; svId ];
        out(kk).GLO.time=Time_index;
        out(kk).GLO.date=time_fun(Time_index,Insert_data);
        [out(kk).GLO.PDOP,out(kk).GLO.H]=DOP(Absolute_SatPosGLO.');
    end

    if useGalileo
        [Absolute_SatPosGAL,elGAL,azGAL,PRN, svId]=visible_satGAL(phi(kk),lambda(kk),h(kk),Sat(kk).GAL_all,el_mask);
        out(kk).GAL.xyz = Absolute_SatPosGAL;
        out(kk).GAL.el=elGAL;
        out(kk).GAL.az=azGAL;
        out(kk).GAL.PRN=PRN;
        out(kk).GAL.indexes=svId;
        out(kk).indexes = [ out(kk).indexes; svId ];
        out(kk).GAL.time=Time_index;
        out(kk).GAL.date=time_fun(Time_index,Insert_data);
        [out(kk).GAL.PDOP,out(kk).GAL.H]=DOP(Absolute_SatPosGAL.');
    end

    if useBeidou
        [Absolute_SatPosBEI,elBEI,azBEI,PRN, svId]=visible_satBEI(phi(kk),lambda(kk),h(kk),Sat(kk).BEI_all,el_mask);
        out(kk).BEI.xyz = Absolute_SatPosBEI;
        out(kk).BEI.el=elBEI;
        out(kk).BEI.az=azBEI;
        out(kk).BEI.PRN=PRN;
        out(kk).BEI.indexes=svId;
        out(kk).indexes = [ out(kk).indexes; svId ];
        out(kk).BEI.time=Time_index;
        out(kk).BEI.date=time_fun(Time_index,Insert_data);
        [out(kk).BEI.PDOP,out(kk).BEI.H]=DOP(Absolute_SatPosBEI.');
    end

    kk=kk+1;
end

SatelliteInformation = out;

disp('Simulation completed')
disp('*******************************************************************')