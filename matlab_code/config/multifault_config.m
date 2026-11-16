function cfg = multifault_config()
% Nominal scenario + injected outliers.
cfg = nominal_scenario_config();

cfg.outliers.enabled         = true;
cfg.outliers.profileFilename = "configOutliersProfile_test_0";
end