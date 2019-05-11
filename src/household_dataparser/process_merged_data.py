import pandas as pd
from sklearn import linear_model


def get_sample1(mergedDF):
    sample1DF = mergedDF.loc[(mergedDF['sex'] == 1) & (mergedDF['usual_principal_activity_status'] <= 51)]
    print(sample1DF.shape)
    return sample1DF


def get_filtered_married_male_with_female(mergedDF):

    # Todo: uncomment if required for verification
    # print('After: ')
    # with pd.option_context('display.max_rows', 10 , 'display.max_columns', 52):
    #     print(sample1DF.loc[sample1DF['usual_principal_activity_status'] > '51'])

    # with pd.option_context('display.max_rows', 10 , 'display.max_columns', 52):
    #     print(sample1DF)

    columns_to_show = ['hhid', 'pid', 'personal_serial_no', 'relation_to_head', 'sex']

    # print(mergedDF[columns_to_show])
    print("MergedDF: " , mergedDF.shape)

    #print(mergedDF.dtypes)

    #print(mergedDF['sex'])

    fatherDF = mergedDF[mergedDF['relation_to_head'].isin([1, 7])]

    marriedDF = mergedDF.loc[mergedDF['relation_to_head'] <= 4]


    #marriedDF = marriedDF.loc[marriedDF['general_education'] != '']

    #marriedDF.personal_serial_no = marriedDF.personal_serial_no.astype(int)
    #marriedDF.general_education = marriedDF.general_education.astype(float)
    # marriedDF.mpce = marriedDF.mpce.astype(int)
    # marriedDF.loc[:, 'personal_serial_no'] = marriedDF['personal_serial_no'].astype(int)

    marriedMaleDF = marriedDF.loc[marriedDF['sex'] == 1]
    marriedFemaleDF = marriedDF.loc[marriedDF['sex'] == 2]

    print("MarriedMale : ",marriedMaleDF.shape)
    print("MarriedFeMale : ",marriedFemaleDF.shape)




    # Take only a few columns out of women education
    specific_columns = ['hhid', 'pid', 'age', 'general_education', 'usual_principal_activity_status',
                        'personal_serial_no']
    marriedFemaleDF = marriedFemaleDF[specific_columns]

    marriedFemaleDF = marriedFemaleDF.rename(
        {'pid': 'pid_f', 'age': 'age_f', 'general_education': 'general_education_f',
         'usual_principal_activity_status': 'usual_principal_activity_status_',
         'personal_serial_no': 'personal_serial_no_f'}, axis='columns')

    marriedMaleWithFemaleDF = marriedMaleDF.merge(marriedFemaleDF, on=['hhid'], how='outer')

    filteredMarriedMaleWithFemaleDF = \
        marriedMaleWithFemaleDF.loc[(
            (marriedMaleWithFemaleDF['personal_serial_no'] + 1) ==
            marriedMaleWithFemaleDF['personal_serial_no_f'])]

    columns_to_show_married = ['pid_x', 'pid_y', 'personal_serial_no_x',
                               'personal_serial_no_y', 'relation_to_head_x', 'relation_to_head_y', 'sex_x', 'sex_y']

    ruralDF = filteredMarriedMaleWithFemaleDF.loc[filteredMarriedMaleWithFemaleDF['sector'] == 1]
    urbanDF = filteredMarriedMaleWithFemaleDF.loc[filteredMarriedMaleWithFemaleDF['sector'] == 2]

    print("U: ", urbanDF.shape)
    print("R: ", ruralDF.shape)
    print("FilteredMaleFemale: ", filteredMarriedMaleWithFemaleDF.shape)
    print(filteredMarriedMaleWithFemaleDF.shape)

    # cleanedDF = filteredMarriedMaleWithFemaleDF[]

    # print(filteredMarriedMaleWithFemaleDF[columns_to_show_married])

    # x = filteredMarriedMaleWithFemaleDF['general_education'].values
    # y = filteredMarriedMaleWithFemaleDF['mpce'].values
    #
    # x = x.reshape(x.shape[0], 1)
    # y = y.reshape(x.shape[0], 1)
    # print(x.shape)
    # print(y.shape)
    # regr = linear_model.LinearRegression()
    #
    # # regr.fit(filteredMarriedMaleWithFemaleDF['general_education_x'], filteredMarriedMaleWithFemaleDF['mpce_x'])
    # regr.fit(x, y)
    # print(regr.coef_)
    return filteredMarriedMaleWithFemaleDF

