function out_img = image_convolve_approx(img, kernel, compressor_type)
% IMAGE_CONVOLVE_APPROX - Fast 2D convolution using approximate multiplier
%
% Uses a precomputed 256x256 lookup table for the approximate multiplier
% so that approx_dadda_8x8 is called at most 65536 times (once per unique
% pixel-kernel pair) instead of once per pixel per kernel tap.
%
% Inputs:
%   img             - Input grayscale image (uint8)
%   kernel          - 2D convolution kernel (unnormalized integer values)
%   compressor_type - String: 'proposed1', 'proposed2', etc.
%
% Output:
%   out_img - Filtered image (uint8)

    img = double(rgb2gray_safe(img));
    [rows, cols] = size(img);
    [kr, kc]     = size(kernel);
    pad_r = floor(kr / 2);
    pad_c = floor(kc / 2);

    img_pad = padarray(img, [pad_r, pad_c], 'replicate');

    % Scale kernel values to fit in uint8 range for the multiplier
    k_max         = max(abs(kernel(:)));
    k_scale       = 255 / k_max;
    kernel_scaled = uint8(min(round(abs(kernel) * k_scale), 255));

    k_sum = sum(kernel(:));   % normalization denominator

    % ------------------------------------------------------------------
    % Build lookup table: only for unique kernel values that appear.
    % LUT(pv+1, ki) = approx_dadda_8x8(pv, unique_kvals(ki))
    % This reduces calls from rows*cols*kr*kc down to 256*numel(unique_kvals)
    % For a 5x5 kernel that has at most ~10 unique values: 256*10 = 2560 calls
    % ------------------------------------------------------------------
    unique_kvals = unique(kernel_scaled(:));
    num_unique   = length(unique_kvals);

    LUT = zeros(256, num_unique);
    for ki = 1:num_unique
        kv = unique_kvals(ki);
        for pv = 0:255
            LUT(pv+1, ki) = double(approx_dadda_8x8(uint8(pv), kv, compressor_type));
        end
    end

    % Map each kernel_scaled value -> LUT column index
    kval_to_idx = zeros(256, 1, 'uint32');
    for ki = 1:num_unique
        kval_to_idx(unique_kvals(ki)+1) = ki;
    end

    % ------------------------------------------------------------------
    % Convolution: vectorized over all pixels using LUT
    % ------------------------------------------------------------------
    out = zeros(rows, cols);

    for m = 1:kr
        for n = 1:kc
            kv = kernel_scaled(m, n);
            ki = kval_to_idx(kv + 1);
            % Patch for this kernel tap across all output pixels
            patch     = img_pad(m : m+rows-1, n : n+cols-1);   % rows x cols
            patch_idx = uint32(patch) + 1;                      % 1-indexed for LUT
            % Vectorized LUT lookup - no loop over pixels
            prod_map  = reshape(LUT(patch_idx(:), ki), rows, cols);
            out       = out + prod_map / k_scale;
        end
    end

    out_img = uint8(min(abs(out / k_sum), 255));
end
