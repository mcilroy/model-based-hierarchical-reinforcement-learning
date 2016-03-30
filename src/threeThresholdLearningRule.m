%http://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1004439
%weight matrix -- row = outgoing conections at node j, column = incoming connections at node i
function threeThresholdLearningRule()
    close all; clear;
    %% variable definition
    bin_size=40;
    N = 1001;
    lamda = 1.08;
    f = 0.5;
    theta = 350;
    psi = theta/(N-1); %0.35;
    epsilon = 0;
    eta = 0.01;
    gamma = 6;
    s = randi(2,N,1)-1;
    pattern = randi(2,N,1)-1;
    X = gamma*sqrt(N);
    w = normrnd(1,1,N,N);
    w(w<0)=0; % no negative weights
    w = w.*xor(1,eye(N,N)); % set wjj to 0
    H0 = (N-1)*(f*mean(w(:))-psi) + std(w(:))*inverse_H(f)*sqrt((N-1)*f);
    H1 = f*gamma*sqrt(N-1);
    theta0 = theta - (gamma + epsilon)*f*sqrt(N);
    theta1 = theta + (gamma + epsilon)*f*sqrt(N);
    
    %% present data once
    xi = pattern*X;
    inhibition = inh(s,H0,H1,f,N,X,xi,lamda);
    figure;
    subplot(2,2,1);
    histogram(w*s - inhibition,bin_size); title('without external input before learning');% without external input before learning
    v = w*s + xi - inhibition;
    s = v > theta;
    hamming_distance(pattern,s);
    subplot(2,2,2);
    histogram(w*s + xi - inhibition,bin_size); title('with external input before learning')% with external input before learning
    for t = 1:20;
        %% learn
        for i=1:size(v,1);
            if theta0 < v(i,1) && v(i,1) < theta
                w(:,i) = w(:,i) - eta*s; %incoming connections at i
                mask = w(:,i) >= 0;
                w(:,i) = w(:,i) .*mask;
            elseif theta < v(i,1) && v(i,1) < theta1
                w(:,i) = w(:,i) + eta*s;
                mask = w(:,i) >= 0;
                w(:,i) = w(:,i) .*mask;
            end
        end
        w(w<0)=0; % no negative weights
        w = w.*xor(1,eye(N,N)); % set wjj to 0
        %% present data once
        xi = pattern*X;
        inhibition = inh(s,H0,H1,f,N,X,xi,lamda);
        v = w*s + xi - inhibition;
        s = v > theta;
        hamming_distance(pattern,s);
    end
    xi = 0;
    for t = 1:20;
        v = w*s + xi - inhibition;
        s = v > theta;
        inhibition = inh(s,H0,H1,f,N,X,xi,lamda);
    end
    subplot(2,2,3);
    histogram(w*s + xi - inhibition, bin_size); title('without external input after learning'); % without external input after learning
    subplot(2,2,4);
    xi = pattern*X;
    histogram(w*s + xi - inhibition, bin_size); title('with external input after learning'); % with external input after learning
    %% test a noisy pattern
    pattern(1:500,1) = 1;%xor(1, pattern(1:1000,1));
    xi = pattern*X;
    inhibition = inh(s,H0,H1,f,N,X,xi,lamda);
    v = w*s + xi - inhibition;
    s = v > theta;
    hamming_distance(pattern,s)
end

function distance = hamming_distance(pattern, s)
    distance = sum(abs(pattern - s) > 0);
end

function H = inverse_H(f)
    H= sqrt(2)*erfcinv(2*f);
    %H = .5*erfc(f/sqrt(2));
end

function i = inh(s,H0,H1,f,N,X,x,lamda)
    i = H0 + H1*(sum(x)/(f*N*X)) + lamda * (sum(s) - f*N);
end
