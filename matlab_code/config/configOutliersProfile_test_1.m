%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fault / Outliers Profile Configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.outliers.profile(1).type = 'clock_jump';
cfg.outliers.profile(1).startTime = 30;
cfg.outliers.profile(1).endTime = 35;
cfg.outliers.profile(1).seed = 1001;
cfg.outliers.profile(1).satelliteSelection.mode = 'random_sv_selected_cons';
cfg.outliers.profile(1).satelliteSelection.constellations = {'GAL'};
cfg.outliers.profile(1).satelliteSelection.nSat = 3;
cfg.outliers.profile(1).frequencies = 1;
cfg.outliers.profile(1).observation = 'code';
cfg.outliers.profile(1).clockJump = 10;
