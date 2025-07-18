# ✅ Full Python Script: Enhanced Churn Prediction with Better Features

import pandas as pd
import numpy as np
import mysql.connector
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split

# Step 1: Connect to MySQL
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Sasha123##",
    database="assignment16.2"
)
cursor = conn.cursor()

# Step 2: Load Tables
customers = pd.read_sql("SELECT * FROM customers", conn)
orders = pd.read_sql("SELECT * FROM orders", conn)
returns = pd.read_sql("SELECT * FROM returns", conn)
tickets = pd.read_sql("SELECT * FROM support_tickets", conn)

# Step 3: Feature Engineering
order_counts = orders.groupby("customer_id").size().reset_index(name="order_count")
return_counts = returns.groupby("customer_id").size().reset_index(name="return_count")
ticket_counts = tickets.groupby("customer_id").size().reset_index(name="ticket_count")

# Join all into one table
data = customers[["customer_id", "join_date", "is_active", "region", "segment"]]
data = data.merge(order_counts, on="customer_id", how="left")
data = data.merge(return_counts, on="customer_id", how="left")
data = data.merge(ticket_counts, on="customer_id", how="left")

# Fill missing counts with 0
data.fillna({"order_count": 0, "return_count": 0, "ticket_count": 0}, inplace=True)

# Add recency_days feature
today = pd.to_datetime("2025-07-17")
data["join_date"] = pd.to_datetime(data["join_date"])
data["recency_days"] = (today - data["join_date"]).dt.days

# One-hot encode region & segment
data = pd.get_dummies(data, columns=["region", "segment"], drop_first=True)

# Step 4: Model Training
features = [col for col in data.columns if col not in ["customer_id", "join_date", "is_active"]]
X = data[features]
y = data["is_active"].apply(lambda x: 0 if x == 0 else 1)  # Churn = 0, Active = 1

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, stratify=y, test_size=0.2, random_state=42)
model = LogisticRegression()
model.fit(X_train, y_train)

# Step 5: Predict on all customers
probs = model.predict_proba(X_scaled)[:, 0]  # probability of churn (label 0)
data["churn_probability"] = np.round(probs, 3)

# Step 6: Save Predictions Back to SQL
cursor.execute("DROP TABLE IF EXISTS churn_predictions")
cursor.execute("""
CREATE TABLE churn_predictions (
    customer_id INT PRIMARY KEY,
    churn_probability FLOAT
)
""")

for _, row in data.iterrows():
    cursor.execute("INSERT INTO churn_predictions (customer_id, churn_probability) VALUES (%s, %s)",
                   (int(row.customer_id), float(row.churn_probability)))

conn.commit()
cursor.close()
conn.close()

print("✅ Churn predictions saved to MySQL table 'churn_predictions'")
