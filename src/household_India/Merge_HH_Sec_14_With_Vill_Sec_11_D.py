import pandas as pd


# Read Data and extract varaible labels as well
section07_rev_fra = pd.read_stata('resources/India_data_with_Sayali/HH_data_2015_revFRA/SECTION07_REV_FRA.dta')
#section014_rev_fra = pd.read_stata('resources/India_data_with_Sayali/HH_data_2015_revFRA/SECTION14_REV_FRA.dta')
section_07_reader = pd.io.stata.StataReader('resources/India_data_with_Sayali/HH_data_2015_revFRA/SECTION14_REV_FRA.dta')
var_lbl_hh_sec_07_dict = section_07_reader.variable_labels()
section_07_reader.close()

# Read Data and extract varaible labels as well
section_11_d = pd.read_stata('resources/India_data_with_Sayali/village_data_2017/SECTION_11_D.dta')
section_11_d_reader = pd.io.stata.StataReader('resources/India_data_with_Sayali/village_data_2017/SECTION_11_D.dta')
var_lbl_vill_sec_11_d_dict = section_11_d_reader.variable_labels()
section_11_d_reader.close()

# Merge variable labels
merged_variable_labels = dict(var_lbl_hh_sec_07_dict, **var_lbl_vill_sec_11_d_dict)

# Convert village names to lowercase for case-insensitive joining
section07_rev_fra["village"] = section07_rev_fra["village"].str.lower()
section_11_d["village_name"] = section_11_d["village_name"].str.lower()

# Join 2 datasets, with inner join
mergedDf = section07_rev_fra.merge(section_11_d, left_on='village', right_on='village_name', how='inner')

# Write the merged dataset as stata file,with variable labels
mergedDf.to_stata("resources/merged_HH_Section07_with_V_section_11d.dta", variable_labels=merged_variable_labels)
