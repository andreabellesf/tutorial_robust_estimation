function [trialFaulty,outlierLog] = injectOutliers(...
    trial,outlierProfiles,cfg)
%INJECTOUTLIERS Inject configurable outliers / faults into simulated GNSS data.
%
% Supported outlier types:
% outlier.type:
%   'measurement_bias' (Generic additive measurement bias)
%   'clock_jump' (Receiver/satellite clock-like jump)
%   'ephemeris_error' (Ephemeris position error)
%   'noise_scale' (Observation-noise scaling)
%
% Supported observation selections:
%   'code'
%   'none'          mainly for ephemeris outliers
%
%
% outlier.magnitude:
%   struct describing how the outlier evolves in time
%
% Supported type:
%   'constant' (step)
%   'ramp'
%   'gaussian'
%   'random_walk'
%
% outlier.selection:
%   struct describing how satellites are selected
%
% Supported satelliteSelection.mode:
%   'fraction'
%       --> Use fraction of outlier from all satellites from all enabled constellations
%   'explicit' 
%       --> Use outlier.satIDs
%   'all'
%       --> Use all satellites from all enabled constellations
%   'random_sv_all_cons' 
%       --> Randomly choose outlier.nSat satellites from all enabled satellites
%   'random_sv_selected_cons' 
%       --> Randomly choose outlier.nSat satellites from outlier.constellations
%   'random_sv_multi_constellation'
%       --> Randomly choose outlier.nSatPerConstellation(i) from each
%       outlier.constellations enabled
%
% outlier.seed:
%   optional independent RNG seed for this profile.
%
%
% Units:
%   step/ramp magnitude     : metres for code
%   clockJump               : metres
%   ephemerisError          : [dX dY dZ] metres
%   noiseScale              : multiplier on nominal observation STD
%
% Multiple/overlapping outliers are supported automatically.
%
% -------------------------------------------------------------------------
% Measurement organization expected:
%   trial.gnss.pseudorange:             nSat x nEpochs (x nFreq == 1)
%   trial.gnss.satellitePosition:       3 x nSat
%
% NOTES: 
%        - For satellite ephemeris errors, the function changes the 
%           satellite coordinates used by the receiver. That's preferable to 
%           simply adding an arbitrary pseudorange bias if your objective is 
%           specifically to test an ephemeris outlier, because the resulting 
%           measurement inconsistency then depends on line-of-sight geometry.
% 	     - For a receiver clock jump, the outlier should affect all 
%           observations and all satellites --> an explicit mode for this is 
%           recommended rather than using random selection such that 'selectionMode','all'. 
%           A satellite clock outlier would instead use explicit for one or more satellites. 

    obs = trial.gnss.pseudorange;
    [nSat,nEpoch,nFreq] = size(obs);

    assert(cfg.simulation.nFreq == nFreq,'cfg.simulation.nFreq disagrees with pseudorange dimensions.');
    assert(isscalar(cfg.simulation.dt) && cfg.simulation.dt>0,'dt must be positive.');

    timeSec = (0:nEpoch-1).' * cfg.simulation.dt;

    trialFaulty = trial;
       
    % % Build global constellation mask
    % constellationMap = buildConstellationMap( ...
    %     scenario.gnss,nSat,cfg);

    % Outlier log
    outlierLog = struct( ...
        'profileIndex',{}, ...
        'type',{}, ...
        'seed',{}, ...
        'startTime',{}, ...
        'endTime',{}, ...
        'epochs',{}, ...
        'timeSec',{}, ...
        'selectionMode',{}, ...
        'requestedSatellites',{}, ...
        'selectedSatellites',{}, ...
        'selectedConstellations',{}, ...
        'fraction',{}, ...
        'frequencies',{}, ...
        'observation',{}, ...
        'mode',{}, ...
        'magnitudeRealization',{}, ...
        'profile',{});

    % Apply every outlier profile
    for iOutlier = 1:numel(outlierProfiles)

        outlier = applyOutlierDefault(outlierProfiles(iOutlier));

        assert(isscalar(outlier.startTime) && isscalar(outlier.endTime) && ...
            outlier.startTime<=outlier.endTime, ...
        'Invalid startTime/endTime in profile %d.',iOutlier);

        % Independent RNG stream for this profile
        oldRng = rng;

        if ~isempty(outlier.seed)
            rng(outlier.seed,'twister');
        end

        cleanupObj = onCleanup(@() rng(oldRng));

        % Time selection
        epochMask = ...
            timeSec >= outlier.startTime & ...
            timeSec <= outlier.endTime;

        epochIdx = find(epochMask);

        if isempty(epochIdx)
            warning('Outlier %d has no epochs inside simulation.',iOutlier);
            clear cleanupObj
            continue;
        end

        outlierTime = timeSec(epochIdx);

        % Satellite selection
        [satIdx,selectionInfo] = selectAffectedSatellites( ...
            outlier,iOutlier,nSat,trial.gnss,outlierLog);

        if isempty(satIdx)
            warning('Outlier %d: no satellites selected.',iOutlier);
            clear cleanupObj
            continue;
        end

        % Frequency selection
        freqIdx = selectOutlierFrequencies(outlier,nFreq);


        % Apply outlier
        switch lower(outlier.type)

            % =====================================================
            % ADDITIVE MEASUREMENT BIAS
            % =====================================================
            case {'measurement_bias','bias'}

                % Generate magnitude realization
                magnitude = generateOutlierMagnitude( ...
                    outlier,outlierTime,iOutlier);

                trialFaulty.gnss.pseudorange = addObservationBias( ...
                    trialFaulty.gnss.pseudorange,epochIdx,satIdx,freqIdx,...
                    outlier.observation,magnitude);

            % =====================================================
            % RECEIVER/SATELLITE CLOCK-LIKE JUMP
            % =====================================================
            case {'clock_jump','clockjump'}

                % Here the clock jump is injected directly into
                % observations in metres.
                %
                % For receiver-clock jump:
                % usually select many/all satellites.
                %
                % For satellite-clock jump:
                % select individual satellites.

                for k = epochIdx(:).'

                    trialFaulty.gnss.pseudorange = addObservationBias( ...
                        trialFaulty.gnss.pseudorange,k,satIdx,freqIdx, ...
                        outlier.observation, ...
                        outlier.clockJump);
                end


            % =====================================================
            % EPHEMERIS POSITION ERROR
            % =====================================================
            case {'ephemeris_error','ephemeris'}

                ephError = outlier.ephemerisError(:);

                if numel(ephError) ~= 3
                    error(['ephemerisError must be ', ...
                           '[dX dY dZ] in metres.']);
                end

                trialFaulty.gnss.satellitePosition.ENU(1:3, satIdx) = ...
                    trialFaulty.gnss.satellitePosition.ENU(1:3, satIdx) + ephError(1:3);

            % =====================================================
            % MEASUREMENT NOISE INFLATION
            % =====================================================
            case {'noise_scale','noise','variance_scale'}

                [trialFaulty.gnss.pseudorange, satIdx] = injectAdditionalNoise( ...
                    trialFaulty.gnss.idealPseudorange,trialFaulty.gnss.pseudorange,epochIdx,nSat,freqIdx, ...
                    outlier,cfg);

            otherwise

                error('Unsupported GNSS outlier type: %s',outlier.type);
        end

        % ================================================================
        % Store realized selection and magnitude
        % ================================================================
        j = numel(outlierLog)+1;

        outlierLog(j).profileIndex = iOutlier;
        outlierLog(j).type = outlier.type;
        outlierLog(j).seed = outlier.seed;

        outlierLog(j).startTime = outlier.startTime;
        outlierLog(j).endTime   = outlier.endTime;

        outlierLog(j).epochs  = epochIdx(:).';
        outlierLog(j).timeSec = outlierTime(:).';

        outlierLog(j).selectionMode = ...
            outlier.satelliteSelection.mode;

        if strcmp(outlier.satelliteSelection.mode, 'fraction')
            outlierLog(j).fraction = ...
            outlier.satelliteSelection.fraction;
        end

        outlierLog(j).requestedSatellites = ...
            selectionInfo.requestedSatellites;

        outlierLog(j).selectedSatellites = ...
            satIdx(:).';

        outlierLog(j).selectedConstellations = ...
            selectionInfo.selectedConstellations;

        outlierLog(j).frequencies = freqIdx(:).';

        outlierLog(j).observation = outlier.observation;

        outlierLog(j).magnitudeType = ...
            outlier.magnitudeType;

        outlierLog(j).magnitudeValue = outlier.magnitudeValue;

        outlierLog(j).profile = outlier;

        % Restore outer MC RNG state immediately.
        clear cleanupObj
    end
