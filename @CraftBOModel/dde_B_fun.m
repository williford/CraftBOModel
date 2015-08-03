function [dBdt] = dde_B_fun(obj, B, Gp, t)
% Calculates dB/dt
% Given lagged Grouping cell values

do_debug = false;

dBdt = zeros(size(B));

% orientation in the opposite direction
num_dir = size(B,3); % number of directed orientations
ind = 1:num_dir;
opp = mod( ind + num_dir/2 - 1, num_dir) + 1;

% feed-forward
% for now, don't implement the T-junction
C_ffwd = obj.C(:,:,[1:size(obj.C,3) 1:size(obj.C,3)]);

% up-sample and zero-pad grouping cells
Gp0 = cell(1,length(obj.G));
for ri = 1:length(Gp)
   ksize = size(obj.K{ri},1);
   Gp0{ri} = zeros(...
      size(B,1)+2*ksize, ...
      size(B,2)+2*ksize);
   Gp0{ri}(ksize+1:ksize+size(B,1),...
      ksize+1:ksize+size(B,2)) = ...
      imresize(Gp{ri}, [size(B,1), size(B,2)]);
end

% for each direction, perform convolution
for dir = 1:size(B,3)
   G_fback = zeros(size(B(:,:,1)));
   %debug_temp = cell(length(Gp));
   for ri = 1:length(Gp)
      ksize = size(obj.K{ri},1);
      
%       tempj = imfilter( Gp0{ri}, obj.K{ri}(:,:,opp(dir)), 'same','conv');
%       hk = floor(ksize/2);
%       tempj2 = tempj(hk+1:hk+size(B,1),hk+1:hk+size(B,2));
     
      % based on Sudarshan's code
      % perform convolution
      temp = conv2(Gp0{ri}, obj.K{ri}(:,:,opp(dir)),'same');
      temp2 = temp(ksize+1:ksize+size(B,1), ...
                   ksize+1:ksize+size(B,2));
      %debug_temp{ri} = temp;
      G_fback = G_fback + ...
         obj.rho_r(ri) * temp2;
   end
   
   if do_debug && max(abs(G_fback(:))) > 0
      for ri = 1:length(Gp)
         figure;
         imagesc(debug_temp{ri}(:,:,dir));
         rectangle('Position',[62,62,4,4]);
         title(strcat('GC feedback, Scale ',num2str(ri)));
      end
      assert(false)
   end
   
   % inhibition between border-ownership cells in opposite direction
   B_inh = obj.Beta*B(:,:,opp(dir));

   dBdt(:,:,dir) = (1 / obj.tau_B) * ( ...
      -B(:,:,dir) + max(0, C_ffwd(:,:,dir) - B_inh - G_fback) );
end