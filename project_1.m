% Ashley Larweck
% 10.26.2020
% BME 4293-002
% Project I

% Import data from text file
% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 4);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["x", "y", "z", "HU_VAL"];
opts.VariableTypes = ["double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
S1 = table2array(readtable('Subject1_Baseline.txt', opts));
S1_Post = table2array(readtable('Subject1_one_year.txt', opts));
S2 = table2array(readtable('Subject2_Baseline.txt', opts));
S2_Post = table2array(readtable('Subject2_one_year.txt', opts));
S3 = table2array(readtable('Subject3_Baseline.txt', opts));
S3_Post = table2array(readtable('Subject3_one_year.txt', opts));
S4 = table2array(readtable('Subject4_Baseline.txt', opts));
S4_Post = table2array(readtable('Subject4_one_year.txt', opts));
S5 = table2array(readtable("Subject5_Baseline.txt", opts));
S5_Post = table2array(readtable("Subject5_one_year.txt", opts));
S6 = table2array(readtable("Subject6_Baseline.txt", opts));
S6_Post = table2array(readtable("Subject6_one_year.txt", opts));
S7 = table2array(readtable("Subject7_Baseline.txt", opts));
S7_Post = table2array(readtable("Subject7_one_year.txt", opts));
S8 = table2array(readtable("Subject8_Baseline.txt", opts));
S8_Post = table2array(readtable("Subject8_one_year.txt", opts));
S9 = table2array(readtable("Subject9_Baseline.txt", opts));
S9_Post = table2array(readtable("Subject9_one_year.txt", opts));
S10 = table2array(readtable("Subject10_Baseline.txt", opts));
S10_Post = table2array(readtable("Subject10_one_year.txt", opts));

% Clear temporary variables
clear opts

% Declare and define matrices for Baseline and +1Yr-Post Subject values 
BASELINE_PT_DATA = [S1(:,4)  S2(:,4) S3(:,4) S4(:,4) S5(:,4) S6(:,4)  S7(:,4) S8(:,4) S9(:,4) S10(:,4)];
POST_ONE_YEAR_PT_DATA = [S1_Post(:,4) S2_Post(:,4) S3_Post(:,4) S4_Post(:,4) S5_Post(:,4) S6_Post(:,4) S7_Post(:,4) S8_Post(:,4) S9_Post(:,4) S10_Post(:,4)];

% Declare manufacturer provided matrices of KH2PO4-to-H2O equivalence and average HU
% phantom values
Equivalence_Table_KH2PO4_H2O_Avg = [-51.8 1012.2 -41.7938; -53.4 1057 7.2098; 58.9000 1103.6 229.8727; 157.0 1119.5 388.9733; 375.8 923.2 490.0947];
KH2PO4 = Equivalence_Table_KH2PO4_H2O_Avg(:,1);
H2O = Equivalence_Table_KH2PO4_H2O_Avg(:,2);
avg_Values = Equivalence_Table_KH2PO4_H2O_Avg(:,3);

% Declare zero matrices x & y 
x = zeros(1, length(Equivalence_Table_KH2PO4_H2O_Avg));
y = zeros(1, length(Equivalence_Table_KH2PO4_H2O_Avg));

% Use for-loop to fill x & y matrices with calculated values
for i = 1:5
    y(i) = avg_Values(i) - H2O(i);
    x(i) = KH2PO4(i);
end

% Linear regresson using egression function: 
% inputs: target matrix or cell array data with a total of N matrix rows (x,y)
% outputs: R-squared value, Slope (Sigma_Ref), and Intercept (Beta_Ref)
[r_Squared,Sigma_Ref,Beta_Ref] = regression(x,y);

% Calculate CT values based on the difference between provided
%constants & Sigma_Ref, Beta_Ref
Sigma_CT = Sigma_Ref - 0.2174;
Beta_CT = Beta_Ref + 999.6;

% Struct declaration containing all calculated data values, sorted by Subject number
% Access data in "Subject" in Workspace
for i = 1:10;
    Subject(i).Subject_Number = i;
    Subject(i).Baseline_HU = BASELINE_PT_DATA(:,i);
    Subject(i).Baseline_BMD = (BASELINE_PT_DATA(:,i) - Beta_CT) / Sigma_CT;
    Subject(i).Baseline_BMD_Average = mean(Subject(i).Baseline_BMD);
    Subject(i).Baseline_BMD_StdDev = std(Subject(i).Baseline_BMD);
    Subject(i).One_Year_Post_BMD = (POST_ONE_YEAR_PT_DATA(:,i)- Beta_CT) / Sigma_CT;
    Subject(i).One_Year_Post_BMD_Average = mean(Subject(i).One_Year_Post_BMD);
    Subject(i).One_Year_Post_BMD_StdDev = std(Subject(i).One_Year_Post_BMD);
   
   % Use ttest2 function to perform a tw-sample ttest
   % inputs: data vectors 1 and 2
   % outputs: p-value and hypthesis test (returns 1 or "Y" if the test
   % rejects the null hypothesis at the 5% significance level, and 0 or "N" otherwise)
    [hypothesis_test_result, p_val] = ttest2(Subject(i).Baseline_BMD,Subject(i).One_Year_Post_BMD);
    if hypothesis_test_result == 1 || p_val < 0.05
        Subject(i).Statistically_Significant = "Y";
    else if hypothesis_test_result == 0
            Subject(i).Statistically_Significant = "N";
        end
    end
    
end

% Use struct2table function to convert struct to table 
T = struct2table(Subject);

% Use removevars function to remove all structure table T columns except Average and
% Standard Deviation values; Display new modified table values
T = removevars(T,{'Baseline_BMD','Baseline_HU', 'One_Year_Post_BMD', 'Statistically_Significant'});
disp(T)

% Bar plots of calculated Average data values
hold on
figure(1) 
    bar([Subject.Baseline_BMD_Average])
    xlabel('Subject Number')
    ylabel('BMD Average')
    title ('BMD Baseline')
    
figure(2) 
    bar([Subject.One_Year_Post_BMD_Average])
    xlabel('Subject Number')
    ylabel('BMD Average')
    title ('BMD Post One-Year')