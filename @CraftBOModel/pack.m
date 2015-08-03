function Y = pack( obj, B, G )
% PACK Pack the border-ownership cells B and grouping cells G into a single
% vector Y. Necessary for the ODE solver.

Y = B(:);
for ri = 1:length(G)
   Y = [Y; G{ri}(:)];
end
