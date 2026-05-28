% MULTI GNSS SIMULATION TOOL
% Path: MULTI_GNSS_Simulation_Tool.m
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
% External M-Files required: none
%
% Author: Filippo Giacomo, Rizzi
% Email: filippo.rizzi@dlr.de
% Matlab ver.: Tested on 7 (R2022a)
% Created: 2022-12-15
%--------------------------------------------------------------------------
% TODO % Rename some variables written in Italian
% TODO % Describe accurately all functions with input/outptu
%--------------------------------------------------------------------------

% clear all
% close all
clc

disp('*******************************************************************')
disp('**************     MULTI GNSS SIMULATION TOOL   *******************')
disp('*******************************************************************')

%% Load files and functions is subdir
addpath(genpath('config\'));
addpath(genpath('input\'));
addpath(genpath('output\'));
addpath(genpath('scripts\'));
addpath(genpath('src\'));

%% Import config parameters
global constellations

run('cfg_harp4nav.m');
if download_last_rinex==1
    run('DownloadRinex.m')
end
% Loading the input
if load_eph==1
    load('eph.mat');               %To load the saved ephemeris
else
    eph=import_rinex(in_path);     %import the rinex
end

%% FIND LAST EPHEMERIS
disp('Searching eph...')
[indexG,indexR,indexC,indexE]=find_last_eph(eph,Insert_data);

%% PARAMETERS CALCULATION
el_mask=deg2rad(el_mask);
dir_az=deg2rad(dir_az);
phi=deg2rad(location(:,1));   %lat
lambda=deg2rad(location(:,2));%long
h=location(:,2);              %position height
[JD,tetaG0,tetaG]=juliandata(Insert_data(1,1),Insert_data(1,2),Insert_data(1,3),0);%JD and tetaG0 at GMST
initial_time=Insert_data(1,4)*3600+Insert_data(1,5)*60+Insert_data(1,6);

%% SATELLITES POSITION CALCULATION
disp('Computing satellites orbits...')
if load_raw_orbits == 1
    load('input\satRawPos.mat', 'Sat');
else
    kk=1;
    for Time_index=initial_time:step_sim:initial_time+simulation_time-1
    
        [SatGPS_all]=orbitGPS(eph,indexG,Time_index);
        Sat(kk).GPS_all=SatGPS_all;
    
        [SatGLO_all]=orbitGLO(eph,indexR,Time_index,tetaG0); 
        Sat(kk).GLO_all=SatGLO_all;
    
       [SatBEI_all]=orbitBEI(eph,indexC,Time_index);
        Sat(kk).BEI_all=SatBEI_all;
    
        [SatGAL_all]=orbitGAL(eph,indexE,Time_index);
        Sat(kk).GAL_all=SatGAL_all;
        kk=kk+1;
    end
    if save_raw_orbits == 1
        save('input\satRawPos.mat','Sat')
    end
end
%% Visible Satellites calculation
if load_vis_orbits == 1
    load("output\satVisPos.mat", 'out');
else
    kk=1;
    for Time_index=initial_time:step_sim:initial_time+simulation_time-1
        [Absolute_SatPosGPS, SatPosGPS,elGPS,azGPS,PRN,svId]=visible_satGPS(phi(kk),lambda(kk),h(kk),Sat(kk).GPS_all,el_mask);
        out(kk).GPS.abs_xyz = Absolute_SatPosGPS;
        out(kk).GPS.xyz=SatPosGPS;
        out(kk).GPS.el=elGPS;
        out(kk).GPS.az=azGPS;
        out(kk).GPS.PRN=PRN;
        out(kk).GPS.svId = svId;
        out(kk).svId = svId;
        out(kk).GPS.time=Time_index;
        out(kk).GPS.date=time_fun(Time_index,Insert_data);
        [out(kk).GPS.PDOP,out(kk).GPS.H]=DOP(SatPosGPS);
    
       [Absolute_SatPosGLO,SatPosGLO,elGLO,azGLO,PRN, svId]=visible_satGLO(phi(kk),lambda(kk),h(kk),Sat(kk).GLO_all,el_mask);
       out(kk).GLO.abs_xyz = Absolute_SatPosGLO;
       out(kk).GLO.xyz=SatPosGLO;
       out(kk).GLO.el=elGLO;
       out(kk).GLO.az=azGLO;
       out(kk).GLO.SV=PRN;
       out(kk).GLO.svId=svId;
       out(kk).svId = [ out(kk).svId, svId ];
       out(kk).GLO.time=Time_index;
       out(kk).GLO.date=time_fun(Time_index,Insert_data);
       [out(kk).GLO.PDOP,out(kk).GLO.H]=DOP(SatPosGLO);
    
        [Absolute_SatPosGAL,SatPosGAL,elGAL,azGAL,PRN, svId]=visible_satGAL(phi(kk),lambda(kk),h(kk),Sat(kk).GAL_all,el_mask);
        out(kk).GAL.abs_xyz = Absolute_SatPosGAL;
        out(kk).GAL.xyz=SatPosGAL;
        out(kk).GAL.el=elGAL;
        out(kk).GAL.az=azGAL;
        out(kk).GAL.SV=PRN;
        out(kk).GAL.svId=svId;
        out(kk).svId = [ out(kk).svId, svId ];
        out(kk).GAL.time=Time_index; 
        out(kk).GAL.date=time_fun(Time_index,Insert_data);
        [out(kk).GAL.PDOP,out(kk).GAL.H]=DOP(SatPosGAL);

        [Absolute_SatPosBEI,SatPosBEI,elBEI,azBEI,PRN, svId]=visible_satBEI(phi(kk),lambda(kk),h(kk),Sat(kk).BEI_all,el_mask);
        out(kk).BEI.abs_xyz = Absolute_SatPosBEI;
        out(kk).BEI.xyz=SatPosBEI;
        out(kk).BEI.el=elBEI;
        out(kk).BEI.az=azBEI;
        out(kk).BEI.PRN=PRN;
        out(kk).BEI.svId=svId;
        out(kk).svId = [ out(kk).svId, svId ];
        out(kk).BEI.time=Time_index;   
        out(kk).BEI.date=time_fun(Time_index,Insert_data);
        [out(kk).BEI.PDOP,out(kk).BEI.H]=DOP(SatPosBEI);
        kk=kk+1;
    end
    
    % Save the satellites position at the specified location and time interval
% % %     if save_vis_orbits == 1
%         save('output\satVisPos.mat','out')
        SatelliteInformation = out;
        save('data\temporal_latest_data.mat','SatelliteInformation')
% % %     end
end
%% PLOT THE PDOP OPEN SKY
if enable_pdop ==1
    disp('OPEN SKY VALUES:')
    for kk=1:length(out)
        MultiPDOP(1,kk)=multipdop(Constellation,out,kk);
    end
    Plot_Pdop(out,Constellation,MultiPDOP,step_sim,Insert_data)
end

% Plot the skyplot
if enable_skyplot==1
    disp('Plotting open skyplot...')
    Skyplot(Insert_data,step_sim,out,Skyplot_time,Skyplot_constellation,Constellation, skyplot_downsample)
end

%% URBAN SIMULATION
% Return Struct with satellites
if enable_urban_sim==1
    urban=urban_simulation(out,Constellation,dir_az,width,height);
    % Plot_Pdop_urban(urban,Constellation,multi_urban,step_sim,Insert_data)
    if enable_pdop==1
        disp('URBAN SIMULATION VALUES:')
        for kk=1:length(urban)
            multi_urban(1,kk)=multipdop(Constellation,urban,kk);
        
        end

    
        Plot_Pdop(urban,Constellation,multi_urban,step_sim,Insert_data)
    end
    % Skyplot
    if enable_skyplot==1
        disp('Plotting urban skyplot...')
        Skyplot(Insert_data,step_sim,urban,Skyplot_time,Skyplot_Constellation,Constellation,skyplot_downsample)
    end
end
disp('Simulation completed')
disp('*******************************************************************')