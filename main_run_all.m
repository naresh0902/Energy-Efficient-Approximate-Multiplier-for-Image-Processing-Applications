%% MAIN_RUN_ALL.m
% =========================================================================
% MAIN SCRIPT - Reproduces ALL results from the paper:
%   "Energy Efficient Approximate Multiplier for Image Processing Applications"
%   Chakraborty et al., Results in Engineering 25 (2025) 103798
%
% This script generates:
%   1. Table 4 - Accuracy metrics comparison
%   2. Table 6 - MSSIM comparison for image processing applications
%   3. Figure 8 - Visual output images (saved to disk)
%
% REQUIREMENTS:
%   - MATLAB Image Processing Toolbox (for ssim, imfilter, imread)
%   - Images: 'crater.png' and 'cameraman.tif' in the working directory
%     (cameraman.tif ships with MATLAB; crater.png is a standard test image)
%
% HOW TO RUN:
%   1. Place all .m files in the same folder
%   2. Set that folder as MATLAB current directory
%   3. Run: main_run_all
%
% EXPECTED RUNTIME: ~15-30 minutes depending on hardware
%   (65536 multiplications per compressor x 11 compressors x 3 applications)
% =========================================================================

clear; clc; close all;

%% ---- Setup ----
addpath(pwd);  % ensure all .m files are on path

% List of all compressors to evaluate
compressor_names = {
    'proposed1',  'Proposed Design 1';
    'proposed2',  'Proposed Design 2';
    'fang',       'Fang et al. (Design 1)';
    'odugu',      'Odugu et al.';
    'krishna',    'L.H. Krishna et al.';
    'rafiee',     'Mahmood Rafiee et al.';
    'edavoor',    'P.J. Edavoor et al.';
    'gorantla',   'Gorantla et al.';
    'reddy',      'K. Manikantta Reddy et al.';
    'ha_lee',     'Ha and Lee et al.';
    'momeni',     'Momeni et al. (Design 2)';
};

num_designs = size(compressor_names, 1);


%% ---- Load Images ----
fprintf('\n=== Loading Images ===\n');

% Crater image - used for image multiplication
if exist('crater.png', 'file')
    crater = imread('crater.png');
else
    % Fallback: use MATLAB built-in moon image as substitute
    warning('crater.png not found. Using moon.tif as substitute.');
    crater = imread('moon.tif');
end

% Cameraman - standard MATLAB test image used for all three applications
if exist('cameraman.tif', 'file')
    cameraman = imread('cameraman.tif');
else
    error('cameraman.tif not found. It should ship with MATLAB Image Toolbox.');
end

crater    = rgb2gray_safe(crater);
cameraman = rgb2gray_safe(cameraman);

% Resize crater to match cameraman dimensions if needed
if ~isequal(size(crater), size(cameraman))
    crater = imresize(crater, size(cameraman));
end

fprintf('Crater image size: %dx%d\n', size(crater,1), size(crater,2));
fprintf('Cameraman image size: %dx%d\n', size(cameraman,1), size(cameraman,2));


%% ---- Compute Exact Reference Outputs ----
fprintf('\n=== Computing Exact Reference Outputs ===\n');

K_smooth = get_smooth_kernel();
K_sharp  = get_sharp_kernel();

% Exact image multiplication (pixel-wise, scaled)
exact_mul = uint8(min(double(crater) .* double(cameraman) / 255, 255));

% Exact convolutions using MATLAB's imfilter
exact_smooth = image_convolve_exact(cameraman, K_smooth);
exact_sharp  = image_convolve_exact(cameraman, K_sharp);

fprintf('Reference outputs computed.\n');


%% ---- TABLE 4: Accuracy Metrics ----
fprintf('\n=== Computing Table 4: Accuracy Metrics ===\n');
fprintf('(This is the most time-consuming step)\n\n');

acc_results = struct();

for k = 1:num_designs
    ctype = compressor_names{k, 1};
    cname = compressor_names{k, 2};
    fprintf('\n[%d/%d] %s\n', k, num_designs, cname);

    m = compute_accuracy_metrics(ctype);

    acc_results(k).name  = cname;
    acc_results(k).ER    = m.ER;
    acc_results(k).AOC   = m.AOC;
    acc_results(k).MED   = m.MED;
    acc_results(k).MRED  = m.MRED;
    acc_results(k).NED   = m.NED;
end

% Print Table 4
fprintf('\n\n========== TABLE 4: Accuracy Metrics ==========\n');
fprintf('%-30s %10s %10s %12s %10s %10s\n', ...
    'Design', 'ER(%)', 'AOC', 'MED', 'MRED', 'NED');
