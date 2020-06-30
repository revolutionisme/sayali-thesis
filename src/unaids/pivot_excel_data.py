import pandas as pd
#pd.set_option('display.max_columns', None)
#pd.set_option('display.width', 300)

# header is defined on line 3, and set column 0 and 1 as row indexes  columnn
df = pd.read_excel('Dashboard_on_ODA_and_economic_shocks.xlsx', sheet_name="Master data", header=2, index_col=[0,1])

#drop the column named 'Key'
df = df.drop(columns=['Key'])

#stack the dataframe and unstack it on level 0, i.e unstack on column 0 (1st column index)
dft = df.stack().unstack(level=0)

dft.to_excel('output_proper.xlsx')

