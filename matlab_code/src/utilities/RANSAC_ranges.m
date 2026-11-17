function bestInliers = RANSAC_ranges( y, satPos, pos, nObs, cfg)
%**************************************************************************
%function varargout = RANSAC_ranges( varargin )
%
% Date: 30.10.2026
% DLR - Institute of Communications and Navigation
% Daniel Medina (daniel.ariasmedina@dlr.de)
%
% This function applies the Random Sample Consensus (RANSAC) algorithm to
% GNSS range measurements to identify consistent observations.
%
% INPUTS:
%   y         : nx1 vector of measured ranges [m]
%   satPos     : nx3 matrix of satellite positions [m]
%   R         : nxn measurement covariance matrix [m^2], default: eye(N)
%
%
%**************************************************************************

%% 1. Validate inputs

% Make sure measurement vector is a column
y = y(:);

R = cfg.noisemodel.std^2 * eye(nObs);

if ~isequal(size(satPos), [nObs,3])
    error('satPos must be an Nx3 matrix.');
end

if nObs < cfg.filters.cekf.minSubsetSize
    error('At least four satellite measurements are required.');
end

if ~isequal(size(R), [nObs,nObs])
    error('R must be an NxN covariance matrix.');
end

if any(~isfinite(R(:))) || ~isreal(R)
    error('R must contain finite, real values.');
end

if norm(R-R','fro') > 1e-10*max(1,norm(R,'fro'))
    error('R must be symmetric.');
end

if any(diag(R) <= 0)
    error('Diagonal elements of R must be positive.');
end

[~, cholFlag] = chol(R);

if cholFlag ~= 0
    error('R must be positive definite.');
end


%% Initialize RANSAC

% bestInliers = false(required_number_of_iterations,1);

% Determine all possible subsets and randomize their order
all_subsets = nchoosek( [1:1:nObs], cfg.filters.cekf.minSubsetSize );
total_subsets = size( all_subsets, 1 );
random_indexes = randi([1,total_subsets],total_subsets, 1 );
all_subsets_random = all_subsets( random_indexes, : );

% Determine what is the minimal number of iterations (subset evaluations)
% to find a outlier-free set of measurements. It depends on the probability
% confidence (P = 0.99 by default), on the prior probability for an
% measurement to be an outlier (cfg.filters.cekf.priorProbOutlier = 0.50 by default) and on the
% minimal sample needed to compute a solution
required_number_of_iterations = ceil( log( 1- cfg.filters.cekf.probConfidence)/log(1-(1-cfg.filters.cekf.priorProbOutlier)^cfg.filters.cekf.minSubsetSize) );

% Limit the minimum number of iterations to the user's selected maximum
% number
max_iterations_to_check = min( cfg.filters.cekf.maxIter, required_number_of_iterations );

% Initialize variables for inliers and cost (sum squared residuals)
inliers_subset = false( max_iterations_to_check, nObs );
cost_subset = nan( max_iterations_to_check, 1 );

for i_subset = 1:max_iterations_to_check


    %% 1. Randomly sample satellites

    current_subset = all_subsets_random(i_subset,:);
    y_subset   = y( current_subset );
    satPos_subset = satPos( current_subset,:);
    R_subset = R(current_subset,current_subset);

    %% 2. Estimate candidate solution
    [ position_subset, clk_subset, residuals_subset ]= MultiGNSS_Snapshot( y_subset, satPos_subset, 'subset', current_subset, 'initial_position', pos, 'r_matrix', R_subset );


    %% 4. Classify inliers and the cost (minimum residual of sum of squares)
    % Inliers based on normalized residuals
    inliers_subset(i_subset,current_subset) = abs( residuals_subset./sqrt(diag(R_subset)) ) < cfg.filters.cekf.inlierThreshold;
    % Find the cost function for the subset (RMSE)
    cost_subset(i_subset) = residuals_subset.' * inv(R_subset) * residuals_subset;

    

end

%% 5. Keep largest consensus set (with minimum RMSE in case of tie)
% Calculate the number of inliers for every iteration
inlier_counts = sum(inliers_subset, 2);

% Find indices corresponding to maximum inliers
candidate_indices = find(inlier_counts == max(inlier_counts));

% Locate the index within candidate_indices that minimizes cost
[min_cost, local_idx] = min(cost_subset(candidate_indices));
best_idx = candidate_indices(local_idx);
current_subset = all_subsets_random(best_idx,:);
y_subset   = y( current_subset );
satPos_subset = satPos( current_subset,:);
R_subset = R(current_subset,current_subset);


%% 6. Optional refinement with all inliers
if cfg.filters.cekf.ransacRefinement
    % Re-calculate the solution with the best inliers from the best subset
    current_subset = all_subsets_random(best_idx,:);
    y_subset   = y( current_subset );
    satPos_subset = satPos( current_subset,:);
    R_subset = R(current_subset,current_subset);
    [ position_refinement, clk_refinement, residuals_refinement ]= MultiGNSS_Snapshot( y_subset, satPos_subset, 'subset', current_subset, 'initial_position', pos, 'r_matrix', R_subset );
    % Find new inliers
    inliers_refinement = abs( residuals_refinement./sqrt(diag(R_subset)) ) < cfg.filters.cekf.inlierThreshold;
    % Return solution
    bestInliers = current_subset(inliers_refinement);
else
    % Return solution
    bestInliers = current_subset;
end


end
