function [pts] = bb2pts(bb)
pts = zeros(4,2);
pts(1,:) = bb([1,2]);
pts(2,:) = bb([1,2]) + [bb(3),0];
pts(3,:) = bb([1,2]) + [0,bb(4)];
pts(4,:) = bb([1,2]) + bb([3,4]);
end