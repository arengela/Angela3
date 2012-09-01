function [ps_raw,realPLV,bse]=PLVstats(zscore_stack1,zscore_stack2,baseline,bPLV,chanNum)
%%do single condition statistics on one condition
%%Use range null hypothesis: zscore-delta>0 for zscore>delta | zscore+delta<0 for zscore<-delta (latencies within "good enough" belt of baseline)
%%delta is the bootstrap standard error of baseline means
%%INPUTS:
%%ZSCORE_STACK= N BY S MATRIX OF SINGLE CONDITION ZSCORES WHERE N IS NUMBER
%%OF TRIALS AND S IS NUMBER OF SAMPLES
%%ZSCORE_BASELINE=
%%  1 BY Sb ARRAY OF BASELINE ZSCORES IF TAKEN FROM END OR REST BLOCK
%%  1 BY 2 ARRAY OF SAMPLE INDEX OF ZSCORE_STACK IF BASELINE TAKEN FROM BEFORE EACH EVENT ONSET
%%TEST_SAMP= 1 BY St ARRAY OF SAMPLES IN ZSCORE_DATA TO PERFORM STATS ON
%%OUTPUT:
%%PS_RAW= UNCORRECT P VALUES

%%Make baseline PLV belt
%%Get baseline stack resampling
%%Calc PLV for new stack
%%Repeat 10000x
%%Get Error Belt

zscore_baseline=length(baseline);

ps=repmat(NaN,[1,size(zscore_stack1,2)]); 




%%Calculate PLV_1_2
%%Get test samps outside of baseline error belt; only use those for
%%bootstrap PLV
nboot=10;
boot_means=zeros([1 nboot]);
newbase=zeros(2,2000,10);
for i=1:nboot
    for s=1:10
        rand_idx=ceil(rand(1,2000)*zscore_baseline);
        newbase(:,:,s)=baseline(:,rand_idx);
        
    end
    tmp=pn_eegPLV_modified(newbase,400,[],[]);  
    boot_means(i)=mean(tmp(:,1,2));
    
end
bse=sqrt(sum((mean(boot_means)-boot_means).^2)/(nboot-1));%Calculate the standard error of the bootstrap distribution of baseline mean (d aka delta)


%%Make distribution of PLV
%%Make zscore_stack2 stack by resampling
%%Calc PLV between original zscore_stack1 and new zscore_stack2
%%Repeat 10000
%%Calc significance


baselinePLVmean=repmat(mean(boot_means),[1 size(zscore_stack1,2)]);
baselinePLVstd=repmat(std(boot_means),[1 size(zscore_stack1,2)]);

%baselinePLVmean=repmat(bPLV(1).mean(1,chanNum(1),chanNum(2)),[1 2000]);
%baselinePLVstd=repmat(bPLV(1).std(1,chanNum(1),chanNum(2)),[1 2000]);

% baselinePLVmean=repmat(mean(boot_means),[1 2000]);
% baselinePLVstd=repmat(std(boot_means),[1 2000]);
nboot=10;
bootPLV=zeros(nboot,size(zscore_stack1,2));
for i=1:nboot
    newIdx=ceil(rand(1,size(zscore_stack2,1))*size(zscore_stack2,1));
    zscore_stack2_sur=zscore_stack2(newIdx,:);
    tmp=cat(3,zscore_stack1,zscore_stack2_sur);
    tmp2=permute(tmp,[3 2 1]);
    tmpPLV=pn_eegPLV_modified(tmp2,400,[],[]);
    bootPLV(i,:)=(squeeze((tmpPLV(:,1,2)))'-baselinePLVmean)./baselinePLVstd;
end
    tmp=cat(3,zscore_stack1,zscore_stack2);
    tmp2=permute(tmp,[3 2 1]);
    tmpPLV=pn_eegPLV_modified(tmp2,400,[],[]);
    realPLV=(squeeze((tmpPLV(:,1,2)))'-baselinePLVmean)./baselinePLVstd;
    
    ps=zeros(1, size(zscore_stack1,2));
    for s=1:size(zscore_stack1,2)
        ps(s)=length(find(bootPLV(:,s)>=realPLV(s)))/1000;
    end 
    ps_raw=ps;

    