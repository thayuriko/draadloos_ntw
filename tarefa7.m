%% Q2. BER da BPSK no canal lento p/ SC e MRC com AWGN + Rayleigh, curvas com 1, 2 e 4 antenas
% --------------------------------------------------
% Adaptado de Krishna Pillai (www.dsplog.com)
% Rayleigh fading channel with selection diversity
% http://www.dsplog.com/db-install/wp-content/uploads/2008/09/script_selection_diversity_effective_snr.m
% --------------------------------------------------
% https://github.com/thayuriko/draadloos_ntw

clear all; close all; clc;

rand('state',0); randn('state',0); bar = waitbar(0,'Setting up...');

EbN0_db = 0:20;
nBits = 1e7;
EbN0 = 10.^(EbN0_db/10);
ber_awgn = zeros(1,length(EbN0));
m_naka = 3;
nRx = [1 2 4];  %vetor com a qtde de antenas
m = rand(1,nBits)>0.5;
x = 2*m-1;      %BPSK
step = 64;

for i=1:length(EbN0)    
    waitbar(EbN0_db(i)/length(EbN0),bar,'Please wait');
    
    for j=1:length(nRx)
        [err1, err2] = deal(0);
        
        for k=1:step:(nBits-rem(nBits,step))
            frame = x(k:k+step-1);
            
            N0 = 1/EbN0(i);
            n = sqrt(0.5*N0)*repmat((randn(nRx(j),1)+1i*randn(nRx(j),1)),1,step);
            r = repmat(nak_m(m_naka,nRx(j),1),1,step);

            sd = kron(ones(nRx(j),1),frame);
            y1 = sd.*r + n;

            rPower = r.*conj(r);
            [rMaxVal ind] = max(rPower,[],1);
            rMaxValMat = kron(ones(nRx(j),1),rMaxVal);

            ySel = y1(rPower==rMaxValMat);
            rSel = r(rPower==rMaxValMat);

            if j>1
                ySel = ySel.';
                rSel = rSel.';
            end

            yHat = sum(conj(r).*y1,1)./sum(r.*conj(r),1); 
            
            err1 = err1 + sum((ySel./rSel>0) ~= m(k:k+step-1));
            err2 = err2 + sum((yHat>0) ~= m(k:k+step-1));
        end
        
        ber_naka_sc(j,i) = err1/(nBits-rem(nBits,step));
        ber_naka(j,i) = err2/(nBits-rem(nBits,step));
    end
end
close(bar);

plot_mrc = figure('NumberTitle', 'off','units','normalized','outerposition',[0 0 1 1],'Name', 'Maximum Ratio Combining');
semilogy(EbN0_db,ber_naka(1,:),'-v','Linewidth', 2); hold on;
semilogy(EbN0_db,ber_naka(2,:),'-v','Linewidth', 2);
semilogy(EbN0_db,ber_naka(3,:),'-v','Linewidth', 2); hold off;
legend('nRx = 1', 'nRx = 2', 'nRx = 4');
title('Canal AWGN com desvanecimento Nakagami-m (m=3) utilizando MRC');
ylabel('BER'); xlabel('EbN0 (dB)');
grid on; axis([1 length(EbN0)-1 1e3/nBits 1]);

plot_sc = figure('NumberTitle', 'off','units','normalized','outerposition',[0 0 1 1],'Name', 'Selection Combining');
semilogy(EbN0_db,ber_naka_sc(1,:),'-^','Linewidth', 2); hold on;
semilogy(EbN0_db,ber_naka_sc(2,:),'-^','Linewidth', 2);
semilogy(EbN0_db,ber_naka_sc(3,:),'-^','Linewidth', 2); hold off;
legend('nRx = 1', 'nRx = 2', 'nRx = 4');
title('Canal AWGN com desvanecimento Nakagami-m (m=3) utilizando SC');
ylabel('BER'); xlabel('EbN0 (dB)');
grid on; axis([1 length(EbN0)-1 1e3/nBits 1]);

