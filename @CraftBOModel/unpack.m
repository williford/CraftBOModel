function [B, G] = unpack( obj, Y )
% UNPACK Unpack the vector Y into the border-ownership cells B and the
%      grouping cells G. Does the reverse of Pack.
%
% See also PACK.


B_len = length(obj.B(:));
B = reshape( Y(1:B_len), size(obj.B));

read_len = B_len;

G = cell(1, length(obj.G));
for ri = 1:length(obj.G)
   G{ri} = reshape( ...
      Y(read_len+1:read_len + obj.G_npixels{ri}), ...
      size(obj.G{ri}));
   read_len = read_len + obj.G_npixels{ri};
end
