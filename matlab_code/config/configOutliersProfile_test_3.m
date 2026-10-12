%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fault / Outliers Profile Configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.outliers.profile(1).type = 'measurement_bias';
cfg.outliers.profile(1).startTime = 10;
cfg.outliers.profile(1).endTime = 15;
cfg.outliers.profile(1).seed = 1001;
cfg.outliers.profile(1).satelliteSelection.mode = 'fraction';
cfg.outliers.profile(1).satelliteSelection.fraction = 0.2;
cfg.outliers.profile(1).frequencies = 1;
cfg.outliers.profile(1).observation = 'code';
cfg.outliers.profile(1).magnitudeType = 'constant';
cfg.outliers.profile(1).magnitudeValue = 10;

cfg.outliers.profile(2).type = 'noise';
cfg.outliers.profile(2).startTime = 25;
cfg.outliers.profile(2).endTime = 30;
cfg.outliers.profile(2).seed = 1002;
cfg.outliers.profile(2).satelliteSelection.mode = 'fraction';
cfg.outliers.profile(2).satelliteSelection.fraction = 0.2;
cfg.outliers.profile(2).frequencies = 1;
cfg.outliers.profile(2).observation = 'code';
cfg.outliers.profile(2).noise.model = 'gaussian';
cfg.outliers.profile(2).noise.scale = 10;
cfg.outliers.profile(2).noise.mean = 10;

cfg.outliers.profile(3).type = 'measurement_bias';
cfg.outliers.profile(3).startTime = 40;
cfg.outliers.profile(3).endTime = 45;
cfg.outliers.profile(3).seed = 1003;
cfg.outliers.profile(3).satelliteSelection.mode = 'random_sv_all_cons';
cfg.outliers.profile(3).satelliteSelection.nSat = 3;
cfg.outliers.profile(3).frequencies = 1;
cfg.outliers.profile(3).observation = 'code';
cfg.outliers.profile(3).magnitudeType = 'constant';
cfg.outliers.profile(3).magnitudeValue = 10;