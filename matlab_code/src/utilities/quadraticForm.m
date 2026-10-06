function q = quadraticForm(e,P)
% Stable e' inv(P) e with mild regularization if needed.
    P = 0.5*(P+P.');
    [L,p] = chol(P,'lower');

    if p == 0
        y = L\e;
        q = y.'*y;
    else
        reg = 1e-10*max(1,trace(P)/size(P,1));
        q = e.'*((P+reg*eye(size(P)))\e);
    end
end