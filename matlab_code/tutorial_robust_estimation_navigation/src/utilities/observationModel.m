function [hx,H,R] = observationModel(predPos, satPos, n, cfg)

%% State indexing
[~, nx] = stateIndex();

%% Measurement model and observation noise
hx = zeros(n, 1);
H = zeros(n, nx);

for i = 1:n
    d = predPos - satPos(:, i);
    rho = norm(d);

    hx(i) = rho;

    H(i, 1:3) = d' / rho;
    H(i, 4:6) = zeros(1, 3);
end

R = cfg.gnss.pseudorangeSigma^2 * eye(n);

end