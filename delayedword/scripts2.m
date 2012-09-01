blockpath='E:\PreprocessedFiles\EC22\EC22_B1'

load([blockpath filesep 'segmented_sorted_3to3s.mat']);
load([blockpath filesep 'zScoreall_sorted_3to3s.mat']);

load([blockpath filesep 'segmentedAnalog_sorted.mat']);
%%
zScoreall=seg;
zScoreall.data=zScore;
save('zScoreall_3to3s','zScoreall','-v7.3');
%%
allfiles=    {
    'E:\DelayWord\EC18\EC18_B1';
    'E:\DelayWord\EC18\EC18_B2';    
    'E:\DelayWord\EC20\EC20_B18';
    'E:\DelayWord\EC20\EC20_B23';
    'E:\DelayWord\EC20\EC20_B54';
    'E:\DelayWord\EC20\EC20_B64';
    'E:\DelayWord\EC20\EC20_B67';
    'E:\DelayWord\EC21\EC21_B1';
    'E:\DelayWord\EC22\EC22_B1'
    }
%%
baseline{1}='E:\DelayWord\EC18'

baseline{2}='E:\DelayWord\EC18'
baseline{8}=    'E:\DelayWord\EC21\EC21_B1';
    baseline{9}='E:\DelayWord\EC22'

seg={[repmat(41,[1 40]);1:40],[1:40;repmat(42,[1 40])],[42;43],[43;44],[44;45]}
            clear test
