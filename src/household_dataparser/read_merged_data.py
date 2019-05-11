import pandas as pd
from sklearn import linear_model
import numpy as np
import process_merged_data

mergedDF_61 = pd.read_pickle('MergedData/mergedDF_61.pkl')


# TOdo: uncomment if required for verification
# print('Before: ')
# with pd.option_context('display.max_rows', 10 , 'display.max_columns', 52):
#     print(mergedDF.loc[mergedDF['usual_principal_activity_status'] > '51'])

sample1_61 = process_merged_data.get_sample1(mergedDF_61)
filteredMarriedMaleWithFemaleDF_61 = process_merged_data.get_filtered_married_male_with_female(mergedDF_61)
sample1_61.to_stata('MergedData/sample1_61.dta')
filteredMarriedMaleWithFemaleDF_61.to_stata('MergedData/filteredMarrriedMale_68.dta')

mergedDF_68 = pd.read_pickle('MergedData68/mergedDF_68.pkl')
sample1_68 = process_merged_data.get_sample1(mergedDF_68)
filteredMarriedMaleWithFemaleDF_68 = process_merged_data.get_filtered_married_male_with_female(mergedDF_68)
sample1_68.to_stata('MergedData68/sample1_68.dta')
filteredMarriedMaleWithFemaleDF_68.to_stata('MergedData68/filteredMarrriedMale_68.dta')
