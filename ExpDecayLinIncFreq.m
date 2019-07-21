clf
clear

fs =1000;

tspan = 1:0.001:150;
%y_s = 2.*sin(2.*tspan) + sin(0.01.*tspan .* tspan);

y_1 = exp(-0.01.*tspan).*sin(0.01.*tspan.*tspan);
y_1 = y_1';

y_2 = exp(-0.02.*tspan).*sin((1./150).*tspan.* tspan);
y_2 = y_2';



y_s = y_1 + y_2;
tspan = tspan';

clf
plot(tspan, y_s,'LineWidth', 1.5)
hold on
%plot(tspan, y_1)
%plot(tspan, y_2)

% Perform ensemble EMD
Ne = 750;
sigma_e = 1.75; % still works with sigma = 1.5
rng(50);
[m,n] = size(y_s);

avg_trials = [];
for trial_ =1:1:Ne
    noise_ = randn(m,1).*sigma_e;
    imf_ = emd(y_s + noise_, 'Interpolation', 'pchip', 'MaxNumIMF', 12);
    
    
    % add on to running avg
    if trial_ == 1
        avg_trials = imf_(:,1:12);
    end
    if trial_ >1
        current_N  = trial_-1;
        avg_trials = avg_trials + imf_(:,1:12);        
    end
end
imf_eemd = avg_trials./Ne;

imf_= imf_eemd;%emd(y_s, 'Interpolation', 'spline');
[hs,f,t,imfinsf,imfinse] = hht(imf_eemd, fs./2);

clf
plot(t, imf_(:,9))
hold on
%plot(t, y_1)
legend("imf","y_i")
%plot(t, y_1-imf_eemd(:,9),'LineWidth',1.5,'Color','blue')

clf
plot(t(10000:148000), 2.*pi.*imfinsf(10000:148000,9))
hold on
plot(t, (1./100).*tspan)
plot(t, (1./150).*tspan)
ylabel("freq")
xlabel("time")
ylim([0,1])

clf
plot(t(10000:148000), sqrt(imfinse(10000:148000,9)))
hold on
plot(t, exp(-(1./100).*tspan))
ylabel("amplitude")
xlabel("time")