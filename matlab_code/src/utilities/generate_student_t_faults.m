function [faults, faultVariance] = generate_student_t_faults(nSamples, sigma, kappa, muOut, dof)
%GENERATE_STUDENT_T_FAULTS Generate Student-t faults without toolboxes.
%
%   [faults, faultVariance] = generate_student_t_faults( ...
%       nSamples, sigma, kappa, muOut, dof)
%
% Inputs:
%   nSamples  - Number of fault samples to generate (nonnegative integer)
%   sigma     - Nominal standard deviation (nonnegative scalar)
%   kappa     - Outlier variance inflation factor (positive scalar)
%   muOut     - Mean of the fault distribution (finite scalar)
%   dof       - Degrees of freedom (integer greater than 2)
%
% Outputs:
%   faults        - [nSamples x 1] Student-t-distributed fault samples
%   faultVariance - Theoretical variance of the faults: kappa * sigma^2
%
% The Student-t random variable is constructed as Z / sqrt(V / dof),
% with Z ~ N(0,1) and V ~ chi-square(dof). For INTEGER dof, V is a sum
% of squares of independent standard normal random variables.
% Scaling gives the requested mean muOut and variance kappa*sigma^2.
%
% Uses only core MATLAB functions (randn, sum, sqrt).

    validateattributes(nSamples, {'numeric'}, ...
        {'scalar', 'integer', 'nonnegative', 'finite'}, mfilename, 'nSamples', 1);
    validateattributes(sigma, {'numeric'}, ...
        {'scalar', 'real', 'nonnegative', 'finite'}, mfilename, 'sigma', 2);
    validateattributes(kappa, {'numeric'}, ...
        {'scalar', 'real', 'positive', 'finite'}, mfilename, 'kappa', 3);
    validateattributes(muOut, {'numeric'}, ...
        {'scalar', 'real', 'finite'}, mfilename, 'muOut', 4);
    validateattributes(dof, {'numeric'}, ...
        {'scalar', 'integer', 'real', 'finite', '>', 2}, mfilename, 'dof', 5);

    faultVariance = kappa * sigma^2;

    Z = randn(nSamples, 1);
    V = sum(randn(nSamples, dof).^2, 2);
    T = Z ./ sqrt(V / dof);

    scale = sqrt(faultVariance * (dof - 2) / dof);
    faults = muOut + scale .* T;
end
