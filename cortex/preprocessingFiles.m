addpath(genpath('/home/angela/Dropbox'))
B=accessDatabase
b=B.searchTrials('s',{'EC28'},'t',{'Learning'})

for i=1:length(b)
    blocks(i).name=b{i};
end
main='/data_store/human/prcsd_data/EC28'
main2='/data_store/human/raw_data/EC28'
for i=12:length(blocks)
    mkdir([main filesep blocks(i).name filesep 'Artifacts'])
    cd([main filesep blocks(i).name])
    if length(dir([main filesep blocks(i).name filesep 'RawHTK']))-2<1
        copyfile([main2 filesep blocks(i).name filesep 'RawHTK'],[main filesep blocks(i).name filesep 'RawHTK'])
    end
    chanTot=length(dir([main filesep blocks(i).name filesep 'RawHTK']))-2;
    cd([main filesep blocks(i).name])
    contents=dir
    %if contents(3).date< datestr(now)
        copyfile('/data_store/human/prcsd_data/EC28/EC28_B33/Artifacts',[main filesep blocks(i).name filesep 'Artifacts'])
        quickPreprocessing_ALL([main filesep blocks(i).name],2,0,1,[],[],chanTot);
    %end
end

