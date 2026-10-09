%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fault / Outliers Profile Configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.outliers.profile(1).type = 'noise_scale';
cfg.outliers.profile(1).startTime = 10;
cfg.outliers.profile(1).endTime = 15;
cfg.outliers.profile(1).seed = 1001;
cfg.outliers.profile(1).mode = 'random_sv_selected_cons';
cfg.outliers.profile(1).constellations = {'GAL'};
cfg.outliers.profile(1).nSat = 3;
cfg.outliers.profile(1).frequencies = 1;
cfg.outliers.profile(1).observation = 'code';
cfg.outliers.profile(1).noiseScale = 10;

cfg.outliers.profile(2).type = 'measurement_bias';
cfg.outliers.profile(2).startTime = 20;
cfg.outliers.profile(2).endTime = 25;
cfg.outliers.profile(2).seed = 1002;
cfg.outliers.profile(2).mode = 'explicit';
cfg.outliers.profile(2).satIDs = [2 4 30 1];
cfg.outliers.profile(2).constellations = {'GPS','GAL'};
cfg.outliers.profile(2).frequencies = 1;
cfg.outliers.profile(2).observation = 'code';
cfg.outliers.profile(2).magnitudeType = 'gaussian';
cfg.outliers.profile(2).magnitudeMean = 10;
cfg.outliers.profile(2).magnitudeStd = 10;

cfg.outliers.profile(3).type = 'measurement_bias';
cfg.outliers.profile(3).startTime = 30;
cfg.outliers.profile(3).endTime = 35;
cfg.outliers.profile(3).seed = 1003;
cfg.outliers.profile(3).mode = 'random_sv_all_cons';
cfg.outliers.profile(3).nSat = 3;
cfg.outliers.profile(3).frequencies = 1;
cfg.outliers.profile(3).observation = 'code';
cfg.outliers.profile(3).magnitudeType = 'constant';
cfg.outliers.profile(3).magnitudeValue = 100;

cfg.outliers.profile(4).type = 'measurement_bias';
cfg.outliers.profile(4).startTime = 40;
cfg.outliers.profile(4).endTime = 45;
cfg.outliers.profile(4).seed = 1003;
cfg.outliers.profile(4).mode = 'random_sv_multi_constellation';
cfg.outliers.profile(4).constellations = {'GPS', 'GAL'};
cfg.outliers.profile(4).nSatPerConstellation = [2 1];
cfg.outliers.profile(4).frequencies = 1;
cfg.outliers.profile(4).observation = 'code';
cfg.outliers.profile(4).magnitudeType = 'constant';
cfg.outliers.profile(4).magnitudeValue = 100;
