function [idx, nx] = stateIndex(nCons)

nx = 6+nCons;

idx.pos = 1:3;
idx.vel = 4:6;
idx.clk = 7:nx;


end