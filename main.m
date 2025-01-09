% Reading a sample file from X:ad.i16
FS=16000;

adFileName='x:\ad.i16';
fH=5000;%the upbound of freq

line_iast=[];
line_num2=0;

dwav=zeros(60*FS/100,1);
dwav2=dwav;
baseFreq=zeros(60,4);
bUAV=0;
ti=0;
fileCnt=-1;
while (1)
    fid=fopen(adFileName,'rb');
    while fid<=0
        disp([adFileName 'is not exist!']);
        pause(1);
    end
    head=fread(fid,4,'int16');
    while length(head)<4
        pause(0.01);
        fseek(fid,0,'bof');
        head=fread(fid,4,'int16');        
    end
    
    if fileCnt~=head(1) % new data frame
        ti=ti+1;
        FLEN=head(4);

        d1=fread(fid,'int16');
        while length(d1)<FLEN
            pause(0.01);
            fseek(fid,4*2,'bof');
            d1=fread(fid,'int16');
        end
        fileCnt=head(1);

        wavtmp=d1(1:100:end);
        dwav=[dwav((FS/100+1):end);wavtmp];

        [f_o,t_o,D_TF] = STFT_func (d1 ,FS/8,FS/8,FS);
        D_TF=sum(D_TF,1);
        DF=f_o(2);

        if ti==1
            D2_TF=ones(60,length(D_TF))*min(D_TF);     
        end

        D2_TF(2:end,:)=D2_TF(1:(end-1),:);
        D2_TF(1,:)=D_TF;

        fidx=1:ceil(fH/(f_o(2)));
        figure(2);
        subplot(2,2,4);imagesc(f_o(fidx),1:length(D2_TF(:,1)),log10(D2_TF(:,fidx)));
        xlabel('freq /Hz');
        ylabel('time /s');
        title('time spectrum');

        subplot(2,2,2);plot(f_o(fidx),D_TF(fidx));
        title('power spectrum');
        [line_ias,line_num]=line_detect_be_func(D_TF(fidx),15,6,6,10);
        bFreqTmp=zeros(1,4);
        bFreqCnt=0;

        if line_num>0
            % harmonic decision
            line_fab=[f_o(line_ias(:,1)).',line_ias(:,2),zeros(line_num,1)];
            for bi=1:(line_num-1)
               for bii=(bi+1):line_num
                   nn=round(line_fab(bii,1)/line_fab(bi,1));
                   if abs(line_fab(bi,1)-line_fab(bii,1)/nn)<DF
                       line_fab(bi,3)=line_fab(bi,3)+1;
                   end
               end
            end

            hold on;
            plot(f_o(line_ias(:,1)),line_ias(:,2),'b*');

            for jj=1:(line_num-1)
                if line_fab(jj,3)>=3
                    plot(line_fab(jj,1),line_fab(jj,2),'r*');
                    bUAV=1;
                    bFreqCnt=bFreqCnt+1;
                    if bFreqCnt<=4
                        bFreqTmp(bFreqCnt)=line_fab(jj,1);                   
                    end
                end
            end
            hold off; 
            line_iast=[line_iast;line_ias ones(line_num,1)*ti];
            line_num2=line_num2+line_num;
        end

        if bUAV==1
            dwav2=[dwav2((FS/100+1):end);wavtmp];
        else
            dwav2=[dwav2((FS/100+1):end);zeros(FS/100,1)];
        end
        baseFreq=[baseFreq(2:end,:);bFreqTmp];

        subplot(2,2,1);
        t_wav=(1:length(dwav))*100/FS;
        plot(t_wav,dwav,'b',t_wav,dwav2,'r',t_wav,dwav*0,'b');
        axis('tight');
        title('waveform of signal');

        subplot(2,2,3);
        plot(baseFreq,'b.');
        axis([0  60  0  1000]);
        title(['base freq',num2str(round(baseFreq(60,:)*10)/10)]);

    end
    fclose(fid);
    pause(0.01);
end


