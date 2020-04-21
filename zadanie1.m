% generowanie próbek
Aw = max(0, randn(1000, 10));
Xw = max(0, randn(10, 100));
Y = Aw * Xw;
N = 100;

[MUE_X_est, MUE_A_est, MUE_RES, MUE_MSE, MUE_SIR, MUE_elapsed_time] = optymalizacja_naprzemienna(Y, @mue_next_x, @mue_next_a, N);
[ALS_X_est, ALS_A_est, ALS_RES, ALS_MSE, ALS_SIR, ALS_elapsed_time] = optymalizacja_naprzemienna(Y, @als_next_x, @als_next_a, N);
[HALS_X_est, HALS_A_est, HALS_RES, HALS_MSE, HALS_SIR, HALS_elapsed_time] = optymalizacja_naprzemienna(Y, @hals_next_x, @hals_next_a, N);

% wykresy
iter = 1:N;

subplot(3, 1, 1);
plot(iter, MUE_RES, '-o', iter, ALS_RES, '-x', iter, HALS_RES, '-*');
legend('MUE', 'ALS', 'HALS');
ylabel('Błąd residuidalny');
xlabel('Numer iteracji');

subplot(3, 1, 2);
plot(iter, MUE_MSE, '-o', iter, ALS_MSE, '-x', iter, HALS_MSE, '-*');
legend('MUE', 'ALS', 'HALS');
ylabel('MSE');
xlabel('Numer iteracji');

subplot(3, 1, 3);
plot(iter, MUE_SIR, '-o', iter, ALS_SIR, '-x', iter, HALS_MSE, '-*');
legend('MUE', 'ALS', 'HALS');
ylabel('SIR');
xlabel('Numer iteracji');

% Alg. MUE
function [A_next] = mue_next_a(A, X, Y)
    A_next = A.*(Y*X')./(A*(X*X') + eps);
    A_next = A_next * diag( 1 ./ sum(A_next, 1)); % A -> A_next
end

function [X_next] = mue_next_x(A, X, Y)
    X_next = X.*(A'*Y)./(A'*A*X);
end
% /Alg. MUE


% Alg. ALS
function [A_next] = als_next_a(A, X, Y)
    % A = Y * X^+
    A_next = Y * (X' * inv(X*X')); % TODO: alfa_x*I
    A_next = max(0, A_next);
end

function [X_next] = als_next_x(A, X, Y)
    % X = A^+ * Y
    X_next = inv(A' * A) * A' * Y;
    X_next = max(0, X_next);
end
% /Alg. ALS


% Alg. HALS
function [A_next] = hals_next_a(A, X, Y)
    C = Y * X';
    B = X * X';
    J = size(A, 2); % J kolumn
    A_next = A;
    for k=1:5
       for j=1:J
           A_with_negatives = A_next(:, j) +  (C(:, j) - A_next * B(:, j)) / B(j, j);
           A_next(:, j) = max(0, A_with_negatives);
       end
    end
end

function [X_next] = hals_next_x(A, X, Y)
    C = A' * Y;
    B = A' * A;
    J = size(X, 1); % J wierszy
    X_next = X;
    for k=1:5
        for j=1:J
           X_with_negatives = X_next(j, :) + (C(j, :) - B(j, :) * X_next) / B(j, j);
           X_next(j, :) = max(0, X_with_negatives);
        end
    end
end
% / Alg. HALS


% wyznaczenie estymowanych faktorów A i B
% optymalizacja naprzemienna
function [X, A, RES, MSE, SIR, elapsed_time] = optymalizacja_naprzemienna(Y, next_X_fun, next_A_fun, N)
    t_start = tic; 
    % inicjalizacja
    X = max(0, randn(10, 100));
    A = max(0, randn(1000, 10));
    RES = zeros(1, N); MSE = zeros(1, N); SIR = zeros(1, N);
    for n=1:N %TODO 
        % kroki algorytmu
        A = next_A_fun(A, X, Y);
        X = next_X_fun(A, X, Y);
        % obliczenie błędów dla n
        [RES(n), MSE(n), SIR(n)] = calcErrors(A*X, Y);
    end
    elapsed_time = toc(t_start);
end

function [res, mse, sir] = calcErrors(Y_est, Y)
    res = norm(Y - Y_est)/norm(Y);
    mse = immse(Y_est, Y); 
    sir = mean(CalcSIR(normalize(Y), normalize(Y_est)));
end

% credits: https://github.com/andrewssobral/TDALAB/blob/master/CalcSIR.m
function [SIR maps] = CalcSIR(A,Aest)
    % Sergio Cruces & Andrzej Cichocki
    % A(:,maps) matches Aest properly.  --Added by Guoxu Zhou
    
    % mean value should be extracted first --Added by Guoxu Zhou
    A=real(A);
    A=bsxfun(@minus,A,mean(A));
    Aest=bsxfun(@minus,Aest,mean(Aest));
    
    A=A*diag(1./(sqrt(sum(A.^2))+eps));
    Aest=Aest*diag(1./(sqrt(sum(Aest.^2))+eps));
    
    col=size(A,2);flag=zeros(1,col);
    MSE=inf*ones(1,col);
    for i=1:size(Aest,2)
        temp=min(sum(bsxfun(@minus,Aest(:,i),A).^2,1),...
            sum(bsxfun(@plus,Aest(:,i),A).^2,1));
        temp=max(temp,flag);
        [MSE(i),maps(i)]=min(temp);
        flag(maps(i))=inf;
    end
    SIR=-10*log10(MSE);
end

