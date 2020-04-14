% generowanie próbek
Aw = max(0, randn(1000, 10));
Xw = max(0, randn(10, 100));
Y = Aw * Xw;



[Xest, Aest] = optymalizacja_naprzemienna(@(x) x+1, @(a) a+1, 10);

% Alg. MUE

% Alg. ALS

% Alg. HALS


% wyznaczenie estymowanych faktorów A i B
% optymalizacja naprzemienna
function [X, A] = optymalizacja_naprzemienna(next_X_fun, next_A_fun, convergence)
    X = max(0, randn(10, 100));
    A = max(0, randn(1000, 10));
    for n=1:convergence %TODO 
        X = next_X_fun(X);
        A = next_A_fun(A);
    end
end
