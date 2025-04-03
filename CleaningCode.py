import pandas as pd
import os
import re

def get_files_recursive(directory):
    file_paths = []
    for root, _, files in os.walk(directory):
        for file in files:
            file_path = os.path.join(root, file)
            file_paths.append(file_path)
    return file_paths

directory = "./Data Sets/1. Parking Data"
all_files = get_files_recursive(directory)
all_files = [file for file in all_files if ".xlsx" in file]


def create_file_dict(file):
    type = re.split("[-_]", file)[1].strip().split(".")[0]
    if type == "EntriesExits":
        type = "EntryExit"
    return {"filename" : file, "location" : re.split("[-_]", file)[0].strip(), "type" : type, "amano" : True if len(re.split("[-_]", file)) > 2 else False}

all_files = [create_file_dict(file) for file in all_files]

def read_csv_files(files):
    entry_exit_regular = None
    entry_exit_amano = None
    revenue_transactions_regular = None
    revenue_transactions_amano = None
    num = len(files)
    i = 0
    for file in files:
        i += 1
        print(f"{(i / num) * 100}% done")
        df = pd.read_excel(file["filename"])
        df["location"] = file["location"]
        if file["type"] == "EntryExit":
            if not file["amano"]:
                if entry_exit_regular is None:
                    entry_exit_regular = [df]
                else:
                    entry_exit_regular.append(df)
            else:
                if entry_exit_amano is None:
                    entry_exit_amano = [df]
                else:
                    entry_exit_amano.append(df)
        else:
            if not file["amano"]:
                if revenue_transactions_regular is None:
                    revenue_transactions_regular = [df]
                else:
                    revenue_transactions_regular.append(df)
            else:
                if revenue_transactions_amano is None:
                    revenue_transactions_amano = [df]
                else:
                    revenue_transactions_amano.append(df)

    return pd.concat(entry_exit_regular), pd.concat(entry_exit_amano), pd.concat(revenue_transactions_regular), pd.concat(revenue_transactions_amano)

entry_exit_regular, entry_exit_amano, revenue_transactions_regular, revenue_transactions_amano = read_csv_files(all_files)

entry_exit_regular.to_csv("entry_exit_regular.csv")
entry_exit_amano.to_csv("entry_exit_amano.csv")
revenue_transactions_regular.to_csv("revenue_transactions_regular.csv")
revenue_transactions_amano.to_csv("revenue_transactions_amano.csv")