end


% ========================================================================
function outlier = applyOutlierDefault(outlier)

    % -------------------------------------------------------------
    % Top-level default
    % -------------------------------------------------------------
    default.type = 'measurement_bias';
    default.startTime = 0;
    default.endTime   = inf;
    default.seed = [];
    default.frequencies = 1;
    default.observation = 'code';

    % -------------------------------------------------------------
    % Satellite-selection default
    % -------------------------------------------------------------
    selectionDefaults = struct( ...
    'mode', 'fraction', ...
    'fraction', 0.2, ...
    'satIDs', [], ...
    'constellations', {{'GPS'}}, ...
    'nSat', 1, ...
    'nSatPerConstellation', []);

    if ~isfield(outlier, 'satelliteSelection') || ...
            ~isstruct(outlier.satelliteSelection)
        outlier.satelliteSelection = struct();
    end

    fields = fieldnames(selectionDefaults);

    for i = 1:numel(fields)
        name = fields{i};

        if ~isfield(outlier.satelliteSelection, name) || ...
                isempty(outlier.satelliteSelection.(name))
            outlier.satelliteSelection.(name) = ...
                selectionDefaults.(name);
        end
    end

    % -------------------------------------------------------------
    % Magnitude-model default
    % -------------------------------------------------------------
    default.magnitudeType = 'constant';
    default.magnitudeValue = 0;
    default.magnitudeInitialValue = 0;
    default.magnitudeSlope = 0;
    default.magnitudeMean = 0;
    default.magnitudeStd = 1;
    default.magnitudeSigma = 1;
    default.magnitudeDirection = [1 0 0]; % Optional vector direction for ephemeris outlier
    default.magnitudeDoF = 5;

    % -------------------------------------------------------------
    % Merge default
    % -------------------------------------------------------------
    namesDefault = fieldnames(default);
    for i = 1:numel(namesDefault)
        nameDefault = namesDefault{i};
        if ~isfield(outlier,nameDefault) || isempty(outlier.(nameDefault))
            outlier.(nameDefault) = default.(nameDefault);
        end
    end
   
