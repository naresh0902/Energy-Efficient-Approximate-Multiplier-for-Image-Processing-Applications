%% PLOT_RESULTS.m
% =========================================================================
% PLOTTING SCRIPT - Generates bar charts and comparison plots
%
% Run AFTER main_run_all.m has populated acc_results and img_results.
% Produces publication-quality comparison figures.
%
% Usage (after main_run_all):
%   plot_results(acc_results, img_results)
% =========================================================================

function plot_results(acc_results, img_results)

    if nargin == 0
        error('Run main_run_all.m first to generate acc_results and img_results.');
    end

    n = length(acc_results);
    names = {acc_results.name};
    % Shorten names for axis labels
    short_names = {'Prop.D1','Prop.D2','Fang','Odugu','Krishna', ...
                   'Rafiee','Edavoor','Gorantla','Reddy','Ha-Lee','Momeni'};

    if ~exist('output_images', 'dir'), mkdir('output_images'); end

    %% -- Plot 1: Error Rate Comparison --
    figure('Name', 'Error Rate Comparison', 'Position', [100 100 900 400]);
    er_vals = [acc_results.ER];
    b = bar(er_vals, 'FaceColor', 'flat');
    b.CData(1,:) = [0.2 0.6 0.9];  % proposed1 highlighted
    b.CData(2,:) = [0.1 0.4 0.8];  % proposed2 highlighted
    for k = 3:n
        b.CData(k,:) = [0.7 0.7 0.7];
    end
    set(gca, 'XTickLabel', short_names, 'XTickLabelRotation', 30, 'FontSize', 9);
    ylabel('Error Rate (%)');
    title('Error Rate Comparison (Lower is Better)');
    grid on;
    yline(er_vals(1), '--b', sprintf('Prop.D1=%.2f%%', er_vals(1)), 'LineWidth', 1.2);
    saveas(gcf, 'output_images/plot_error_rate.png');
    fprintf('Saved: output_images/plot_error_rate.png\n');

    %% -- Plot 2: AOC Comparison --
    figure('Name', 'Accurate Output Count', 'Position', [100 100 900 400]);
    aoc_vals = [acc_results.AOC];
    b = bar(aoc_vals, 'FaceColor', 'flat');
    b.CData(1,:) = [0.2 0.6 0.9];
    b.CData(2,:) = [0.1 0.4 0.8];
    for k = 3:n, b.CData(k,:) = [0.7 0.7 0.7]; end
    set(gca, 'XTickLabel', short_names, 'XTickLabelRotation', 30, 'FontSize', 9);
    ylabel('AOC (number of correct outputs)');
    title('Accurate Output Count - AOC (Higher is Better)');
    grid on;
    saveas(gcf, 'output_images/plot_aoc.png');
    fprintf('Saved: output_images/plot_aoc.png\n');

    %% -- Plot 3: MED Comparison --
    figure('Name', 'Mean Error Distance', 'Position', [100 100 900 400]);
    med_vals = [acc_results.MED];
    b = bar(med_vals, 'FaceColor', 'flat');
    b.CData(1,:) = [0.2 0.6 0.9];
    b.CData(2,:) = [0.1 0.4 0.8];
    for k = 3:n, b.CData(k,:) = [0.7 0.7 0.7]; end
    set(gca, 'XTickLabel', short_names, 'XTickLabelRotation', 30, 'FontSize', 9);
    ylabel('MED');
    title('Mean Error Distance - MED (Lower is Better)');
    grid on;
    saveas(gcf, 'output_images/plot_med.png');
    fprintf('Saved: output_images/plot_med.png\n');

    %% -- Plot 4: MSSIM Grouped Bar Chart (Table 6) --
    figure('Name', 'MSSIM Comparison', 'Position', [100 100 1000 450]);
    mssim_mul    = [img_results.mssim_mul];
    mssim_smooth = [img_results.mssim_smooth];
    mssim_sharp  = [img_results.mssim_sharp];

    data = [mssim_mul; mssim_smooth; mssim_sharp]';
    b = bar(data, 'grouped');
    b(1).FaceColor = [0.2 0.5 0.9];
    b(2).FaceColor = [0.4 0.8 0.4];
    b(3).FaceColor = [0.9 0.5 0.2];
    set(gca, 'XTickLabel', short_names, 'XTickLabelRotation', 30, 'FontSize', 9);
    ylabel('MSSIM');
    ylim([0, 1.05]);
    title('MSSIM Comparison for Image Processing Applications');
    legend({'Multiplication', 'Smoothing', 'Sharpening'}, 'Location', 'southeast');
    grid on;
    yline(0.9759, '--k', 'Paper Avg=97.59%', 'LineWidth', 1.2);
    saveas(gcf, 'output_images/plot_mssim.png');
    fprintf('Saved: output_images/plot_mssim.png\n');

    %% -- Plot 5: Overall Radar/Spider Chart for Proposed Designs --
    figure('Name', 'Design Comparison Radar', 'Position', [100 100 700 600]);

    % Normalize metrics for radar (higher = better for all axes)
    er_norm   = 1 - [acc_results.ER]   / 100;
    aoc_norm  = [acc_results.AOC] / max([acc_results.AOC]);
    med_norm  = 1 - [acc_results.MED]  / max([acc_results.MED]);
    mssim_avg = (mssim_mul + mssim_smooth + mssim_sharp) / 3;

    categories = {'Low ER', 'High AOC', 'Low MED', 'High MSSIM'};
    subplot(1,1,1);

    % Simple grouped bar as radar substitute
    scores = [er_norm(1:2); aoc_norm(1:2); med_norm(1:2); mssim_avg(1:2)]';
    b = bar(scores);
    b(1).FaceColor = [0.2 0.6 0.9];
    b(2).FaceColor = [0.9 0.4 0.2];
    set(gca, 'XTickLabel', categories, 'FontSize', 10);
    ylabel('Normalized Score (higher = better)');
    title('Proposed Designs: Normalized Performance Summary');
    legend({'Proposed Design 1', 'Proposed Design 2'}, 'Location', 'southeast');
    ylim([0 1.1]);
    grid on;
    saveas(gcf, 'output_images/plot_design_comparison.png');
    fprintf('Saved: output_images/plot_design_comparison.png\n');

    fprintf('\nAll plots saved to output_images/ folder.\n');
end
