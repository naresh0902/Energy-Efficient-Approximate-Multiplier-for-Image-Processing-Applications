function out_img = image_convolve_exact(img, kernel)
% IMAGE_CONVOLVE_EXACT - Reference convolution using MATLAB's exact imfilter
%
% Produces the ground-truth output for MSSIM comparison.
% Uses MATLAB's built-in imfilter (floating point, exact arithmetic).
%
% Inputs:
%   img    - Input grayscale image (uint8)
%   kernel - 2D convolution kernel (unnormalized)
%
% Output:
%   out_img - Filtered image (uint8)

    img    = rgb2gray_safe(img);
    k_norm = kernel / sum(kernel(:));
    out_img = uint8(imfilter(double(img), k_norm, 'replicate'));
end
