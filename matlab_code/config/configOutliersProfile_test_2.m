%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fault / Outliers Profile Configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.outliers.profile(2).type = 'ephemeris_error';
cfg.outliers.profile(2).startTime = 20;
cfg.outliers.profile(2).endTime = 25;
cfg.outliers.profile(2).seed = 1002;
cfg.outliers.profile(2).mode = 'explicit';
cfg.outliers.profile(2).satIDs = [2 4 30];
cfg.outliers.profile(2).constellations = {'GPS'};
cfg.outliers.profile(2).frequencies = 1;
cfg.outliers.profile(2).observation = 'code';
cfg.outliers.profile(2).ephemerisError = [10 10 5];
