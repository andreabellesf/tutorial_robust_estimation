function [nees, neesPos, neesVel] = computeNees(error, P, idx)

nees = quadraticForm(error,P);
neesPos = quadraticForm(error(idx.pos),P(idx.pos,idx.pos));
neesVel = quadraticForm(error(idx.pos),P(idx.vel,idx.vel));

end