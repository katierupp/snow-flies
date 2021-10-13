% imtool(frame, [])
% xcenter = 0;
% ycenter = 0;
% radius = 1;
% figure();
% imagesc(frame);
% hold on;
% viscircles([xcenter ycenter], radius);

% imsize = size(frame);
% xd = imsize(1);
% yd = imsize(2);
% mask = getCircleMask(xd, yd, xcenter, ycenter, radius);

% figure();
% imagesc(frame.*mask);

function mask = getCircleMask(xd, yd, xc, yc, radius)

   [xx,yy] = meshgrid(1:yd,1:xd);
   mask = false(xd,yd);
   mask = mask | hypot(xx - xc, yy - yc) <= radius;

end