%%
for n=[2 9]
                test=SegmentedData([allfiles{n} '/HilbReal_4to200_40band']); 
                load([baseline{n} '\ecogBaseline.mat']);

            for ich=1:32:224
                %test=SegmentedData([allfiles{n} '/HilbReal_4to200_40band'],[baseline{n} '/HilbReal_4to200_40band',0); 
                 test=SegmentedData([allfiles{n} '/HilbReal_4to200_40band']); 

    %             if n==1
    %                 test.channelsTot=128;
    %             end
                ch=ich:ich+31;
                test.usechans=ch;
                test.channelsTot=length(test.usechans)
                test.Artifacts.badChannels=[];
                test.Artifacts.badTimeSegments=[];
                test.ecogBaseline.std=ecogBaseline.std(test.usechans,:,:,:);
                test.ecogBaseline.mean=ecogBaseline.mean(test.usechans,:,:,:);



                test.Params.sortidx=1;

                if n==2
                  test.segmentedDataEvents40band([seg(1:3) [43; 41]],{[2500 2500],[2500 2500],[2500 2500],[2500 2500]},'keep',[],'aa')

                else
                    test.segmentedDataEvents40band(seg,{[2500 2500],[2500 2500],[2500 2500],[2500 2500],[2500 2500]},'keep',[],'aa')
                end


                test.Params.indplot=1;
                test.BaselineChoice='ave';
                test.plotData('spectrogram')
                dos('cmd /c "echo off | clip"')
            end
            clear test
        end
end
    
%%   
cd('E:\DelayWord\EC20\EC20_B18\segmented_40band')
eventfolders=cellstr(ls);
alllog=eventfolders(3:7)'
r=1;
for n=2:length(allfiles)
    for e=1:5
        cd([allfiles{n} '\segmented_40band']);
            eventfolders=cellstr(ls);
            for f=3:length(eventfolders)
                idx=find(strcmp(eventfolders{f},alllog(1,:)));
                if idx
                    cd([allfiles{n} '\segmented_40band' filesep eventfolders{f}]);
                    %input('cont')
                    alllog{n+1,6}=length(ls)-2;
                    chanFile=cellstr(ls);
                    if length(chanFile)>2
                        for c=3%:length(chanFile)-1

                                 cd([allfiles{n} '\segmented_40band' filesep eventfolders{f} filesep chanFile{c}])
                            %alllog{n+1,idx}=[alllog{n+1,idx} length(ls)-2];
                                alllog{n+1,idx}=length(ls)-2;


                        end
                    end
                end
            end
    end
end
        
%%

ppt=saveppt2('batch.ppt','init');
for i=1:10
    plot(rand(1,100),rand(1,100),'*');
    saveppt2('ppt',ppt)
    if mod(i,5)==0 % Save half way through incase of crash
      saveppt2('ppt',ppt,'save')
    end
end
saveppt2('batch.ppt','ppt',ppt,'close');
%%
    save_file='C:\Users\Angela_2\Documents\Presentations\DelayWordAutoImages3.ppt'
N=10;
powerpoint_object=SAVEPPT2(save_file,'init')
load('E:\DelayWord\EC22\EC22_B1\activech')
load('E:\DelayWord\EC22\EC22_B1\baseline_ave')
for n=9%4:length(allfiles)
   %test=SegmentedData([allfiles{n} '/HilbReal_4to200_40band'],[baseline{n} '/HilbReal_4to200_40band'],0); 
    test=SegmentedData([allfiles{n} '/HilbReal_4to200_40band']); 

   test.Artifacts.badChannels=[];
   test.Artifacts.badTimeSegments=[];
    for e=1:5
        
            %test=SegmentedData([allfiles{n} '/HilbRel_4to200_40band'],[baseline{n} '/HilbReal_4to200_40band'],0); 
            if n==1
                test.channelsTot=128;
            else
                test.usechans=1:256%activech{e}
                test.channelsTot=length(test.usechans);
                %test.Artifacts.badtrials-[7 8];
            end 
            
           % test.loadSegments({[allfiles{n} '\segmented_40band\event' int2str(unique(seg{e}(1,:))) '_5000_5000']},10,1)
             %test.segmentedDataEvents40band(seg(e),{[5000 5000]},'keep',N)  
            %test.segmentedDataEvents40band(seg{e},{[3000 3000]},'keep')  
            test.segmentedDataEvents40band({[repmat([42;43],[1,40]);1:40]},{[3000 3000]},'keep',10)
            test.ecogBaseline.mean=baseline.mean(test.usechans,:,:);
            test.ecogBaseline.std=baseline.std(test.usechans,:,:);
            test.Params.indplot=1;
            test.BaselineChoice='ave';
            %test.Params.indplot=1;
            test.plotData('spectrogram')

            %keyboard
%             SAVEPPT2('ppt',powerpoint_object,'n',[allfiles{n} ' event=' int2str(unique( seg{e}(1,:))) ' buffer=' int2str([5000 5000])...
%                 ' N=' int2str(N) ' sprectrogram']);

%            test.resetCLimPlot
%               SAVEPPT2('ppt',powerpoint_object,'n',[allfiles{n} ' event=' int2str(unique( seg{e}(1,:))) ' buffer=' int2str([5000 5000])...
%                 ' N=' int2str(N) ' sprectrogram']);
%             saveppt2('ppt',powerpoint_object,'driver','bitmap','stretch','off');return;

%             test.plotData('image')
%             
%               SAVEPPT2('ppt',powerpoint_object,'n',[allfiles{n} ' event=' int2str(unique( seg{e}(1,:))) ' buffer=' int2str([5000 5000])...
%                 ' N=' int2str(N) ' sprectrogram']);
%             test.plotData('stacked')
%              powerpoint_object=SAVEPPT2(save_file,'init')
% 
%             SAVEPPT2('ppt',powerpoint_object,'n',[allfiles{n} ' event=' int2str(unique( seg{e}(1,:))) ' buffer=' int2str([5000 5000])...
%                 ' N=' int2str(N) ' stacked']);
%            keyboard
%             test.segmentedEcog(1).data=[];
%             test.segmentedEcog(1).event=[];
%             test.segmentedEcog(1).rt=[];
            close all

        
    end
    keyboard
      %saveppt2(save_file, 'ppt')
    clear test
    pack

end
%%
    save_file='C:\Users\Angela_2\Documents\Presentations\Autotest5.ppt'
    powerpoint_object=SAVEPPT2(save_file,'init')
    SAVEPPT2('ppt',powerpoint_object,'n','This is a test2');
    SAVEPPT2('ppt',powerpoint_object);
%
%%


figure
set(gcf,'Color','w')
ha = axes('units','normalized','position',[0 0 1 1]);
cd('E:\General Patient Info\EC18_v2')
imname='E:\General Patient Info\EC18_v2\brain+grid_3Drecon_cropped.jpg'
[xy_org,img] = eCogImageRegister(imname,0);
hi=imagesc(img);
colormap(gray)
set(ha,'handlevisibility','off')
imgsize=size(img);
xy(1,:)=xy_org(1,:)/imgsize(2);
xy(2,:)=1-xy_org(2,:)/imgsize(1);


% Plot individual selected zscores on brain image

for i=x:256
    %subplot(8,6,i-x+1-59)
    %subplot(2,1,1)
    chanNum=b(i);
    %ch=i;
    xy_coord=xy(:,ch);
    axes('position',[xy_coord(1),xy_coord(2),.03,.03]);
    hl=line([1200 1200],[-1 3]);
    %set(hl,'Color','r')
    set(hl,'Color','k');
    %title([num2str(ch)])
    hold on
    
    
    %subplot('Position',[xy_coord(1) xy_coord(2) xy_coord(1)+10 xy_coord(2)+1]);
    
    %     Y=zScoreall(2).data{event};
    %     zScore{i}=mean(Y,3);
    %     E = std(Y,[],3)/sqrt(size(Y,3));
    %     plot(zScore{i}(ch,:),'g')
    %     hold on
    %
    %     X=1:size(Y,2);
    %     hp=patch([X, fliplr(X)], [zScore{i}(ch,:)+E(ch,:),fliplr(zScore{i}(ch,:)-E(ch,:))],'y');
    %     set(hp,'FaceAlpha',.5)
    %     set(hp,'EdgeColor','none')
    
    
    Y=mean(test.segmentedEcog(1).zscore_separate(chanNum,:,:,:),4);
    
%     zScore{i}=mean(Y,3);
%     E = std(Y,[],3)/sqrt(size(Y,3));
%     plot(zScore{i}(ch,:),'r','LineWidth',.7);
%     set(gca,'Color','none');
%     miny=min(zScore{i}(ch,:));
    
    
    
    hold off
    
    %     X=1:size(Y,2);
    %     hp=patch([X, fliplr(X)], [zScore{i}(ch,:)+E(ch,:),fliplr(zScore{i}(ch,:)-E(ch,:))],'m');
    %     set(hp,'FaceAlpha',.5)
    %     set(hp,'EdgeColor','none')
    
    %axis([0 4000 -1 1])
    set(gca,'XTick',[0:400:2400]);
    %set(gca,'XTickLabel',[-3:1:3])
    set(gca,'XTickLabel',[]);
    set(gca,'YTickLabel',[]);
    set(gca,'Box','off');
    set(gca,'visible','off');
    
    
    try
        axis([0 2400 miny 3]);
        
    end
    %hold off
    %         subplot(2,1,2)
    %
    %         ECogDataVis (['C:\Users\Angela_2\Dropbox\ChangLab\General Patient Info\EC18'],'EC18',ch,[],2,[],[]);
    %         colormap(gray)
    %r=input('next')
    
end

%% Paste all images on ppt

allplots=cellstr(ls);
 powerpoint_object=SAVEPPT2(save_file,'init')
for i=3:length(allplots)
    openfig(allplots{i})
     SAVEPPT2('ppt',powerpoint_object,'n',[allplots{i} ])
     close
end
%%

for i=1:size(allEventTimes,1)
    if ~isempty(find(strcmp(allEventTimes{i,2},wordlist)))
        currentword=allEventTimes{i,2};
    elseif strmatch(allEventTimes{i-1,2},'slide')
            allEventTimes{i+1,3}=currentword;
        end

    allEventTimes{i,3}=currentword;
end

%% Corr between frequency bands
figure

set(gcf,'Color','w')
                            ha = axes('units','normalized','position',[0 0 1 1]);
                            cd(['E:\General Patient Info\' handles.patientID])
                            imname=[pwd filesep 'brain+grid_3Drecon_cropped2.jpg']
                            [xy_org,img] = eCogImageRegister(imname,0);
                            G=real2rgb(img,'gray');
                            hi=imagesc(G);
                            %colormap(gray)
                            set(ha,'handlevisibility','off')
                            imgsize=size(img);
                            xy(1,:)=xy_org(1,:)/imgsize(2);
                            xy(2,:)=1-xy_org(2,:)/imgsize(1);
for c=2:length(activech{2}),
    %subplot(5,8,c-1)
    for i=1:size(tmp,4),
        R(i,:,:)=corrcoef(squeeze(tmp(c,:,:,i)));,
    end,
      xy_coord=xy(:,activech{2}(c));
    ha=axes('position',[xy_coord(1),xy_coord(2),.03,.03]);
    imagesc(squeeze(mean(R,1))),
%    title(int2str(activech{2}(c))),
         set(gca,'XTickLabel',[]);
                        set(gca,'YTickLabel',[]);
                        %set(gca,'Box','off');
                        set(gca,'visible','off');
                        %axis([1500 3500 0 40])
                        text(1, 1,int2str(activech{2}(c)))
%      set(gca,'XTick',1:41);
%     set(gca,'YTick',1:41);
%     set(gca,'YTickLabel',activech{2});
%     set(gca,'XTickLabel',activech{2});
%     set(gca,'XTick',1:40);
%     set(gca,'YTick',1:40);
%      set(gca,'YTickLabel',round(cfs));
%      set(gca,'XTickLabel',round(cfs));
    %keyboard
    %print(gcf,'-dbitmap')
    %input('s'),
    
    
end
%%
load('E:\DelayWord\frequencybands');
tmp=test.segmentedEcog(1).zscore_separate(:,1200:1600,:,:);
for t=1:size(tmp,4)
    imagesc(flipud(squeeze((tmp(ch,:,:,t)))'))
    input('n')
end
imagesc(flipud(squeeze(mean(tmp(ch,:,:,:),4))'))

for f=1:40
    subplot(5,8,f)
    imagesc(flipud(squeeze((tmp(ch,:,f,:)))'),[0 4])
    colormap(flipud(pink))
    title(int2str(f))
    line([1200 1200],[0 52])
    %input('n')
end
    