print(plot_mrc,'t7_q2_mrc','-dpng')
print(plot_sc,'t7_q2_sc','-dpng')

%% Q3
% --------------------------------------------------
% Adaptado de Krishna Pillai (www.dsplog.com)
% Rayleigh fading channel with Maximal Ratio Combining
% http://www.dsplog.com/db-install/wp-content/uploads/2008/09/script_ber_bpsk_rayleigh_channel_maximal_ratio_combining.m
% --------------------------------------------------
clear all; close all; clc;

rand('state',0); randn('state',0); bar = waitbar(0,'Setting up...');

EbN0_db = 0:40;
nBits = 1e7;
EbN0 = 10.^(EbN0_db/10);
[ber_awgn, ber_rayl] = deal(zeros(1,length(EbN0)));
nRx = [1 2 4];  %vetor com a qtde de antenas

m = rand(1,nBits)>0.5;
x = 2*m-1;      %BPSK

for i=1:length(EbN0)
    waitbar(EbN0_db(i)/length(EbN0),bar,'Please wait');
    
    for j=1:length(nRx)
        N0 = 1/EbN0(i);
        n = sqrt(0.5*N0)*(randn(nRx(j),nBits)+1i*randn(nRx(j),nBits));
        h = sqrt(0.5)*(randn(nRx(j),nBits)+1i*randn(nRx(j),nBits));

        sd = kron(ones(nRx(j),1),x);
        y = sd.*h + n;

        yHat =  sum(conj(h).*y,1)./sum(h.*conj(h),1); 
        err2 = sum((yHat>0)~= m);
        ber_rayl(j,i) = err2/nBits;
    end
    
    y0 = x + n(1,:);
    err0 = sum((y0>0)~= m);
    ber_awgn(i) = err0/nBits;
end

figure;
semilogy(EbN0_db, ber_rayl(1,:), '-o', 'Linewidth', 2); hold on;
semilogy(ber_rayl(2,:), '-d', 'Linewidth', 2);
semilogy(ber_rayl(3,:), '-s', 'Linewidth', 2);
semilogy(ber_awgn, '-*', 'Linewidth', 2);
grid on; axis([1 length(EbN0)-1 1e2/nBits 1]);
ylabel('BER'); xlabel('EbN0 (dB)');
legend('Rayleigh + MRC (nRx = 1)', 'Rayleigh + MRC (nRx = 2)', 'Rayleigh + MRC (nRx = 4)', 'AWGN');
title('BER da BPSK em um canal Rayleigh utilizando a t�cnica MRC');
close(bar);

Pt = 1e-3; Gt_db = 4; Gr_db = 8; Pl_db = 100; margem_db = 5; 
N0_db = -204; BER = 0.1e-2; B = 5e6; alpha = 0.25; Bmax = 0; M = 2;
Pt_db = 10*log10(Pt);
Pl = 10^(Pl_db/10);
N0 = 10^(N0_db/10);
Pr_db = Pt_db + (Gt_db + Gr_db) - Pl_db - margem_db;
Pr = 10^(Pr_db/10);

for i=1:length(nRx)+1
    if i == 1
        EbN01(i) = ((qfuncinv(BER*log2(M)/2)/sin(pi/M))^2)/(2*log2(M));
    else
        [a, EbN0_db1] = min(abs(ber_rayl(i-1,:)-BER)); %SNR correspondente ao valor mais pr�ximo da BER requerida
        EbN01(i) = 10^(EbN0_db1/10);
    end

    Rb1 = Pr/(N0*EbN01(i));
    Rs = Rb1/log2(M);
    Bcl(i) = Rs*(1+alpha);

    Rs = B/(1+alpha);
    Rb2 = Rs*log2(M);

    if B >= Bcl(i)
        if Bcl(i) > Bmax
            Bmax_id = i;
            Bmax = Bcl(i);
        end
    end
    
    Rb_kbps(i,1) = Rb1/1e3;
    Rb_kbps(i,2) = Rb2/1e3;
end

10*log10(EbN01)
Rb_kbps(:,1)'/10