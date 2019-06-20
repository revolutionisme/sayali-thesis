import pandas as pd
from math import log

data1 = [{'t1': 1, 't2': 4, 't3': 7, 't4': 10},
         {'t1': 2, 't2': 5, 't3': 8, 't4': 11},
         {'t1': 3, 't2': 6, 't3': 9, 't4': 12}]

data2 = [{'t1': 10, 't2': 15, 't3': 20, 't4': 14},
         {'t1': 20, 't2': 20, 't3': 21, 't4': 21},
         {'t1': 30, 't2': 5, 't3': 9, 't4': 9}]

df1 = pd.DataFrame(data1)
df2 = pd.DataFrame(data2)

#print(type(df1['t1']))

df = pd.DataFrame(columns=list(df1))
for col in df1:
    series = pd.Series([])
    for val in df1[col]:
        series = series.append(df2[col].apply(lambda x: x * val))
    df[col] = series

df = df.reset_index()
#print(df)



"""
    Calculating log series 
"""

data_other = [{'t1': 1, 't2': 4, 't3': 7, 't4': 10},
              {'t1': 2, 't2': 5, 't3': 8, 't4': 11},
              {'t1': 3, 't2': 6, 't3': 9, 't4': 12}]

ddf = pd.DataFrame(data_other)

colsum = ddf.sum(axis=0)
rowsum = ddf.sum(axis=1)


print(colsum, rowsum)
print(type(colsum), type(rowsum))


if rowsum.sum() != colsum.sum():
    raise ValueError("Row sum and column sum is not same, something is wrong")

totalsum = rowsum.sum()

klm = 0.0
#for col in ddf:
#    for row in ddf[col]:

for colindex, col in ddf.iteritems():
    #print(type(col), col)
    for rowindex,item in col.items():
        print(rowindex,colindex, item, colsum[colindex])
        pre = item/colsum[colindex]
        klm = klm + (pre*log(pre/(rowsum[rowindex]/totalsum)))

print(klm)

for index, row in ddf.iteritems():
    for item in row:
        print(index, item)

ddf.loc['ColSum',:]= ddf.sum(axis=0)

#Total sum per column:
ddf.loc[:,'RowSum'] = ddf.sum(axis=1)

print(ddf)


