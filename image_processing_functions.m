function out_img = image_multiply_approx(img1, img2, compressor_type)
% IMAGE_MULTIPLY_APPROX - Pixel-wise image multiplication using approx multiplier
%
% Multiplies corresponding pixels of two images using the approximate
% Dadda multiplier. Result is scaled back to uint8 range [0, 255].
% Used in Section 6.3 (Image Multiplication application).
%
% Inputs:
%   img1, img2      - Grayscale images of same size (uint8)
%   compressor_type - String: 'proposed1', 'proposed2', etc.
%
% Output:
%   out_img - Result image (uint8)
%
% Usage:
%   result = image_multiply_approx(crater, cameraman, 'proposed1');

    img1 = double(rgb2gray_safe(img1));
    img2 = double(rgb2gray_safe(img2));

    % Resize img2 to match img1 if needed
    if ~isequal(size(img1), size(img2))
        img2 = imresize(img2, size(img1));
    end

    [rows, cols] = size(img1);
    out = zeros(rows, cols);

    for i = 1:rows
        for j = 1:cols
            a = uint8(img1(i,j));
            b = uint8(img2(i,j));
            % Product is 16-bit; scale back to 8-bit
            prod_val = approx_dadda_8x8(a, b, compressor_type);
            % Normalize by 255 to keep in uint8 range
            out(i,j) = min(round(prod_val / 255), 255);
        end
    end

    out_img = uint8(out);
end


function out_img = image_convolve_approx(img, kernel, compressor_type)
% IMAGE_CONVOLVE_APPROX - 2D convolution using approximate multiplier
%
% Applies a convolution kernel to an image using the approximate Dadda
% multiplier for all multiply operations within the kernel.
% Used for both Smoothing (Eq.13) and Sharpening (Eq.14) in Section 6.3.
%
% Inputs:
%   img             - Input grayscale image (uint8)
%   kernel          - 2D convolution kernel matrix (will be normalized)
%   compressor_type - String: 'proposed1', 'proposed2', etc.
%
% Output:
%   out_img - Filtered image (uint8)
%
% Usage:
%   K = get_smooth_kernel();
%   result = image_convolve_approx(cameraman, K, 'proposed1');

    img = double(rgb2gray_safe(img));
    [rows, cols]   = size(img);
    [kr, kc]       = size(kernel);
    pad_r = floor(kr / 2);
    pad_c = floor(kc / 2);

    % Pad image with border replication
    img_pad = padarray(img, [pad_r, pad_c], 'replicate');

    % Normalize kernel so weights fit in uint8 (scale to 0-255)
    k_max   = max(abs(kernel(:)));
    k_scale = 255 / k_max;
    kernel_scaled = round(kernel * k_scale);  % scaled integer kernel

    out = zeros(rows, cols);

    for i = 1:rows
        for j = 1:cols
            patch = img_pad(i:i+kr-1, j:j+kc-1);
            accum = 0;
            for m = 1:kr
                for n = 1:kc
                    pixel_val = uint8(min(patch(m,n), 255));
                    kern_val  = uint8(min(abs(kernel_scaled(m,n)), 255));
                    prod      = approx_dadda_8x8(pixel_val, kern_val, compressor_type);
                    % Scale back (divide by k_scale)
                    accum = accum + prod / k_scale;
                end
            end
            % Normalize by kernel sum
            k_sum = sum(abs(kernel(:)));
            out(i,j) = min(abs(accum / k_sum), 255);
        end
    end

    out_img = uint8(out);
end


function K = get_smooth_kernel()
% GET_SMOOTH_KERNEL - Returns smoothing kernel from Equation (13)
%
% 5x5 Gaussian-like smoothing kernel as specified in the paper.

    K = [1  1  1  1  1;
         1  4  4  4  1;
         1  4 12  4  1;
         1  4  4  4  1;
         1  1  1  1  1];
end


function K = get_sharp_kernel()
% GET_SHARP_KERNEL - Returns sharpening kernel from Equation (14)
%
% 5x5 Gaussian sharpening kernel as specified in the paper.

    K = [ 1   4   7   4  1;
          4  16  26  16  4;
          7  26  41  26  7;
          4  16  26  16  4;
          1   4   7   4  1];
end


function out_img = image_convolve_exact(img, kernel)
% IMAGE_CONVOLVE_EXACT - Reference convolution using MATLAB's exact imfilter
%
% Produces ground-truth output for MSSIM comparison.
%
% Inputs:
%   img    - Input grayscale image (uint8)
%   kernel - 2D convolution kernel (unnormalized)
%
% Output:
%   out_img - Filtered image (uint8)

    img = rgb2gray_safe(img);
    k_norm = kernel / sum(kernel(:));
    out_img = uint8(imfilter(double(img), k_norm, 'replicate'));
end


function img = rgb2gray_safe(img)
% RGB2GRAY_SAFE - Converts image to grayscale if needed
%
% Helper function to safely handle both grayscale and RGB images.

    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    img = uint8(img);
end
