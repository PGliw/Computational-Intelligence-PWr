% Generowanie faktorów
I = [10 20 30]; % liczby elementów w poszczególnych modach
J = 5; % rząd faktoryzacji
U{1} = max(0, rand(I(1), J));
U{2} = max(0, rand(I(2), J));
U{3} = max(0, rand(I(3), J));

% Generowanie syntetycznych obserwacji
% ones(J, 1) - wektor kolumnowy wag (wszystkie takie same i równe 1)
Y=ktensor(ones(J, 1), U);

% dekompozycja tensora obserwacji i pomiar błędów
[U_est, err] = CP(Y, 2, J, 10, @unfold3, U);

% wykresy
iter = 1:size(err, 1);
RES = err(:, 1);
MSE = err(:, 2);
SIR = err(:, 3);

subplot(3, 1, 1);
plot(iter, RES, '-o');
ylabel('Błąd residuidalny');
xlabel('Numer iteracji');

subplot(3, 1, 2);
plot(iter, MSE, '-o');
ylabel('MSE');
xlabel('Numer iteracji');

subplot(3, 1, 3);
plot(iter, SIR, '-o');
ylabel('SIR');
xlabel('Numer iteracji');


function [U, errors] = CP(Y, p, J, iterations, unfold, U_original)
%CP wykonuje dekompozycje tensora Y na faktory z rzędem faktoryzacji J
% p określa normę zastosowaną do normalizacji faktorów
% itenrations określa liczbę iteracji
% unfold to funkcja o sygnaturze (tensor, mod) => macierz
% przekazanie funkcji unfold jako praramter pozwala w przyszłości rozwinąć
% ten program dla liczby modów > 3 
% (obecnie zaimplementowaliśmy tylko unfold dla N=3 modów)
% U_original to cell array przekazywana tylko w liczenia błędów

   % Pomiar błędów w funkcji iteracji
   errors = zeros(iterations, 3);

   % N - liczba modów
   I = size(Y);
   
   % losowa inicjalizacja faktorów
   U = cell(1, 3);
   for i=1:size(I, 2)
       U{i} = max(0, rand(I(i), J));
   end
   
   N = size(Y.u, 1); % liczba modów
   Y_arr = double(Y); % konwersja tensora na tablicę wielowymiarową
   
   % wyznaczanie faktorów powtórzone iterations razy
   for i = 1:iterations
       % błędy dla poszczgólnych faktorów w iteracji
       n_errors = zeros(N, 3); % mierzymy 3 typy błędów
       
       % przemiatanie po wszystkich (N) modach tensora obserwacji Y
       for n = 1:N
           % Matrycyzacja względem n-tego modu
           Yn = unfold(Y_arr, n);
           
           % Estymacja n-tego faktora za pomocą m. najmniejszych kwadratów
           
           % Iloczyn Hadamana faktorów poza n-tym
           indexes_without_n = copy_without_element(1:N, n);
           B = ones(J, J);
           for j = indexes_without_n
              B = B .* (U{j}' * U{j});
           end
           
           % Iloczyn Khatri-Rao faktorów poza n-tym
           kr_indexes = flip(indexes_without_n);
           for j = 1:size(kr_indexes, 2)-1               
               current_index = kr_indexes(j);
               next_index = kr_indexes(j+1);
               U_kr = kr(U{current_index}, U{next_index});
           end
           
           % Estymacja U{n}
           U{n} = (Yn * U_kr) / B; 
           
           % Skalowanie n-tego faktora
           if n ~= N
               coefficient = inv(diag(vecnorm(U{n}, p)));
               U{n} = U{n} * coefficient;
           end
           
           % Liczenie błędów dla n-tego modu w i-tej iteracji
           [res, mse, sir] = calcErrors(U{n}, U_original{n});
           n_errors(n, :) = [res, mse, sir];
       end
       
       % uśrednione błędy ze wszystkich modów dla i-tej iteracji
       errors(i, :) = mean(n_errors);
   end
end




