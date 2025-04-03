import pandas as pd

entry_exit_amano = pd.read_csv("entry_exit_amano.csv")
entry_exit_regular = pd.read_csv("entry_exit_regular.csv")

#entry_exit_amano = entry_exit_amano[[""]]
def find_if_entry(row):
    if row["Direction"] == "Entry":
        return True
    elif row["Direction"] == "Exit":
        return False
    elif row["Entry Exit?"] == "Entry":
        return True
    elif row["Entry Exit?"] == "Exit":
        return False
    else:
        return None
    
def find_parking_type(row):
    if row["Type"] == "Monthly":
        return "Monthly"
    elif row["Type"] == "Pulled Ticket":
        return "Transient"
    elif not isinstance(row["TicketType"], float) and ("Short" in row["TicketType"] or "Event" in row["TicketType"]):
        return "Transient"
    elif not isinstance(row["TicketType"], float) and "Long" in row["TicketType"]:
        return "Monthly"
    else:
        return "Unknown"
    

entry_exit_regular["Entry_dummy"] = entry_exit_regular.apply(find_if_entry, axis=1)
entry_exit_regular["parking_type"] = entry_exit_regular.apply(find_parking_type, axis=1)
entry_exit_regular = entry_exit_regular[["Time", "Entry_dummy", "parking_type", "location"]]


def find_if_entry_amano(row):
    if row["Direction"] == "Entry":
        return True
    else:
        return False

entry_exit_amano = entry_exit_amano[["Activity Date", "Payment Type", "Direction", "location"]]
entry_exit_amano["Direction"] = entry_exit_amano.apply(find_if_entry_amano, axis=1)

entry_exit_amano.rename(columns={"Activity Date" : "Time", "Payment Type": "parking_type", "Direction" : "Entry_dummy"}, inplace=True)
entry_exit_amano = entry_exit_amano[["Time", "parking_type", "Entry_dummy", "location"]]
final_ee_data = pd.concat([entry_exit_regular, entry_exit_amano])

def find_correct_location(row):
    return row["location"].split("\\")[-1]

final_ee_data["location"] = final_ee_data.apply(find_correct_location, axis=1)

final_ee_data.to_csv("entry_exit_combined.csv")





