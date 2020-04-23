function [res, mse, sir] = calcErrors(Y_est, Y)
    res = norm(Y - Y_est)/norm(Y);
    mse = immse(Y_est, Y); 
    sir = mean(CalcSIR(normalize(Y), normalize(Y_est)));
end