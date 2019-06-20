import pandas as pd
from math import log

import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("KLM")
# logger.setLevel(logging.DEBUG)

def get_partial_klm_sum(df):
    colsum = df.sum(axis=0)
    rowsum = df.sum(axis=1)

    #print("Rowsum, colsum")
    #print(colsum, rowsum)
    klm = 0.0

    if rowsum.sum() != colsum.sum():
        raise ValueError("Row sum and column sum is not same, something is wrong")

    totalsum = rowsum.sum()

    for colindex, col in df.iteritems():
        #print(type(col))
        #print(col)
        for rowindex, item in col.items():
            #print("Inside inner loop")
            #print(rowindex, colindex, item, colsum[colindex])
            pre = item / colsum[colindex]
            klm = klm + (pre * log(pre / (rowsum[rowindex] / totalsum)))

    return colsum, rowsum, klm, df


def get_mi_klm_sum(idf, hdf, odf, icolsum, hcolsum, ocolsum):
    mi_klm = 0.0
    for i, h, o in zip(idf.iteritems(), hdf.iteritems(), odf.iteritems()):
        # print(f"Data - {i}, {icolsum[i[0]]}")
        col_list = []
        for irow, ival in i[1].items():
            for hrow, hval in h[1].items():
                col_list.append((ival * hval) / (icolsum[i[0]] * hcolsum[i[0]]))
                # print(f"COlumns - {i[0]}, {h[0]}, {ival}, {hval}")
        # print(f"oColumn - {o[1].tolist()}, {type(o[1])}")

        data = {o[0]: o[1].tolist(), "mixed": col_list}
        for oval, ihval in zip(o[1].tolist(), col_list):
            #print(oval, ihval, ocolsum[o[0]])
            prefix = (oval / ocolsum[o[0]])
            mi_klm = mi_klm + prefix * log(prefix / ihval)
    #    print(f"data - {data}")
    #    print(f"Data {i}, {h}, {o}")
    print(mi_klm)
    return mi_klm


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

ocolsum, orowsum, oklm, updated_odf = get_partial_klm_sum(odf)
icolsum, irowsum, iklm, updated_idf = get_partial_klm_sum(idf)
hcolsum, hrowsum, hklm, updated_hdf = get_partial_klm_sum(hdf)

print(oklm, iklm, hklm)

logger.info(f"Outcome DF - \n {updated_odf}")
logger.info(f"Income DF - \n {updated_idf}")
logger.info(f"Health DF - \n {updated_hdf}")


mi_klm_sum = get_mi_klm_sum(odf, hdf, odf, icolsum, hcolsum, ocolsum)

print(f"iklm - {iklm}, hklm - {hklm}")

print(f"MI sum -> {mi_klm_sum}")

total_klm_sum = iklm + hklm + mi_klm_sum

print(f"Total KLM Sum -> {total_klm_sum}")