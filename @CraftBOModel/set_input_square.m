function obj = set_input_square( obj, square_wid )
% SET_INPUT_SQUARE Sets the input layer to be a single square of the width
% set to square_wid.

if nargin < 2
   square_wid = max(size(obj.C,1),size(obj.C,2))/obj.pixperdeg/6;
end

unit = 'degrees';

if strcmp(unit, 'pixels')
   wid_px = square_wid;
elseif strcmp(unit, 'degrees')
   wid_px = square_wid * obj.pixperdeg; 
else
   error('Unknown unit parameter');
end

hw = floor(wid_px / 2); % half width

% define solid square first
solid = ( ...
  (obj.C_X >= -hw) & (obj.C_X <= hw) & ...
  (obj.C_Y >= -hw) & (obj.C_Y <= hw));

obj.set_input_image(solid);

end
