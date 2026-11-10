function [noise, SigmaTrue, indicesOutlier] = generate_noise(config)
%==========================================================================
% FUNCTION: generate_noise
%--------------------------------------------------------------------------
% PURPOSE:
%   Generates noise according to a contaminated model:
%
%       n_i ~ (1 - ε) * N(0, σ²) + ε * RES_outlier(μ, κ(σ)²)
%
%   where the outlier component RES_outlier can be Gaussian, Laplacian,
%   or Student-t, according to config.noise.model.
%
% INPUT (from config):
%   config.N_obs          : number of observations
%   config.noise.std      : σ, standard deviation of nominal Gaussian noise
%   config.noise.epsilon  : ε, contamination ratio (fraction of outliers)
%   config.noise.kappa    : κ, variance inflation factor for outliers
%   config.noise.model    : outlier model ("gaussian", "laplacian", "student-t")
%   config.noise.dof      : degrees of freedom (for Student-t)
%   config.noise.scale    : scale parameter (used in Laplacian/Student-t)
%   config.noise.mu       : mean of the outlier distribution
%
% OUTPUT:
%   noise           : generated noise vector [N_obs x 1]
%   SigmaTrue       : covariance matrix (with increased variance for outliers)
%   indicesOutlier  : indices of outlier samples
%
% AUTHORS:  -
% DATE:     29/10/2025
% PROJECT:  SANITS (DLR-TéSA)
%==========================================================================

    %----------------------------------------------------------------------
    % Load parameters
    %----------------------------------------------------------------------
    n       = config.N_obs;
    sigma   = config.noise.std;
    eps     = config.noise.fractionOutlier;
    kappa   = config.noise.kappa;
    model   = lower(config.noise.model);
    mu_out  = config.noise.mu;

    %----------------------------------------------------------------------
    % Base Gaussian noise (nominal, mean 0)
    %----------------------------------------------------------------------
    noise = sigma * randn(n, 1);

    %----------------------------------------------------------------------
    % Randomly select which samples are outliers
    %----------------------------------------------------------------------
    nOut = round(n * eps);
    indicesOutlier = randperm(n, nOut);

    %----------------------------------------------------------------------
    % Generate outlier noise samples
    %----------------------------------------------------------------------
    switch model
        case "gaussian"
            outliers = mu_out + sqrt(kappa) * sigma * randn(nOut, 1);

        case "laplacian"
            u = rand(nOut, 1) - 0.5;
            outliers = mu_out - sign(u) .* sqrt(kappa/2) * sigma .* log(1 - 2*abs(u));

        case {"student-t", "student"}
            dof = 2*sigma^2*kappa/(sigma^2*kappa-1);
            if dof<=2
                warning("Corresponding DOF value in the t distribution is lower than 2");
            end
            outliers = mu_out + trnd(dof, nOut, 1);

        otherwise
            error('Unknown outlier model: %s', model);
    end

    %----------------------------------------------------------------------
    % Replace nominal samples by outliers
    %----------------------------------------------------------------------
    noise(indicesOutlier) = outliers;

    %----------------------------------------------------------------------
    % Build covariance matrix (diagonal, indicating local variances)
    %----------------------------------------------------------------------
    SigmaTrue = sigma^2 * eye(n);
    SigmaTrue(sub2ind([n n], indicesOutlier, indicesOutlier)) = kappa * (sigma)^2;

end