% 线谱提取函数（背景均衡处理） 220720
% 输入：谱数据，单侧点数，丢弃大值点数，丢弃小值点数，门限(1：附近起伏标准差)
%例[line_ias1,line_num1]=line_detect_be_func(psd,10,3,3,8);


function [line_ias,line_num]=line_detect_be_func(data,half_len,max_len,min_len,gate)
%(1)搜索当前极大值，根据左右侧点数截取一段数据
%(2)对数据段进行一次背景均衡（一次）
%(3)除去max_len个最大值和min_len个最小值后计算均值与方差std
%(4)如果(当前点与均值的差值)>(gate*std),将该点的序号(1,2,...)、幅度、SNR保存，线谱计数++
%(5)返回(1)直至搜索结束

    data=(data(:)).';
%%---------------------线谱检测------------------------------------  
    dlen=length(data);
    fHL=10;%左右fHL点判频率线谱
    line_ias=[];
    line_num=0;
    
    for fi=3:(dlen-2)%增加条件为大于左右个两个值的判断
%         fi
       if (data(fi)>data(fi-1) && data(fi)>data(fi-2) && data(fi)>data(fi+1) && data(fi)>data(fi+2) )
           fii=max(1,fi-half_len):min(dlen,fi+half_len);
           tmp=data(fii);
           %%- 一次拟合
%            b1=-(length(tmp)-1)/2:(length(tmp)-1)/2;
%            b1=b1/(sum(b1.^2)).^0.5;
%            a0=mean(tmp);
%            a1=(tmp-a0)*b1.';
%            tmp_s=a1*b1+a0;
           %%- 不进行拟合
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
               line_ias=[line_ias;fi,data(fi),10*log10(data(fi)/(tmp_m+a0))];%freq,val,SNR %200709 修改SNR算法
               line_num=line_num+1;
           end

       end%if (datafs(fi)>datafs(fi-1) && datafs(fi)>datafs(fi+1))     
    end%for fi=2:(fL-1)
end