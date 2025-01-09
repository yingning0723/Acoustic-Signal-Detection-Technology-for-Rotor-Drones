function varargout = Recorder(varargin)
% RECORDER MATLAB code for Recorder.fig
%      RECORDER, by itself, creates a new RECORDER or raises the existing
%      singleton*.
%
%      H = RECORDER returns the handle to a new RECORDER or the handle to
%      the existing singleton*.
%
%      RECORDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECORDER.M with the given input arguments.
%
%      RECORDER('Property','Value',...) creates a new RECORDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Recorder_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Recorder_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Recorder

% Last Modified by GUIDE v2.5 13-Mar-2022 19:57:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Recorder_OpeningFcn, ...
    'gui_OutputFcn',  @Recorder_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Recorder is made visible.
function Recorder_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Recorder (see VARARGIN)

% Choose default command line output for Recorder
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Recorder wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Recorder_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
global workingFlag myrecordering cnt idxp;
if ( get(hObject,'Value'))
    %system('E:\MatlabR2021a\SRTP\Recorder\MyRecorder\for_testing\MyRecorder.exe &');
    FS = 16000;
    workingFlag = 1;
    i = 0;       %所取数据在指定方位内的次数
    cnt = -1;
    pcnt = 0;    %处理的cnt

    adFileName='x:\ad.i16';
    line_iast=[];
    line_num2=0;
    fH=5000;%频率分析上限
            
    dwav=zeros(FS,1);  %%100倍降采样，画波形
    dwav2=dwav;               %%画检测信号，如果检测到就画出来
    baseFreq=zeros(60,4);     %%记录60s，每一秒检测的基频
    bUAV=0;                   %%提示有没有检测到谐波信号
    ti=0;
    fileCnt=-1;
    %特征线の中间变量
    mid=0;
    middle_num=zeros(1,4);
    middle_y=zeros(1,4);
    %
    while workingFlag
%         fid = fopen('x:\audio_data.bin','rb');
%         A1 = fread(fid,2,'int32');
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
            
            if fileCnt~=head(1)%新的数据帧
%                 data = fread(fid,'float32');
%                 fclose(fid);
                ti=ti+1;
                FLEN=head(4);
            
                pcnt = pcnt + 1;            
            
                data=fread(fid,'int16');
                while length(data)<FLEN
                    pause(0.01);
                    fseek(fid,4*2,'bof');
                    data=fread(fid,'int16');
                end
                fileCnt=head(1);
