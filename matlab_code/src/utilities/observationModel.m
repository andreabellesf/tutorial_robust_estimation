function [hx,H,R] = observationModel(state, satPos, nObs, clkMatrix, cfg)

%% State indexing and variable initialization
[idx, nx] = stateIndex(cfg.simulation.nCons);

%% Measurement model and observation noise

hx = zeros(nObs, 1);
H = zeros(nObs, nx);

for i = 1:nObs
    d = state(idx.pos) - satPos(i, :).';
    rho = norm(d);
    clkOff = state(idx.clk(clkMatrix(i, :))); 

    hx(i) = rho + clkOff;    

    H(i, idx.pos) = d' / rho;
    H(i, idx.vel) = zeros(1, numel(idx.vel));
    H(i, idx.clk)   = double(clkMatrix(i, :));
end

R = cfg.noisemodel.std^2 * eye(nObs);

end