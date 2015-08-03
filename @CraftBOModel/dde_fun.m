function dYdt = dde_fun(obj, t, Y, Z)

[B, G] = obj.unpack(Y);
[Bp, Gp] = obj.unpack(Z); % lagged B and G

% Border-ownership cell equations
dBdt = obj.dde_B_fun(B, Gp, t);
% Grouping cell equations
dGdt = obj.dde_G_fun(G, Bp, t);

dYdt = obj.pack( dBdt, dGdt );
assert(isreal(dYdt))
