% ʱƵ�任���� 220720
function [f_o,t_o,D_TF] = STFT_func (Data,W_L,STEP,FS)
%����˵����
% Data    ���������� 
% W_L     ����    
% STEP    ���� 
% FS      ����Ƶ��
L1 =length(Data);             % ���������ݳ���
KK =floor((L1-W_L)/STEP+1);  %֡��
D_TF=zeros(KK,ceil(W_L/2));
for k=1:KK
    dataw = Data((k-1)*STEP+1:(k-1)*STEP+W_L);      % ��ȡһ������������
    fdata = abs(fft(dataw));
    D_TF(k,:) = fdata(1:ceil(W_L/2)).^2;    
end

f_o = (0:(length(D_TF)-1))*FS/W_L;
t_o = (0:(KK-1))*STEP/FS;


end