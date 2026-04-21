function out_img = image_multiply_approx(img1, img2, compressor_type)
% IMAGE_MULTIPLY_APPROX - Fast pixel-wise image multiplication using approx multiplier
%
% Uses a precomputed 256x256 lookup table so approx_dadda_8x8 is called
% only 65536 times total (all unique pairs), not once per pixel.
%
% Inputs:
%   img1, img2      - Grayscale images of same size (uint8)
%   compressor_type - String: 'proposed1', 'proposed2', etc.
%
% Output:
%   out_img - Result image (uint8)

    img1 = double(rgb2gray_safe(img1));
    img2 = double(rgb2gray_safe(img2));

    if ~isequal(size(img1), size(img2))
        img2 = imresize(img2, size(img1));
    end

    % ------------------------------------------------------------------
    % Build full 256x256 lookup table once
    % LUT(a+1, b+1) = approx_dadda_8x8(a, b) / 255  (scaled to uint8)
    % ------------------------------------------------------------------
    fprintf('    Building lookup table...\n');
    LUT = zeros(256, 256, 'double');
    for a = 0:255
        for b = 0:255
            LUT(a+1, b+1) = double(approx_dadda_8x8(uint8(a), uint8(b), compressor_type)) / 255;
        end
    end

    % Vectorized lookup over all pixels
    idx1    = uint32(img1) + 1;   % 1-indexed
    idx2    = uint32(img2) + 1;
    out     = LUT(sub2ind([256 256], idx1(:), idx2(:)));
    out     = reshape(out, size(img1));
    out_img = uint8(min(round(out), 255));
end
