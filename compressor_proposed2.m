function [Sum, Carry] = compressor_proposed2(Y1, Y2, Y3, Y4)
% COMPRESSOR_PROPOSED2 - Proposed Approximate 4:2 Compressor Design 2
%
% Implements equations (6) and (7) from the paper (Section 4.3).
% Minimizes gate count:
%   Sum   = X1  (after reordering)
%   Carry = X2  (after reordering)
%
% Errors occur when input has 2 or 4 ones.
% Total error probability = 55/256.
% Higher error rate but lower hardware cost than Design 1.
%
% Inputs:
%   Y1, Y2, Y3, Y4 - Raw input bits before reordering
%
% Outputs:
%   Sum, Carry - Approximate output bits

    [X1, X2, X3, X4] = input_reorder(Y1, Y2, Y3, Y4);
    Sum   = X1;
    Carry = X2;
    % X3, X4 intentionally unused (hardware simplification)
end
