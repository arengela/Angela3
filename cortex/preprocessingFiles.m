addpath(genpath('/home/angela/Dropbox'))
B=accessDatabase
b=B.searchTrials('s',{'EC28'},'t',{'Timit'})

for i=1:length(b)
    blocks(i).name=b{i};
end
main='/data_store/human/prcsd_data/CH'
main2='/data_store/human/raw_data/CH'
for i=3:length(blocks)
    mkdir([main filesep blocks(i).name filesep 'Artifacts'])
    cd([main filesep blocks(i).name])
    if length(dir([main filesep blocks(i).name filesep 'RawHTK']))-2<1
        copyfile([main2 filesep blocks(i).name filesep 'RawHTK'],[main filesep blocks(i).name filesep 'RawHTK'])
        copyfile([main2 filesep blocks(i).name filesep 'Artifacts'],[main filesep blocks(i).name filesep 'Artifacts'])

    end
    chanTot=length(dir([main filesep blocks(i).name filesep 'RawHTK']))-2;
    cd([main filesep blocks(i).name])
    contents=dir
    %if contents(3).date< datestr(now)
        %copyfile('/data_store/human/prcsd_data/EC28/EC28_B33/Artifacts',[main filesep blocks(i).name filesep 'Artifacts'])
        quickPreprocessing_ALL([main filesep blocks(i).name],2,0,1,[],[],chanTot);
    %end
end

