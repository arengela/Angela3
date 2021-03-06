classdef SegmentedData < handle
    properties
        %Set fields and defaults
        Filepath
        Events
        Baseline
        channelsTot=256;
        MainPath
        Params
        ecogFiltered
        folderType
        patientID
        gridlayout
        Artifacts
        eventParams
        segmentedEcog
        ecogBaseline
        BaselineChoice='ave';
        usechans=1:256;
        AssociatedFilePath
        FrequencyBands
    end
    methods
        function handles=SegmentedData(Filepath,BaselinePath,channels)
            %Initialize variables, load data
            %Inputs: Filepath= path to data to be loaded ie /data_store/EC3/EC3_B1/HilbAA_70to150_8band'
            %        BaselinePath=baseline path (enter '[]' is you want to
            %        take average of segment as baseline
            %        channels= channels to load
            
            [handles.MainPath,handles.folderType,~]=fileparts(Filepath);
            cd(Filepath)
            handles.Filepath=Filepath;
            cd(handles.Filepath)
            
            try
                [data, handles.Params.sampFreq, ~,chanNum] = readhtk ( 'Wav11.htk');
                handles.Params.sampDur=1000/handles.Params.sampFreq;
            catch
                [data, handles.Params.sampFreq, ~,chanNum] = readhtk ( 'ANIN1_400hz.htk');
                handles.Params.sampDur=1000/handles.Params.sampFreq;
            end
            handles.loadArtifacts
            handles.loadGridPic
            
            if nargin>2
                handles.usechans=channels;
                handles.channelsTot=length(channels);
            end
            
            if nargin>1
                if isempty(BaselinePath)
                    handles.BaselineChoice='ave';
                else isempty(BaselinePath) 
                    handles.BaselineChoice=BaselinePath;
                end
            end
            
            %Get Path for associated files for task
            tmp=fileparts(handles.MainPath);
            handles.AssociatedFilePath=fileparts(tmp);
            
            %Info about frequency bands
            handles.FrequencyBands.cfs=[4.07492865382648;4.49908599565877;4.96739366892354;5.48444726014817;6.05532070822666;6.68561609588494;7.38151862391541;8.14985730765295;8.99817199131751;9.93478733784706;10.9688945202963;12.1106414164533;13.3712321917698;14.7630372478308;16.2997146153059;17.9963439826350;19.8695746756941;21.9377890405926;24.2212828329065;26.7424643835396;29.5260744956615;32.5994292306116;35.9926879652699;39.7391493513881;43.8755780811850;48.4425656658129;53.4849287670791;59.0521489913229;65.1988584612231;71.9853759305396;79.4782987027759;87.7511561623698;96.8851313316256;106.969857534158;118.104297982645;130.397716922446;143.970751861079;158.956597405552;175.502312324739;193.770262663251;] ;
            handles.FrequencyBands.theta=[2 3 4 5 6 7 8];
            handles.FrequencyBands.alpha=[9 10 11 12 13];
            handles.FrequencyBands.beta=[14 15 16 17 18 19 20 21 22];
            handles.FrequencyBands.gamma=[23 24 25 26 27 28 29];
            handles.FrequencyBands.hg=[30 31 32 33 34 35 36 37];
            handles.Params.indplot=0;
        end
                
        
        function getDataParams(handles)
            %% GET ECOG DATA PARAMETERS
            cd(handles.Filepath)
            [data, handles.Params.sampFreq, ~,chanNum] = readhtk ( 'Wav11.htk');
            dataLength=size(data,2);
            bandNum=size(data,1);
            handles.ecogFiltered.data=zeros(handles.channelsTot,dataLength,bandNum);
            handles.ecogFiltered.sampFreq=handles.Params.sampFreq;
            handles.Params.sampDur=1000/handles.Params.sampFreq;
        end
        
        function showDataParams(handles)
            %% List Parameters of block
            if isempty(handles.Params.sampFreq)
                handles.getDataParams;
            else
                printf('Sampling Freq: %f Hz',handles.Params.sampFreq)
                printf('Block Duration: %f sec',size(handles.ecogFiltered.data,2)/handles.Params.sampFreq)
                printf('Number of Freq Bands: %d',size(handles.ecogFiltered.data,3))
            end
        end
        
        function loadArtifacts(handles)
            %% LOAD ARTIFACT FILES
            cd(sprintf('%s/Artifacts',handles.MainPath))
            load 'badTimeSegments.mat'
            handles.Artifacts.badTimeSegments=badTimeSegments;
            fprintf('%d bad time segments loaded',size(handles.Artifacts.badTimeSegments,1));
            fid = fopen('badChannels.txt');
            tmp = fscanf(fid, '%d');
            handles.Artifacts.badChannels=tmp';
            fclose(fid);
            fprintf('Bad Channels: %s',int2str(handles.Artifacts.badChannels));
            cd(handles.MainPath)
        end
        
        function loadGridPic(handles)
            %% LOAD GRID CHANNEL LAYOUT
            %% IF NO GRID FILE, USE REGULAR 256 LAYOUT
            tmp=regexp(handles.MainPath,'_','split');
            names=regexp(tmp{1},'\','split');
            handles.patientID=names{end};
            try
                load('gridlayout');
                usechans=reshape(gridlayout',1, size(gridlayout,1)*size(gridlayout,2));
                handles.gridlayout.dim=[size(gridlayout,1) size(gridlayout,2)];
            catch
                usechans=[1:handles.channelsTot];
                handles.gridlayout.dim=[16 16];
            end
            extra=0;
            if length(usechans)>256
                extra=usechans([256:length(usechans)]);
                usechans=usechans(1:256);
                extra=size(zScore,1)-256;
            end
            handles.gridlayout.usechans=usechans;
            handles.gridlayout.extra=extra;
        end
        
        function loadData(handles)
            %% LOAD ECOG DATA
            getDataParams(handles)
            if strmatch(handles.folderType,'HilbReal_4to200_40band')
                blockNum=floor(handles.channelsTot/64);
                elecNum=rem(handles.channelsTot,64);
                for chanNum=1:handles.channelsTot
                    data=loadHTKtoEcog_onechan_complex(handles.MainPath,chanNum,[]);
                    handles.ecogFiltered.data(chanNum,:,:)=data';
                    fprintf([int2str(chanNum) '.'])
                end
            elseif ~isempty(strfind(handles.MainPath,'Rat'))
                handles.ecogFiltered=loadHTKtoEcog_rat_CT(handles.MainPath,96,[])
            elseif strmatch(handles.folderType,'Analog')
                handles.ecogFiltered=loadAnalogtoEcog_CT(handles.MainPath,4,[]);
                handles.baselineChoice='None';
            else
                handles.ecogFiltered=loadHTKtoEcog_CT(handles.Filepath,handles.channelsTot,[]);
                handles.ecogFiltered.data=mean(handles.ecogFiltered.data,3);
            end
        end

        
        function loadBaselineFolder(handles,output,freqband)
            %% LOAD BASELINE FOLDER
            if nargin<2
                output='aa';
            end
            
            if nargin<3
                if  strmatch(handles.folderType,'HilbAA_70to150_8band')
                    freqband=1;
                else
                    freqband=1:40;
                end
            end
            
            cd(handles.BaselineChoice);
            fprintf('Baseline File opened: %s\n',handles.BaselineChoice);
            handles.BaselineChoice=handles.BaselineChoice;
            baselineMainPath=fileparts(handles.BaselineChoice);
            handles.ecogBaseline.data=[];
            handles.ecogBaseline.mean=zeros(length(handles.usechans),1,length(freqband));
            handles.ecogBaseline.std=zeros(length(handles.usechans),1,length(freqband));
            for c= 1:length(handles.usechans)
                        printf([int2str(c) '\n'])
                        chanNum=handles.usechans(c);
                        if strmatch(handles.BaselineChoice,'rest')
                            cd(handles.BaselineChoice)
                            tmp=fileparts(handles.BaselineChoice);
                        end
                        switch output
                            case 'aa'
                                if strmatch(handles.folderType,'HilbAA_70to150_8band')
                                    data=loadHTKtoEcog_onechan(chanNum,[]);
                                    data=mean(data,1);
                                    freqband=1;
                                else
                                    [R,I]=loadHTKtoEcog_onechan_complex_real_imag(tmp,chanNum,[]);
                                    data=complex(R,I);
                                end
                                handles.ecogBaseline.data(c,:,:)=abs(data(freqband,:)');
                                handles.ecogBaseline.zscore_separate(c,:,:)=zscore(abs(data(freqband,:)),[],2)';
                                handles.ecogBaseline.mean(c,1,:)=mean(abs(data(freqband,:)'),1);
                                handles.ecogBaseline.std(c,1,:)=std(abs(data(freqband,:)'),[],1);
                            case {'ds','filtered'}
                                data=loadHTKtoEcog_onechan(chanNum,[]);
                                handles.ecogBaseline.data(c,:,1,1)=mean(data,2);
                            case 'phase'
                                [R,I]=loadHTKtoEcog_onechan_complex_real_imag(tmp,chanNum,[]);
                                data=complex(R,I);
                                handles.ecogBaseline.data(c,:,:,1)=angle(data(freqband,:))';
                        end
            end
            cd( handles.MainPath)
        end
        
        function segmentedDataEvents40band(handles,subsetLabel,segmentTimeWindow,trialnum,output,freqband,sorttrials,getEventMatrix,transcriptionFile)
            %% LOAD TIMESEGMENTS FROM ECOG DATA ON DISK
            % INPUTS: subsetLabel (cell array)= index (from AllConditions file) of event you want to segment by (each cell array specifies different segmentation group) ex {[2],[3]}
                    %           second row is event to sort by ex {[2;3]}
                    %           third row specifies to what type
                    %           of event the event must belong to
            %          segmentTimeWindow (cell array)= pre and post buffer time (ms) around event(one cell corresponds to each subsetLabel) ex. {[500 1000].[500 1000]}
            %          trialnum (int)= max number of trials to load (if empty, load all)
            %          output  (string) = data form to be extracted
            %                  ex. 'aa' extracts Analytic Amplitude (default)
            %                      'phase' extracts phase info
            %                      'complex' extracts complex values
            %          freqband(int array)= frequency bands to extract; default is to take entire matrix on disk         
            %                      31:38 is high gamma range 
            %                      1:40 is all frequency bands
            %          sorttrials (binary)= sort trials by events in second row of subsetLabel
            %                       1 for sort/ 0 for do not sort
            % OUTPUT:  each event stored in separate array under handles.segmentedEcog
            %                    handles.segmentedEcog(1).data= channels x time x frequency
            %                    bands x trials
            %                    handles.segmentedEcog(1).event= event info for each trial
            
            if nargin<6
                freqband=1:40;
            end
            
            if strmatch(handles.folderType,'HilbAA_70to150_8band')
                freqband=1;
            end
            
            if nargin<8
                getEventMatrix='default';
            end
            if nargin<7
                sorttrials=0;
            end
            
            handles.eventParams.subsetLabel=subsetLabel;
            handles.eventParams.segmentTimeWindow=segmentTimeWindow;
            if nargin<9
                load([handles.MainPath '/Analog/allEventTimes.mat'])
                load([handles.MainPath '/Analog/allConditions.mat'])
            else
                [allEventTimes,allConditions]=readLabFile([handles.MainPath '/Analog/' transcriptionFile]);
            end
            
            %load baseline
            try
                handles.loadBaselineFolder(output,freqband);
            end
            allConditions=lower(allConditions);
            allEventTimes(:,2)=lower(allEventTimes(:,2));
            for i=1:length(handles.eventParams.subsetLabel)
                %% FIND EVENT TIMES FROM TRIALLOG
                try
                    curevent=allConditions(unique(handles.eventParams.subsetLabel{i}(1,:)));
                catch
                    curevent=intersect(allConditions,lower(handles.eventParams.subsetLabel{i}));
                end
                p3=find(ismember(allEventTimes(:,2),curevent));
                if size(handles.eventParams.subsetLabel{i},1)>2
                    pidx=find(ismember(allEventTimes(p3,3),allConditions(unique(handles.eventParams.subsetLabel{i}(3,:)))));
                    if ~isempty(pidx)
                        p3=p3(pidx);
                    end
                end
                
                if isempty(trialnum)
                    trialnum=length(p3);
                end
                buffer=handles.eventParams.segmentTimeWindow{i};                
                handles.segmentedEcog(i).data=zeros(handles.channelsTot, round(sum((buffer./1000)*handles.Params.sampFreq)),length(freqband),trialnum);               
                
                
                %% LOAD DATA FROM DISK ONE CHANNEL AND ONE TRIAL AT A TIME
                for s=1:trialnum
                    printf('%i.',s);
                    timeInt=[allEventTimes{p3(s),1}*1000-buffer(1) allEventTimes{p3(s),1}*1000+buffer(2)];
                    for badsegidx=1:size(handles.Artifacts.badTimeSegments,1)
                        if (timeInt(1)>handles.Artifacts.badTimeSegments(1) & timeInt(1)<handles.Artifacts.badTimeSegments(2)) | (timeInt(2)>handles.Artifacts.badTimeSegments(1) & timeInt(1)<handles.Artifacts.badTimeSegments(2))
                            continue
                        end
                    end
                    
                    [d,fs]=readhtk([handles.Filepath filesep 'Wav12.htk']);
                     if timeInt(2)>(size(d,2)/fs)*1000
                         continue
                     end
                    
                    %LOAD ANALOG
                    cd([handles.MainPath '/Analog'])
                    [an1,f]=readhtk(['ANIN1.htk'],round(timeInt));
                    [an2,f]=readhtk(['ANIN2.htk'],round(timeInt));               
                    handles.segmentedEcog(i).analog24Hz(1,:,1,s)=an1;
                    handles.segmentedEcog(i).analog24Hz(2,:,1,s)=an2;
                    handles.segmentedEcog(i).analog400Env(1,:,1,s)=resample(abs(hilbert(an1)),400,round(f));
                    handles.segmentedEcog(i).analog400Env(2,:,1,s)=resample(abs(hilbert(an2)),400,round(f));
                    
                    try
                        load(([handles.MainPath '/Analog/formants.mat']));
                        handles.segmentedEcog(i).formant100Hz(:,:,1,s)=formants(round(timeInt(1)/10):round(timeInt(2)/10),:)';
                    end
                        %GET EVENT INFORMATION
                    switch getEventMatrix
                        case 'DelayRep'
                            handles.segmentedEcog(i).event(s,1:4)=[allEventTimes(p3(s),1:2)  0 0 ];
                            curset=allEventTimes(p3(s),3);
                            try
                                sortbyword=unique(allConditions(handles.eventParams.subsetLabel{i}(2,:)));
                            end
                            position=5;
                            %Get events associated with same word
                            for ii=-5:6
                                try
                                    newset=allEventTimes(p3(s)+ii,2);
                                catch
                                    newset='none';
                                end
                                try
                                    if strmatch(allEventTimes(p3(s)+ii,3),curset)
                                        handles.segmentedEcog(i).event(s,position:position+1)=[allEventTimes(p3(s)+ii,1:2)];
                                        if strmatch(sortbyword,newset,'exact') & ii>0
                                            handles.segmentedEcog(i).event(s,3:4)=[allEventTimes(p3(s)+ii,1:2)];
                                        end
                                        position=position+2;
                                    elseif  strmatch(sortbyword,newset,'exact')
                                        handles.segmentedEcog(i).event(s,3:4)=[allEventTimes(p3(s)+ii,1:2)];
                                    end
                                end
                            end
                            handles.segmentedEcog(i).event(s,:);
                            load('E:\DelayWord\brocawords');
                            handles.Params.brocawords=brocawords;
                        otherwise
                            %Get event info from allEventTimes file
                            handles.segmentedEcog(i).event(s,:)=[allEventTimes(p3(s),:)];
                            try
                                curset=allEventTimes(p3(s),3);
                            end
                            try
                                sortbyword=unique(allConditions(handles.eventParams.subsetLabel{i}(2,:)));
                            end
                    end
                    
                    for c= 1:length(handles.usechans)
                        chanNum=handles.usechans(c);
                        cd(handles.Filepath)
                        switch output
                            case 'aa'
                                if strmatch(handles.folderType,'HilbAA_70to150_8band')
                                    data=loadHTKtoEcog_onechan(chanNum,round(timeInt));
                                    data=mean(data,1);
                                    freqband=1;
                                else
                                    [R,I]=loadHTKtoEcog_onechan_complex_real_imag(handles.MainPath,chanNum,round(timeInt));
                                    data=abs(complex(R,I));
                                end
                                handles.segmentedEcog(i).data(c,:,:,s)=data(freqband,:)';

                            case {'ds','filtered'}
                                data=loadHTKtoEcog_onechan(chanNum,round(timeInt));
                                handles.segmentedEcog(i).data(c,:,:,s)=data';
                            case 'phase'
                                [R,I]=loadHTKtoEcog_onechan_complex_real_imag(handles.MainPath,chanNum,round(timeInt));
                                data=complex(R,I);
                                handles.segmentedEcog(i).data(c,:,:,s)=angle(data(freqband,:))';
                            case 'complex'
                                [R,I]=loadHTKtoEcog_onechan_complex_real_imag(handles.MainPath,chanNum,round(timeInt));
                                data=complex(R,I);
                                handles.segmentedEcog(i).data(c,:,:,s)=data(freqband,:)';
                        end
                    end
                end
                trialnum=[];
            end
            
            %SORT TRIALS
            if sorttrials==1 & size(handles.eventParams.subsetLabel{i},1)<=2
                handles.sortTrials('event');
            elseif sorttrials==1
                handles.sortTrials('wordLength');
            end
            
        end
        
        function sortTrials(handles,sortBy)
            % SORT TRIALS BY SPECIFIED EVENT
            for i=1:length(handles.segmentedEcog)
                switch sortBy
                    case 'event' %Sort trials by specified event
                        rt=cell2mat(handles.segmentedEcog(i).event(:,3))-cell2mat(handles.segmentedEcog(i).event(:,1));
                        [~,sortidx]=sort(rt);
                        handles.segmentedEcog(i).rt=rt(sortidx);
                        handles.segmentedEcog(i).data=handles.segmentedEcog(i).data(:,:,:,sortidx);
                        handles.segmentedEcog(i).event=handles.segmentedEcog(i).event(sortidx,:);
                        try
                            handles.segmentedEcog(i).analog=handles.segmentedEcog(i).analog(:,:,:,sortidx);
                        end
                        try
                            handles.segmentedEcog(i).rt2=cell2mat(handles.segmentedEcog(i).event(:,1))-cell2mat(handles.segmentedEcog(i).event(:,6));
                        end
                    case 'wordLength' %sort trials by wordlength
                        load([handles.AssociatedFilesPath '\DelayWordFiles\wordlength']);
                        for idx=1:length(handles.segmentedEcog(i).event(:,7))
                            try
                                tmp=strmatch(handles.segmentedEcog(i).event(idx,7),wordlength(:,1));
                                wl(idx)=wordlength{tmp,2};
                            end
                        end
                        [sortedwl,sortidx]=sort(wl);
                        handles.segmentedEcog(i).wl=wl(sortidx);
                        handles.segmentedEcog(i).data=handles.segmentedEcog(i).data(:,:,:,sortidx);
                        handles.segmentedEcog(i).event=handles.segmentedEcog(i).event(sortidx,:);
                        handles.segmentedEcog(i).rt=cell2mat(handles.segmentedEcog(i).event(:,3))-cell2mat(handles.segmentedEcog(i).event(:,1));
                        try
                            handles.segmentedEcog(i).rt2=cell2mat(handles.segmentedEcog(i).event(:,1))-cell2mat(handles.segmentedEcog(i).event(:,6));
                        end
                end
            end
                
        end
        
        function plotData(handles,plottype,idx,compareFlag_type,compareFlag_onlyLong,compareFlag_equal,freqBandType,analogFlag)            
            if nargin<3
                idx=1;
            end
            if nargin<8
                analogFlag=1;
            end
            eventSamp=handles.eventParams.segmentTimeWindow{idx}(1)*handles.Params.sampFreq/1000;
            badChannels=handles.Artifacts.badChannels;            
            try
                gridlayout=handles.gridlayout.usechans;
                usechans=reshape(gridlayout',[1 size(gridlayout,1)*size(gridlayout,2)]);
                usechans=usechans(ismember(usechans,handles.usechans));
            end
            extra=handles.gridlayout.extra;            
            rowtot=handles.gridlayout.dim(1);
            coltot=handles.gridlayout.dim(2);
            
            usetrials=1:size(handles.segmentedEcog(idx).zscore_separate,4)
            if nargin<4
                compareFlag=input('Compare Trial Types? ([y]/n)\n','s');
                if ~strcmp('n',compareFlag)
                    indices=handles.findTrials; 
                else
                    indices.cond1=usetrials;
                end
            else
                indices=handles.findTrials(compareFlag_type,compareFlag_onlyLong,compareFlag_equal);
            end
            
            if nargin>6
                freqbands=handles.FrequencyBands.(freqBandType);
            else
                freqbands=1:size(handles.segmentedEcog(idx).zscore_separate,3); 
            end
            
            try
                r_time=handles.segmentedEcog(idx).rt(usetrials)*handles.Params.sampFreq;
            end 
            %%
            figure
            for i=1:length(usechans)
                epos=find(handles.gridlayout.usechans==usechans(i));                                
                switch plottype
                    case 'line'
                        [h,p]=plotGridPosition(epos);
                        h=subplot('Position',p);
                        hp=errorarea(mean(mean(handles.segmentedEcog(1).zscore_separate(usechans(i),:,freqbands,indices.cond1),3),4),...
                            ste(mean(handles.segmentedEcog(1).zscore_separate(usechans(i),:,freqbands,indices.cond1),3),4));
                        hold on
                        try
                            [hl,hp]=errorarea(mean(mean(handles.segmentedEcog(1).zscore_separate(usechans(i),:,freqbands,indices.cond2),3),4),...
                                ste(mean(handles.segmentedEcog(1).zscore_separate(usechans(i),:,freqbands,indices.cond2),3),4));
                            set(hl,'Color','r')
                            set(hp,'FaceColor','r')
                        end                        
                        hl=line([eventSamp,eventSamp],[0 5]);                        
                        set(hl,'Color','r')
                        axis tight
                        ht=text(p(1),p(2),int2str(usechans(i)));
                        set(h, 'ButtonDownFcn', @popupImage4)
                        hold on                        
                    case 'stacked'
                        [s,sidx]=sort(cell2mat(handles.segmentedEcog(idx).event(usetrials,9))- cell2mat(handles.segmentedEcog(idx).event(usetrials,7)));
                        usetrials=usetrials(sidx);
                        
                        [h,p]=plotGridPosition(epos);
                        hp=imagesc(squeeze(mean(handles.segmentedEcog(idx).zscore_separate(usechans(i),:,freqbands,usetrials),3))',[-1.5 1.5]);
                         axis tight
                        ht=text(p(1),p(2),int2str(usechans(i)));
                        hold on
                        for col=[5 7 9 11 13 15]
                            try
                                idx2=find(cellfun(@isempty,handles.segmentedEcog(idx).event(usetrials,col)));
                                if ~isempty(idx2)
                                    handles.segmentedEcog(idx).event{idx2,col}=NaN;
                                end
                                plot(eventSamp+(cell2mat(handles.segmentedEcog(idx).event(usetrials,col))...
                                    -cell2mat(handles.segmentedEcog(idx).event(usetrials,1)))*handles.Params.sampFreq,...
                                    [1:size(handles.segmentedEcog(idx).zscore_separate,4)],'r')
                            end
                        end 
                        plot([eventSamp eventSamp+.001],[0 size(handles.segmentedEcog(idx).zscore_separate,3)],'k')
                        set(h, 'ButtonDownFcn', @popupImage4)
                    case 'spectrogram'
                        for cond=1:2
                            if isfield(indices,['cond' int2str(cond)])
                                figure(cond);
                                [h,p]=plotGridPosition(epos);
                                hp=imagesc(flipud(squeeze(mean(handles.segmentedEcog(idx).zscore_separate(usechans(i),:,:,eval(['indices.cond' int2str(cond)])),4))'),[-1 3]);
                                hold on
                                plot([eventSamp eventSamp+0.001],[0 length(usetrials)],'k');
                                ht=text(p(1),p(2),int2str(usechans(i)));
                                set(h, 'ButtonDownFcn', @popupImage4)
                            end
                        end
                end
                set(gca,'xtick',[],'ytick',[])
                if find(ismember(badChannels,usechans(i)))
                    set(ht,'BackgroundColor','y')
                end
                try
                   if find(ismember(handles.Params.activeCh,usechans(i)))
                        set(ht,'BackgroundColor','g')
                   end
                end
                
                if analogFlag==0
                      plot(mean(mean(handles.segmentedEcog(1).analog400Env(1,:,1,indices.cond1),3),4).*4,'g')
                      hold on
                      try
                        plot(mean(mean(handles.segmentedEcog(1).analog400Env(1,:,1,indices.cond2),3),4).*4,'k')
                      end
                end
                colormap(flipud(pink));
            end
        end
        
     
        
        function listConditions(handles)
            %% LIST CONDITIONS FOR THIS BLOCK
            cd([handles.MainPath '/Analog'])
            load allConditions
            for i=1:length(allConditions)
                printf('%i. %s',i,allConditions{i});
            end
            cd([handles.MainPath '/Analog'])
        end
        
        function calcZscore(handles,onechan,collapseFreq)
            %% CALCULATE ZSCOREAT A TIME USING BASELINE SPEFICIED
            %% onechan: flag (1== calc one channel at a time, 0= calc all at once)
            %% collapseFreq: flag (1== ave all frequency bands before calculating zScore)
            if nargin<2
                onechan=0;
            end
            
            
            if nargin<3
                collapseFreq=0;
            end
            for i=1:length(handles.segmentedEcog)
                datalength=size(handles.segmentedEcog(1).data,2);
                
                if collapseFreq
                    handles.segmentedEcog(i).data=mean(handles.segmentedEcog(i).data,3);
                    handles.ecogBaseline.data=mean(handles.ecogBaseline.data,3);
                    handles.ecogBaseline.mean=mean(handles.ecogBaseline.data,2);
                    handles.ecogBaseline.std=std(handles.ecogBaseline.data,[],2);
                end               
                
                handles.segmentedEcog(i).zscore_separate=zeros(handles.channelsTot,datalength,size(handles.segmentedEcog(i).data,3),size(handles.segmentedEcog(i).data,4));
                for c=1:handles.channelsTot;
                    if onechan==0
                        c=1:handles.channelsTot;
                    end
                    switch handles.BaselineChoice
                        case'PreEvent'
                            %Use 300 ms before each event for baseline
                            samples=[ceil(handles.Params.baselineMS(1)*4/10):floor(handles.Params.baselineMS(2)*4/10)];%This can be changed to adjust time used for baseline
                            Baseline=handles.segmentedEcog(i).data(c,samples,:,:);
                            meanOfBaseline=repmat(mean(Baseline,2),[1, datalength,1,1]);
                            stdOfBaseline=repmat(std(Baseline,0,2),[1,datalength,1, 1]);
                        case 'RestEnd'
                            %Use resting at end for baseline
                            handles.ecogBaseline.data=handles.ecogBaseline.data(c,round(handles.baselineMS(1)*handles.sampFreq/1000:handles.baselineMS(2)*handles.sampFreq/1000),:,:);
                            meanOfBaseline=repmat(mean(handles.ecogBaseline.data,2),[1, datalength,1,size(handles.segmentedEcog(i).data,4)]);
                            stdOfBaseline=repmat(std(handles.ecogBaseline.data,0,2),[1, datalength,1,size(handles.segmentedEcog(i).data,4)]);
                       case 'ave'
                            if ~isfield('mean',handles.ecogBaseline)
                                handles.ecogBaseline.mean(c,:,:)=mean(mean(handles.segmentedEcog(i).data(c,:,:,:),4),2);
                                handles.ecogBaseline.std(c,:,:)=std(std(handles.segmentedEcog(i).data(c,:,:,:),[],4),[],2);
                            end
                            meanOfBaseline=repmat(handles.ecogBaseline.mean,[1, datalength,1,size(handles.segmentedEcog(i).data(c,:,:,:),4)]);
                            stdOfBaseline=repmat(handles.ecogBaseline.mean,[1, datalength,1,size(handles.segmentedEcog(i).data(c,:,:,:),4)]);
                    
                        otherwise
                            %use rest block for baseline
                            meanOfBaseline=repmat(handles.ecogBaseline.mean(c,:,:),[1, datalength,1,size(handles.segmentedEcog(i).data,4)]);
                            stdOfBaseline=repmat(handles.ecogBaseline.std(c,:,:),[1, datalength,1,size(handles.segmentedEcog(i).data,4)]);
                    end
                    handles.segmentedEcog(i).zscore_separate(c,:,:,:)=(handles.segmentedEcog(i).data(c,:,:,:)-meanOfBaseline)./stdOfBaseline;
                    if onechan==0
                        break;
                    end
                end
            end
        end
        
        function rejectExtremes(handles)
            %% REJECT TRIALS WITH DATA EXTREMES
            for event=1:length(handles.segmentedEcog)
                for c=1:handles.channelsTot
                    chanNum=c;
                    usetrials=[];
                    tmp=squeeze(mean(handles.segmentedEcog(event).zscore_separate(chanNum,:,:,:),3));
                    [a,badt]=find(tmp>7);
                    usetrials=setdiff(1:size(handles.segmentedEcog(event).zscore_separate(chanNum,:,:,:),4),unique(badt));
                    handles.segmentedEcog(event).usetrials{chanNum}=usetrials;
                end
            end
        end
        
        
        function resetCLimPlot(handles)
            %% RESET AXES OF PLOTS
            hplots=get(gcf,'Children');
            set(gcf,'Color','w')
            for  chanNum=1:length(hplots)
                axes(hplots(chanNum))
                axis tight
                set(hplots(chanNum),'CLim',[0 1.5]);
                %set(hplots(chanNum),'YLim',[-5 5]);
                %set(hplots(chanNum),'XLim',[1 2]);
                %axis tight
                set(hplots(chanNum),'XTickLabel',[]);
                set(hplots(chanNum),'YTickLabel',[]);
                pos=get(hplots(chanNum),'Position');
                if pos(2)>.5
                    set(hplots(chanNum),'Color',rgb('lightyellow'))
                else
                    set(hplots(chanNum),'Color',rgb('lavender'))
                end
                set(hplots(chanNum),'Color',rgb('white'))
                
                p=get(hplots(chanNum),'Position');
                epos=getGridPosition(p);
                text([0],[0],int2str(epos));
            end
            %%
            axes('position',[0,0,1,1],'visible','off');
            Locations={'L-Front','L-Par','L-Cent1','L-Cent','L-Lat','L-Subtmp','L-Depth','L-Micro'...
                'R-Front','R-Par','R-Cent1','R-Cent2','R-Lat','R-Subtmp','R-Depth','R-Micro'}
            Locations=fliplr(Locations);
            for n=1:16
                p(1)=6*(n-1)/100+.03;
                p(2)=.002
                text(p(2),p(1),Locations{n})
            end
        end
        
        
        
        function indices=findTrials(handles,r,r2,r3) 
            %Splits trials by event type
            %If no r,r2,r3 variables, will need user input
            if ~exist('r')
                r=input('Compare:\n 1. short vs long\n 2. easy vs difficult\n3. frequent vs infrequent\n 4. real vs pseudo\n 5. correct vs incorrect \n 6.real vs pseudo (delay word)\n','s');
            end
            
            if ~strcmp(r,'1')
                if ~exist('r2')
                    r2=input('Use long words only? (y/[n])','s');
                end
            else
                r2='n';
            end
            
            switch r
                case {'1','2','3','6'}
                    try
                        Labels=handles.segmentedEcog(1).event(:,8);
                    catch
                        Labels=handles.segmentedEcog(1).event(:,2);
                    end

                    try
                        brocawords=handles.Params.brocawords;
                    catch
                        load([handles.AssociatedFilePath filesep 'brocawords']);
                    end
                    all_label5=zeros(1,length(Labels));
                    
                    for i=1:length(Labels)
                        try
                            wordidx=find(strcmp(Labels{i},{brocawords.names}));
                            all_label1(i)=find(strcmp({'','','','short','long'},brocawords(wordidx).lengthtype));
                            all_label2(i)=find(strcmp({'easy','pseudo','hard'},brocawords(wordidx).difficulty));
                            all_label3(i)=brocawords(wordidx).logfreq_HAL;
                            all_label4(i)=wordidx;
                            all_label5(i)=find(strcmp({'real','pseudo'},brocawords(wordidx).realpseudo));
                          catch
                            wordidx=NaN;
                            all_label4(i)=wordidx;
                        end
                    end
                    if strcmp(r2,'y')
                        useidx=find(all_label1==5)%only long words
                    elseif strcmp(r,'1')
                        useidx=find(all_label5==1)%only real words
                    else
                        useidx=1:length(Labels);
                    end
                case '4'
                    Labels=handles.segmentedEcog(1).event(:,2);
                    all_label1=handles.segmentedEcog.event(:,3);
                    if strcmp(r2,'y')
                        useidx=find(all_label1==5)%only long words
                    else
                        useidx=1:length(Labels);
                    end
                    
                case '5'
                    Labels=handles.segmentedEcog(1).event(:,2);
                    all_label2=handles.segmentedEcog.event(:,5)';
                    if strcmp(r2,'y')
                        useidx=find(all_label1==5)%only long words
                    else
                        useidx=1:length(Labels);
                    end
                otherwise
                    printf('error')
            end
            
            switch r
                case '1'
                    all_label=all_label1;
                    conditions=[4 5];
                case '2'
                    all_label=all_label2;
                    conditions=[1 3];
                case '3'
                    all_label(find(all_label3<9))=2;%frequent vs less frequent
                    all_label(find(all_label3>9))=1;
                    conditions=[1 2];
                case '4'
                    all_label(find(strcmp('LD',all_label1) | strcmp('LE',all_label1) | strcmp('SE',all_label1) | strcmp('SD',all_label1)))=1;
                    all_label(find(strcmp('LP',all_label1) | strcmp('SP',all_label1)))=2;
                    conditions=[1 2];
                case '5'
                    all_label=cell2mat(all_label2);
                    conditions=[1 0];
                case '6'
                    all_label=all_label5;
                    conditions=[1 2];
                otherwise
                    all_label=all_label1;
                    conditions=[4 5];
            end
            
            if ~exist('r3')
                r3=input('Equal number in 2 groups?(y/[n])\n','s')
            end
            if strcmp(r3,'y')
                count=30;
                cont=0;
                while cont==0
                    useidx2=[find(all_label==conditions(1),count)  find(all_label==conditions(2),count)]%get 50/50 in training/test sets
                    if length(find(all_label(useidx)==conditions(1)))>=count & length(find(all_label(useidx)>=conditions(2)))>=count
                        cont=1;
                    else
                        count=count-1;
                    end
                end
            else
                useidx2=1:size(all_label,2);
            end
            all_label=all_label(useidx2);
            
            indices.cond1=intersect(useidx,find(all_label==conditions(1)));

            indices.cond2=intersect(useidx,find(all_label==conditions(2)));
            
            Labels([indices.cond1 indices.cond2]);
        end
    end
end
