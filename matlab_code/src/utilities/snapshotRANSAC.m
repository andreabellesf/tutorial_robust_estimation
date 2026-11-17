function [bestInliers, info] = snapshotRANSAC( ...
    y, satPos, clkMatrix, xPred, PPred, sppState, cfg)
% SNAPSHOT RANSAC
% Outlier detection for GNSS pseudorange measurements based on 
% Snapshot RANSAC (subset-based consensus estimation)
%
% REFERENCES:
%   'prediction': predicted EKF state
%   'spp'       : standalone GNSS SPP solution
%
% INPUTS:
% y        : N x 1 pseudorange vector [m]
% satPos   : N x 3 satellite positions [m]
% clkMatrix : N x nCons clk matrix 
% xPred    : predicted EKF state
% PPred    : predicted EKF covariance
% sppState : struct with:
%            .x     : SPP position/clock parameters
%            .P     : optional covariance of .x
% cfg      : configuration structure
%
% OUTPUTS:
% bestInliers : indices of accepted observations
% info        : diagnostic structure

    nCons = cfg.simulation.nCons;
    [idxState, nx] = stateIndex(nCons);

    y = y(:);
    nObs = numel(y);

    if ~isequal(size(satPos), [nObs,3])
        error('satPos must have dimensions N x 3.');
    end

    c = cfg.filters.cekf;

    % Nominal measurement covariance
    if isfield(cfg.noisemodel, 'R')
        R = cfg.noisemodel.R;
    else
        sigma = cfg.noisemodel.std;
        if isscalar(sigma)
            R = sigma^2 * eye(nObs);
        else
            sigma = sigma(:);
            R = diag(sigma.^2);
        end
    end

    if ~isequal(size(R), [nObs,nObs])
        error('Invalid measurement covariance dimensions.');
    end

    R = (R + R')/2;

    if any(~isfinite(R(:))) || any(~isfinite(y)) || ...
            any(~isfinite(satPos(:)))
        error('Nonfinite input data.');
    end

    [~, flag] = chol(R);
    if flag ~= 0
        error('Measurement covariance must be positive definite.');
    end
    reference = lower(char(c.reference));
    threshold = c.inlierThreshold;

    if ~isscalar(threshold) || threshold <= 0
        error('Invalid inlier threshold.');
    end

    % Initialize diagnostics
    info = struct();
    info.reference = reference;
    info.nObs = nObs;
    info.residuals = nan(nObs,1);
    info.normalizedResiduals = nan(nObs,1);
    info.inlierMask = false(nObs,1);
    info.nInliers = 0;
    info.bestx = [];
    info.bestCost = Inf;
    info.nIterations = 0;
    info.success = false;

    xCand = zeros(nx, 1);
    xRef = zeros(nx, 1);

    % Reference state
    switch reference
        case 'prediction'
            x0 = xPred;

        case 'spp'
            if isempty(sppState) || ...
                    ~isfield(sppState,'x')
                error('SPP reference state is required.');
            end
            x0 = sppState.x;

        otherwise
            error('Unknown reference: %s',reference);
    end

    x0 = x0(:);

    %% Snapshot RANSAC

    m = c.minSubsetSize;

    if nObs < m
        error('Insufficient observations for RANSAC.');
    end

    p = c.probConfidence;
    epsOut = c.priorProbOutlier;

    if p <= 0 || p >= 1 || ...
            epsOut < 0 || epsOut >= 1
        error('Invalid RANSAC probability parameters.');
    end

    % Iteration count
    probClean = (1-epsOut)^m;

    if probClean >= 1
        nIter = 1;
    else
        nIter = ceil(log1p(-p)/log1p(-probClean));
    end

    nIter = min(nIter,c.maxIter);

    bestCount = 0;
    bestCost = Inf;
    bestMask = false(nObs,1);
    bestx = [];
    bestResiduals = nan(nObs,1);
    bestZ = nan(nObs,1);

    % Nominal measurement standard deviations
    sigma = sqrt(diag(R));

    % Optional prior consistency check
    usePrior = false;

    if isfield(c,'usePriorCheck')
        usePrior = logical(c.usePriorCheck);
    end

    if usePrior
        if ~isfield(model,'priorCovP')
            error('priorCovP adapter required.');
        end

        priorx = xPred;
        priorx = priorx(:);
        priorCov = PPred;
        priorCov = (priorCov + priorCov')/2;

        if ~isequal(size(priorCov), ...
                [numel(priorx),numel(priorx)])
            error('Invalid prior covariance dimensions.');
        end
    end

    for k = 1:nIter

        % 1. Draw minimal subset
        idx = randperm(nObs,m);

        ySubset = y(idx);
        satPosSubset = satPos(idx,:);
        clkMatrixSubset = clkMatrix(idx,:);
        RSubset = R(idx,idx);

        % 2. Estimate candidate snapshot solution
        % try
            [posCand, clkCand, ~, ~, ~, ~] = MultiGNSS_Snapshot( ...
                ySubset, satPosSubset, clkMatrixSubset, ...
                'obsCovR', RSubset, ...
                'initPosition', x0(idxState.pos), ...
                'initClockOffset', x0(idxState.clk));
            xCand(idxState.pos) = posCand;
            xCand(idxState.clk) = clkCand;
            xCand = xCand(:);

            if numel(xCand) ~= numel(x0) || ...
                    any(~isfinite(xCand))
                continue;
            end

            % 3. Optional EKF prior consistency check
            if usePrior
                d = xCand - priorx;

                if rcond(priorCov) < 1e-12
                    continue;
                end

                d2 = d'*(priorCov\d);

                if d2 > c.priorThreshold
                    continue;
                end
            end

            % 4. Predict ALL observations
            [yHat,~,~] = observationModel(xCand, satPos, nObs, ...
                clkMatrix, cfg);
            yHat = yHat(:);

            if numel(yHat) ~= nObs || ...
                    any(~isfinite(yHat))
                continue;
            end

            % 5. Consensus over ALL observations
            residuals = y - yHat;
            z = residuals ./ sigma;
            mask = abs(z) < threshold;

            count = nnz(mask);

            % 6. Tie-breaking using inlier cost
            cost = sum(z(mask).^2);

            if count > bestCount || ...
                    (count == bestCount && cost < bestCost)

                bestCount = count;
                bestCost = cost;
                bestMask = mask;
                bestx = xCand;
                bestResiduals = residuals;
                bestZ = z;
            end

        % catch
        %     % Skip failed candidate solutions
        %     continue;
        % end
    end

    % 7. Optional local optimization / refinement
    if c.ransacRefinement && bestCount >= m

        maxRefine = c.maxRefinementIter;

        for j = 1:maxRefine

            idx = find(bestMask);

            yRef = y(idx);
            satPosRef = satPos(idx,:);
            clkMatrixRef = clkMatrix(idx,:);
            RRef = R(idx,idx);

            try
                [posRef, clkRef, ~, ~, ~, ~] = MultiGNSS_Snapshot( ...
                    yRef, satPosRef, clkMatrixRef, ...
                    'obsCovR', RRef, ...
                    'initPosition', bestx(idxState.pos), ...
                    'initClockOffset', bestx(idxState.clk));
                xRef(idxState.pos) = posRef;
                xRef(idxState.clk) = clkRef;
                xRef = xRef(:);

                [yHat,~,~] = observationModel(xRef, satPos, nObs, ...
                    clkMatrix, cfg);
                yHat = yHat(:);

                if any(~isfinite(yHat))
                    break;
                end

                residuals = y - yHat;
                z = residuals ./ sigma;
                mask = abs(z) < threshold;

                count = nnz(mask);
                cost = sum(z(mask).^2);

                % Keep refinement only if it improves
                % consensus score
                improved = count > bestCount || ...
                    (count == bestCount && cost < bestCost);

                if ~improved
                    break;
                end

                bestCount = count;
                bestCost = cost;
                bestMask = mask;
                bestx = xRef;
                bestResiduals = residuals;
                bestZ = z;

            catch
                break;
            end
        end
    end

    bestInliers = find(bestMask);

    info.residuals = bestResiduals;
    info.normalizedResiduals = bestZ;
    info.inlierMask = bestMask;
    info.nInliers = bestCount;
    info.bestx = bestx;
    info.bestCost = bestCost;
    info.nIterations = nIter;
    info.success = bestCount >= m;


    info.outlierIndices = find(~info.inlierMask);

end
