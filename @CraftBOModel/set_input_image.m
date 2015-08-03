function obj = set_input_image( obj, image )
% SET_INPUT_IMAGE Sets the input layer based on the image.
% Currently expects black and white contrast image
% (ie. solid color figure).

% detect horizontal edges
obj.C(:,:, obj.h_ori) = abs(imfilter( double(image), [-1 -1; 1 1]/2));
% ... and vertical edges
obj.C(:,:, obj.v_ori) = abs(imfilter( double(image), [-1, 1; -1 1]/2));



