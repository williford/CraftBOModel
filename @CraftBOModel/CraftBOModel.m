classdef CraftBOModel < handle
   % CraftBOModel A partial re-implementation of the Craft et al
   % border-ownership model, as described in:
   % Craft,Schütze, Niebur and von der Heydt (2007). J Neurophysiology.
   %
   % Author: Jonathan R. Williford
   % 
   % This program is free software: you can redistribute it and/or modify
   % it under the terms of the GNU Affero General Public License as
   % published by the Free Software Foundation, either version 3 of the
   % License, or (at your option) any later version.

   properties
      tau_B = 10 % ms
      tau_G = 10 % ms
      conduction_delay = 6 % ms
      Beta = 0.5
      gamma_0 = 4.5
      epsilon = 0.5
   end
   % these properties shouldn't be modified after construction
   properties %(Access = private)
      pixperdeg = 2;
      
      % size of the visual field in degrees
      w_deg = 64;
      h_deg = 64;
      
      num_or = 2;
      h_ori = 1; % horizontal orientation index
      v_ori = 2; % vertical orientation index - round(num_or/2) + 1
      K_r_pix = [2,3,5,8,12,18] % the "r" in Craft's paper
      K_sigma_pix % the sigma of the grouping cell connection Gaussian
      G_pixperdeg % the pixels per degree at the multiple scales
      G_npixels
      
      gamma_r % sqrt(gamma_0) * K_r_pix
      rho_r % sqrt(gamma_0) * K_r_pix
   end
   % neural layers
   properties
      C % input layer (y,x, orientation)
      C_X % coord x for input layer
      C_Y % coord y for input layer
      B % Border-ownership cells (y,x,directed orientation)
      G   % Grouping cells, {scale}(y,x)
      G_X % Grouping cells, coord x
      G_Y % Grouping cells, coord y
      K % Grouping connections, {scale}(y,x,directed orientation)
      K_X % Grouping conn., coord x
      K_Y % Grouping conn., coord y
   end
   methods
      function obj = CraftBOModel()
         % Input layer (width, height, orientation)
         % Orientation selective cells
         obj.C = zeros( ...
            obj.h_deg*obj.pixperdeg, ...
            obj.w_deg*obj.pixperdeg, obj.num_or);

         % Coordinates for C (input layer)
         [obj.C_X, obj.C_Y] = meshgrid( ...
            linspace( -obj.w_deg/2, obj.w_deg/2, size(obj.C,2)), ...
            linspace( -obj.h_deg/2, obj.h_deg/2, size(obj.C,1)));

         % Border-ownership cells (x, y, directed orientations)
         obj.B = zeros(...
             obj.h_deg*obj.pixperdeg, ...
             obj.w_deg*obj.pixperdeg, 2*obj.num_or);

         % Grouping cell connections
         obj.K = cell(1, length(obj.K_r_pix));
         %obj.K_X = cell(1, length(obj.K_r_pix));
         %obj.K_Y = cell(1, length(obj.K_r_pix));
         obj.K_sigma_pix = obj.K_r_pix/2.5;
         
         for ri = 1:length(obj.K_r_pix)
            % K has same pixperdeg as B and C
            r = obj.K_r_pix(ri);
            Ksiz = ceil(2*r + 3*obj.K_sigma_pix(ri))+4;
            Ksiz = Ksiz + mod(Ksiz-1,2); % make odd
            [obj.K_X{ri}, obj.K_Y{ri}] = meshgrid( ...
            linspace( -floor(Ksiz/2), ...
                      floor(Ksiz/2), Ksiz), ...
            linspace( -floor(Ksiz/2), ...
                      floor(Ksiz/2), Ksiz));

            % temporary matrix
            I = abs(...
              sqrt(obj.K_X{ri}.^2 + obj.K_Y{ri}.^2)...
              - obj.K_r_pix(ri) ) <= obj.epsilon;
            % normalize I
            I = I / sum(I(:));
            % smooth sharp edges
            smo_size = ceil(obj.K_sigma_pix(ri))*3+1;
            smo_size = smo_size + mod(smo_size-1,2);
            h = fspecial('gaussian', ...
              smo_size, ... filter size
              obj.K_sigma_pix(ri));
            temp_K = imfilter(I, h);
            
            % Debugging the size of the kernels
            % make sure there is at least one pixel surrounding the
            %  box with no more than 2% of max value
            bb = regionprops(temp_K / max(temp_K(:)) > 0.02, ...
               'BoundingBox');
            if ceil(bb.BoundingBox(3) - bb.BoundingBox(1)) >= Ksiz(1)
               error('not sufficient')
            end

            normv = sqrt( double(obj.K_X{ri}.^2) + ...
                        double(obj.K_Y{ri}.^2) );
            nx = -obj.K_X{ri} ./ normv;
            ny = -obj.K_Y{ri} ./ normv;
            nx(isnan(nx))=0;
            ny(isnan(ny))=0;

            obj.K{ri} = zeros(Ksiz, Ksiz, 2*obj.num_or);

            % following is hardcoded for 4 directed orientations
            assert(size(obj.K{ri},3)==4);
            obj.K{ri}(:,:,1) = max(0, temp_K .* ny);
            % make sure the filters are symmetric
            for dir = 1:3
               obj.K{ri}(:,:,dir+1) = rot90(obj.K{ri}(:,:,dir));
            end

            % filters should add to 1
            obj.K{ri} = obj.K{ri} ./ sum(obj.K{ri}(:));
         end
         
         % Grouping cells
         obj.gamma_r = sqrt(obj.gamma_0) * obj.K_r_pix;
         obj.rho_r = sqrt(obj.gamma_0) * obj.K_r_pix;

         obj.G = cell(1, length(obj.K_r_pix));
         %obj.G_X = cell(1, length(obj.K_r_pix));
         %obj.G_Y = cell(1, length(obj.K_r_pix));
         for ri = 1:length(obj.K_r_pix)
            obj.G{ri} = zeros( ...
               floor((size(obj.C,1))/obj.K_r_pix(ri)), ...
               floor((size(obj.C,2))/obj.K_r_pix(ri)));
            % sizes in deg might be slightly larger due to rounding above
%             rw_deg = size(obj.G{ri},2)./obj.G_pixperdeg(ri)/2;
%             rh_deg = size(obj.G{ri},1)./obj.G_pixperdeg(ri)/2;
%             [obj.G_X{ri},obj.G_Y{ri}] = meshgrid( ...
%                linspace( -rw_deg/2, rw_deg/2, size(obj.G{ri},2)), ...
%                linspace( -rh_deg/2, rh_deg/2, size(obj.G{ri},1)));
            obj.G_npixels{ri} = numel(obj.G{ri});
         end
      end
   end
   methods
      dYdt = dde_fun(obj, t, Y, Z)
      dGdt = dde_G_fun(obj, G, Bp, t)
      dBdt = dde_B_fun(obj, B, Gp, t)
      obj = set_input_square(obj, square_wid)
      obj = set_input_image(obj, image)
      sol = run( obj, tspan )
      display_C( obj, C )
      display_B( obj, B )
      display_G( obj, G )
   end
   methods
      [B, G] = unpack(obj, Y)
      Y = pack(obj, B, G)
   end
end
