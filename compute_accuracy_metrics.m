function metrics = compute_accuracy_metrics(compressor_type)
% COMPUTE_ACCURACY_METRICS - Computes all accuracy metrics from Table 4
%
% Exhaustively tests all 256x256 = 65536 input combinations and computes:
%   ER   - Error Rate (%) : fraction of incorrect outputs
%   AOC  - Accurate Output Count : number of correct outputs
%   MED  - Mean Error Distance : average |exact - approx|
%   MRED - Mean Relative Error Distance
%   NED  - Normalized Error Distance
%
% Equations (8)-(12) from Section 6.1 of the paper.
%
% Input:
%   compressor_type - String: 'proposed1', 'proposed2', 'momeni', etc.
%
% Output:
%   metrics - Struct with fields: ER, AOC, MED, MRED, NED
%
% Usage:
%   m = compute_accuracy_metrics('proposed1');
%   fprintf('Error Rate: %.4f%%\n', m.ER);

    fprintf('Computing accuracy metrics for: %s\n', compressor_type);
    fprintf('Testing all 65536 input combinations...\n');

    n       = 256 * 256;       % total combinations
    ED_max  = double(255 * 255); % max possible product value

    total_errors = 0;
    total_ED     = 0;
    total_MRED   = 0;
    total_NED    = 0;
    AOC          = 0;

    for A = 0:255
        for B = 0:255
            exact  = double(uint16(A) * uint16(B));
            approx = double(approx_dadda_8x8(A, B, compressor_type));

            ED = exact - approx;

            if ED == 0
                AOC = AOC + 1;
            else
                total_errors = total_errors + 1;
            end

            total_ED = total_ED + abs(ED);

            if exact ~= 0
                total_MRED = total_MRED + (abs(ED) / exact);
            end

            total_NED = total_NED + (ED / ED_max);
        end
    end

    metrics.ER   = (total_errors / n) * 100;
    metrics.AOC  = AOC;
    metrics.MED  = total_ED / n;
    metrics.MRED = total_MRED / n;
    metrics.NED  = total_NED / n;

    fprintf('Done. ER=%.4f%%, AOC=%d, MED=%.4f, MRED=%.6f, NED=%.4f\n', ...
        metrics.ER, metrics.AOC, metrics.MED, metrics.MRED, metrics.NED);
end
