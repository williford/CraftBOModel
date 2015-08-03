function display_B( obj, B )
% DISPLAY_B Displays border-ownership cell layer B.

if nargin < 2
    B = obj.B;
end

n = size(B,3);
nfigrows = ceil(n/2);
figure
for i = 1:n
    subplot(2,nfigrows,i);
    imagesc( B(:,:,i));
    %axis off;
    title(i);
    colorbar;
end
colormap jet