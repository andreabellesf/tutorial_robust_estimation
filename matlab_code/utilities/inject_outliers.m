function [code_observations] = inject_outliers(cfg, code_observations, n_obs_per_epoch)

if cfg.outliers.add_outliers
    time_vec = 1:cfg.n_epochs;

    % Select affected measurements epochs inside the requested time window
    valid_epochs_outlier = false(size(time_vec));
    n_outlier_windows = length(cfg.outliers.init_time);
    for i=1:n_outlier_windows
        valid_epochs_outlier(cfg.outliers.init_time(i):cfg.outliers.end_time(i)) = 1;
    end
    n_epochs_outliers = sum(valid_epochs_outlier);
    n_outliers = round(cfg.outliers.fraction * n_obs_per_epoch);
    selected_idx = randperm(n_obs_per_epoch, n_outliers);

    % Outlier standard deviation:
    % sigma_outlier^2 = (alpha * sigma)^2
    var_code = cfg.noise.std_noise_code^2 * ones(n_obs_per_epoch); 
    var_outlier = cfg.outliers.alpha^2 .* var_code(selected_idx).';
    mu_outlier = cfg.outliers.mean .* ones(n_outliers, 1);

    switch lower(cfg.outliers.model)
        case "gaussian"
            noise_outlier = mu_outlier + var_outlier .* randn(n_outliers, n_epochs_outliers);

        case "student-t"
            % Student-t with nu > 2, scaled to variance sigma_outlier^2
            tNoise = trnd(nu, n_outliers, cfg.n_epochsOutliers);
            tNoise = tNoise ./ sqrt(nu / (nu - 2));
            noise_outlier = mu_outlier + var_outlier .* tNoise;

        otherwise
            error("Unsupported outlier noise model: %s", cfg.outliers.model);
    end

    code_observations(selected_idx, valid_epochs_outlier) = code_observations(selected_idx, valid_epochs_outlier) + noise_outlier;
end

end