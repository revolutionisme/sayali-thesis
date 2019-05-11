import pandas as pd
import difflib

asha_df = pd.read_stata('E:/JSY MIS data/ASHA/data_asha_nrhm_without15.dta')
dhs_df = pd.read_stata('E:/JSY MIS data/ASHA/st_dist_dhs_2.dta')

print(len(asha_df))


def fix_spelling(x, source):
    try:
        return difflib.get_close_matches(x, source)[0]
    except Exception:
        return "NA"


asha_df['s_nrhm'] = asha_df['s_nrhm'].apply(lambda x: fix_spelling(x, dhs_df['s_nrhm']))

asha_df['sdist'] = asha_df['sdist'].apply(lambda x: fix_spelling(x, dhs_df['sdist']))

merged_df = asha_df.merge(dhs_df, 'inner', on=['s_nrhm', 'sdist'])


merged_df.to_stata('E:/JSY MIS data/ASHA/asha_dhs_merge_state_dist.dta')

print(merged_df.head(25))

print(len(merged_df))
