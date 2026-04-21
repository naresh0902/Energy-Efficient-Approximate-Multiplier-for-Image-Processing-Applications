function [X1, X2, X3, X4] = input_reorder(Y1, Y2, Y3, Y4)
% INPUT_REORDER - Rearranges 4 input bits so that 1s occupy MSB positions
%
% This implements the input reordering circuit from Fig. 3 of the paper.
% It reduces 16 possible input combinations to only 6 unique combinations,
% decreasing switching activity and power consumption.
%
% Inputs:
%   Y1, Y2, Y3, Y4 - Original 4 input bits (0 or 1)
%
% Outputs:
%   X1, X2, X3, X4 - Reordered bits with 1s at MSB positions
%
% Example:
%   inputs 1000, 0100, 0010, 0001 all yield output 1000

    bits = sort([Y1, Y2, Y3, Y4], 'descend');
    X1 = bits(1);
    X2 = bits(2);
    X3 = bits(3);
    X4 = bits(4);
end
