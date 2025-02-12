function [U, Z] = PCA(Y, J)
    %PCA(Y, J) dokonuje dekompopozycji macierzy obserwacji
    % param Y - macierz obserwacji
    % param J - liczba składowych głównych
    % returns U - macierz cech
    % returns Z - macierz składowych głównych
    covariance_matrix = double(Y) * double(Y');
    % Wyznaczenie J-wektorów własnych i J-wartości własnych
    [eigen_vectors, eigen_values] = eigs(covariance_matrix, J);
    U = eigen_vectors;     % macierz wektorów cech
    % Wyznaczenie i normalizacja macierzy składowych głównych
    Z = U' * double(Y);
end

