from __future__ import print_function
import pandas as pd
import itertools
import sys

try:
    ko_table = sys.argv[1]
    module_data = sys.argv[2]
    module_names = sys.argv[3]
    output_table_full = sys.argv[4]
    output_table_reduced = sys.argv[5]
except KeyError:
    print("Needs 3 files arguments (ko table) (module data) (module names) (output module full) (output module reduced)", file=sys.stderr)
    sys.exit(1)

df = pd.read_table(ko_table, delimiter="\t", skiprows=1, index_col=0)

module_dict = {}
for line in open(module_data, 'r'):
    line = line.strip()
    if not line:
        continue
    mod_id, ko_id = line.split('\t')
    try:
        module_dict[mod_id].add(ko_id)
    except KeyError:
        module_dict[mod_id] = set([ko_id])

module_names_dict = {}
for line in open(module_names, 'r'):
    line = line.strip()
    if not line:
        continue
    mod_id, mod_name = line.split('\t')
    module_names_dict[mod_id] = mod_name

module_df = {}
for mod_id, ko_ids in module_dict.iteritems():
    ko_ids = ko_ids & set(df.index)
    # no ids found, skip module
    if not ko_ids:
        continue
    module_df[mod_id] = df.loc[ko_ids].sum()

module_df =  pd.DataFrame.from_dict(module_df, orient='index')
module_df['Module_Name'] = pd.Series(
    {
        mod_id: module_names_dict[mod_id]
        for mod_id in module_df.index
    }
)
module_df.to_csv(output_table_full, sep="\t")

module_df = {}
unique_ids = {}
for mod_id, ko_ids in module_dict.iteritems():
    other_ids = set(itertools.chain(
        *(
            new_ids
            for new_id, new_ids in module_dict.iteritems()
            if new_id != mod_id
        )
    ))
    ko_ids = (ko_ids - other_ids) & set(df.index)
    if not ko_ids:
        continue
    module_df[mod_id] = df.loc[ko_ids].sum()
    unique_ids[mod_id] = '|'.join(ko_ids)

module_df =  pd.DataFrame.from_dict(module_df, orient='index')
module_df['Module_Name'] = pd.Series(
    {
        mod_id: module_names_dict[mod_id]
        for mod_id in module_df.index
    }
)
module_df['Unique_KOs'] = pd.Series(unique_ids)
module_df.to_csv(output_table_reduced, sep="\t")
