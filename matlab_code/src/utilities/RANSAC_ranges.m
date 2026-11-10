function bestInliers = RANSAC_ranges( varargin )
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
%   svPos     : nx3 matrix of satellite positions [m]
%   R         : nxn measurement covariance matrix [m^2], default: eye(N)
%   GNSS_cons : assignation of measurements with 
%   threshold : Maximum absolute normalized residual
%               Default: 3.0 (three standard deviations)
%   maxIter   : Maximum number of RANSAC iterations
%               Default: 200
%
%
%**************************************************************************

%% 1. Check number of inputs and assign default values

% Default parameters
y = varargin{1}; y=y(:);
svPos = varargin{2};

nObs = length(y);
R_matrix = eye( nObs );
GNSS_type = nObs;
initial_position = [0;0;0];
max_iterations = 500;
probability_confidence = 0.99;
prior_probability_outlier = 0.5;
minimum_subset_size = 5;
inlier_threshold = 3;

% Handle input arguments
if nargin > 2
    y = varargin{1};
    svPos = varargin{2};
    for idx = 1:length(varargin)
        if ischar( varargin{idx} )
            switch lower(varargin{idx})
                case 'r_matrix'
                    R = varargin{idx+1};
                case 'gnss_type'
                    GNSS_type = varargin{idx+1};
                case 'initial_position'
                    initial_position = varargin{idx+1};
                case 'max_iterations'
                    max_iterations = varargin{idx+1};
                case 'probability_confidence'
                    probability_confidence = varargin{idx+1};
                case 'prior_probability_outlier'
                    prior_probability_outlier = varargin{idx+1};
                case 'minimum_subset_size'
                    minimum_subset_size = varargin{idx+1};
                case 'inlier_threshold'
                    inlier_threshold = varargin{idx+1};
                otherwise
                    error(['Unrecognized variable: ' varargin{idx}])
            end
        end
    end
elseif nargin<2
    error('Wrong number of inputss')
end


%% 2. Validate inputs

y = y(:);

if ~isequal(size(svPos), [nObs,3])
    error('svPos must be an Nx3 matrix.');
end

if required_number_of_iterations < 4
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

bestInliers = false(required_number_of_iterations,1);
bestCount = 0;

% Determine all possible subsets and randomize their order
all_subsets = nchoosek( [1:1:n_obs], minimum_subset_size );
total_subsets = size( all_subsets, 1 );
random_indexes = randi([1,total_subsets],total_subsets, 1 );
all_subsets_random = all_subsets( random_indexes, : );

% Determine what is the minimal number of iterations (subset evaluations)
% to find a outlier-free set of measurements. It depends on the probability
% confidence (P = 0.99 by default), on the prior probability for an
% measurement to be an outlier (varepsilon = 0.50 by default) and on the
% minimal sample needed to compute a solution
required_number_of_iterations = ceil( log( 1- probability_confidence)/log(1-(1-varepsilon)^minSample) );

% Limit the minimum number of iterations to the user's selected maximum
% number
max_iterations_to_check = min( max_iterations, required_number_of_iterations );

% Initialize variables for inliers and cost (sum squared residuals)
inliers_subset = false( max_iterations_to_check, n_obs );
cost_subset = nan( max_iterations_to_check, 1 );

for i_subset = 1:max_iterations_to_check


    %% 1. Randomly sample satellites

    current_subset = all_subsets_random(i_subset,:);
    y_subset   = y( current_subset );
    svPos_subset = svPos( current_subset,:);

    %% 2. Estimate candidate solution
    [ position_subset, clk_subset, residuals_subset ]= MultiGNSS_Snapshot( y_subset, satSubset, 'subset', current_subset, 'initial_position', initial_position, 'r_matrix', R_matrix );


    %% 4. Classify inliers and the cost (minimum residual of sum of squares)
    % Inliers based on normalized residuals
    inliers_subset(i_subset,:) = abs( residuals_subset./sqrt(diag(R_matrix)) ) < inlier_threshold;
    % Find the cost function for the subset (RMSE
    cost_subset(i_subset) = residuals_subset.' * inv(R_matrix) * residuals_subset;

    

end

%% 5. Keep largest consensus set (with minimum RMSE in case of tie)
% Calculate the number of inliers for every iteration
inlier_counts = sum(inliers_subset, 2);

% Find indices corresponding to maximum inliers
candidate_indices = find(inlier_counts == max(inlier_counts));

% Locate the index within candidate_indices that minimizes cost
[min_cost, local_idx] = min(cost_subset(candidate_indices));
best_idx = candidate_indices(local_idx);


%% 6. Optional refinement with all inliers
if ransac_refinement == 1
    % Re-calculate the solution with the best inliers from the best subset
    [ position_refinement, clk_refinement, residuals_refinement ]= MultiGNSS_Snapshot( y_subset, satSubset, 'subset', idx, 'initial_position', initial_position, 'r_matrix', R_matrix );
    % Find new inliers
    inliers_refinement = abs( residuals_refinement./sqrt(diag(R_matrix)) ) < inlier_threshold;
    % Return solution
    bestInliers = inliers_best;
else
    % Return solution
    bestInliers = best_idx;
end


end
