import pandas as pd

revenue_regular = pd.read_csv("revenue_transactions_regular.csv")
revenue_amano = pd.read_csv("revenue_transactions_amano.csv")
revenue_amano.rename(columns={'Exit _x000D_\nDate': "Exit", 'Entry _x000D_\nDate' : "Entry"}, inplace=True)
print(revenue_regular.columns, revenue_amano.columns)