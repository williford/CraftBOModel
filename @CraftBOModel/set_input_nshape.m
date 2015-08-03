function obj = set_input_nshape( obj, figw, figh, hole_breadth, hole_depth )
% SET_INPUT_NSHAPE Set the input layer to the n/u/c-shape
%
%  ████████████     ^
%  ████████████     |
%  ████         ^   |
%  ████         |  fh
%  ████         hb  |
%  ████         |   |
%  ████<--hd--> v   |
%  ████████████     |
%  ████████████     v
%  <----fw---->
%
%  fw,fh = figure width and height
%  hd,hb = hole depth and breadth

error('Function not yet implemented.')

if nargin < 2
   figw = min(size(obj.C,1),size(obj.C,2))/obj.pixperdeg/6;
   figh = min(size(obj.C,1),size(obj.C,2))/obj.pixperdeg/4;
   hole_breadth = figh/2;
   hole_depth = figw/2;
end

unit = 'degrees';

if strcmp(unit, 'degrees')
   % outer dimensions
   height_px = height * obj.pixperdeg;
   figw_px = figw * obj.pixperdeg;
   % dimensions of hole
   hdepth_px = hole_depth * obj.pixperdeg;
   hbreadth_px = hole_breadth * obj.pixperdeg;
else
   error('Unknown unit parameter');
end

hw = floor(wid_px / 2); % half width

% define outer rectangle
solid = ( ...
   (obj.C_X >= -

% define solid square first
solid = ( ...
  (obj.C_X >= -hw) & (obj.C_X <= hw) & ...
  (obj.C_Y >= -hw) & (obj.C_Y <= hw));

% define horizontal edges
obj.C(:,:, obj.h_ori) = abs(imfilter( double(solid), [-1 -1; 1 1]/2));
% ... and vertical edges
obj.C(:,:, obj.v_ori) = abs(imfilter( double(solid), [-1, 1; -1 1]/2));

end
