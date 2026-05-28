function [code_observations] = inject_gnss_noise(cfg, code_observations, n_obs_per_epoch)

if cfg.noise.add_noise
    %%% Compute nominal noise for GNSS code and phase observations
    var_code = diag(cfg.noise.std_noise_code^2 * ones(1,n_obs_per_epoch));
    noise_code  = mgd( cfg.n_epochs, n_obs_per_epoch, zeros(1,n_obs_per_epoch), var_code ).';

    %%% Add noise
    code_observations  = code_observations  + noise_code;
end


end