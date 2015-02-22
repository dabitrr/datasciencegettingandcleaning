# datasciencegettingandcleaning
Project Assignment
Comments on execution:
The execution of the function fullProcess would carry out all the different steps of the analysis.
It needs two parameters:
- inputFolder: containing the path of the root folder where the data has been unzipped
- outputFolder: containing the path where to leave the files
The outcome:
- output\step1 => subject.txt / y.txt / x.txt,  with the merged data from test & train
- output\step2 => mergedds.txt, subjects and activities merged into observations with variable names (only mean/std)
- output\step3 => mergeddswithactivity.txt, activity factorized
- output\step4 => 

Steps:
- pure merge of data sets (mergeTrnAndTest)
- filter mean/std columns with subjects and activities in a single files (selectSolumns)
- factor activity (relabelActivityNames)
- summarize by factor & activity (summByActAndSub)
