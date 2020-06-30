import pandas as pd
from math import log
from pandas.util.testing import assert_frame_equal
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("KLM")


# logger.setLevel(logging.DEBUG)

def get_partial_klm_sum(df):
    colsum = df.sum(axis=0)
    rowsum = df.sum(axis=1)

    # print("Rowsum, colsum")
    # print(colsum, rowsum)
    klm = 0.0

    if rowsum.sum() != colsum.sum():
        raise ValueError("Row sum and column sum is not same, something is wrong")

    totalsum = rowsum.sum()

    for colindex, col in df.iteritems():
        # print(type(col))
        # print(col)
        for rowindex, item in col.items():
            # print("Inside inner loop")
            # print(rowindex, colindex, item, colsum[colindex])
            pre = item / colsum[colindex]
            klm = klm + (pre * log(pre / (rowsum[rowindex] / totalsum)))

    return colsum, rowsum, totalsum, klm


def get_mi_klm_sum(idf, hdf, odf, icolsum, hcolsum, ocolsum):
    mi_klm = 0.0
    for i, h, o in zip(idf.iteritems(), hdf.iteritems(), odf.iteritems()):
        # print(f"Data - {i}, {icolsum[i[0]]}")
        col_list = []
        # print(f"List len i  - {i[1]}")
        # print(f"List len h - {h[1]}")

        for irow, ival in i[1].items():
            for hrow, hval in h[1].items():
                col_list.append((ival * hval) / (icolsum[i[0]] * hcolsum[i[0]]))
                # print(f"COlumns - {i[0]}, {h[0]}, {ival}, {hval}")
        # print(f"oColumn - {o[1].tolist()}, {type(o[1])}")
        print(f"List len - {len(col_list)}")
        for oval, ihval in zip(o[1].tolist(), col_list):
            # print(oval, ihval, ocolsum[o[0]])
            prefix = (oval / ocolsum[o[0]])
            mi_klm = mi_klm + prefix * log(prefix / ihval)
    #    print(f"data - {data}")
    #    print(f"Data {i}, {h}, {o}")
    # print(mi_klm)
    return mi_klm


def get_j_klm_sum(odf, ototalsum, ocolsum, irowsum, itotalsum, hrowsum, htotalsum):
    required_val_tuple_list = []
    for rowindex, row in odf.iterrows():
        #        print(f"{rowindex} -- \n{row} -- \n{row.sum()}, {ototalsum}")
        denom = row.sum() / ototalsum
        presum = 0.0
        for colvalues, colsumvalue in zip(row.items(), ocolsum.items()):
            presum = presum + (colvalues[1] / colsumvalue[1])
        #            print(f"inside {colvalues[1]}, {colsumvalue[1]}, {presum}")
        required_val_tuple_list.append((presum, denom))

    #    print(required_val_tuple_list)

    nom = []
    for ival in irowsum:
        for hval in hrowsum:
            nom.append((ival * hval) / (itotalsum * htotalsum))
    #            print(ival, hval)

    #    print(nom)

    j_klm_sum = 0.0
    for ovals, nomval in zip(required_val_tuple_list, nom):
        j_klm_sum = j_klm_sum + ovals[0] * log(nomval / ovals[1])
    #        print(ovals[0], ovals[1], nomval)

    return j_klm_sum


def add_row_col_sum(df):
    df.loc['ColSum', :] = df.sum(axis=0)
    df.loc[:, 'RowSum'] = df.sum(axis=1)

    return df


def run():
    outcomes = [{'t1': 1, 't2': 5},
                {'t1': 2, 't2': 6},
                {'t1': 3, 't2': 7},
                {'t1': 4, 't2': 8}]

    income = [{'t1': 3, 't2': 11},
              {'t1': 7, 't2': 15}]

    health = [{'t1': 4, 't2': 12},
              {'t1': 6, 't2': 14}]

    odf = pd.DataFrame(outcomes)
    idf = pd.DataFrame(income)
    hdf = pd.DataFrame(health)


    ocolsum, orowsum, ototalsum, oklm = get_partial_klm_sum(odf)
    icolsum, irowsum, itotalsum, iklm = get_partial_klm_sum(idf)
    hcolsum, hrowsum, htotalsum, hklm = get_partial_klm_sum(hdf)

    # todo:  uncomment before sending to sayali
    #assert ocolsum.equals(icolsum) and icolsum.equals(hcolsum) and ocolsum.equals(hcolsum)
    #assert ototalsum == itotalsum and itotalsum == htotalsum and ototalsum == htotalsum

    print(oklm, iklm, hklm)

    logger.info(f"Outcome DF - \n {odf}, \n{ocolsum}, \n{orowsum}")
    logger.info(f"Income DF - \n {idf}, \n{icolsum}, \n{irowsum}")
    logger.info(f"Health DF - \n {hdf}, \n{hcolsum}, \n{hrowsum}")

    mi_klm_sum = get_mi_klm_sum(idf, hdf, odf, icolsum, hcolsum, ocolsum)

    j_klm_sum = get_j_klm_sum(odf, ototalsum, ocolsum, irowsum, itotalsum, hrowsum, htotalsum)

    print(f"I klm sum -> {iklm}")
    print(f"H klm sum -> {hklm}")
    print(f"MI klm sum -> {mi_klm_sum}")
    print(f"J klm sum -> {j_klm_sum}")

    total_klm_sum = iklm + hklm + mi_klm_sum + j_klm_sum

    print(f"Total KLM Sum -> {total_klm_sum}")


run()