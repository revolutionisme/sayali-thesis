import pandas as pd
from math import log

import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("KLM")
# logger.setLevel(logging.DEBUG)

def get_partial_klm_sum(df):
    colsum = df.sum(axis=0)
    rowsum = df.sum(axis=1)

    print("Rowsum, colsum")
    print(colsum, rowsum)
    klm = 0.0

    if rowsum.sum() != colsum.sum():
        raise ValueError("Row sum and column sum is not same, something is wrong")

    totalsum = rowsum.sum()

    for colindex, col in df.iteritems():
        print(type(col))
        print(col)
        for rowindex, item in col.items():
            print("Inside inner loop")
            print(rowindex, colindex, item, colsum[colindex])
            pre = item / colsum[colindex]
            klm = klm + (pre * log(pre / (rowsum[rowindex] / totalsum)))

    return klm, df

def add_row_col_sum(df):
    df.loc['ColSum', :] = df.sum(axis=0)
    df.loc[:, 'RowSum'] = df.sum(axis=1)

    return df

outcomes = [{'t1': 1, 't2': 5},
            {'t1': 2, 't2': 6},
            {'t1': 3, 't2': 7},
            {'t1': 4, 't2': 8}]

income = [{'t1': 1, 't2': 3},
          {'t1': 2, 't2': 4}]

health = [{'t1': 5, 't2': 7},
          {'t1': 6, 't2': 8}]



odf = pd.DataFrame(outcomes)
idf = pd.DataFrame(income)
hdf = pd.DataFrame(health)

oklm, updated_odf = get_partial_klm_sum(odf)
iklm, updated_idf = get_partial_klm_sum(idf)
hklm, updated_hdf = get_partial_klm_sum(hdf)

print(oklm, iklm, hklm)

logger.info(f"Outcome DF - \n {updated_odf}")
logger.info(f"Income DF - \n {updated_idf}")
logger.info(f"Health DF - \n {updated_hdf}")




for colindex, col in updated_odf.iteritems():
    for rowindex, item in col.items():






