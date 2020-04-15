% generowanie próbek
Aw = max(0, randn(1000, 10));
Xw = max(0, randn(10, 100));
Y = Aw * Xw;
N = 100;

[Xest, Aest, RES, MSE, SIR, elapsed_time] = optymalizacja_naprzemienna(Y, @mue_next_x, @mue_next_a, N);

% wykresy
subplot(3, 1, 1);
plot(1:(N+1), RES);

subplot(3, 1, 2);
plot(1:(N+1), MSE);

subplot(3, 1, 3);
plot(1:(N+1), SIR);


% Alg. MUE
function [A_next] = mue_next_a(A, X, Y)
    A_next = A.*(Y*X')./(A*(X*X') + eps);
    A_next = A_next * diag( 1 ./ sum(A, 1));
end

function [X_next] = mue_next_x(A, X, Y)
    X_next = X.*(A'*Y)./(A'*A*X);
end
% /Alg. MUE

% Alg. ALS
function [A_next] = als_next_a(A, X, Y)
    A_next = A.*(Y*X')./(A*(X*X') + eps);
    A_next = A_next * diag( 1 ./ sum(A, 1));
end
% /Alg. ALS

function [X_next] = als_next_x(A, X, Y)
    X_next = X.*(A'*Y)./(A'*A*X);
end

% Alg. HALS

% / Alg. HALS


% wyznaczenie estymowanych faktorów A i B
% optymalizacja naprzemienna
function [X, A, RES, MSE, SIR, elapsed_time] = optymalizacja_naprzemienna(Y, next_X_fun, next_A_fun, N)
    % inicjalizacja
    t_start = tic; 
    X = max(0, randn(10, 100));
    A = max(0, randn(1000, 10));
    RES = zeros(1, N+1); MSE = zeros(1, N+1); SIR = zeros(1, N+1);
    for n=1:N %TODO 
        % calc errors
        [RES(n), MSE(n), SIR(n)] = calcErrors(A*X, Y);
        % alghoritm steps
        A = max(0, next_A_fun(A, X, Y));
        X = max(0, next_X_fun(A, X, Y));
    end
    [RES(n+1), MSE(n+1), SIR(n+1)] = calcErrors(A*X, Y);
    elapsed_time = toc(t_start);
end

function [res, mse, sir] = calcErrors(Y_est, Y)
    res = norm(Y - Y_est, 'fro')/norm(Y, 'fro');
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

