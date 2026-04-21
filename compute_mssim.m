function mssim_val = compute_mssim(ref_img, approx_img)
% COMPUTE_MSSIM - Mean Structural Similarity Index Measure
%
% Computes MSSIM between a reference (exact) image and an approximate image.
% Uses MATLAB's built-in ssim() which implements MS-SSIM per Wang et al.
%
% Higher MSSIM = closer to exact output = better quality.
% Value ranges from 0 (no similarity) to 1 (identical).
%
% Paper reports average MSSIM of 97.59% for proposed designs (Table 6).
%
% Inputs:
%   ref_img    - Reference image from exact multiplier (uint8)
%   approx_img - Output from approximate multiplier (uint8)
%
% Output:
%   mssim_val  - MSSIM value (0 to 1)
%
% Usage:
%   score = compute_mssim(exact_result, approx_result);
%   fprintf('MSSIM: %.4f (%.2f%%)\n', score, score*100);

    ref_img    = double(rgb2gray_safe(ref_img));
    approx_img = double(rgb2gray_safe(approx_img));

    % Resize if dimensions differ
    if ~isequal(size(ref_img), size(approx_img))
        approx_img = imresize(approx_img, size(ref_img));
    end

    % MATLAB's ssim() computes SSIM; for MSSIM use mean over windows
    mssim_val = ssim(uint8(approx_img), uint8(ref_img));
end


function img = rgb2gray_safe(img)
% Helper: convert to grayscale if needed
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    img = uint8(img);
end
