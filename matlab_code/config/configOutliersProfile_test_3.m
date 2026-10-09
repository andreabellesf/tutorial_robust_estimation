%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fault / Outliers Profile Configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.outliers.profile(1).type = 'measurement_bias';
cfg.outliers.profile(1).startTime = 10;
cfg.outliers.profile(1).endTime = 15;
cfg.outliers.profile(1).seed = 1001;
cfg.outliers.profile(1).mode = 'random_sv_all_cons';
cfg.outliers.profile(1).nSat = 3;
cfg.outliers.profile(1).frequencies = 1;
cfg.outliers.profile(1).observation = 'code';
cfg.outliers.profile(1).magnitudeType = 'constant';
cfg.outliers.profile(1).magnitudeValue = 10;

cfg.outliers.profile(2).type = 'measurement_bias';
cfg.outliers.profile(2).startTime = 25;
cfg.outliers.profile(2).endTime = 30;
cfg.outliers.profile(2).seed = 1002;
cfg.outliers.profile(2).mode = 'random_sv_all_cons';
cfg.outliers.profile(2).nSat = 3;
cfg.outliers.profile(2).frequencies = 1;
cfg.outliers.profile(2).observation = 'code';
cfg.outliers.profile(2).magnitudeType = 'constant';
cfg.outliers.profile(2).magnitudeValue = 10;

cfg.outliers.profile(3).type = 'measurement_bias';
cfg.outliers.profile(3).startTime = 40;
cfg.outliers.profile(3).endTime = 45;
cfg.outliers.profile(3).seed = 1003;
cfg.outliers.profile(3).mode = 'random_sv_all_cons';
cfg.outliers.profile(3).nSat = 3;
cfg.outliers.profile(3).frequencies = 1;
cfg.outliers.profile(3).observation = 'code';
cfg.outliers.profile(3).magnitudeType = 'constant';
cfg.outliers.profile(3).magnitudeValue = 10;