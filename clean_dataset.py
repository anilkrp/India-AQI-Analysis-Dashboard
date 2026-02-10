import pandas as pd
import numpy as np

def clean_air_quality_data(file_path):
    # Load the dataset
    df = pd.read_csv(file_path)
    
    # Drop Redundant/Empty Columns
    # 'note' is 100% null, 'unit' is a constant string description
    df.drop(columns=['note', 'unit'], inplace=True, errors='ignore')
    
    # Fix Date Formats
    # Data uses DD-MM-YYYY. Converting to standard datetime objects.
    df['date'] = pd.to_datetime(df['date'], errors='coerce')

    # Standardize Categorical Data
    df['state'] = df['state'].str.strip().str.title()
    df['area'] = df['area'].str.strip().str.title()
    
    # Handle Geographic Ambiguity
    # Aurangabad exists in both Bihar and Maharashtra. 
    # Create a unique Location ID to prevent visualization errors.
    df['location_key'] = df['area'] + ", " + df['state']
    
    # Validate AQI Ranges
    # Ensuring AQI is within expected bounds (0-500)
    df = df[(df['aqi_value'] >= 0) & (df['aqi_value'] <= 500)]
    
    # Save the cleaned dataset
    df.to_csv('dataset\\cleaned_aqi.csv', index=False)
    print("Cleaned dataset saved as 'cleaned_aqi.csv'")

if __name__ == "__main__":
    clean_air_quality_data('dataset\\raw_aqi.csv')