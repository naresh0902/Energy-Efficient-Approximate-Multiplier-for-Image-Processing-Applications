function [Sum, Carry] = compressor_proposed1(Y1, Y2, Y3, Y4)
% COMPRESSOR_PROPOSED1 - Proposed Approximate 4:2 Compressor Design 1
%
% Implements equations (4) and (5) from the paper (Section 4.2).
% Uses the input reordering circuit then computes:
%   Sum   = X1 AND NOT(X2 OR X3 OR X4)
%   Carry = (X2 OR X3) AND NOT(X4)
%
% Error occurs ONLY when input has three 1s (1110 after reordering).
% Probability of error = 12/256 (only +1 error, never negative).
%
% Inputs:
%   Y1, Y2, Y3, Y4 - Raw input bits before reordering
%
% Outputs:
%   Sum, Carry - Approximate output bits

    [X1, X2, X3, X4] = input_reorder(Y1, Y2, Y3, Y4);
    Sum   = X1 & ~(X2 | X3 | X4);
    Carry = (X2 | X3) & ~X4;
end
