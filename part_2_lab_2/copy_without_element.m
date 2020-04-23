function [A_without_n] = copy_without_element(A, n)
    A_without_n = A([1:(n-1) (n+1):end]);
end

