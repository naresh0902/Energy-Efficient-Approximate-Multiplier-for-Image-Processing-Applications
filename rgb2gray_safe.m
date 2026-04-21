function img = rgb2gray_safe(img)
% RGB2GRAY_SAFE - Converts image to grayscale if it is RGB, otherwise passthrough
%
% Safely handles both grayscale and RGB inputs.
% Always returns uint8.
%
% Input:
%   img - Image array (uint8, grayscale or RGB)
%
% Output:
%   img - Grayscale uint8 image

    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    img = uint8(img);
end