end

% ========================================================================
function [affectedSatIdx,info] = selectAffectedSatellites( ...
    outlier,iOutlier,nSat,gnssData,outlierLog)

    satIDs = gnssData.satelliteId;
    satIdx = gnssData.satelliteIdx;
    mode = lower(outlier.satelliteSelection.mode);

    info = struct();

    info.requestedSatellites = [];
    info.selectedConstellations = {};

    switch mode

        % ---------------------------------------------------------
        case 'fraction'
            candidates = 1:nSat;
            nCandidates = numel(candidates);

            fractionOutliers = outlier.satelliteSelection.fraction;
            assert(isscalar(fractionOutliers) && isfinite(fractionOutliers) && ...
                fractionOutliers >= 0 && fractionOutliers <= 1, ...
                'Satellite fraction must be between 0 and 1.');

            nAffected = round(nCandidates * fractionOutliers);
            nChoose = min( ...
                nAffected, ...
                nCandidates);
            order = randperm(nCandidates,nChoose);
            affectedSatIdx = candidates(order);

        % ---------------------------------------------------------
        case 'explicit'
            cons = normalizeConstellationList( ...
                outlier.satelliteSelection.constellations);
            candidatesId = [];
            candidatesIdx = [];
            affectedSatIdx = [];
            for i = 1:numel(cons)
                field = constellationField(cons{i});
                if isfield(satIDs, field)
                    candidatesId = satIDs.(field)(:);
                    candidatesIdx = satIdx.(field)(:);
                end
                [isFound, tmp] = ismember(outlier.satelliteSelection.satIDs(:), candidatesId);
                selectedIdx = candidatesIdx(tmp(isFound));
                affectedSatIdx = [affectedSatIdx; selectedIdx(:)];
            end

            
            info.requestedSatellites = ...
                outlier.satelliteSelection.satIDs(:).';

        % ---------------------------------------------------------
        case 'all'
            affectedSatIdx = 1:nSat;
            cons = [];
            if isfield(satIDs,'GPS')
                cons = [cons "GPS"];
            end
            if isfield(satIDs,'GAL')
                cons = [cons "GAL"];
            end
            if isfield(satIDs,'GLO')
                cons = [cons "GLO"];
            end
            if isfield(satIDs,'BEI')
                cons = [cons "BEI"];
            end
            info.selectedConstellations = cellstr(cons);


        % ---------------------------------------------------------
        case 'random_sv_all_cons'
            candidates = 1:nSat;
            nChoose = min( ...
                outlier.satelliteSelection.nSat, ...
                numel(candidates));
            order = randperm(numel(candidates),nChoose);
            affectedSatIdx = candidates(order);

        % ---------------------------------------------------------
        case 'random_sv_selected_cons'
            cons = normalizeConstellationList( ...
                outlier.satelliteSelection.constellations);
            candidates = [];
            for i = 1:numel(cons)
                field = constellationField(cons{i});
                if isfield(satIdx, field)
                    candidates = [candidates; satIdx.(field)(:)];
                end
            end
            candidates = unique(candidates, 'stable');
            nCandidates = numel(candidates);
            nChoose = min( outlier.satelliteSelection.nSat, nCandidates);
            order = randperm(nCandidates,nChoose);
            affectedSatIdx = candidates(order);
            info.selectedConstellations = cons;

        % ---------------------------------------------------------
        case 'random_sv_multi_constellation'
            cons = normalizeConstellationList( ...
                outlier.satelliteSelection.constellations);

            if isempty(cons)
                error('outlier.constellations is missing in outliersProfile(%d).', iOutlier);
            end
            if numel(outlier.satelliteSelection.nSatPerConstellation) ~= ...
                    numel(cons)
                error('outlier.nSatPerConstellation in outliersProfile(%d) must contain one value per constellation.', iOutlier );
            end

            affectedSatIdx = [];
            for i = 1:numel(cons)
                field = constellationField(cons{i});

                if ~isfield(satIdx,field)
                    continue;
                end

                candidates = ...
                    satIdx.(field);
                nChoose = min( ...
                    outlier.satelliteSelection.nSatPerConstellation(i), ...
                    numel(candidates));
                order = randperm( ...
                    numel(candidates),nChoose);
                selected = candidates(order);
                affectedSatIdx = [affectedSatIdx; selected(:)];
            end

            info.selectedConstellations = cons;

       % ---------------------------------------------------------
        case 'reuse_previous_selection'

            if isempty(outlierLog)
                error('No previous satellite selection available.');
            end

            affectedSatIdx = outlierLog(end).selectedSatellites;

            info.requestedSatellites = affectedSatIdx;
            info.selectedConstellations = ...
                outlierLog(end).selectedConstellations;


        otherwise
            error('Unknown outlier.satelliteSelection.mode: %s in outliersProfile(%d).',mode,iOutlier);
    end

    affectedSatIdx = unique(affectedSatIdx,'stable');

    if any(affectedSatIdx < 1 | affectedSatIdx > nSat)
        error('Selected satellite index outside valid range.');
    end
