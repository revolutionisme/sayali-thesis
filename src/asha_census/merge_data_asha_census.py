import pandas as pd
from src.normalize import fix_spelling


def get_normalized_census(census_df):
    filtered_total_census = census_df.loc[census_df['TRU'].str.lower() == 'total']

    state_name = 'NA'
    filtered_total_census['state_name'] = 'NA'
    for index, row in filtered_total_census.iterrows():
        if row['Level'].lower() == 'state':
            state_name = row['Name']

        # print(state_name)
        filtered_total_census.at[index, 'state_name'] = state_name
        # print(row[['Name', 'Level']])

    # print(filtered_total_census[['state_name', 'Name', 'Level']])
    return filtered_total_census[filtered_total_census.Level != 'STATE']


# sdist, state
asha_df = pd.read_stata('data/data_asha_nrhm.dta')

# sdist, s_dhs
dhs_df = pd.read_stata('data/st_dist_dhs_2.dta')

# print(asha_df.columns)
# print(dhs_df.columns)

# print(len(asha_df.s_nrhm.unique()))
# print(len(dhs_df.s_nrhm.unique()))
# print(asha_df.s_nrhm.unique())
# print(dhs_df.s_nrhm.unique())

# print(len(asha_df.sdist.unique()))
# print(len(dhs_df.sdist.unique()))
# print(asha_df.sdist.unique())
# print(dhs_df.sdist.unique())

# print(asha_df[['s_nrhm', 'state', 'sdist']])
# print(dhs_df[['s_nrhm', 's_dhs', 'sdist']])

asha_df['s_nrhm'] = asha_df['s_nrhm'].apply(lambda x: fix_spelling(x, dhs_df['s_nrhm'], 0.5))
dhs_df['sdist'] = dhs_df['sdist'].apply(lambda x: fix_spelling(x, asha_df['sdist'], 0.5))

# print(len(asha_df.s_nrhm.unique()))696, 634 --  610, 634
# print(len(dhs_df.s_nrhm.unique()))
# print(asha_df.s_nrhm.unique())
# print(dhs_df.s_nrhm.unique())

# print(len(asha_df.sdist.unique()))
# print(len(dhs_df.sdist.unique()))
# print(asha_df.sdist.unique())
# print(dhs_df.sdist.unique())

# print(asha_df[['s_nrhm', 'state', 'sdist']])
# print(dhs_df[['s_nrhm', 's_dhs', 'sdist']])

merged_asha_dhs_df = asha_df.merge(dhs_df, 'inner', on=['s_nrhm', 'sdist'])

# print(len(merged_asha_dhs_df.sdist.unique()))
# print(merged_asha_dhs_df.sdist.unique())

# Todo: merge of sdist and (state, s_dhs)
census_district_df = pd.read_excel('data/census_pop_district_SC_ST.xlsx')

# print(census_district_df.columns)
# census_district_df['TRU'].apply(lambda x: fix_spelling(x, census_district_df['TRU']))

normalized_census_df = get_normalized_census(census_district_df)
normalized_census_df = normalized_census_df[normalized_census_df.state_name != 'NA']
# print(normalized_census_df[['state_name', 'Name', 'Level']])

# print(normalized_census_df.state_name.unique())
# print(len(normalized_census_df.state_name.unique()))


# print(normalized_census_df.Name.unique())
# print(len(normalized_census_df.Name.unique()))


# print(normalized_census_df[['state_name', 'Name', 'Level']])
# print(merged_asha_dhs_df[['s_nrhm', 'sdist']])

normalized_census_df['state_name'] = normalized_census_df['state_name'].apply(lambda x: fix_spelling(x, merged_asha_dhs_df['s_nrhm'], 0.5))
normalized_census_df['Name'] = normalized_census_df['Name'].apply(lambda x: fix_spelling(x.upper(), merged_asha_dhs_df['sdist'], 0.5))


# print(normalized_census_df[['state_name', 'Name', 'Level']])
# print(merged_asha_dhs_df[['s_nrhm', 'sdist']])

merged_asha_dhs_with_census_df = pd.merge(merged_asha_dhs_df, normalized_census_df, how='inner', left_on=['s_nrhm', 'sdist'], right_on=['state_name', 'Name'])
# merged_asha_dhs_with_census_df = merged_asha_dhs_df.merge(normalized_census_df, 'inner', on=['s_nrhm', 'sdist'])

# print(merged_asha_dhs_with_census_df)

merged_asha_dhs_with_census_df.to_excel('output.xlsx')
merged_asha_dhs_with_census_df.to_excel('output.xls')
merged_asha_dhs_with_census_df.to_csv('output.csv')