fprintf('%s\n', repmat('-', 1, 85));
for k = 1:num_designs
    r = acc_results(k);
    fprintf('%-30s %10.4f %10d %12.4f %10.6f %10.4f\n', ...
        r.name, r.ER, r.AOC, r.MED, r.MRED, r.NED);
end


%% ---- TABLE 6: Image Processing MSSIM ----
fprintf('\n\n=== Computing Table 6: MSSIM for Image Processing ===\n');

img_results = struct();

for k = 1:num_designs
    ctype = compressor_names{k, 1};
    cname = compressor_names{k, 2};
    fprintf('\n[%d/%d] %s - Running image processing...\n', k, num_designs, cname);

    % Application 1: Image Multiplication
    approx_mul = image_multiply_approx(crater, cameraman, ctype);
    mssim_mul  = compute_mssim(exact_mul, approx_mul);

    % Application 2: Image Smoothing
    approx_smooth = image_convolve_approx(cameraman, K_smooth, ctype);
    mssim_smooth  = compute_mssim(exact_smooth, approx_smooth);

    % Application 3: Image Sharpening
    approx_sharp = image_convolve_approx(cameraman, K_sharp, ctype);
    mssim_sharp  = compute_mssim(exact_sharp, approx_sharp);

    img_results(k).name         = cname;
    img_results(k).ctype        = ctype;
    img_results(k).mssim_mul    = mssim_mul;
    img_results(k).mssim_smooth = mssim_smooth;
    img_results(k).mssim_sharp  = mssim_sharp;
    img_results(k).approx_mul   = approx_mul;
    img_results(k).approx_smooth= approx_smooth;
    img_results(k).approx_sharp = approx_sharp;

    fprintf('  Multiplication MSSIM : %.4f\n', mssim_mul);
    fprintf('  Smoothing MSSIM      : %.4f\n', mssim_smooth);
    fprintf('  Sharpening MSSIM     : %.4f\n', mssim_sharp);
end

% Print Table 6
fprintf('\n\n========== TABLE 6: MSSIM Comparison ==========\n');
fprintf('%-30s %14s %14s %14s\n', 'Design', 'Multiplication', 'Smoothing', 'Sharpening');
fprintf('%s\n', repmat('-', 1, 75));
for k = 1:num_designs
    r = img_results(k);
    fprintf('%-30s %14.4f %14.4f %14.4f\n', ...
        r.name, r.mssim_mul, r.mssim_smooth, r.mssim_sharp);
end


%% ---- Figure 8: Visual Image Comparison ----
fprintf('\n=== Generating Figure 8: Visual Comparison ===\n');

% Show proposed designs vs exact for all three applications
save_image_comparison(img_results, exact_mul, exact_smooth, exact_sharp);

fprintf('\n=== ALL DONE ===\n');
fprintf('Check output_images/ folder for saved comparison figures.\n');


%% ---- Helper: Save Image Comparison ----
function save_image_comparison(img_results, exact_mul, exact_smooth, exact_sharp)

    if ~exist('output_images', 'dir')
        mkdir('output_images');
    end

    % Show only proposed designs for Fig 8 style output
    designs_to_show = {'proposed1', 'proposed2'};
    design_labels   = {'Proposed Design 1', 'Proposed Design 2'};

    app_names = {'Multiplication', 'Smoothing', 'Sharpening'};
    exact_imgs = {exact_mul, exact_smooth, exact_sharp};
    field_names = {'approx_mul', 'approx_smooth', 'approx_sharp'};

    for app = 1:3
        figure('Name', ['Image ' app_names{app}], 'Position', [100 100 900 300]);
        for d = 1:2
            % Find matching result
            for k = 1:length(img_results)
                if strcmp(img_results(k).ctype, designs_to_show{d})
                    subplot(1, 3, d);
                    imshow(img_results(k).(field_names{app}));
                    title(design_labels{d}, 'FontSize', 9);
                    break;
                end
            end
        end
        subplot(1, 3, 3);
        imshow(exact_imgs{app});
        title('Accurate Multiplier', 'FontSize', 9);
        sgtitle(['Image ' app_names{app}]);

        fname = fullfile('output_images', ['fig8_' lower(app_names{app}) '.png']);
        saveas(gcf, fname);
        fprintf('Saved: %s\n', fname);
    end
end


%% ---- Helper: RGB to Grayscale ----
function img = rgb2gray_safe(img)
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    img = uint8(img);
end
