import pandas as pd

df_level_01 = pd.read_stata('NSS61/Block_1_2_and_3_level_01.dta')
df_level_03 = pd.read_stata('NSS61/Block_4_level_03.dta')
df_level_04 = pd.read_stata('NSS61/Block_5pt1_level_04.dta')
df_level_08 = pd.read_stata('NSS61/Block_7pt1_level_08.dta')
df_level_09 = pd.read_stata('NSS61/Block_7pt2_level_09.dta')
# df_level_11 = pd.read_stata('NSS61/Block_9_level_11.dta')

df_level_01.columns = df_level_01.columns.str.lower()
df_level_03.columns = df_level_03.columns.str.lower()
df_level_04.columns = df_level_04.columns.str.lower()
df_level_08.columns = df_level_08.columns.str.lower()
df_level_09.columns = df_level_09.columns.str.lower()
# df_level_11.columns = df_level_11.columns.str.lower()

# print(df_level_01.head(5))

# with pd.option_context('display.max_rows', , 'display.max_columns', 52):
#     print(df_level_11)

column_list_level_01 = ['hhid', 'state_region', 'state_code', 'district', 'district_code',
                        'household_type_code', 'mpce', 'land_owned', 'land_possessd',
                        'land_cultivated', 'social_grp', 'religion',
                        'hh_type', 'hh_size']

column_list_level_03 = ['hhid', 'pid', 'sector', 'personal_serial_no', 'relation_to_head', 'sex',
                        'age', 'marital_status', 'general_education', 'technical_education']
column_list_level_04 = ['hhid', 'pid', 'usual_principal_activity_status', 'type_of_job_contract',
                        'eligible_for_paid_leave', 'social_security_benefits']
column_list_level_08 = ['hhid', 'pid', 'full_time_or_part_time', 'worked_more_or_less_regularly_36',
                        'no_of_months_without_work']
column_list_level_09 = ['hhid', 'pid', 'nature_of_employment', 'union_association',
                        'member_of_union_association']
# column_list_level_11 = ['hhid','pid','value_of_consumption_last_30_day',
#                         'value_of_consumption_last_365_day']


filteredDF_level_01 = pd.DataFrame(df_level_01, columns=column_list_level_01)
filteredDF_level_03 = pd.DataFrame(df_level_03, columns=column_list_level_03)
filteredDF_level_04 = pd.DataFrame(df_level_04, columns=column_list_level_04)
filteredDF_level_08 = pd.DataFrame(df_level_08, columns=column_list_level_08)
filteredDF_level_09 = pd.DataFrame(df_level_09, columns=column_list_level_09)
# filteredDF_level_11=pd.DataFrame(df_level_11, columns=column_list_level_11)
# print(df.loc[:,])

# print(filteredDF_level_01.head(5))
# print(filteredDF_level_03.head(5))
# print(filteredDF_level_04.head(5))
# print(filteredDF_level_08.head(5))
# print(filteredDF_level_09.head(5))
# print(filteredDF_level_11.head(5))

mergedDF = filteredDF_level_03 \
    .merge(filteredDF_level_04, on=['pid', 'hhid']) \
    .merge(filteredDF_level_08, on=['pid', 'hhid']) \
    .merge(filteredDF_level_09, on=['pid', 'hhid']) \
    .merge(filteredDF_level_01, on=['hhid'], how='left').sort_values(by='pid')

mergedDF = mergedDF.loc[mergedDF['general_education'] != '']

mergedDF.hhid = mergedDF.hhid.astype(int)
mergedDF.pid = mergedDF.pid.astype(int)
mergedDF.personal_serial_no = mergedDF.personal_serial_no.astype(int)
mergedDF.sex = mergedDF.sex.astype(int)
mergedDF.sector = mergedDF.sector.astype(int)
mergedDF.general_education = mergedDF.general_education.astype(float)
mergedDF.relation_to_head = mergedDF.relation_to_head.astype(float)
mergedDF.usual_principal_activity_status = mergedDF.usual_principal_activity_status.astype(int)

print(mergedDF['sex'])
print(mergedDF.dtypes)
mergedDF.to_pickle("MergedData/mergedDF_61.pkl")

