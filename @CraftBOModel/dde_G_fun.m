function [dGdt] = dde_G_fun(obj, G, Bp, t)
% Calculates dG/dt
% Given lagged BO values
% Equations 1-3

do_debug = false;

dGdt = cell(1,length(obj.G));
% for each scale
for ri = 1:length(obj.G)
   % Currently, all of the Grouping cell layers are the same size, so
   % the following "step" variable is not use.
   % According to the original paper, the pixels in G is 1/r^2 of the
   % normal input.
   step = obj.K_r_pix(ri);
   
   % S should be same w*h as BO + 2 * filter size
   S = zeros(size(Bp));
          
   % for each direction, perform convolution
   for dir = 1:size(Bp,3)
     ksize = size(obj.K{ri},1);
     hk = floor(ksize/2); % half K
     tempj = imfilter( Bp(:,:,dir), obj.K{ri}(:,:,dir), 'full','conv');
     S(:,:,dir) = tempj(hk+1:hk+size(S,1),hk+1:hk+size(S,2));
   end
   % sum each combination of S
   sumSS = zeros(size(S,1),size(S,2));
   for i = 1:(size(Bp,3)+1)
      for j = (i+1):size(Bp,3)
         sumSS = sumSS + S(:,:,i).*S(:,:,j);
      end
   end
   % downsample
   dsSumSS = imresize(sumSS, size(G{ri}));
   % dsSumSS can have negative values because of rounding error
   dsSumSS = max(0,dsSumSS);
   dGdt{ri} = (1 / obj.tau_G) * ( ...
      -G{ri} + obj.gamma_r(ri) * sqrt(dsSumSS) );
   assert(isreal(dGdt{ri}));
   
   if do_debug && max(S(:)) > 0 && ri == 3
      nfigrows = ceil(size(Bp,3)/2);
%       figure;
%       for or = 1:size(obj.C,3)
%          subplot(2,ceil(size(obj.C,3)/2),or);
%          imagesc(obj.C(60:68,60:68,or));
%          rectangle('Position',[63-60,63-60,4,4]);
%          title(strcat('Edge, OR ',num2str(or)));
%       end
%       figure;
%       for dir = 1:size(Bp,3)
%          subplot(2,nfigrows,dir);
%          imagesc(Bp(60:68,60:68,dir));
%          rectangle('Position',[63-60,63-60,4,4]);
%          title(strcat('BO, Direction ',num2str(dir)));
%       end
      figure;
      for dir = 1:size(Bp,3)
         subplot(2,nfigrows,dir);
         imagesc(obj.K{ri}(:,:,dir));
         title(strcat('K, Direction ',num2str(dir)));
      end
      figure; 
      for dir = 1:size(Bp,3)
         subplot(2,nfigrows,dir);
         imagesc(S(60:68,60:68,dir));
         rectangle('Position',[63-60,63-60,4,4]);
         title(strcat('S, Direction ',num2str(dir)));
      end
      figure;
      imagesc(sumSS(60:68,60:68));
      title('Sum i,j S_i*S_j');
      rectangle('Position',[63-60,63-60,4,4]);
      
      figure;
      imagesc(sumSS);
      title('Sum i,j S_i*S_j');
      rectangle('Position',[62,62,4,4]);
      
      figure;
      imagesc(dsSumSS);
      title('dsSumSS_r');
      w = size( G{ri}, 2 );
      h = size( G{ri}, 1 );
      line([1,w], [(h+1)/2,(h+1)/2]);
      line([(w+1)/2,(w+1)/2], [1,h]);
      
      figure;
      imagesc(dGdt{ri});
      title('dGdt_r');
      w = size( G{ri}, 2 );
      h = size( G{ri}, 1 );
      line([1,w], [(h+1)/2,(h+1)/2]);
      line([(w+1)/2,(w+1)/2], [1,h]);
      
      assert(false);
   end
end
