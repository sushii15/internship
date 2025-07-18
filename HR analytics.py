import pandas as pd
from sklearn.cluster import KMeans
import mysql.connector
import os

# Step 1: Connect to MySQL
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Sasha123##",
    database="assignment16"
)

# Step 2: Load tables
employees = pd.read_sql("SELECT * FROM employees", conn)
reviews = pd.read_sql("SELECT * FROM performance_reviews", conn)
promotions = pd.read_sql("SELECT * FROM promotions", conn)

# Step 3: Attrition Rate
employees['is_active'] = employees['exit_date'].isnull()
attrition_rate = 1 - employees['is_active'].mean()
print(f"🔻 Attrition Rate: {round(attrition_rate*100, 2)}%")

# Step 4: Promotion Frequency
promo_counts = promotions.groupby('emp_id').size().reset_index(name='promotion_count')
employees = employees.merge(promo_counts, on='emp_id', how='left').fillna({'promotion_count': 0})

today = pd.to_datetime("2025-07-01")
employees['join_date'] = pd.to_datetime(employees['join_date'])
employees['exit_date'] = pd.to_datetime(employees['exit_date'])
employees['end_date'] = employees['exit_date'].fillna(today)
employees['years_worked'] = (employees['end_date'] - employees['join_date']).dt.days / 365.25
employees['promo_per_year'] = employees['promotion_count'] / employees['years_worked']

# Step 5: Review Score
avg_reviews = reviews.groupby('emp_id')['score'].mean().reset_index(name='avg_review_score')
employees = employees.merge(avg_reviews, on='emp_id', how='left')

# Step 6: Clustering (High Potential Tagging)
X = employees[['promo_per_year', 'avg_review_score']].dropna()
kmeans = KMeans(n_clusters=2, random_state=42).fit(X)
employees.loc[X.index, 'potential_tag'] = kmeans.labels_

# Step 7: Export CSV to Desktop
output_path = r"C:\Users\sasha\Downloads\hr_kpis.csv"
employees.to_csv(output_path, index=False)
print("✅ Exported to:", output_path)
print("📁 Full path:", os.path.abspath(output_path))
# Export tables to CSV
