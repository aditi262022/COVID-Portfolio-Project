import pandas as pd

def scrape_currency_data(start_date, end_date):
    try:
        # Construct the URL for downloading the CSV file
        url = "https://covid.ourworldindata.org/data/owid-covid-data.csv"

        # Read the CSV file directly into a DataFrame
        df = pd.read_csv(url)

        # Filter data based on date range
        df['date'] = pd.to_datetime(df['date'])
        df = df[(df['date'] >= start_date) & (df['date'] <= end_date)]

        return df
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

# Define start and end dates
start_date = "2020-02-24"
end_date = "2021-04-30"

# Scrape currency data
currency_data = scrape_currency_data(start_date, end_date)

# Save DataFrame to CSV file
if currency_data is not None:
    currency_data.to_csv("covid_data.csv", index=False)
    print("Data has been successfully saved to Covid_Deaths.csv")
else:
    print("Failed to save data to CSV file.")
