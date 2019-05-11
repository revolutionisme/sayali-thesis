import pandas as pd

df_level_123 = pd.read_stata('Sorted_and_merged_data/sort_B123.dta')
df_level_4 = pd.read_stata('Sorted_and_merged_data/sort_B4.dta')
df_level_51 = pd.read_stata('Sorted_and_merged_data/sort_B51.dta')
df_level_6 = pd.read_stata('Sorted_and_merged_data/sort_B6.dta')
# df_level_8 = pd.read_stata('Sorted_and_merged_data/Block_8.dta')
# df_level_11 = pd.read_stata('NSS61/Block_9_level_11.dta')

# df_level_8 = df_level_8.rename({'sample_hhld_no': 'hhold_key'}, axis='columns')

df_level_123.columns = df_level_123.columns.str.lower()
print(df_level_123.dtypes)
df_level_4.columns = df_level_4.columns.str.lower()
print(df_level_4.dtypes)
df_level_51.columns = df_level_51.columns.str.lower()
print(df_level_51.dtypes)
df_level_6.columns = df_level_6.columns.str.lower()
print(df_level_6.dtypes)
# df_level_8.columns = df_level_8.columns.str.lower()
# print(df_level_8.columns)

# df_level_11.columns = df_level_11.columns.str.lower()

# print(df_level_01.head(5))


column_list_level_123 = ['hhold_key', 'sector', 'district', 'state', 'district_code',
                         'hh_size', 'hh_type', 'religion', 'social_group', 'land_owned',
                         'land_possessed', 'land_cultivated', 'nreg_job_card', 'household_type']

column_list_level_4 = ['hhold_key', 'person_key', 'hid', 'pid', 'relation_to_head',
                       'sex', 'age', 'marital_status', 'general_education', 'sector']

column_list_level_51 = ['hhold_key', 'person_key', 'usual_principal_activity_status',
                        'type_of_job_contract', 'eligible_for_paid_leave',
                        'social_security_benefits']

column_list_level_6 = ['hhold_key', 'person_key', 'full_time_or_part_time',
                       'worked_more_or_less_regularly', 'no_of_months_without_work',
                       'any_union_association', 'member_union_association',
                       'nature_of_employement']
#
# column_list_level_8 = ['sample_hhld_no', 'item_group_srl_no',
#                        'value_of_consumption_last_30_day', 'value_consumption_last_365_days']

filteredDF_level_123 = pd.DataFrame(df_level_123, columns=column_list_level_123)
filteredDF_level_4 = pd.DataFrame(df_level_4, columns=column_list_level_4)
filteredDF_level_51 = pd.DataFrame(df_level_51, columns=column_list_level_51)
filteredDF_level_6 = pd.DataFrame(df_level_6, columns=column_list_level_6)
# filteredDF_level_8 = pd.DataFrame(df_level_8, columns=column_list_level_8)
# filteredDF_level_11=pd.DataFrame(df_level_11, columns=column_list_level_11)
# print(df.loc[:,])

# print(filteredDF_level_01.head(5))
# print(filteredDF_level_03.head(5))
# print(filteredDF_level_04.head(5))
# print(filteredDF_level_08.head(5))
# print(filteredDF_level_09.head(5))
# print(filteredDF_level_11.head(5))

mergedDF = filteredDF_level_4 \
    .merge(filteredDF_level_51, on=['hhold_key', 'person_key']) \
    .merge(filteredDF_level_6, on=['hhold_key', 'person_key']) \
    .merge(filteredDF_level_123, on=['hhold_key'], how='left').sort_values(by='hhold_key')

with pd.option_context('display.max_rows', 10, 'display.max_columns', 52):
    print(mergedDF)


mergedDF = mergedDF.rename({'hhold_key': 'hhid', 'pid': 'personal_serial_no', 'person_key': 'pid'},
                           axis='columns')
mergedDF.pid = mergedDF.pid.astype(int)

marriedMaleDF = filteredDF_level_4.loc[(filteredDF_level_4['sex'] == 1) &
                                       (filteredDF_level_4['sector'] == 1)]
marriedFemaleDF = filteredDF_level_4.loc[(filteredDF_level_4['sex'] == 2) &
                                         (filteredDF_level_4['sector'] == 1)]

print("MarriedMale : ", marriedMaleDF.shape)
print("MarriedFeMale : ", marriedFemaleDF.shape)

print(mergedDF.dtypes)
mergedDF.to_pickle("MergedData68/mergedDF_68.pkl")