%                 idx=(1:FS)+(1-1)*FS; %%取下标构成
%                 
%                 data=data(idx);
                wavtmp=data(1:100:end); %%100倍降采样
                dwav=[dwav((FS/100+1):end);wavtmp];%%保证i是60s
    
                [f_o,t_o,D_TF] = STFT_func (data ,FS/8,FS/8,FS);
                D_TF=sum(D_TF,1);
                DF=f_o(2);
    
                if pcnt==1
                    D2_TF=ones(60,length(D_TF))*min(D_TF);  
                end
                
                D2_TF(2:end,:)=D2_TF(1:(end-1),:);  %%时谱图
                D2_TF(1,:)=D_TF;
        
                fidx=1:ceil(fH/(f_o(2)));
                imagesc(handles.axes4,f_o(fidx),1:length(D2_TF(:,1)),log10(D2_TF(:,fidx)));
                % imagesc(f_o(1:1000),t_o,(D_TF(:,1:1000)));
                xlabel(handles.axes4,'freq /Hz');
                ylabel(handles.axes4,'time /s');
                title(handles.axes4,'时频谱');
    
                plot(handles.axes2,f_o(fidx),D_TF(fidx));
                title(handles.axes2,'功率谱');
                xlabel(handles.axes2,'freq /Hz');
                ylabel(handles.axes2,'幅度/db');  
                 %%       
                jud_l=0;
                jud_r=0;
                for iii=1:1:125
                  jud_l=jud_l+D_TF(iii);
                end
                for jjj=125:1:625
                  jud_r=jud_r+D_TF(jjj);
                end 
                 %%
                [line_ias,line_num]=line_detect_be_func(D_TF(fidx),15,6,6,10);
                bFreqTmp=zeros(1,4);                          
                bFreqCnt=0;
        
                if line_num>0
                    %谐波判断，五个点是否有关系
                    line_fab=[f_o(line_ias(:,1)).',line_ias(:,2),zeros(line_num,1)];
                    for bi=1:(line_num-1)
                        for bii=(bi+1):line_num
                            nn=round(line_fab(bii,1)/line_fab(bi,1));
                            if abs(line_fab(bi,1)-line_fab(bii,1)/nn)<DF
                                line_fab(bi,3)=line_fab(bi,3)+1; %最后一个数代表有多少是倍频
                            end
                        end%for bii=2:line_num
                    end%for bi=1:(line_num-1)
        
                    hold(handles.axes2,'on');
                    plot(handles.axes2,f_o(line_ias(:,1)),line_ias(:,2),'b*');

                    for jj=1:(line_num-1)
                        if line_fab(jj,3)>=3
                            plot(handles.axes2,line_fab(jj,1),line_fab(jj,2),'r*');
                            bUAV=1;
                            bFreqCnt=bFreqCnt+1;
                            if bFreqCnt<=4
                                bFreqTmp(bFreqCnt)=line_fab(jj,1);                   
                            end
                        end
                    end
                    hold(handles.axes2,'off');
                    line_iast=[line_iast;line_ias ones(line_num,1)*pcnt];
                    line_num2=line_num2+line_num;
                end
                
                if jud_l<jud_r
                    if bUAV==1%时间累计
                        dwav2=[dwav2((FS/100+1):end);wavtmp];
                    else
                        dwav2=[dwav2((FS/100+1):end);zeros(FS/100,1)];
                    end
                    baseFreq=[baseFreq(2:end,:);bFreqTmp];
                end
            %
                target_div=200;
                if ((baseFreq(60,1)~=0)&&(ti==2)) 
                    target_div=baseFreq(60,1);
                end %默认第一个数据为基础倍频，再看实际数据吧

                if ti>1
                      middle_num=zeros(1,4);
                      middle_y=zeros(1,4);
                     for tim_1=1:60
                        for tim_2=1:4
                                ti_1=round(ti);                       
                                    mid=round(baseFreq((61-tim_1),tim_2)/target_div);
                                    if mid>0
                                    middle_num(mid)=middle_num(mid)+1;%四倍基频个数
                                    middle_y(mid)=(middle_y(mid)*(middle_num(mid)-1)+(baseFreq((61-tim_1),tim_2)))/middle_num(mid);%拟合直线，倍频平均
                                    end
                        end
                    end
                end
                %
                t_wav=(1:length(dwav))*100/FS;
                plot(handles.axes1,t_wav,dwav,'b',t_wav,dwav2,'b',t_wav,dwav*0,'b');
                axis(handles.axes1,'tight');
                title(handles.axes1,'信号波形');
                grid(handles.axes1,'on');
    
                plot(handles.axes3,baseFreq,'b.');
              %特征点拟合直线
                whether_have=0;%表示没有检测出无人机
                num_0=0;
                for mm=1:4
                    if middle_num(mm)>=3
                        num_0=num_0+1;
                       sound(sin(2*pi*25*(1:4000)/100));%警报声
                       yline(handles.axes3,middle_y(mm),'r');
                    end
                    if num_0>=2
                        whether_have=1;%表示检测出无人机
                    end
                end
                %
                if whether_have==1
                    set(handles.edit1,'string','监测到无人机');
                end
                axis(handles.axes3,[0  60  0  1000]);
                title(handles.axes3,'基频');              
        else
            fclose(fid);
        end
                pause(0.5);
%             end%for ii=1:length(tt)%每秒一次
            
    end
else
    workingFlag = 0;
end

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
global myrecordering;
if ( get(hObject,'Value'))
    [filname,~] = uiputfile('.wav');
    audiowrite(filname,myrecordering,22050);
end


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
global fn x Fs path cnt;
if ( get(hObject,'Value'))
    FS=44100;

    [fname,path] = uigetfile('.f32');
    fid=fopen(fname,'rb');
    data=fread(fid,'float32');
    fclose(fid);
    
    tt=(1:length(data))/FS;
    
    fH=5000;%限定处理范围，提升效率
    
    line_iast=[];
    line_num2=0;

    dwav=zeros(60*FS/100,1);  %%100倍降采样，画波形
    dwav2=dwav;               %%画检测信号，如果检测到就画出来
    baseFreq=zeros(60,4);     %%记录60s，每一秒检测的基频
    bUAV=0;                   %%提示有没有检测到谐波信号
    
    [f_o,t_o,D_TF] = STFT_func (data ,FS/4,FS/4,FS);
    
    fidx=1:ceil(fH/(f_o(2)));
    %特征线の中间变量
    mid=0;
    middle_num=zeros(1,4);
    middle_y=zeros(1,4);
    %


    for ti=1:length(D_TF(:,1))
        idx=(1:FS)+(ti-1)*FS; %%取下标构成
        d1=data(idx);
        wavtmp=d1(1:100:end); %%100倍降采样
        dwav=[dwav((FS/100+1):end);wavtmp];%%保证i是60s
    
        [f_o,t_o,D_TF] = STFT_func (d1 ,FS/8,FS/8,FS);
        D_TF=sum(D_TF,1);
        DF=f_o(2);
    
        if ti==1
            D2_TF=ones(60,length(D_TF))*min(D_TF);     
        end
        
        D2_TF(2:end,:)=D2_TF(1:(end-1),:);  %%时谱图
        D2_TF(1,:)=D_TF;
        
        fidx=1:ceil(fH/(f_o(2)));
        imagesc(handles.axes4,f_o(fidx),1:length(D2_TF(:,1)),log10(D2_TF(:,fidx)));
        % imagesc(f_o(1:1000),t_o,(D_TF(:,1:1000)));
        xlabel(handles.axes4,'freq /Hz');
        ylabel(handles.axes4,'time /s');
        title(handles.axes4,'时频谱');  
        
        plot(handles.axes2,f_o(fidx),D_TF(fidx)); 
        
         xlabel(handles.axes2,'freq /Hz');
         ylabel(handles.axes2,'幅度/db');        
        title(handles.axes2,'功率谱');
        [line_ias,line_num]=line_detect_be_func(D_TF(fidx),15,6,6,10);
        bFreqTmp=zeros(1,4);                          
        bFreqCnt=0;
        %
        jud_1=0;
        jud_2=0;
        for iii=1:1:50
          jud_1=jud_1+D_TF(iii);
        end
        for jjj=50:1:625
          jud_2=jud_2+D_TF(jjj);
        end 
        %
        if line_num>0
            %谐波判断，五个点是否有关系
            line_fab=[f_o(line_ias(:,1)).',line_ias(:,2),zeros(line_num,1)];
            for bi=1:(line_num-1)
                for bii=(bi+1):line_num
                    nn=round(line_fab(bii,1)/line_fab(bi,1));
                    if abs(line_fab(bi,1)-line_fab(bii,1)/nn)<DF
                        line_fab(bi,3)=line_fab(bi,3)+1; %最后一个数代表有多少是倍频
                    end
                end%for bii=2:line_num
            end%for bi=1:(line_num-1)
            
            hold(handles.axes2,'on');
            plot(handles.axes2,f_o(line_ias(:,1)),line_ias(:,2),'r*');
            
            for jj=1:(line_num-1)
                if line_fab(jj,3)>=3
                    plot(handles.axes2,line_fab(jj,1),line_fab(jj,2),'r*');
                    bUAV=1;
                    bFreqCnt=bFreqCnt+1;
                    if bFreqCnt<=4
                        bFreqTmp(bFreqCnt)=line_fab(jj,1);                   
                    end
                end
            end
            hold(handles.axes2,'off'); 
            line_iast=[line_iast;line_ias ones(line_num,1)*ti];
            line_num2=line_num2+line_num;
        end
        if jud_1<jud_2
            if bUAV==1%时间累计
                dwav2=[dwav2((FS/100+1):end);wavtmp];
            else
                dwav2=[dwav2((FS/100+1):end);zeros(FS/100,1)];
            end
            baseFreq=[baseFreq(2:end,:);bFreqTmp];
        end
            %%
        target_div=200;
        if ((baseFreq(60,1)~=0)&&(ti==2)) 
            target_div=baseFreq(60,1);
        end %默认第一个数据为基础倍频，再看实际数据吧

        if ti>1
              middle_num=zeros(1,4);
              middle_y=zeros(1,4);
             for tim_1=1:60
                for tim_2=1:4
                        ti_1=round(ti);                       
                            mid=round(baseFreq((61-tim_1),tim_2)/target_div);
                            if mid>0
                            middle_num(mid)=middle_num(mid)+1;%四倍基频个数
                            middle_y(mid)=(middle_y(mid)*(middle_num(mid)-1)+(baseFreq((61-tim_1),tim_2)))/middle_num(mid);%拟合直线，倍频平均
                            end
                end
            end
        end  
        %%
        
        t_wav=(1:length(dwav))*100/FS;
        plot(handles.axes1,t_wav,dwav,'b',t_wav,dwav2,'r',t_wav,dwav*0,'b');
    %
        axis(handles.axes1,'tight');
        title(handles.axes1,'信号波形');
        
        plot(handles.axes3,baseFreq,'b.');
        %
         whether_have=0;%表示没有检测出无人机
            num_0=0;
            for mm=1:4
                if middle_num(mm)>=3
                    num_0=num_0+1;
                   sound(sin(2*pi*25*(1:4000)/100));%警报声
                   yline(handles.axes3,middle_y(mm),'r');
                end
                
                if num_0>=2
                    whether_have=1;%表示检测出无人机
                end
            end
            %
            if whether_have==1
                set(handles.edit1,'string','监测到无人机');
            end
           %
        axis(handles.axes3,[0  60  0  1000]);
        title(handles.axes3,'基频');

pause(0.5);
    end

end

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
global myrecordering cnt;
data_TF=[];
plot(handles.axes1,myrecordering);
title(handles.axes1,num2str(cnt));

dataf=fft(myrecordering);
datap=abs(dataf).^2;
datap=datap(1:end/2);
plot(handles.axes2,log10(datap));

data_TF=[ datap data_TF];
imagesc(handles.axes3,log10(data_TF.'));



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');

end
