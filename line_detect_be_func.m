% ������ȡ�������������⴦�� 220720
% ���룺�����ݣ����������������ֵ����������Сֵ����������(1�����������׼��)
%��[line_ias1,line_num1]=line_detect_be_func(psd,10,3,3,8);


function [line_ias,line_num]=line_detect_be_func(data,half_len,max_len,min_len,gate)
%(1)������ǰ����ֵ���������Ҳ������ȡһ������
%(2)�����ݶν���һ�α������⣨һ�Σ�
%(3)��ȥmax_len�����ֵ��min_len����Сֵ������ֵ�뷽��std
%(4)���(��ǰ�����ֵ�Ĳ�ֵ)>(gate*std),���õ�����(1,2,...)�����ȡ�SNR���棬���׼���++
%(5)����(1)ֱ����������

    data=(data(:)).';
%%---------------------���׼��------------------------------------  
    dlen=length(data);
    fHL=10;%����fHL����Ƶ������
    line_ias=[];
    line_num=0;
    
    for fi=3:(dlen-2)%��������Ϊ�������Ҹ�����ֵ���ж�
%         fi
       if (data(fi)>data(fi-1) && data(fi)>data(fi-2) && data(fi)>data(fi+1) && data(fi)>data(fi+2) )
           fii=max(1,fi-half_len):min(dlen,fi+half_len);
           tmp=data(fii);
           %%- һ�����
%            b1=-(length(tmp)-1)/2:(length(tmp)-1)/2;
%            b1=b1/(sum(b1.^2)).^0.5;
%            a0=mean(tmp);
%            a1=(tmp-a0)*b1.';
%            tmp_s=a1*b1+a0;
           %%- ���������
            tmp_s=0;a0=0;
%             
           %--------background ------------------
           
           %-----freqency domain-----------------
           
           tmp1=tmp-tmp_s;%tmp1=tmp;
           for jj=1:max_len
               [a,b]=max(tmp1);
               tmp1=tmp1([1:b-1,b+1:end]);
           end

           for jj=1:min_len
               [a,b]=min(tmp1);
               tmp1=tmp1([1:b-1,b+1:end]);
           end

           tmp_m=mean(tmp1);
           tmp_std=std(tmp1);

           if (data(fi)-a0-tmp_m)>gate*tmp_std
               line_ias=[line_ias;fi,data(fi),10*log10(data(fi)/(tmp_m+a0))];%freq,val,SNR %200709 �޸�SNR�㷨
               line_num=line_num+1;
           end

       end%if (datafs(fi)>datafs(fi-1) && datafs(fi)>datafs(fi+1))     
    end%for fi=2:(fL-1)
end