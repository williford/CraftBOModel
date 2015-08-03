function display_G( obj, G )
% DISPLAY_G Displays grouping cell layers G.

if nargin < 2
    G = obj.G;
end

ncols = ceil(length(G)/2);
nrows = ceil(length(G)/ncols);
figure
for ri = 1:length(G)   
   subplot(ncols,nrows,ri);
   imagesc( G{ri}(:,:,1));
   %caxis([0 1]);
   %axis off;
   title(strcat('Scale ', num2str(ri)));
   colorbar;
   w = size( G{ri}, 2 );
   h = size( G{ri}, 1 );
   line([1,w], [(h+1)/2,(h+1)/2]);
   line([(w+1)/2,(w+1)/2], [1,h]);
end
colormap jet