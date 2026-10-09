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
% Supported mode:
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
% Frequency selection:
%   [] or 'all'  -> all frequencies
%   numeric      -> frequency indices, e.g. [1 2]
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

    nSat   = size(trial.gnss.pseudorange,1);
    nEpoch = size(trial.gnss.pseudorange,2);
    nFreq  = cfg.simulation.nFreq; 

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
        'frequencies',{}, ...
        'observation',{}, ...
        'magnitudeType',{}, ...
        'magnitudeRealization',{}, ...
        'profile',{});

    % Apply every outlier profile
    for iOutlier = 1:numel(outlierProfiles)

        outlier = applyOutlierDefault(outlierProfiles(iOutlier));
        % outlier = outlierProfiles(iOutlier);

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

                trialFaulty.gnss.pseudorange = injectAdditionalNoise( ...
                    trialFaulty.gnss.pseudorange,epochIdx,satIdx,freqIdx, ...
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
            outlier.mode;

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
    default.frequencies = 'all';
    default.observation = 'both';

    % -------------------------------------------------------------
    % Satellite-selection default
    % -------------------------------------------------------------
    default.mode = 'explicit';
    default.satIDs = [];
    default.constellations = {'GPS'};
    default.nSat = 1;
    default.nSatPerConstellation = [];
    default.reuseOutlier = [];

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
    mode = lower(outlier.mode);

    info = struct();

    info.requestedSatellites = [];
    info.selectedConstellations = {};

    switch mode

        % ---------------------------------------------------------
        case 'explicit'
            cons = normalizeConstellationList( ...
                outlier.constellations);
            candidates = [];
            for i = 1:numel(cons)
                field = constellationField(cons{i});
                candidates = satIDs.(field);
            end

            [~, affectedSatIdx] = ismember(outlier.satIDs(:), candidates);
            info.requestedSatellites = ...
                outlier.satIDs(:).';

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
                outlier.nSat, ...
                numel(candidates));
            order = randperm(numel(candidates),nChoose);
            affectedSatIdx = candidates(order);

        % ---------------------------------------------------------
        case 'random_sv_selected_cons'
            cons = normalizeConstellationList( ...
                outlier.constellations);
            candidates = [];
            for i = 1:numel(cons)
                field = constellationField(cons{i});
                candidates = satIdx.(field);
            end
            nCandidates = numel(candidates);
            nChoose = min( outlier.nSat, nCandidates);
            order = randperm(nCandidates,nChoose);
            affectedSatIdx = candidates(order);
            info.selectedConstellations = cons;

        % ---------------------------------------------------------
        case 'random_sv_multi_constellation'
            cons = normalizeConstellationList( ...
                outlier.constellations);

            if isempty(cons)
                error('outlier.constellations is missing in outliersProfile(%d).', iOutlier);
            end
            if numel(outlier.nSatPerConstellation) ~= ...
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
                    outlier.nSatPerConstellation(i), ...
                    numel(candidates));
                order = randperm( ...
                    numel(candidates),nChoose);
                selected = candidates(order);
                affectedSatIdx = [affectedSatIdx; selected(:)];
            end

            info.selectedConstellations = cons;

       % ---------------------------------------------------------
        case 'reuse_selection'

            refOutlier = outlier.reuseOutlier;

            if refOutlier < 1 || refOutlier > numel(outlierLog)
                error('Outlier %d requests invalid reuseOutlier = %d.', ...
                    iOutlier,refOutlier);
            end

            affectedSatIdx = outlierLog(iOutlier-1).selectedSatellites;

            info.requestedSatellites = affectedSatIdx;
            info.selectedConstellations = ...
                outlierLog(refOutlier).selectedConstellations;


        otherwise
            error('Unknown outlier.mode: %s in outliersProfile(%d).',mode,iOutlier);
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
function obs = injectAdditionalNoise( ...
    obs,epochIdx,satIdx,freqIdx,outlier,cfg)
% Increase observation STD by outlier.noiseScale.
%
% If sigma_outlier = scale * sigma_nominal, additional independent
% noise must satisfy
%
% sigma_additional^2 =
%       sigma_outlier^2 - sigma_nominal^2.
%
% This avoids incorrectly multiplying the already-existing sample.

    scale = outlier.noiseScale;
    sigma_nominal = cfg.gnss.pseudorangeSigma;

    if scale < 1
        error('noiseScale must be >= 1.');
    end

    sigmaCode0 = sigma_nominal;

    sigmaAddCode = ...
        sigmaCode0 * sqrt(scale^2 - 1);

    for f = freqIdx(:).'

        switch lower(outlier.observation)

            case 'code'

                obs(epochIdx,satIdx,f) = ...
                    obs(epochIdx,satIdx,f) + ...
                    sigmaAddCode * ...
                    randn(numel(epochIdx),numel(satIdx));

            case 'none'

                % no observation modification

            otherwise

                error('Unknown observation type.');
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