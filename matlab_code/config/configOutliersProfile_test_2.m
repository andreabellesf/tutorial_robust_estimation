%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fault / Outliers Profile Configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.outliers.profile(1).type = 'ephemeris_error';
cfg.outliers.profile(1).startTime = 20;
cfg.outliers.profile(1).endTime = 25;
cfg.outliers.profile(1).seed = 1002;
cfg.outliers.profile(1).satelliteSelection.mode = 'explicit';
cfg.outliers.profile(1).satelliteSelection.satIDs = [2 4 30];
cfg.outliers.profile(1).satelliteSelection.constellations = {'GPS'};
cfg.outliers.profile(1).frequencies = 1;
cfg.outliers.profile(1).observation = 'code';
cfg.outliers.profile(1).ephemerisError = [10 10 5];
