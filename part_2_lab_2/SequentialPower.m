function [U, Y_est] = SequentialPower(Y, j)
    %SEQUENTIALPOWER wyznacza zadane J komponentów głównych; 
    %param j - liczba wektorów cech, które mają zostać zwrócone
    %returns U - wektory cechy cech
    %Y_est - macierz obserwacji estymowana 
    C = Y * Y';
    s = size(C, 1);
    U = rand(s, j);
    for k = 1:j
        [u, lambda] = Power(C);
        U(:, k) = u';
        C = C - lambda * u * u';
    end
    % Wyznaczenie i normalizacja Y_est
    Y_est_unnormalized = double(Y') * U;
    Y_est_normalized = normalize(Y_est_unnormalized, 'range');
    Y_est = 255 * Y_est_normalized;
end

function[x, lambda] = Power(matrix)
    %param matrix - macierz kowariancji
    %returns dominujący wektor własny x oraz dominującą wartość własną lambda
    s = size(matrix);
    x = rand(s(1),1);
    k = 0;
    while(k < 100)
        k = k + 1;
        x = matrix * double(x);
        x = x ./ norm(x);
    end
    lambda = (x' * matrix * x) / (x' * x);
end