function display_C( obj, C )

if nargin < 2
    C = obj.C;
end

n = size(C,3);
nfigrows = ceil(n/2);
figure
for i = 1:n
    subplot(2,nfigrows,i);
    imagesc( C(:,:,i));
    title(i);
    colorbar;
end
colormap jet