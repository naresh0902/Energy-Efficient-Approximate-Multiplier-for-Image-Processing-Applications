function [Sum, Carry] = compressor_fang(X1, X2, X3, X4)
% COMPRESSOR_FANG - Fang et al. Design 1 (Reference [1])
% "Approximate multipliers based on a novel unbiased approximate 4-2 compressor"
% Integration, 2021.
%
% Unbiased design targeting reduced mean error distance.
% Error rate: 65.27%

    [X1r, X2r, X3r, X4r] = input_reorder(X1, X2, X3, X4);
    num_ones = X1r + X2r + X3r + X4r;

    if num_ones == 0
        Sum = 0; Carry = 0;
    elseif num_ones == 1
        Sum = 1; Carry = 0;
    elseif num_ones == 2
        Sum = 0; Carry = 1;
    elseif num_ones == 3
        Sum = 1; Carry = 1;
    else
        Sum = 0; Carry = 0;
    end
end
