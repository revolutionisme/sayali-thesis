import pandas as pd
from math import log

data = [{'t1': 1, 't2': 4, 't3': 7, 't4': 10},
              {'t1': 2, 't2': 5, 't3': 8, 't4': 11},
              {'t1': 3, 't2': 6, 't3': 9, 't4': 12}]

ddf = pd.DataFrame(data)

colsum = ddf.sum(axis=0)
rowsum = ddf.sum(axis=1)

if rowsum.sum() != colsum.sum():
    raise ValueError("Row sum and column sum is not same, something is wrong")

totalsum = rowsum.sum()

klm = 0.0

for colindex, col in ddf.iteritems():
    # print(type(col), col)
    for rowindex,item in col.items():
        # print(rowindex,colindex, item, colsum[colindex])
        pre = item/colsum[colindex]
        klm = klm + (pre*log(pre/(rowsum[rowindex]/totalsum)))


ddf.loc['ColSum', :] = ddf.sum(axis=0)
ddf.loc[:, 'RowSum'] = ddf.sum(axis=1)

print(ddf)
print(klm)
