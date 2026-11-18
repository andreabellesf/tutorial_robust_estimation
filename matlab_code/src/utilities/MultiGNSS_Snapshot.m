function [pos, clkOffset, residuals, P, G, reliable] = ...
    MultiGNSS_Snapshot( ...
    pseudorange, satPos, clockMatrix, varargin)
%MULTIGNSS_SNAPSHOT Weighted least-squares GNSS positioning.
%
% [pos, clkOffset, residuals, P, G, reliable] = ...
%     MultiGNSS_Snapshot_refactored(pseudorange, satPos, clockMatrix, ...)
%
% Required inputs (full observation set, before subsetting):
%   pseudorange  - N-by-1 corrected pseudoranges, in metres.
%   satPos  - N-by-3 satellite ECEF positions, in metres.
%   clockMatrix  - N-by-K clock indicator/design matrix. Examples:
%                  ones(N,1) for a shared receiver clock;
%                  [ones(nGPS,1),zeros(nGPS,1);
%                   zeros(nGAL,1),ones(nGAL,1)] for separate clocks.
%
% Name-value options:
%   'subset'           - Selected observation indices or N-element logical
%                        mask. [] (default) means all observations.
%   'obsCovR'   - N-by-N covariance for the full observations, or
%                        M-by-M covariance already restricted to subset.
%                        Default: identity covariance.
%   'initPosition' - Initial ECEF position, 3-by-1 (default [0;0;0]).
%   'initClockOffset' - Initial receiver clock offset, nCons-by-1 (default [0;0]).
%   'maxIter'   - Maximum WLS iterations (default 100).
%   'errorTol'  - Position-update convergence tolerance, m (1e-6).
%   'conditionCheck'  - Maximum condition number of weighted G (1000).
%
% Outputs correspond to selected observations:
%   pos   - 3-by-1 estimated ECEF receiver position, metres.
%   clkOffset  - K-by-1 receiver clock biases, in metres (divide by c for s).
%   residuals  - M-by-1 post-fit pseudorange residuals, metres.
%   P          - (3+K)-by-(3+K) formal state covariance.
%   G          - M-by-(3+K) final design matrix.
%   reliable   - True if solution is valid and converged.
%
% The clock columns must have full column rank among selected observations.

    pseudorange = pseudorange(:);
    nSat = numel(pseudorange);
    nCons = size(clockMatrix,2);
    validateattributes(satPos, {'numeric'}, {'real','finite','size',[nSat,3]}, mfilename, 'satPos');
    validateattributes(clockMatrix, {'numeric','logical'}, {'real','finite','2d'}, mfilename, 'clockMatrix');
    if size(clockMatrix,1) ~= nSat || size(clockMatrix,2) < 1
        error('clockMatrix must have N rows and at least one clock column.');
    end
    validateattributes(pseudorange, {'numeric'}, {'real','finite'}, mfilename, 'pseudorange');

    parser = inputParser;
    parser.FunctionName = mfilename;
    addParameter(parser, 'subset', [], @(x) isnumeric(x) || islogical(x));
    addParameter(parser, 'obsCovR', [], @(x) isnumeric(x) && ismatrix(x));
    addParameter(parser, 'initPosition', [0;0;0], @(x) isnumeric(x) && isreal(x) && numel(x)==3 && all(isfinite(x(:))));
    addParameter(parser, 'initClockOffset', zeros(nCons,1), @(x) isnumeric(x) && isreal(x) && numel(x)==nCons && all(isfinite(x(:))));
    addParameter(parser, 'maxIter', 100, @(x) isnumeric(x) && isscalar(x) && isfinite(x) && x>=1 && x==floor(x));
    addParameter(parser, 'errorTol', 1e-6, @(x) isnumeric(x) && isscalar(x) && isfinite(x) && x>0);
    addParameter(parser, 'conditionCheck', 1000, @(x) isnumeric(x) && isscalar(x) && isfinite(x) && x>0);
    parse(parser, varargin{:});
    opts = parser.Results;

    % Resolve subset once, then apply it consistently to all observation data.
    subset = opts.subset;
    if isempty(subset)
        subset = (1:nSat).';
    elseif islogical(subset)
        if numel(subset) ~= nSat
            error('Logical subset must have N elements.');
        end
        subset = find(subset(:));
    else
        subset = subset(:);
        if any(~isfinite(subset) | subset~=floor(subset) | subset<1 | subset>nSat) || numel(unique(subset))~=numel(subset)
            error('subset must contain unique integer indices between 1 and N.');
        end
    end

    yObs = pseudorange(subset);
    sv = satPos(subset,:);
    C = double(clockMatrix(subset,:));
    m = numel(subset);
    nClock = size(C,2);
    nState = 3 + nClock;

    R = opts.obsCovR;
    if isempty(R)
        R = eye(m);
    elseif isequal(size(R), [nSat,nSat])
        R = R(subset,subset);
    elseif ~isequal(size(R), [m,m])
        error('obsCovR must be N-by-N or M-by-M, where M=numel(subset).');
    end
    if ~isreal(R) || any(~isfinite(R(:))) || ~isequal(R,R.')
        error('Observation covariance must be real, finite and symmetric.');
    end
    [L,cholFlag] = chol(R,'lower');
    if cholFlag ~= 0
        error('Observation covariance must be positive definite.');
    end

    pos = opts.initPosition(:);
    % clkOffset = zeros(nClock,1);
    clkOffset = opts.initClockOffset(:);
    G = NaN(m,nState);
    residuals = NaN(m,1);
    P = NaN(nState,nState);
    reliable = false;

    if m < nState || rank(C) < nClock
        warning('Insufficient observations or missing constellation clock observability.');
        pos(:) = NaN;
        clkOffset(:) = NaN;
        return;
    end

    for iteration = 1:opts.maxIter
        delta = pos.' - sv;              % M-by-3 receiver-minus-SV vectors
        distance = sqrt(sum(delta.^2,2));     % M-by-1 geometric ranges
        if any(distance <= 0)
            warning('Receiver position coincides with a satellite position.');
            break;
        end
        G = [delta ./ distance, C];
        earthRotationCorr = sv(:, 1:2)*[pos(2); -pos(1)] * 2.432387790989725e-13;
        innovation = yObs - distance - C*clkOffset - earthRotationCorr;

        % Whitened WLS: minimizes ||L\(G*step - innovation)||^2.
        A = L\G;
        b = L\innovation;
        if rank(A) < nState || cond(A) >= opts.conditionCheck
            warning('GNSS geometry is rank deficient or poorly conditioned.');
            break;
        end
        step = A\b;
        % step = (G'*G)\G'*innovation;
        pos = pos + step(1:3);
        clkOffset = clkOffset + step(4:end);

        if norm(step(1:3)) <= opts.errorTol
            % Recompute G and residuals at the final estimated state.
            delta = pos.' - sv;
            distance = sqrt(sum(delta.^2,2));
            if any(distance <= 0), break; end
            G = [delta ./ distance, C];
            A = L\G;
            if rank(A) < nState || cond(A) >= opts.conditionCheck
                break;
            end
            earthRotationCorr = sv(:, 1:2)*[pos(2); -pos(1)] * 2.432387790989725e-13;
            residuals = yObs - distance - C*clkOffset - earthRotationCorr;
            P = (A.'*A)\eye(nState);
            reliable = true;
            return;
        end
    end

    % A nonconverged/invalid solution is explicitly marked as unusable.
    pos(:) = NaN;
    clkOffset(:) = NaN;
    G(:) = NaN;
    warning('GNSS WLS solution did not converge to a reliable solution.');
end