end

% ========================================================================
function freqIdx = selectOutlierFrequencies(fault,nFreq)

    if ischar(fault.frequencies) || isstring(fault.frequencies)

        if strcmpi(fault.frequencies,'all')
            freqIdx = 1:nFreq;
        else
            error('Unknown frequency ');
        end

    else

        freqIdx = unique(fault.frequencies(:).');

    end

    if any(freqIdx < 1 | freqIdx > nFreq)
        error('Frequency index outside valid range.');
    end
end

% ========================================================================
function [obs, indicesOutlier] = injectAdditionalNoise( ...
    obs_ideal,obs,epochIdx,nSat,freqIdx,outlier,cfg)
% Increase observation STD by outlier.noiseScale.
%
% If sigma_outlier = scale * sigma_nominal, additional independent
% noise must satisfy
%
% sigma_additional^2 =
%       sigma_outlier^2 - sigma_nominal^2.
%
% This avoids incorrectly multiplying the already-existing sample.

    candidates = 1:nSat;
    n = numel(candidates);
    nEpochs = numel(epochIdx);
    nFreq = numel(freqIdx);
    scale = outlier.noise.scale;
    sigma = cfg.gnss.pseudorangeSigma;
    eps             = outlier.satelliteSelection.fraction;
    model   = lower(outlier.noise.model);
    mu_out  = outlier.noise.mean;

    if scale < 1
        error('noiseScale must be >= 1.');
    end

    %----------------------------------------------------------------------
    % Base Gaussian noise (nominal, mean 0)
    %----------------------------------------------------------------------
    noise = sigma * randn(n, nEpochs, nFreq);

    %----------------------------------------------------------------------
    % Randomly select which samples are outliers
    %----------------------------------------------------------------------
    nOut = round(n * eps);
    indicesOutlier = randperm(n, nOut);

    %----------------------------------------------------------------------
    % Generate outlier noise samples
    %----------------------------------------------------------------------
    switch model
        case 'gaussian'
            outliers = mu_out + sqrt(scale) * sigma * randn(nOut, nEpochs, nFreq);

        case 'laplacian'
            u = rand(nOut, nEpochs, nFreq) - 0.5;
            outliers = mu_out - sign(u) .* sqrt(scale/2) * sigma .* log(1 - 2*abs(u));

        case {'student-t', 'student'}
            dof = 2*sigma^2*scale/(sigma^2*scale-1);
            if dof<=2
                warning('Corresponding DOF value in the t distribution is lower than 2');
            end
            outliers = mu_out + trnd(dof, nOut, nEpochs, nFreq);

        otherwise
            error('Unknown outlier model: %s', model);
    end

    %----------------------------------------------------------------------
    % Replace nominal samples by outliers
    %----------------------------------------------------------------------
    noise(indicesOutlier, :, :) = outliers;

    for k = 1:numel(epochIdx)
        for f = freqIdx(:).'
    
            switch lower(outlier.observation)
    
                case 'code'
    
                    obs(:,epochIdx(k),f) = ...
                        obs_ideal(:,epochIdx(k),f) + ...
                        noise(:, k, f);
    
                case 'none'
    
                    % no observation modification
    
                otherwise
    
                    error('Unknown observation type.');
            end
        end
    end
end

% ========================================================================
function cons = normalizeConstellationList(cons)

    if isempty(cons)
        cons = {};
    elseif ischar(cons) || isstring(cons)
        cons = cellstr(cons);
    end
end

% ========================================================================
function field = constellationField(name)

    switch upper(char(name))

        case {'GPS','G'}
            field = 'GPS';

        case {'GAL','GALILEO','E'}
            field = 'GAL';

        case {'GLO','GLONASS','R'}
            field = 'GLO';

        case {'BEI','BDS','BEIDOU','C'}
            field = 'BEI';

        otherwise
            error('Unknown constellation: %s',name);
    end
end

% ========================================================================
function magnitude = generateOutlierMagnitude(model,timeSec,iOutlier)
%GENERATEFAULTMAGNITUDE Generate temporal outlier realization.
%
% magnitude is returned as nEpochOutlier x 1.

    t = timeSec(:);

    if isempty(t)
        magnitude = [];
        return;
    end

    if isempty(model.magnitudeType)
        error('model.magnitudeType is missing in outliersProfile(%d).', iOutlier');
    end

    tau = t - t(1);

    switch lower(model.magnitudeType)

        % ---------------------------------------------------------
        case 'constant'
            magnitude = ...
                model.magnitudeValue * ones(size(t));

        % ---------------------------------------------------------
        case 'ramp'
            magnitude = ...
                model.magnitudeInitialValue + ...
                model.magnitudeSlope .* tau;

        % ---------------------------------------------------------
        case 'gaussian'
            magnitude = ...
                model.magnitudeMean + ...
                model.magnitudeStd .* randn(size(t));

        % ---------------------------------------------------------
        case {'student-t', 'student'}

            nu = model.magnitudeDoF;

            if ~isscalar(nu) || ~isfinite(nu) || nu <= 2
                error('magnitudeDoF must be greater than 2.');
            end

            scale = model.magnitudeStd * sqrt((nu - 2)/nu);

            magnitude = model.magnitudeMean + ...
                scale * trnd(nu, numel(t), 1);

        % ---------------------------------------------------------
        case 'random_walk'
            magnitude = zeros(size(t));
            magnitude(1) = model.magnitudeInitialValue;
            if numel(t) > 1
                dt = diff(t);
                increments = ...
                    model.magnitudeSigma .* sqrt(dt) .* ...
                    randn(numel(dt),1);
                magnitude(2:end) = ...
                    magnitude(1) + cumsum(increments);
            end

        % ---------------------------------------------------------
        otherwise
            error('Unknown magnitude model: %s', ...
                model.magnitudeType);
    end
end

% ========================================================================
function obs = addObservationBias( ...
    obs,epochIdx,satIdx,freqIdx,observation,bias)

    bias = bias(:);

    if numel(bias) ~= numel(epochIdx)
        error('Bias realization must contain one value per epoch.');
    end

    for i = 1:numel(epochIdx)

        k = epochIdx(i);
        b = bias(i);

        switch lower(observation)

            case 'code'
                obs(satIdx,k,freqIdx) = ...
                    obs(satIdx,k,freqIdx) + b;

            case 'none'
                % intentionally no direct observation modification

            otherwise
                error('Unknown observation type: %s',observation);
        end
    end
end