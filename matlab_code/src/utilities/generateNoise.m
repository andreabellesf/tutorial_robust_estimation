function trial = generateNoise(scenario, cfg)
%==========================================================================
% FUNCTION: generateNoise
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
%   scenario
%   cfg
%
% OUTPUT:
%   noise           : generated noise vector [N_obs x 1]
%   SigmaTrue       : covariance matrix (with increased variance for outliers)
%   indicesOutlier  : indices of outlier samples
%
%==========================================================================

    %% Start from reference scenario
    trial.time = scenario.time;
    trial.gnss = scenario.gnss;
    n = scenario.gnss.nSatellites; % number of observations
    nEpochs = cfg.simulation.nEpochs; 
    sigma = cfg.noisemodel.std; % pseudorange std
    model = cfg.noisemodel.outliers.type;
    nOutIntervals = size(cfg.noisemodel.outliers.times, 1);
    idxEpochsOut = cfg.noisemodel.outliers.times;
    eps = cfg.noisemodel.outliers.epsilon;
    muOut = cfg.noisemodel.outliers.mu;
    alpha = cfg.noisemodel.outliers.alpha;

    if size(eps, 1) ~= nOutIntervals
        eps = repmat(eps, [nOutIntervals 1]);
    end

    if size(muOut, 1) ~= nOutIntervals
        muOut = repmat(muOut, [nOutIntervals 1]);
    end

    if size(alpha, 1) ~= nOutIntervals
        alpha = repmat(alpha, [nOutIntervals 1]);
    end

    %% Base Gaussian noise (nominal, mean 0)
   
    R = sigma^2 * eye(n);
    
    noise = mgd( nEpochs, n, zeros(1,n), R ).';

    if cfg.noisemodel.outliers.enabled

        %% Generate outlier noise samples
        for i = 1:nOutIntervals
            
            %%% Randomly select which samples are outliers
            nOut = round(n * eps(i));
            indicesOutlier = randperm(n, nOut);

            epochsOut = idxEpochsOut(i, 1):cfg.simulation.dt:idxEpochsOut(i, 2);
            nEpochsOut = numel(epochsOut);

            switch model
                case "gaussian"
                    outliers = muOut(i) + sqrt(alpha(i)) .* sigma .* randn(nOut, nEpochsOut);

                case "laplacian"
                    u = rand(nOut, nEpochsOut) - 0.5;
                    outliers = muOut(i) - sign(u) .* sqrt(alpha(i)/2) * sigma .* log(1 - 2*abs(u));

                case {"student-t", "student"}
                    dof = 2*sigma^2*alpha(i)/(sigma^2*alpha(i)-1);
                    if dof<=2
                        warning("Corresponding DOF value in the t distribution is lower than 2");
                    end
                    outliers = muOut(i) + trnd(dof, nOut, nEpochsOut);

                otherwise
                    error('Unknown outlier model: %s', model);
            end

            %%% Replace nominal samples by outliers

            noise(indicesOutlier, epochsOut) = outliers;

            trial.gnss.trueIndicesOutlier{i} = indicesOutlier;

        end

    end

    trial.gnss.pseudorange = scenario.gnss.idealPseudorange + noise;

    %% Store true measurement errors
    trial.gnss.truePseudorangeError = noise;
   
end