import pandas as pd

def process_for_powerbi(input_file):
    print("Processing for Power BI...")
    df = pd.read_csv(input_file)
    df['date'] = pd.to_datetime(df['date'])
    
    # 1. Explode Pollutants (The "Advanced" part)
    # Split "PM2.5,PM10" into a list, then explode into separate rows
    df['pollutant_individual'] = df['prominent_pollutants'].str.split(',')
    df_exploded = df.explode('pollutant_individual')
    df_exploded['pollutant_individual'] = df_exploded['pollutant_individual'].str.strip()
    
    # 2. Time-Based Aggregations
    df_exploded['year'] = df_exploded['date'].dt.year
    df_exploded['month_name'] = df_exploded['date'].dt.month_name()
    df_exploded['day_type'] = df_exploded['date'].dt.dayofweek.apply(lambda x: 'Weekend' if x >= 5 else 'Weekday')
    
    # 3. Pollution Severity levels
    bins = [0, 50, 100, 200, 300, 400, 500]
    labels = ['Good', 'Satisfactory', 'Moderate', 'Poor', 'Very Poor', 'Severe']
    df_exploded['air_quality_status'] = pd.cut(df_exploded['aqi_value'], bins=bins, labels=labels)
    
    # 4. Save final file
    df_exploded.to_csv('dataset\\aqi.csv', index=False)
    print("Processed file ready with exploded pollutants.")

if __name__ == "__main__":
    process_for_powerbi('dataset\\cleaned_aqi.csv')