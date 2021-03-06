classdef PLVtests_HG < handle    
    properties
        AllFilePaths
        AllBaselinePaths
        SegmentTypes
        UserChoice
        EventIdx
        FilePath
        BaselinePath
        eventVariables
        ActiveCh
        SubjectID
        Data
        %OtherCommands
    end
    
    methods
        function handles=PLVtests_HG(n,e,ch)   
        %INITIALIZES VARIABLES  
        %OPTIONAL INPUT: n= index to blockpath
        %%
            %paths of data blocks
            handles.AllFilePaths= {
                'E:\DelayWord\EC18\EC18_B1';
                'E:\DelayWord\EC18\EC18_B2';
                'E:\DelayWord\EC20\EC20_B18';
                'E:\DelayWord\EC20\EC20_B23';
                'E:\DelayWord\EC20\EC20_B54';
                'E:\DelayWord\EC20\EC20_B64';
                'E:\DelayWord\EC20\EC20_B67';
                'E:\DelayWord\EC21\EC21_B1';
                'E:\DelayWord\EC22\EC22_B1';
                'E:\DelayWord\EC23\EC23_B1';
                'E:\DelayWord\EC25\EC24_B2';
                'E:\DelayWord\EC24\EC24_B1';
                'E:\DelayWord\EC24\EC24_B3';
                '\data_store\human\prcsd_data\EC23\EC23_B1';
                'E:\PreprocessedFiles\EC26\EC26_B2';
                'C:\Users\ego\Documents\UCSF\EcogData\EC24\EC24_B1';
                'E:\DelayWord\EC16\EC16_B1';
                'E:\PreprocessedFiles\EC26\EC26_B6';
                'E:\PreprocessedFiles\EC26\EC26_B9';
                'E:\PreprocessedFiles\EC26\EC26_B12';
                'E:\PreprocessedFiles\EC26\EC26_B14';
                'E:\PreprocessedFiles\EC26\EC26_B18';
                'E:\PreprocessedFiles\EC26\EC26_B20';
                'E:\PreprocessedFiles\EC26\EC26_B23';
                'E:\PreprocessedFiles\EC26\EC26_B24';
                'E:\PreprocessedFiles\EC26\EC26_B26';
                'E:\PreprocessedFiles\EC26\EC26_B27';
                'E:\PreprocessedFiles\EC26\EC26_B28';
                'E:\PreprocessedFiles\EC26\EC26_B35';
                'E:\PreprocessedFiles\EC26\EC26_B36';
                }
            
            %path of associated baseline
            handles.AllBaselinePaths{1}='E:\DelayWord\EC18\EC18_rest'
            handles.AllBaselinePaths{2}='E:\DelayWord\EC18\EC18_rest'
            handles.AllBaselinePaths{8}=    'E:\DelayWord\EC21\EC21_B2';
            handles.AllBaselinePaths{9}='E:\DelayWord\EC22\EC22_B2'
            handles.AllBaselinePaths{10}= 'E:\DelayWord\EC23\EC23_B2';
            handles.AllBaselinePaths{11}='E:\DelayWord\EC25\EC24_B3'
            handles.AllBaselinePaths{12}='E:\DelayWord\EC24\EC24_B2'
            handles.AllBaselinePaths{14}= 'data_store\human\prcsd_data\EC23\EC23_B2';
             handles.AllBaselinePaths{15}='E:\PreprocessedFiles\EC26\EC26_B1';
            handles.AllBaselinePaths{16}= 'C:\Users\ego\Documents\UCSF\EcogData\EC24\EC24_B1';
            handles.AllBaselinePaths{17}= 'E:\DelayWord\EC16\EC16_rest';
            handles.AllBaselinePaths{18}= 'E:\PreprocessedFiles\EC26\EC26_B3';
            handles.AllBaselinePaths{19}= 'E:\PreprocessedFiles\EC26\EC26_B3';
            handles.AllBaselinePaths{20}= 'E:\PreprocessedFiles\EC26\EC26_B17';
            handles.AllBaselinePaths{21}= 'E:\PreprocessedFiles\EC26\EC26_B17'; 
            handles.AllBaselinePaths{22}= 'E:\PreprocessedFiles\EC26\EC26_B21';
            handles.AllBaselinePaths{23}= 'E:\PreprocessedFiles\EC26\EC26_B21';
            handles.AllBaselinePaths{24}= 'E:\PreprocessedFiles\EC26\EC26_B21';
            handles.AllBaselinePaths{25}= 'E:\PreprocessedFiles\EC26\EC26_B21';            
            handles.AllBaselinePaths{26}= 'E:\PreprocessedFiles\EC26\EC26_B32';
            handles.AllBaselinePaths{27}= 'E:\PreprocessedFiles\EC26\EC26_B32';
            handles.AllBaselinePaths{28}= 'E:\PreprocessedFiles\EC26\EC26_B38';
            handles.AllBaselinePaths{29}= 'E:\PreprocessedFiles\EC26\EC26_B38';            
            
            
            %load('E:\DelayWord\wordgroups')
            %load('E:\DelayWord\brocawords')
            %lh=wordgroups.lh
            lh=1:40%load all words            
            handles.SegmentTypes={[repmat([41],[1 length(lh)]);lh],[lh;repmat([42],[1 length(lh)])],[repmat([42],[1 length(lh)]);lh],[repmat([43],[1 length(lh)]);lh],[repmat([44],[1 length(lh)]);lh],[45;41]};
            
             if nargin<2
                  handles.EventIdx=[5];
            else
                  handles.EventIdx=e;
             end
            
            if nargin>0
                handles.ChooseBlock(n,ch);
            end
            
           

        end
        
        function ListBlocks(handles) 
        %%LISTS BLOCK PATHS    
            for i=1:length(handles.AllFilePaths)
                printf('%s. %s',num2str(i), handles.AllFilePaths{i})
            end
        end
            
        
        function ChooseBlock(handles,n,ch)
        %%    
        %%CHOOSE WHICH BLOCK OF DATA TO LOAD    
            handles.UserChoice=n;
            handles.FilePath=handles.AllFilePaths{handles.UserChoice};
            try
                handles.BaselinePath=handles.AllBaselinePaths{handles.UserChoice};
            end
            [a,b,c]=fileparts(handles.FilePath);
            [a,b,c]=fileparts(a);
            handles.SubjectID=b;
            try           
                load('E:\DelayWord\areamap')
            end
                %handles.ActiveCh=1:256;%load all channels   
            if ~isempty(ch)
                handles.ActiveCh=ch;
            elseif ~isempty(areamap(strcmp(b,{areamap.subj})).event(handles.EventIdx).allactive)
                handles.ActiveCh=unique(areamap(strcmp(b,{areamap.subj})).event(handles.EventIdx).allactive); %load active channels
            else
                %keyboard
                handles.ActiveCh=1:256;%load all channels    
            end
            handles.LoadAllChans;
        end               
        
        function handles=LoadAllChans(handles)    
        %% LOADS BASELINE AND ECOG SEGMENTS
            n=handles.UserChoice;
            seg=handles.SegmentTypes;            
            test=SegmentedData([handles.FilePath '/HilbAA_70to150_8band']);        
            

            test.usechans=handles.ActiveCh;
            test.channelsTot=length(test.usechans)
            test.Artifacts.badChannels=[];
            test.Artifacts.badTimeSegments=[];
            test.Params.sortidx=0;

            %Calc baseline
            try
                %test.loadBaselineFolder([handles.BaselinePath '/HilbAA_70to150_8band']);%load baseline files
            end
            %test.loadBaselineFolder([handles.BaselinePath '/HilbReal_4to200_40band'],'phase');%load baseline files

            test.BaselineChoice='PreEvent';%use specified pre-event segment as baseline
            %test.BaselineChoice='ave';%use rest block as baseline
            test.Params.baselineMS=[500 1000];%time of pre-event baseline (ms)
            test.Params.indplot=0;%do not plot individual channels
            test.Params.sorttrials=0;%1 to sort trials, 0 to skip sorting
            %test.segmentedDataEvents40band(seg(:,handles.EventIdx),{[2000 2000]},'keep',[],'phase',1:40)%load data segments

            test.segmentedDataEvents40band_2({[1:50;1:50]},{[2000 2000]},'keep',[],'aa',31:38)
            %test.segmentedDataEvents40band(seg(:,handles.EventIdx),{[2000 2000]},'keep',[],'aa',31:38)%load data segments
            
            test.calcZscore;%calculate zscore
            handles.Data=test;%save data object in handles                                                                          
        end       
        
%         function handles=OtherCommands(handles)
%             test.Params.indplot=0;%0 for plotting each channel individually and scrolling through each, 1 for plotting all on one figure            
%             handles.Data.plotData('stacked')%plot single stacked trials
%             handles.Data.plotData('line')%plot average ERPs
%             handles.Data.plotData('spectrogram')%ave spectrogram
%         end
    end
end