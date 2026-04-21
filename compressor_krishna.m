function [Sum, Carry] = compressor_krishna(X1, X2, X3, X4)
% COMPRESSOR_KRISHNA - L.H. Krishna et al. Design 2 (Reference [13])
% "Energy efficient approximate multiplier design with lesser error rate
%  using the probability-based approximate 4:2 compressor"
% IEEE Embedded Systems Letters, 2023.
%
% Probability-based design. Error rate: 75.94%

    [X1r, X2r, ~, ~] = input_reorder(X1, X2, X3, X4);
    Sum   = X1r & ~X2r;
    Carry = X2r;
end
