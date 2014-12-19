function morphed_im = morph(im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac)

[h1, w1, color_depth1] = size(im1);
[h2, w2, color_depth2] = size(im2);

% Match color and size
if (color_depth1 ~= 1 && color_depth1 ~= 3) || (color_depth2 ~= 1 && color_depth2 ~= 3)
    error('images are neither grayscale (MxNx1) nor three-channel color (MxNx3)')
end

if color_depth1 < color_depth2
    im1 = cat(3,im1,im1,im1);
    color_depth1 = 3;
elseif color_depth2 < color_depth1
    im2 = cat(3,im2,im2,im2);
    color_depth2 = 1;
end

if h1 < h2 && w1 < w2
    scaling = min(h2/h1, w2/w1);
    im1 = imresize(im1,scaling);
    [h1, w1, ~] = size(im1);
elseif h2 < h1 && w2 < w1
    scaling = min(h1/h2, w1/w2);
    im2 = imresize(im2,scaling);
    [h2, w2, ~] = size(im2);
end

h = max(h1, h2);
w = max(w1, w2);


[ys,xs] = ind2sub([h, w], 1:(h*w));

int_pts = (1-warp_frac)*im1_pts + warp_frac*im2_pts;
if length(int_pts) >= 5
    int_pts(1:4,:) = [1,1; 1,h; w,1; w,h];
end


im1_x = zeros(h,w);
im1_y = zeros(h,w);
im2_x = zeros(h,w);
im2_y = zeros(h,w);

[l_tri,~] = size(tri);
for ii = 1:l_tri
    tri_pts = [int_pts(tri(ii,:),1), int_pts(tri(ii,:),2)];
    tri_mask = poly2mask(tri_pts(:,1), tri_pts(:,2), h, w);

    x = xs(tri_mask);
    y = ys(tri_mask);

    greek = [tri_pts(:,1)'; tri_pts(:,2)'; ones(1,3)]\[x; y; ones(1,length(x))];
    im1_warp = [im1_pts(tri(ii,:),1)'; im1_pts(tri(ii,:),2)'; ones(1,3)] * greek;
    im2_warp = [im2_pts(tri(ii,:),1)'; im2_pts(tri(ii,:),2)'; ones(1,3)] * greek;

    im1_x(tri_mask) = im1_warp(1,:)./im1_warp(3,:);
    im1_y(tri_mask) = im1_warp(2,:)./im1_warp(3,:);
    im2_x(tri_mask) = im2_warp(1,:)./im1_warp(3,:);
    im2_y(tri_mask) = im2_warp(2,:)./im1_warp(3,:);
end

im1_x(im1_x<1) = 1;
im1_y(im1_y<1) = 1;
im2_x(im2_x<1) = 1;
im2_y(im2_y<1) = 1;

im1_x(im1_x>w1) = w1;
im1_y(im1_y>h1) = h1;
im2_x(im2_x>w2) = w2;
im2_y(im2_y>h2) = h2;

im1_x = round(im1_x);
im1_y = round(im1_y);
im2_x = round(im2_x);
im2_y = round(im2_y);

im1_ind = sub2ind([h1,w1],im1_y,im1_x);
im2_ind = sub2ind([h2,w2],im2_y,im2_x);

if (color_depth1 == 3)
    im1_ind = cat(3,im1_ind, im1_ind+h1*w1, im1_ind+h1*w1*2);
end
if (color_depth2 == 3)
    im2_ind = cat(3,im2_ind, im2_ind+h2*w2, im2_ind+h2*w2*2);
end

im1_comp = (1-dissolve_frac)*im1(im1_ind);

im2_comp = dissolve_frac*im2(im2_ind);

morphed_im = im1_comp + im2_comp;


