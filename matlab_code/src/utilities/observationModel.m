function [hx,H,R] = observationModel(state, satPos, n, cfg)

% % % % %% State indexing
% % % % [~, nx] = stateIndex();

%% Measurement model and observation noise
nx = length(state);

hx = zeros(n, 1);
H = zeros(n, nx);

for i = 1:n
    d = state(1:3) - satPos(:, i);
    rho = norm(d);

    hx(i) = rho + state(7);     %%%%% DM: update this state appropiately

    H(i, 1:3) = d' / rho;
    H(i, 4:6) = zeros(1, 3);
    H(i, 7)   = 1;
end

R = cfg.noisemodel.pseudorangeSigma^2 * eye(n);

end